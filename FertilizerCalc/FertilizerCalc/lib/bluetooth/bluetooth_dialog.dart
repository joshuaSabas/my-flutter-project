import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';

class BluetoothDialog {
  static Future<BluetoothDevice?> show({
    required BuildContext context,
    required List<BluetoothDiscoveryResult> devices,
  }) async {
    if (devices.isEmpty) {
      return showDialog<BluetoothDevice>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("No Devices Found"),
            content: const Text(
              "No Bluetooth devices found. Please make sure your device is discoverable and try again.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }

    return showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bluetooth, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Select Bluetooth Device",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Info bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${devices.length} device${devices.length > 1 ? 's' : ''} found',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index].device;
                      final deviceName = device.name ?? "Unknown Device";
                      final isSoilSensor = deviceName.contains('Soil Sensor');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSoilSensor ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSoilSensor ? Colors.green : Colors.grey.shade300,
                            width: isSoilSensor ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSoilSensor
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bluetooth,
                              color: isSoilSensor ? Colors.green : Colors.blue,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            deviceName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSoilSensor ? FontWeight.bold : FontWeight.w500,
                              color: isSoilSensor ? Colors.green.shade800 : Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              device.address,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          trailing: isSoilSensor
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Recommended',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                          onTap: () => Navigator.pop(context, device),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show scanning dialog
  static Future<void> showScanningDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          title: Text("Scanning for Devices"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Please wait while we scan for Bluetooth devices...",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Error",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context,
    String deviceName,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Connected Successfully!",
            style: TextStyle(color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 10),
              Text(
                "Connected to $deviceName",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
