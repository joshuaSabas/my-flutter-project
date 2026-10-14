import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  // I-SAVE ANG LAST CONNECTED DEVICE PARA SA AUTO-RECONNECT
  BluetoothDevice? _lastConnectedDevice;

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
      return await isBluetoothEnabled();
    } catch (e) {
      print('Error requesting Bluetooth: $e');
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

      // I-SAVE ANG DEVICE PARA SA AUTO-RECONNECT
      if (_connection?.isConnected ?? false) {
        _lastConnectedDevice = device;
      }

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
  // AUTO-RECONNECT SA LAST CONNECTED DEVICE
  // ============================================
  Future<bool> autoReconnect() async {
    if (_lastConnectedDevice == null) {
      print('⚠️ No last connected device to reconnect');
      return false;
    }

    try {
      print('🔄 Attempting to reconnect to ${_lastConnectedDevice!.name}...');
      _connection = await BluetoothConnection.toAddress(
        _lastConnectedDevice!.address,
      );
      return _connection?.isConnected ?? false;
    } catch (e) {
      print('❌ Auto-reconnect failed: $e');
      return false;
    }
  }

  // ============================================
  // GET LAST CONNECTED DEVICE NAME
  // ============================================
  String? get connectedDeviceName => _lastConnectedDevice?.name;

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
      // HUWAG I-CLEAR ANG _lastConnectedDevice PARA PWEDE PA RIN MAG-AUTO-RECONNECT
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // ============================================
  // CLEAR LAST DEVICE (manual disconnect)
  // ============================================
  void clearLastDevice() {
    _lastConnectedDevice = null;
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
        _connection!.output.add(Uint8List.fromList(data.codeUnits));
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
        _connection!.output.add(Uint8List.fromList(bytes));
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
