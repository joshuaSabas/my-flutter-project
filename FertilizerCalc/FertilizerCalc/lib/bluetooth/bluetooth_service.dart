import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import 'package:flutter/services.dart';

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  // ============================================
  // CHECK IF BLUETOOTH IS ENABLED
  // ============================================
  Future<bool> isBluetoothEnabled() async {
    try {
      final result = await _bluetooth.isEnabled;
      return result ?? false;
    } on PlatformException catch (e) {
      print('PlatformException: $e');
      return false;
    } catch (e) {
      print('Error checking Bluetooth: $e');
      return false;
    }
  }

  // ============================================
  // REQUEST TO ENABLE BLUETOOTH
  // ============================================
  Future<bool> requestEnableBluetooth() async {
    try {
      final result = await _bluetooth.requestEnable();
      return result ?? false;
    } on PlatformException catch (e) {
      print('PlatformException: $e');
      return false;
    } catch (e) {
      print('Error enabling Bluetooth: $e');
      return false;
    }
  }

  // ============================================
  // SCAN FOR BLUETOOTH DEVICES
  // ============================================
  Future<List<BluetoothDiscoveryResult>> scanDevices() async {
    List<BluetoothDiscoveryResult> devices = [];
    try {
      await for (final result in _bluetooth.startDiscovery()) {
        bool exists = devices.any(
          (e) => e.device.address == result.device.address,
        );
        if (!exists) {
          devices.add(result);
        }
      }
    } on PlatformException catch (e) {
      print('PlatformException during scan: $e');
      return [];
    } catch (e) {
      print('Error scanning devices: $e');
      return [];
    }
    return devices;
  }

  // ============================================
  // CONNECT TO A BLUETOOTH DEVICE
  // ============================================
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      return _connection?.isConnected ?? false;
    } on PlatformException catch (e) {
      print('PlatformException during connect: $e');
      return false;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  // ============================================
  // CHECK IF CONNECTED
  // ============================================
  bool get isConnected {
    if (_connection == null) return false;
    return _connection!.isConnected;
  }

  // ============================================
  // DISCONNECT FROM DEVICE
  // ============================================
  void disconnect() {
    try {
      _connection?.dispose();
      _connection = null;
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // ============================================
  // GET CURRENT CONNECTION
  // ============================================
  BluetoothConnection? get connection => _connection;

  // ============================================
  // SEND DATA TO DEVICE
  // ============================================
  void sendData(String data) {
    try {
      if (_connection != null && _connection!.isConnected) {
        _connection!.output.add(data.codeUnits);
        _connection!.output.allSent;
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  // ============================================
  // SEND BYTES TO DEVICE
  // ============================================
  void sendBytes(List<int> bytes) {
    try {
      if (_connection != null && _connection!.isConnected) {
        _connection!.output.add(bytes);
        _connection!.output.allSent;
      }
    } catch (e) {
      print('Error sending bytes: $e');
    }
  }

  // ============================================
  // GET PAIRED DEVICES
  // ============================================
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  // ============================================
  // CHECK IF DEVICE IS PAIRED
  // ============================================
  Future<bool> isDevicePaired(String address) async {
    try {
      final devices = await getPairedDevices();
      return devices.any((device) => device.address == address);
    } catch (e) {
      print('Error checking if device is paired: $e');
      return false;
    }
  }
}
