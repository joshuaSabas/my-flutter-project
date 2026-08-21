import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  // FIXED: bool? → bool gamit ang ?? false
  Future<bool> isBluetoothEnabled() async {
    try {
      final result = await _bluetooth.isEnabled;
      return result ?? false; // ← KUNG NULL, RETURN FALSE
    } catch (e) {
      return false;
    }
  }

  // FIXED: bool? → bool gamit ang ?? false
  Future<bool> requestEnableBluetooth() async {
    try {
      final result = await _bluetooth.requestEnable();
      return result ?? false; // ← KUNG NULL, RETURN FALSE
    } catch (e) {
      return false;
    }
  }

  Future<List<BluetoothDiscoveryResult>> scanDevices() async {
    List<BluetoothDiscoveryResult> devices = [];
    try {
      await for (final result in _bluetooth.startDiscovery()) {
        devices.add(result);
      }
    } catch (e) {
      print('Scan error: $e');
    }
    return devices;
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get isConnected => _connection?.isConnected ?? false;

  void disconnect() {
    _connection?.dispose();
    _connection = null;
  }

  BluetoothConnection? get connection => _connection;
}
