import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth/bluetooth_service.dart';
import 'bluetooth/bluetooth_dialog.dart';
import 'bluetooth/bluetooth_permission.dart';
import 'models/sensor_reading.dart';
import 'services/recommendation_service.dart';
import 'database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'directions_screen.dart';
import 'dashboard_helpers.dart';

class DashboardLogic extends ChangeNotifier with WidgetsBindingObserver {
  final BuildContext context;

  DashboardLogic({required this.context});

  // ============================================
  // STATE VARIABLES
  // ============================================
  late BluetoothService _bluetoothService;
  SensorReading? _currentReading;
  bool _isConnected = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _deviceName = '';
  bool _isScanning = false;
  Map<String, dynamic>? _recommendationResult;
  bool _isAppInBackground = false;

  AnimationController? _bounceController;
  Animation<double>? _bounceAnimation;

  // ============================================
  // GETTERS
  // ============================================
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String get errorMessage => _errorMessage;
  String get deviceName => _deviceName;
  SensorReading? get currentReading => _currentReading;
  Map<String, dynamic>? get recommendationResult => _recommendationResult;

  // ============================================
  // INIT STATE
  // ============================================
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _bluetoothService = BluetoothService();
    _checkBluetoothStatus();
    _restoreState();
  }

  void setBounceController(AnimationController controller, Animation<double> animation) {
    _bounceController = controller;
    _bounceAnimation = animation;
    notifyListeners();
  }

  // ============================================
  // APP LIFE CYCLE
  // ============================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('📱 App Lifecycle State: $state');

    if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      _restoreState();
    } else if (state == AppLifecycleState.paused) {
      _isAppInBackground = true;
      _saveState();
    }
  }

  // ============================================
  // STATE PRESERVATION
  // ============================================
  Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isConnected = prefs.getBool('dashboard_isConnected') ?? false;
      final deviceName = prefs.getString('dashboard_deviceName') ?? '';
      final isScanning = prefs.getBool('dashboard_isScanning') ?? false;

      _isConnected = isConnected;
      _deviceName = deviceName;
      _isScanning = isScanning;
      notifyListeners();

      if (_isConnected && _deviceName.isNotEmpty) {
        _startListeningForData();
      }
    } catch (e) {
      print('❌ Error restoring state: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dashboard_isConnected', _isConnected);
      await prefs.setString('dashboard_deviceName', _deviceName);
      await prefs.setBool('dashboard_isScanning', _isScanning);
    } catch (e) {
      print('❌ Error saving state: $e');
    }
  }

  Future<void> _clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('dashboard_isConnected');
      await prefs.remove('dashboard_deviceName');
      await prefs.remove('dashboard_isScanning');
    } catch (e) {
      print('❌ Error clearing state: $e');
    }
  }

  // ============================================
  // DRAWER NAVIGATION
  // ============================================
  void onDrawerTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DirectionsScreen()),
      );
    }
  }

  // ============================================
  // BLUETOOTH FUNCTIONS
  // ============================================
  Future<void> _checkBluetoothStatus() async {
    try {
      final isEnabled = await _bluetoothService.isBluetoothEnabled();
      _isConnected = _bluetoothService.isConnected;
      if (!isEnabled) {
        _errorMessage = 'Bluetooth is disabled. Please enable Bluetooth.';
      }
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
        final enabled = await _bluetoothService.requestEnableBluetooth();
        if (!enabled) {
          _errorMessage = 'Bluetooth must be enabled to connect';
          _isLoading = false;
          notifyListeners();
          _showBluetoothDisabledDialog();
          return;
        }
      }

      final hasPermissions = await BluetoothPermissions.requestPermissions();
      if (!hasPermissions) {
        _errorMessage = 'Bluetooth permissions are required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isScanning = true;
      notifyListeners();
      await _saveState();

      final devices = await _bluetoothService.scanDevices();

      _isScanning = false;
      notifyListeners();
      await _saveState();

      if (devices.isEmpty) {
        _errorMessage = 'No Bluetooth devices found';
        _isLoading = false;
        notifyListeners();
        await _saveState();
        return;
      }

      final selectedDevice = await BluetoothDialog.show(
        context: context,
        devices: devices,
      );

      if (selectedDevice == null) {
        _isLoading = false;
        notifyListeners();
        await _saveState();
        return;
      }

      final connected = await _bluetoothService.connect(selectedDevice);
      if (connected) {
        _isConnected = true;
        _deviceName = selectedDevice.name ?? 'Soil Sensor';
        _isLoading = false;
        notifyListeners();
        await _saveState();
        _startListeningForData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${selectedDevice.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _errorMessage = 'Failed to connect to ${selectedDevice.name}';
        _isLoading = false;
        notifyListeners();
        await _saveState();
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      _isScanning = false;
      notifyListeners();
      await _saveState();
    }
  }

  // ============================================
  // START LISTENING FOR DATA - WALANG POPUP!
  // ============================================
  void _startListeningForData() {
    final connection = _bluetoothService.connection;
    if (connection == null) {
      _errorMessage = 'Connection error. Please reconnect.';
      notifyListeners();
      return;
    }

    connection.input?.listen(
      (data) {
        final String rawString = String.fromCharCodes(data);
        print('📊 RAW: "$rawString"');

        if (rawString.contains("NO_DATA")) {
          _errorMessage = 'Waiting for sensor data...';
          _currentReading = null;
          notifyListeners();
          return;
        }

        final reading = _parseSensorData(data);
        if (reading != null) {
          _currentReading = reading;
          _errorMessage = '';
          notifyListeners();
          _saveToHistory(reading);
          // 👇 WALANG POPUP DITO!
        } else {
          _errorMessage = 'Failed to parse sensor data. Check format.';
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Error reading data: $error';
        notifyListeners();
      },
      onDone: () {
        _isConnected = false;
        _deviceName = '';
        notifyListeners();
        _clearState();
      },
    );
  }

  // ============================================
  // PARSE SENSOR DATA
  // ============================================
  SensorReading? _parseSensorData(List<int> data) {
    try {
      final String message = String.fromCharCodes(data).trim();
      if (message.isEmpty) return null;

      if (message.contains("NO_DATA")) {
        _errorMessage = 'Waiting for sensor data...';
        _currentReading = null;
        notifyListeners();
        return null;
      }

      String nitrogen = '--';
      String phosphorus = '--';
      String potassium = '--';
      String ph = '--';

      if (message.contains('N:') || message.contains('P:') || message.contains('K:') || message.contains('pH:')) {
        final parts = message.split(',');
        for (String part in parts) {
          part = part.trim();
          if (part.startsWith('N:')) nitrogen = part.substring(2).trim();
          else if (part.startsWith('P:')) phosphorus = part.substring(2).trim();
          else if (part.startsWith('K:')) potassium = part.substring(2).trim();
          else if (part.toLowerCase().startsWith('ph:')) ph = part.substring(3).trim();
        }
      } else if (message.contains(',') && !message.contains(':')) {
        final parts = message.split(',');
        if (parts.length >= 4) {
          nitrogen = parts[0].trim();
          phosphorus = parts[1].trim();
          potassium = parts[2].trim();
          ph = parts[3].trim();
        }
      } else if (message.contains('N') && message.contains('P') && message.contains('K')) {
        final RegExp nRegExp = RegExp(r'N(\d+\.?\d*)');
        final RegExp pRegExp = RegExp(r'P(\d+\.?\d*)');
        final RegExp kRegExp = RegExp(r'K(\d+\.?\d*)');
        final RegExp phRegExp = RegExp(r'pH(\d+\.?\d*)');
        final nMatch = nRegExp.firstMatch(message);
        final pMatch = pRegExp.firstMatch(message);
        final kMatch = kRegExp.firstMatch(message);
        final phMatch = phRegExp.firstMatch(message);
        if (nMatch != null) nitrogen = nMatch.group(1) ?? '--';
        if (pMatch != null) phosphorus = pMatch.group(1) ?? '--';
        if (kMatch != null) potassium = kMatch.group(1) ?? '--';
        if (phMatch != null) ph = phMatch.group(1) ?? '--';
      } else {
        _errorMessage = 'Unknown data format: "$message"';
        notifyListeners();
        return null;
      }

      if (nitrogen != '--' || phosphorus != '--' || potassium != '--' || ph != '--') {
        return SensorReading(
          nitrogen: nitrogen,
          phosphorus: phosphorus,
          potassium: potassium,
          ph: ph,
          timestamp: DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToHistory(SensorReading reading) async {
    try {
      final db = DatabaseHelper();
      await db.insertRecommendation(reading);
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  // ============================================
  // DISCONNECT - KUMpleto na!
  // ============================================
  Future<void> disconnect() async {
    try {
      _bluetoothService.disconnect();
      _isConnected = false;
      _deviceName = '';
      _currentReading = null;
      _recommendationResult = null;
      notifyListeners();
      await _clearState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from sensor'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disconnect error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================
  // BLUETOOTH DISABLED DIALOG
  // ============================================
  void _showBluetoothDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Bluetooth Required",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bluetooth is not enabled on your device.", style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text("Please turn on Bluetooth first.", style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await connectToDevice();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Try Again"),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // MOISTURE REMINDER
  // ============================================
  void showMoistureReminderDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade100,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Color(0xFF2E7D32),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Color(0xFF42A5F5),
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Moisture Reminder",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ITEM 1
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF43A047),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Keep soil moist, but not waterlogged.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ITEM 2
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF1E88E5),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Water early morning or late afternoon.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ITEM 3
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Color(0xFF42A5F5),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "This helps prevent evaporation and root rot.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Got it",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
  // ============================================
  // GOOGLE SEARCH
  // ============================================
  Future<void> launchGoogleSearch(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open Google Search'), backgroundColor: Colors.red),
      );
    }
  }

  // ============================================
  // GET RECOMMENDATION
  // ============================================
  Future<void> getRecommendation() async {
    if (_currentReading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sensor data available.'), backgroundColor: Colors.orange),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final recommendationService = RecommendationService();
      await recommendationService.loadRules();

      int n = int.tryParse(_currentReading!.nitrogen) ?? 0;
      int p = int.tryParse(_currentReading!.phosphorus) ?? 0;
      int k = int.tryParse(_currentReading!.potassium) ?? 0;
      double ph = double.tryParse(_currentReading!.ph) ?? 0.0;

      int statusN = DashboardHelpers.getStatusN(n);
      int statusP = DashboardHelpers.getStatusP(p);
      int statusK = DashboardHelpers.getStatusK(k);
      int statusPh = DashboardHelpers.getStatusPh(ph);

      final result = recommendationService.getRecommendation(
        n: n, p: p, k: k, ph: ph,
        statusN: statusN, statusP: statusP, statusK: statusK, statusPh: statusPh,
      );

      _recommendationResult = result;
      _isLoading = false;
      notifyListeners();

      showRecommendationDialog(result);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

 void showRecommendationDialog(Map<String, dynamic> result) {
  final String fertilizer = result['fertilizer'] ?? 'Unknown';
  final String imageUrl = result['image'] ?? '';
  final String googleSearch = result['google_search'] ?? '';
  final String alternative = result['alternative'] ?? 'N/A';
  final String amount = result['amount'] ?? 'N/A';
  final String applicationRate = result['application_rate'] ?? '';
  final String modeOfApplication = result['mode_of_application'] ?? '';
  final String applicationTiming = result['application_timing'] ?? '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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
              // ============================================
              // HEADER
              // ============================================
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
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fertilizer Recommendation",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Based on your soil and crop needs",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // SCROLLABLE CONTENT
              // ============================================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============================================
                      // RECOMMENDED FERTILIZER
                      // ============================================
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF43A047), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF43A047),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "RECOMMENDED FERTILIZER",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag,
                                      size: 40,
                                      color: const Color(0xFF43A047),
                                    ),
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
                                        GestureDetector(
                                          onTap: () {
                                            if (googleSearch.isNotEmpty) {
                                              launchGoogleSearch(googleSearch);
                                            }
                                          },
                                          child: Row(
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF43A047).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Color(0xFF43A047),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ============================================
                      // ALTERNATIVE FERTILIZER
                      // ============================================
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFB8C00), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFB8C00),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "ALTERNATIVE FERTILIZER",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      size: 40,
                                      color: Color(0xFFFB8C00),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alternative,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: () {
                                            if (alternative != 'N/A' && alternative.isNotEmpty) {
                                              final altSearch =
                                                  'https://www.google.com/search?q=${Uri.encodeComponent(alternative + " fertilizer")}&tbm=isch';
                                              launchGoogleSearch(altSearch);
                                            }
                                          },
                                          child: Row(
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFB8C00).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Color(0xFFFB8C00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ============================================
                      // RECOMMENDED AMOUNT
                      // ============================================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.scale,
                                color: Colors.white,
                                size: 24,
                              ),
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
                                      fontSize: 22,
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

                      // ============================================
                      // APPLICATION DETAILS (3 columns)
                      // ============================================
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // RATE
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.speed,
                                    color: const Color(0xFF2E7D32),
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Application Rate",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    applicationRate.isNotEmpty ? applicationRate : 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 80,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),

                            // MODE
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    color: Color(0xFF1565C0),
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Mode of Application",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    modeOfApplication.isNotEmpty ? modeOfApplication : 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 80,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),

                            // TIMING
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    color: Color(0xFF6A1B9A),
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Application Timing",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    applicationTiming.isNotEmpty ? applicationTiming : 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ============================================
              // BOTTOM BUTTONS
              // ============================================
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // SAVE BUTTON
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_currentReading != null && _recommendationResult != null) {
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
                            _saveToHistory(reading);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to history!'),
                              backgroundColor: Colors.green,
                            ),
                          );
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // GOT IT BUTTON
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildNpkBar(String label, String value, Color color) {
    double val = double.tryParse(value) ?? 0;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (val / 100).clamp(0.0, 1.0) * 35,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNpkChip(String label, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          Text(subtitle,
              style: const TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildParamChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ============================================
  // DISPOSE
  // ============================================
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bluetoothService.disconnect();
    super.dispose();
  }
}
