import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bluetooth/bluetooth_dialog.dart';
import 'bluetooth/bluetooth_permission.dart';
import 'bluetooth/bluetooth_service.dart';
import 'database/database_helper.dart';
import 'directions_screen.dart';
import 'models/sensor_reading.dart';
import 'services/recommendation_service.dart';
import 'dashboard_helpers.dart';

class DashboardLogic extends ChangeNotifier with WidgetsBindingObserver {
  final BuildContext context;
  DashboardLogic({required this.context});

  late BluetoothService _bluetoothService;
  SensorReading? _currentReading;
  bool _isConnected = false;
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isListening = false;
  String _errorMessage = '';
  String _deviceName = '';
  Map<String, dynamic>? _recommendationResult;
  StreamSubscription<List<int>>? _sensorSubscription;

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String get errorMessage => _errorMessage;
  String get deviceName => _deviceName;
  SensorReading? get currentReading => _currentReading;
  Map<String, dynamic>? get recommendationResult => _recommendationResult;

  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _bluetoothService = BluetoothService();
    _checkBluetoothStatus();
    _restoreState();
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

  void onDrawerTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectionsScreen()));
    }
  }

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
      if (!await _bluetoothService.isBluetoothEnabled() && !await _bluetoothService.requestEnableBluetooth()) {
        _errorMessage = 'Bluetooth must be enabled to connect';
        return;
      }
      if (!await BluetoothPermissions.requestPermissions()) {
        _errorMessage = 'Bluetooth permissions are required';
        return;
      }
      _isScanning = true;
      notifyListeners();
      final devices = await _bluetoothService.scanDevices();
      _isScanning = false;
      if (devices.isEmpty) {
        _errorMessage = 'No Bluetooth devices found';
        return;
      }
      final selected = await BluetoothDialog.show(context: context, devices: devices);
      if (selected == null) return;
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

  void _startListeningForData() {
    if (_isListening || _bluetoothService.connection?.input == null) return;
    _isListening = true;
    _sensorSubscription = _bluetoothService.connection!.input!.listen((data) {
      final reading = _parseSensorData(data);
      if (reading != null) {
        _currentReading = reading;
        _errorMessage = '';
        _saveToHistory(reading);
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
      n = parts[0].trim(); p = parts[1].trim(); k = parts[2].trim(); ph = parts[3].trim();
    }
    if (n == '--' && p == '--' && k == '--' && ph == '--') return null;
    return SensorReading(nitrogen: n, phosphorus: p, potassium: k, ph: ph, timestamp: DateTime.now());
  }

  Future<void> _saveToHistory(SensorReading reading) async {
    try { await DatabaseHelper().insertRecommendation(reading); } catch (e) { debugPrint('Error saving history: $e'); }
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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> getRecommendation() async {
    if (_currentReading == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final service = RecommendationService();
      await service.loadRules();
      final n = int.tryParse(_currentReading!.nitrogen) ?? 0;
      final p = int.tryParse(_currentReading!.phosphorus) ?? 0;
      final k = int.tryParse(_currentReading!.potassium) ?? 0;
      final ph = double.tryParse(_currentReading!.ph) ?? 0;
      _recommendationResult = service.getRecommendation(
        n: n, p: p, k: k, ph: ph,
        statusN: DashboardHelpers.getStatusN(n), statusP: DashboardHelpers.getStatusP(p),
        statusK: DashboardHelpers.getStatusK(k), statusPh: DashboardHelpers.getStatusPh(ph),
      );
      await _saveState();
      showRecommendationDialog(_recommendationResult!);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showRecommendationDialog(Map<String, dynamic> result) {
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Fertilizer Recommendation'),
      content: Text(result['fertilizer']?.toString() ?? 'Unknown'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('OK'))],
    ));
  }

  void showMoistureReminderDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(children: [Icon(Icons.water_drop, color: Colors.blue), SizedBox(width: 10), Text('Moisture Reminder')]),
        content: const Text('Keep the soil moist, but not waterlogged.\n\nWater early morning or late afternoon.'),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK'))],
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
