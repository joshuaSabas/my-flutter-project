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
  // START LISTENING FOR DATA
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
  // DISCONNECT
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
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.water_drop, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              const Text("💧 Moisture Reminder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🌱 Keep soil moist, but not waterlogged.", style: TextStyle(fontSize: 15)),
              SizedBox(height: 8),
              Text("⏰ Water early morning or late afternoon.", style: TextStyle(fontSize: 14, color: Colors.black54)),
              SizedBox(height: 4),
              Text("💧 This helps prevent evaporation and root rot.", style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
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

  // ============================================
  // SHOW RECOMMENDATION DIALOG
  // ============================================
  void showRecommendationDialog(Map<String, dynamic> result) {
    // ... (existing recommendation dialog code)
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
