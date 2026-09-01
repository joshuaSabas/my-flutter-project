import 'package:flutter/material.dart';
import 'bluetooth/bluetooth_service.dart';
import 'bluetooth/bluetooth_dialog.dart';
import 'bluetooth/bluetooth_permission.dart';
import 'models/sensor_reading.dart';
import 'services/recommendation_service.dart';
import 'database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  @override
  bool get wantKeepAlive => true;

  late BluetoothService _bluetoothService;
  SensorReading? _currentReading;
  bool _isConnected = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _deviceName = '';
  bool _isScanning = false;
  Map<String, dynamic>? _recommendationResult;

  // ✅ BOUNCE ANIMATION
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bluetoothService = BluetoothService();
    _checkBluetoothStatus();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverse: true,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 0.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _bluetoothService.disconnect();
    super.dispose();
  }

  // ============================================
  // MOISTURE REMINDER FLOATING ICON (BILOG AT GUMAGALAW)
  // ============================================
  Widget _buildMoistureReminderIcon() {
    return Positioned(
      bottom: 24,
      right: 20,
      child: GestureDetector(
        onTap: () {
          _showMoistureReminderDialog();
        },
        child: Transform.translate(
          offset: Offset(0, -_bounceAnimation.value * 12),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.water_drop,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // MOISTURE REMINDER DIALOG
  // ============================================
  void _showMoistureReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "💧 Moisture Reminder",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🌱 Keep soil moist, but not waterlogged.",
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 8),
              Text(
                "⏰ Water early morning or late afternoon.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 4),
              Text(
                "💧 This helps prevent evaporation and root rot.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Got it",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // GOOGLE SEARCH
  // ============================================
  Future<void> _launchGoogleSearch(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open Google Search'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================
  // BLUETOOTH FUNCTIONS
  // ============================================
  Future<void> _checkBluetoothStatus() async {
    try {
      final isEnabled = await _bluetoothService.isBluetoothEnabled();
      setState(() {
        _isConnected = _bluetoothService.isConnected;
      });
      if (!isEnabled) {
        setState(() {
          _errorMessage = 'Bluetooth is disabled. Please enable Bluetooth.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking Bluetooth status: $e';
      });
    }
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final isEnabled = await _bluetoothService.isBluetoothEnabled();
      if (!isEnabled) {
        final enabled = await _bluetoothService.requestEnableBluetooth();
        if (!enabled) {
          setState(() {
            _errorMessage = 'Bluetooth must be enabled to connect';
            _isLoading = false;
          });
          _showBluetoothDisabledDialog();
          return;
        }
      }

      final hasPermissions = await BluetoothPermissions.requestPermissions();
      if (!hasPermissions) {
        setState(() {
          _errorMessage = 'Bluetooth permissions are required';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isScanning = true;
      });

      final devices = await _bluetoothService.scanDevices();

      setState(() {
        _isScanning = false;
      });

      if (devices.isEmpty) {
        setState(() {
          _errorMessage = 'No Bluetooth devices found';
          _isLoading = false;
        });
        return;
      }

      final selectedDevice = await BluetoothDialog.show(
        context: context,
        devices: devices,
      );

      if (selectedDevice == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final connected = await _bluetoothService.connect(selectedDevice);
      if (connected) {
        setState(() {
          _isConnected = true;
          _deviceName = selectedDevice.name ?? 'Soil Sensor';
          _isLoading = false;
        });
        _startListeningForData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${selectedDevice.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to ${selectedDevice.name}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
        _isScanning = false;
      });
    }
  }

  void _startListeningForData() {
    final connection = _bluetoothService.connection;
    if (connection == null) return;

    connection.input?.listen(
      (data) {
        final reading = _parseSensorData(data);
        if (reading != null) {
          setState(() {
            _currentReading = reading;
          });
          _saveToHistory(reading);
        }
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Error reading data: $error';
        });
      },
      onDone: () {
        setState(() {
          _isConnected = false;
          _deviceName = '';
        });
      },
    );
  }

  SensorReading? _parseSensorData(List<int> data) {
    try {
      final String message = String.fromCharCodes(data).trim();
      if (message.isEmpty) return null;

      final parts = message.split(',');
      String nitrogen = '--';
      String phosphorus = '--';
      String potassium = '--';
      String ph = '--';

      for (String part in parts) {
        if (part.startsWith('N:')) nitrogen = part.substring(2);
        if (part.startsWith('P:')) phosphorus = part.substring(2);
        if (part.startsWith('K:')) potassium = part.substring(2);
        if (part.startsWith('pH:')) ph = part.substring(3);
      }

      return SensorReading(
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        ph: ph,
        timestamp: DateTime.now(),
      );
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

  Future<void> _disconnect() async {
    try {
      _bluetoothService.disconnect();
      setState(() {
        _isConnected = false;
        _deviceName = '';
        _currentReading = null;
        _recommendationResult = null;
      });
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
              Text(
                "Bluetooth is not enabled on your device.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                "Please turn on Bluetooth first to connect to the soil sensor.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
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
                await _connectToDevice();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text("Try Again"),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // STATUS FUNCTIONS
  // ============================================
  int _getStatusN(int n) {
    if (n < 30) return 0;
    if (n <= 60) return 2;
    return 1;
  }

  int _getStatusP(int p) {
    if (p < 18) return 0;
    if (p <= 40) return 2;
    return 1;
  }

  int _getStatusK(int k) {
    if (k < 40) return 0;
    if (k <= 75) return 2;
    return 1;
  }

  int _getStatusPh(double ph) {
    if (ph < 5.5) return 0;
    if (ph <= 7.0) return 2;
    return 1;
  }

  String _getStatusName(int code, String type) {
    if (type == 'ph') {
      switch (code) {
        case 0: return 'Acidic';
        case 1: return 'Alkaline';
        case 2: return 'Neutral';
        default: return 'Unknown';
      }
    } else {
      switch (code) {
        case 0: return 'Deficient';
        case 1: return 'Excess';
        case 2: return 'Optimal';
        default: return 'Unknown';
      }
    }
  }

  Color _getStatusColor(int code, String type) {
    if (type == 'ph') {
      switch (code) {
        case 0: return Colors.orange;
        case 1: return Colors.red;
        case 2: return Colors.green;
        default: return Colors.grey;
      }
    } else {
      switch (code) {
        case 0: return Colors.orange;
        case 1: return Colors.red;
        case 2: return Colors.green;
        default: return Colors.grey;
      }
    }
  }

  // ============================================
  // RECOMMENDATION
  // ============================================
  Future<void> _getRecommendation() async {
    if (_currentReading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sensor data available.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recommendationService = RecommendationService();
      await recommendationService.loadRules();

      int n = int.tryParse(_currentReading!.nitrogen) ?? 0;
      int p = int.tryParse(_currentReading!.phosphorus) ?? 0;
      int k = int.tryParse(_currentReading!.potassium) ?? 0;
      double ph = double.tryParse(_currentReading!.ph) ?? 0.0;

      int statusN = _getStatusN(n);
      int statusP = _getStatusP(p);
      int statusK = _getStatusK(k);
      int statusPh = _getStatusPh(ph);

      final result = recommendationService.getRecommendation(
        n: n,
        p: p,
        k: k,
        ph: ph,
        statusN: statusN,
        statusP: statusP,
        statusK: statusK,
        statusPh: statusPh,
      );

      setState(() {
        _recommendationResult = result;
        _isLoading = false;
      });

      _showRecommendationDialog(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRecommendationDialog(Map<String, dynamic> result) {
    final String fertilizer = result['fertilizer'] ?? 'Unknown';
    final String imageUrl = result['image'] ?? '';
    final String googleSearch = result['google_search'] ?? '';
    final String alternative = result['alternative'] ?? 'N/A';
    final String amount = result['amount'] ?? 'N/A';
    final int sacks = result['sacks'] ?? 0;
    final String npk = result['npk'] ?? '--';
    final String applicationRate = result['application_rate'] ?? '';
    final String modeOfApplication = result['mode_of_application'] ?? '';
    final String applicationTiming = result['application_timing'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.eco, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                "Recommendation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (googleSearch.isNotEmpty) {
                      _launchGoogleSearch(googleSearch);
                    }
                  },
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.agriculture,
                              size: 40,
                              color: Colors.green.shade400,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    "Tap to search",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    if (googleSearch.isNotEmpty) {
                      _launchGoogleSearch(googleSearch);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            fertilizer,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Icon(Icons.search, size: 18, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "NPK ANALYSIS",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        npk.isNotEmpty ? npk : '--',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildNpkBar('N', _currentReading?.nitrogen ?? '--', Colors.green),
                          const SizedBox(width: 4),
                          _buildNpkBar('P', _currentReading?.phosphorus ?? '--', Colors.orange),
                          const SizedBox(width: 4),
                          _buildNpkBar('K', _currentReading?.potassium ?? '--', Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNpkChip('🌿 N', 'Leaf Growth', Colors.green),
                          _buildNpkChip('🌱 P', 'Root Growth', Colors.orange),
                          _buildNpkChip('🍎 K', 'Plant Health', Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "APPLICATION DETAILS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (applicationRate.isNotEmpty)
                        Text("Rate: $applicationRate",
                            style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      if (modeOfApplication.isNotEmpty)
                        Text("Mode: $modeOfApplication",
                            style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      if (applicationTiming.isNotEmpty)
                        Text("Timing: $applicationTiming",
                            style: const TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "QUANTITY",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "$sacks SAKO",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              amount,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildParamChip("N", _currentReading?.nitrogen ?? '--'),
                      _buildParamChip("P", _currentReading?.phosphorus ?? '--'),
                      _buildParamChip("K", _currentReading?.potassium ?? '--'),
                      _buildParamChip("pH", _currentReading?.ph ?? '--'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            ElevatedButton.icon(
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
                    recommendedSacks: sacks,
                    npkAnalysis: npk,
                  );
                  _saveToHistory(reading);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              icon: const Icon(Icons.save, size: 18),
              label: const Text("Save"),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN SCROLLABLE CONTENT
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Stack(
                    children: [
                      Image.asset(
                        "images/background.png",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade300,
                                  Colors.green.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.agriculture,
                                  size: 60, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.45),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              "images/text.png",
                              height: 48,
                              errorBuilder: (context, error, stackTrace) {
                                return RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Fertilizer",
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Calc",
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF76FF03),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Smart Soil Analysis &\nFertilizer Recommendation",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // CONNECT CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.green.shade50,
                            child: Image.asset(
                              "images/sensor_device.png",
                              width: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.sensors,
                                    size: 30, color: Colors.green);
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Connect to Soil Sensor",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isConnected
                                      ? "Connected to $_deviceName"
                                      : "Connect your device via Bluetooth\nto start monitoring your soil.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _isConnected
                                        ? Colors.green
                                        : Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                                if (_isScanning) ...[
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text('Scanning...',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue)),
                                    ],
                                  ),
                                ],
                                if (_errorMessage.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isConnected)
                            TextButton(
                              onPressed: _disconnect,
                              child: const Text("Disconnect",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12)),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: _isLoading || _isScanning
                                  ? null
                                  : _connectToDevice,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.bluetooth, size: 16),
                              label: _isLoading
                                  ? const SizedBox.shrink()
                                  : const Text("Connect",
                                      style: TextStyle(fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LIVE SOIL PARAMETERS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Live Soil Parameters",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (_currentReading == null)
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "No Data",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildParameterCard(
                              title: "N",
                              subtitle: "Nitrogen",
                              value: _currentReading?.nitrogen ?? "--",
                              unit: "mg/kg",
                              color: Colors.green,
                              icon: Icons.eco,
                            ),
                            const SizedBox(width: 8),
                            _buildParameterCard(
                              title: "P",
                              subtitle: "Phosphorus",
                              value: _currentReading?.phosphorus ?? "--",
                              unit: "mg/kg",
                              color: Colors.orange,
                              icon: Icons.circle,
                            ),
                            const SizedBox(width: 8),
                            _buildParameterCard(
                              title: "K",
                              subtitle: "Potassium",
                              value: _currentReading?.potassium ?? "--",
                              unit: "mg/kg",
                              color: Colors.blue,
                              icon: Icons.water_drop_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildParameterCard(
                              title: "pH",
                              subtitle: "pH Level",
                              value: _currentReading?.ph ?? "--",
                              unit: "pH",
                              color: Colors.purple,
                              icon: Icons.science_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FERTILIZER RECOMMENDATION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "images/leaf.png",
                            width: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.eco,
                                  size: 44, color: Colors.green);
                            },
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Fertilizer Recommendation",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isConnected && _currentReading != null
                                      ? "Get personalized fertilizer recommendation based on real-time soil data."
                                      : "Connect to your soil sensor and get personalized fertilizer recommendation based on real-time soil data.",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: (_isConnected &&
                                            _currentReading != null)
                                        ? _getRecommendation
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.green.shade300,
                                      disabledForegroundColor: Colors.white70,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Get Recommendation",
                                                style:
                                                    TextStyle(fontSize: 13),
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 13,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            "images/fertilizer.png",
                            width: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.science,
                                  size: 36, color: Colors.blue);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SOIL STATUS
                  if (_isConnected && _currentReading != null) ...[
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Soil Status",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatusChip("N",
                                    _currentReading!.nitrogen, _getStatusN),
                                const SizedBox(width: 6),
                                _buildStatusChip("P",
                                    _currentReading!.phosphorus, _getStatusP),
                                const SizedBox(width: 6),
                                _buildStatusChip("K",
                                    _currentReading!.potassium, _getStatusK),
                                const SizedBox(width: 6),
                                _buildStatusChip(
                                    "pH", _currentReading!.ph, null,
                                    isPh: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // BLUETOOTH STATUS
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bluetooth,
                      size: 14,
                      color: _isConnected ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isConnected ? "Connected" : "Disconnected",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isConnected ? Colors.blue : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color:
                            _isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ MOISTURE REMINDER FLOATING ICON (BILOG AT GUMAGALAW)
            _buildMoistureReminderIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard({
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    double numVal = double.tryParse(value) ?? 0;
    double progress = (numVal / 100).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 16, color: color.withOpacity(0.5)),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (unit.isNotEmpty)
              Text(unit,
                  style:
                      const TextStyle(fontSize: 8, color: Colors.grey)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value == '--' ? 0 : progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                    value == '--'
                        ? color.withOpacity(0.2)
                        : color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value,
      Function(int)? statusFunc,
      {bool isPh = false}) {
    if (value == '--') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text("$label: --",
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      );
    }

    int numVal = int.tryParse(value) ?? 0;
    double phVal = double.tryParse(value) ?? 0.0;

    int statusCode = isPh
        ? _getStatusPh(phVal)
        : (statusFunc != null ? statusFunc(numVal) : 0);

    String statusName = _getStatusName(statusCode, isPh ? 'ph' : '');
    Color statusColor = _getStatusColor(statusCode, isPh ? 'ph' : '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "$label: $statusName",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
