import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bluetooth/bluetooth_dialog.dart';
import 'bluetooth/bluetooth_permission.dart';
import 'bluetooth/bluetooth_service.dart';
import 'database/database_helper.dart';
import 'directions_screen.dart';
import 'models/sensor_reading.dart';
import 'random_forest_service.dart';
import 'dashboard_helpers.dart';

class DashboardLogic extends ChangeNotifier with WidgetsBindingObserver {
  final BuildContext context;
  DashboardLogic({required this.context});

  late BluetoothService _bluetoothService;
  final RandomForestService _rfService = RandomForestService();
  SensorReading? _currentReading;
  bool _isConnected = false;
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isListening = false;
  bool _rfLoaded = false;
  String _errorMessage = '';
  String _deviceName = '';
  Map<String, dynamic>? _recommendationResult;
  StreamSubscription<List<int>>? _sensorSubscription;

  // CALLBACK para i-refresh ang History screen pag na-save
  VoidCallback? onHistorySaved;

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String get errorMessage => _errorMessage;
  String get deviceName => _deviceName;
  SensorReading? get currentReading => _currentReading;
  Map<String, dynamic>? get recommendationResult => _recommendationResult;
  bool get rfLoaded => _rfLoaded;

  // ============================================
  // INIT STATE
  // ============================================
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _bluetoothService = BluetoothService();
    _checkBluetoothStatus();
    _restoreState();
    _loadRandomForest();
  }

  Future<void> _loadRandomForest() async {
    await _rfService.loadModel();
    _rfLoaded = _rfService.isLoaded;
    notifyListeners();
  }

  void setBounceController(AnimationController controller, Animation<double> animation) {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreState();
    } else if (state == AppLifecycleState.paused) {
      _saveState();
    }
  }

  // ============================================
  // STATE PRESERVATION
  // ============================================
  Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reading = prefs.getString('dashboard_last_reading');
      final recommendation = prefs.getString('dashboard_last_recommendation');
      if (reading != null && reading.isNotEmpty) {
        final decoded = jsonDecode(reading);
        if (decoded is Map<String, dynamic>) _currentReading = SensorReading.fromMap(decoded);
      }
      if (recommendation != null && recommendation.isNotEmpty) {
        final decoded = jsonDecode(recommendation);
        if (decoded is Map<String, dynamic>) _recommendationResult = decoded;
      }
      _isConnected = prefs.getBool('dashboard_isConnected') ?? false;
      _deviceName = prefs.getString('dashboard_deviceName') ?? '';
      _isScanning = prefs.getBool('dashboard_isScanning') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error restoring state: $e');
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboard_isConnected', _isConnected);
    await prefs.setString('dashboard_deviceName', _deviceName);
    await prefs.setBool('dashboard_isScanning', _isScanning);
    await prefs.setString('dashboard_last_reading', _currentReading == null ? '' : jsonEncode(_currentReading!.toMap()));
    await prefs.setString('dashboard_last_recommendation', _recommendationResult == null ? '' : jsonEncode(_recommendationResult!));
  }

  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dashboard_isConnected');
    await prefs.remove('dashboard_deviceName');
    await prefs.remove('dashboard_isScanning');
    await prefs.remove('dashboard_last_reading');
    await prefs.remove('dashboard_last_recommendation');
  }

  // ============================================
  // DRAWER
  // ============================================
  void onDrawerTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectionsScreen()));
    }
  }

  // ============================================
  // BLUETOOTH
  // ============================================
  Future<void> _checkBluetoothStatus() async {
    try {
      final enabled = await _bluetoothService.isBluetoothEnabled();
      _isConnected = _bluetoothService.isConnected;
      if (!enabled) _errorMessage = 'Bluetooth is disabled. Please enable Bluetooth.';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error checking Bluetooth status: $e';
      notifyListeners();
    }
  }

  Future<void> connectToDevice() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final isEnabled = await _bluetoothService.isBluetoothEnabled();

      if (!isEnabled) {
        _errorMessage = 'Bluetooth is disabled. Please enable Bluetooth.';
        _isLoading = false;
        notifyListeners();
        _showBluetoothDisabledDialog();
        return;
      }

      if (!await BluetoothPermissions.requestPermissions()) {
        _errorMessage = 'Bluetooth permissions are required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isScanning = true;
      notifyListeners();

      final devices = await _bluetoothService.scanDevices();

      _isScanning = false;

      if (devices.isEmpty) {
        _errorMessage = 'No Bluetooth devices found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final selected = await BluetoothDialog.show(
        context: context,
        devices: devices,
      );

      if (selected == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (await _bluetoothService.connect(selected)) {
        _isConnected = true;
        _deviceName = selected.name ?? 'Soil Sensor';
        _startListeningForData();
      } else {
        _errorMessage = 'Failed to connect to ${selected.name}';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      _isScanning = false;
      notifyListeners();
      await _saveState();
    }
  }

  void _showBluetoothDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.bluetooth_disabled, color: Colors.red),
              SizedBox(width: 10),
              Text('Bluetooth Required'),
            ],
          ),
          content: const Text(
            'Bluetooth is not enabled on your device.\n\nPlease turn on Bluetooth first to connect to the soil sensor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                connectToDevice();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // SENSOR DATA
  // ============================================
  void _startListeningForData() {
    if (_isListening || _bluetoothService.connection?.input == null) return;
    _isListening = true;
    _sensorSubscription = _bluetoothService.connection!.input!.listen((data) {
      final reading = _parseSensorData(data);
      if (reading != null) {
        _currentReading = reading;
        _errorMessage = '';
        // WALANG AUTO-SAVE DITO. Manual na pag-save sa recommendation dialog.
        _saveState();
        notifyListeners();
      }
    }, onError: (error) {
      _isListening = false;
      _errorMessage = 'Error reading data: $error';
      notifyListeners();
    }, onDone: () {
      _isListening = false;
      _isConnected = false;
      _deviceName = '';
      notifyListeners();
    });
  }

  SensorReading? _parseSensorData(List<int> data) {
    final message = String.fromCharCodes(data).trim();
    if (message.isEmpty || message.contains('NO_DATA')) return null;

    var n = '--', p = '--', k = '--', ph = '--';

    if (message.contains(':')) {
      for (final raw in message.split(',')) {
        final part = raw.trim();
        if (part.startsWith('N:')) n = part.substring(2).trim();
        if (part.startsWith('P:')) p = part.substring(2).trim();
        if (part.startsWith('K:')) k = part.substring(2).trim();
        if (part.toLowerCase().startsWith('ph:')) ph = part.substring(3).trim();
      }
    } else {
      final parts = message.split(',');
      if (parts.length < 4) return null;
      n = parts[0].trim();
      p = parts[1].trim();
      k = parts[2].trim();
      ph = parts[3].trim();
    }

    final nVal = double.tryParse(n) ?? -1;
    final pVal = double.tryParse(p) ?? -1;
    final kVal = double.tryParse(k) ?? -1;
    final phVal = double.tryParse(ph) ?? -1;

    if (nVal < 0 || nVal > 2000) return null;
    if (pVal < 0 || pVal > 2000) return null;
    if (kVal < 0 || kVal > 2000) return null;
    if (phVal < 0 || phVal > 14) return null;

    return SensorReading(
      nitrogen: n,
      phosphorus: p,
      potassium: k,
      ph: ph,
      timestamp: DateTime.now(),
    );
  }

  Future<void> disconnect() async {
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _isListening = false;
    _bluetoothService.disconnect();
    _isConnected = false;
    _deviceName = '';
    _currentReading = null;
    _recommendationResult = null;
    await _clearState();
    notifyListeners();
  }

  Future<void> launchGoogleSearch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // ============================================
  // GET RECOMMENDATION — RANDOM FOREST
  // ============================================
  Future<void> getRecommendation() async {
    if (_currentReading == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final n = double.tryParse(_currentReading!.nitrogen) ?? 0;
      final p = double.tryParse(_currentReading!.phosphorus) ?? 0;
      final k = double.tryParse(_currentReading!.potassium) ?? 0;
      final ph = double.tryParse(_currentReading!.ph) ?? 0;

      final fertilizerType = _rfService.predict(n: n, p: p, k: k, ph: ph);
      debugPrint('🌲 Random Forest Prediction: "$fertilizerType"');

      final rules = await _loadFertilizerRules();

      final normalizedPrediction = fertilizerType.trim().toLowerCase();

      Map<String, dynamic>? rule;
      try {
        rule = rules.firstWhere(
          (r) => (r['fertilizer'] ?? '').toString().trim().toLowerCase() == normalizedPrediction,
        );
        debugPrint('✅ Exact match found: ${rule['fertilizer']}');
      } catch (e) {
        rule = null;
      }

      if (rule == null) {
        debugPrint('⚠️ No exact match. Finding closest match...');
        for (final r in rules) {
          final ruleName = (r['fertilizer'] ?? '').toString().trim().toLowerCase();
          if (ruleName.contains(normalizedPrediction) ||
              normalizedPrediction.contains(ruleName)) {
            rule = r;
            debugPrint('✅ Found closest match: ${r['fertilizer']}');
            break;
          }
        }
      }

      if (rule == null) {
        debugPrint('⚠️ No match found. Using fallback: ${rules.first['fertilizer']}');
        rule = rules.first;
      }

      _recommendationResult = {
        'fertilizer': rule['fertilizer'] ?? fertilizerType,
        'image': rule['image'] ?? '',
        'google_search': rule['google_search'] ?? '',
        'alternative': rule['alternative'] ?? 'N/A',
        'amount': rule['amount'] ?? 'N/A',
        'application_rate': rule['application_rate'] ?? '',
        'mode_of_application': rule['mode_of_application'] ?? '',
        'application_timing': rule['application_timing'] ?? '',
      };

      await _saveState();
      if (context.mounted) {
        showRecommendationDialog(_recommendationResult!);
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('❌ Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _loadFertilizerRules() async {
    final jsonString = await rootBundle.loadString('assets/fertilizer_rules.json');
    final List<dynamic> data = json.decode(jsonString);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ============================================
  // RECOMMENDATION DIALOG
  // ============================================
  void showRecommendationDialog(Map<String, dynamic> result) {
    final fertilizer = result['fertilizer'] ?? 'Unknown';
    final imageUrl = result['image'] ?? '';
    final googleSearch = result['google_search'] ?? '';
    final alternative = result['alternative'] ?? 'N/A';
    final amount = result['amount'] ?? 'N/A';
    final applicationRate = result['application_rate'] ?? '';
    final modeOfApplication = result['mode_of_application'] ?? '';
    final applicationTiming = result['application_timing'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "Fertilizer Recommendation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),

                // SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RECOMMENDED FERTILIZER
                        const Text(
                          "RECOMMENDED FERTILIZER",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (googleSearch.isNotEmpty) {
                              launchGoogleSearch(googleSearch);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF43A047), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.shopping_bag, size: 35, color: Color(0xFF43A047));
                                            },
                                          ),
                                        )
                                      : const Icon(Icons.shopping_bag, size: 35, color: Color(0xFF43A047)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fertilizer,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B5E20),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.search, size: 14, color: Color(0xFF43A047)),
                                          const SizedBox(width: 4),
                                          const Text(
                                            "Click Here to see more",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF43A047),
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF43A047)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ALTERNATIVE FERTILIZER
                        const Text(
                          "ALTERNATIVE FERTILIZER",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (alternative != 'N/A' && alternative.isNotEmpty) {
                              final altSearch =
                                  'https://www.google.com/search?q=${Uri.encodeComponent(alternative + " fertilizer")}&tbm=isch';
                              launchGoogleSearch(altSearch);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFB8C00), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.shopping_bag, size: 35, color: Color(0xFFFB8C00)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alternative,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE65100),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.search, size: 14, color: Color(0xFFFB8C00)),
                                          const SizedBox(width: 4),
                                          const Text(
                                            "Click Here to see more",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFB8C00),
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFB8C00)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // RECOMMENDED AMOUNT
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.scale, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "RECOMMENDED AMOUNT",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      amount,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // APPLICATION DETAILS — VERTICAL & CENTERED
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // APPLICATION RATE
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.speed,
                                      color: Color(0xFF2E7D32),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Application Rate",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    applicationRate.isNotEmpty ? applicationRate : 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B5E20),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Divider(height: 1, color: Colors.grey.shade300),
                              const SizedBox(height: 16),

                              // MODE OF APPLICATION
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1565C0).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: Color(0xFF1565C0),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Mode of Application",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1565C0),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    modeOfApplication.isNotEmpty ? modeOfApplication : 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B5E20),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Divider(height: 1, color: Colors.grey.shade300),
                              const SizedBox(height: 16),

                              // APPLICATION TIMING
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6A1B9A).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month,
                                      color: Color(0xFF6A1B9A),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Application Timing",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    applicationTiming.isNotEmpty ? applicationTiming : 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B5E20),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // BOTTOM BUTTONS
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      // SAVE IN HISTORY BUTTON
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (_currentReading == null || _recommendationResult == null) {
                              return;
                            }
                            try {
                              final reading = SensorReading(
                                nitrogen: _currentReading!.nitrogen,
                                phosphorus: _currentReading!.phosphorus,
                                potassium: _currentReading!.potassium,
                                ph: _currentReading!.ph,
                                timestamp: DateTime.now(),
                                fertilizerType: fertilizer,
                                fertilizerImageUrl: imageUrl,
                                alternativeType: alternative,
                                recommendedSacks: 0,
                                amount: amount,
                                npkAnalysis: '',
                              );
                              await DatabaseHelper().insertRecommendation(reading);

                              // I-refresh ang History screen
                              onHistorySaved?.call();

                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Saved to history!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Error saving to history: $e');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.bookmark_border, size: 20),
                          label: const Text(
                            "Save in History",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // GOT IT BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 4,
                            shadowColor: Colors.green.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text(
                            "Got it",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMoistureReminderDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.blue),
            SizedBox(width: 10),
            Text('Moisture Reminder'),
          ],
        ),
        content: const Text(
          'Keep the soil moist, but not waterlogged.\n\nWater early morning or late afternoon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sensorSubscription?.cancel();
    if (_bluetoothService.isConnected) _bluetoothService.disconnect();
    super.dispose();
  }
}
