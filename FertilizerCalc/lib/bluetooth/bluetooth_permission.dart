import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BluetoothPermissions {
  static Future<bool> requestPermissions() async {
    try {
      // Request all required permissions
      final permissions = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      // Check if all permissions are granted
      final allGranted = permissions.values.every(
        (permission) => permission.isGranted,
      );

      if (!allGranted) {
        // Check if any permission is permanently denied
        final isPermanentlyDenied = permissions.values.any(
          (permission) => permission.isPermanentlyDenied,
        );

        if (isPermanentlyDenied) {
          // User has permanently denied permissions
          // We can show a dialog to guide them to settings
          return false;
        }
      }

      return allGranted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Check if all permissions are granted without requesting
  static Future<bool> checkPermissions() async {
    try {
      final bluetoothStatus = await Permission.bluetooth.status;
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      final locationStatus = await Permission.location.status;

      return bluetoothStatus.isGranted &&
          bluetoothScanStatus.isGranted &&
          bluetoothConnectStatus.isGranted &&
          locationStatus.isGranted;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  // Show permission denied dialog
  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permissions Required"),
          content: const Text(
            "Bluetooth and location permissions are required to connect to the soil sensor. "
            "Please grant all permissions in the app settings.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  // Show permission explanation before requesting
  static Future<bool> requestPermissionsWithExplanation(
    BuildContext context,
  ) async {
    // First check if permissions are already granted
    final hasPermissions = await checkPermissions();
    if (hasPermissions) {
      return true;
    }

    // Show explanation dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bluetooth Access Needed"),
          content: const Text(
            "FertilizerCalc needs Bluetooth and location permissions to:\n\n"
            "• Scan for your soil sensor device\n"
            "• Connect to the sensor via Bluetooth\n"
            "• Receive real-time soil data",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Not Now"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Allow"),
            ),
          ],
        );
      },
    );

    if (shouldRequest == true) {
      return await requestPermissions();
    }

    return false;
  }

  // Get permission status as string
  static String getPermissionStatusString(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  // Check individual permission statuses
  static Future<Map<String, PermissionStatus>> getPermissionStatuses() async {
    return {
      'bluetooth': await Permission.bluetooth.status,
      'bluetoothScan': await Permission.bluetoothScan.status,
      'bluetoothConnect': await Permission.bluetoothConnect.status,
      'location': await Permission.location.status,
    };
  }
}
