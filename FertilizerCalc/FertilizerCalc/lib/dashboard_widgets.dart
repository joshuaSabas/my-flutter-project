import 'package:flutter/material.dart';
import 'dashboard_logic.dart';
import 'dashboard_helpers.dart';

class DashboardWidgets {
  // ============================================
  // BAGONG BUILD DASHBOARD BODY (WALANG SCAFFOLD)
  // ============================================
  static Widget buildDashboardBody({
    required BuildContext context,
    required DashboardLogic logic,
    required Animation<double> bounceAnimation,
    required Function(int) onDrawerTap,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: buildDrawer(context, logic, onDrawerTap),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(context, logic),
                  const SizedBox(height: 12),
                  buildConnectCard(context, logic),
                  const SizedBox(height: 24),
                  buildLiveSoilParameters(logic),
                  const SizedBox(height: 24),
                  buildRecommendationCard(context, logic),
                  const SizedBox(height: 16),
                  buildSoilStatus(logic),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            buildBluetoothIndicator(logic),
            buildMoistureReminderIcon(context, logic, bounceAnimation),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HEADER - WALANG BABAGUHIN!
  // ============================================
  static Widget buildHeader(BuildContext context, DashboardLogic logic) {
    return Stack(
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
                  colors: [Colors.green.shade300, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.agriculture, size: 60, color: Colors.white),
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
              const SizedBox(height: 20),
              Image.asset(
                "images/text.png",
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    "FertilizerCalc",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "Smart Soil Analysis &\nFertilizer Recommendation",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // DRAWER
  // ============================================
  static Widget buildDrawer(BuildContext context, DashboardLogic logic, Function(int) onDrawerTap) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.agriculture, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "FertilizerCalc",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "v1.0.0",
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bluetooth,
                          size: 14,
                          color: logic.isConnected ? Colors.greenAccent : Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          logic.isConnected ? "Sensor Connected" : "No Sensor",
                          style: TextStyle(
                            fontSize: 11,
                            color: logic.isConnected ? Colors.greenAccent : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.directions, color: Colors.green),
              title: const Text(
                "Directions",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () => onDrawerTap(0),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.eco, size: 16, color: Colors.green.shade300),
                  const SizedBox(width: 8),
                  const Text(
                    "Smart Soil Analysis",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CONNECT CARD
  // ============================================
  static Widget buildConnectCard(BuildContext context, DashboardLogic logic) {
    return Padding(
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
                  return const Icon(Icons.sensors, size: 30, color: Colors.green);
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
                    logic.isConnected
                        ? "Connected to ${logic.deviceName}"
                        : "Connect your device via Bluetooth\nto start monitoring your soil.",
                    style: TextStyle(
                      fontSize: 11,
                      color: logic.isConnected ? Colors.green : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  if (logic.isScanning) ...[
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                        ),
                        SizedBox(width: 6),
                        Text('Scanning...', style: TextStyle(fontSize: 10, color: Colors.blue)),
                      ],
                    ),
                  ],
                  if (logic.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      logic.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (logic.isConnected)
              TextButton(
                onPressed: logic.disconnect,
                child: const Text("Disconnect", style: TextStyle(color: Colors.red, fontSize: 12)),
              )
            else
              ElevatedButton.icon(
                onPressed: logic.isLoading || logic.isScanning ? null : logic.connectToDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                icon: logic.isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.bluetooth, size: 16),
                label: logic.isLoading
                    ? const SizedBox.shrink()
                    : const Text("Connect", style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // LIVE SOIL PARAMETERS - BAGONG DESIGN!
  // ============================================
  static Widget buildLiveSoilParameters(DashboardLogic logic) {
    return Padding(
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
              if (logic.currentReading == null)
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
              buildGaugeCard(
                title: "Soil Nitrogen",
                subtitle: "(N)",
                value: logic.currentReading?.nitrogen ?? "--",
                unit: "mg/kg",
                color: Colors.green,
                icon: Icons.eco,
                maxValue: 100,
                status: logic.currentReading != null
                    ? DashboardHelpers.getStatusName(
                        DashboardHelpers.getStatusN(int.tryParse(logic.currentReading!.nitrogen) ?? 0), '')
                    : '--',
                statusColor: logic.currentReading != null
                    ? DashboardHelpers.getStatusColor(
                        DashboardHelpers.getStatusN(int.tryParse(logic.currentReading!.nitrogen) ?? 0), '')
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              buildGaugeCard(
                title: "Soil Phosphorus",
                subtitle: "(P)",
                value: logic.currentReading?.phosphorus ?? "--",
                unit: "mg/kg",
                color: Colors.orange,
                icon: Icons.circle,
                maxValue: 100,
                status: logic.currentReading != null
                    ? DashboardHelpers.getStatusName(
                        DashboardHelpers.getStatusP(int.tryParse(logic.currentReading!.phosphorus) ?? 0), '')
                    : '--',
                statusColor: logic.currentReading != null
                    ? DashboardHelpers.getStatusColor(
                        DashboardHelpers.getStatusP(int.tryParse(logic.currentReading!.phosphorus) ?? 0), '')
                    : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              buildGaugeCard(
                title: "Soil Potassium",
                subtitle: "(K)",
                value: logic.currentReading?.potassium ?? "--",
                unit: "mg/kg",
                color: Colors.blue,
                icon: Icons.water_drop_outlined,
                maxValue: 100,
                status: logic.currentReading != null
                    ? DashboardHelpers.getStatusName(
                        DashboardHelpers.getStatusK(int.tryParse(logic.currentReading!.potassium) ?? 0), '')
                    : '--',
                statusColor: logic.currentReading != null
                    ? DashboardHelpers.getStatusColor(
                        DashboardHelpers.getStatusK(int.tryParse(logic.currentReading!.potassium) ?? 0), '')
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              buildGaugeCard(
                title: "Soil pH Level",
                subtitle: "(pH)",
                value: logic.currentReading?.ph ?? "--",
                unit: "pH",
                color: Colors.purple,
                icon: Icons.science_outlined,
                maxValue: 14,
                status: logic.currentReading != null
                    ? DashboardHelpers.getStatusName(
                        DashboardHelpers.getStatusPh(double.tryParse(logic.currentReading!.ph) ?? 0.0), 'ph')
                    : '--',
                statusColor: logic.currentReading != null
                    ? DashboardHelpers.getStatusColor(
                        DashboardHelpers.getStatusPh(double.tryParse(logic.currentReading!.ph) ?? 0.0), 'ph')
                    : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // GAUGE CARD
  // ============================================
  static Widget buildGaugeCard({
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
    required double maxValue,
    required String status,
    required Color statusColor,
  }) {
    double numVal = double.tryParse(value) ?? 0;
    double progress = (numVal / maxValue).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      unit,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status == 'Optimal' || status == 'Neutral'
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    size: 12,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // RECOMMENDATION CARD
  // ============================================
  static Widget buildRecommendationCard(BuildContext context, DashboardLogic logic) {
    return Padding(
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
                return const Icon(Icons.eco, size: 44, color: Colors.green);
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
                    logic.isConnected && logic.currentReading != null
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
                      onPressed: (logic.isConnected && logic.currentReading != null)
                          ? logic.getRecommendation
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.shade300,
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: logic.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Get Recommendation", style: TextStyle(fontSize: 13)),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_ios, size: 13),
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
                return const Icon(Icons.science, size: 36, color: Colors.blue);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SOIL STATUS
  // ============================================
  static Widget buildSoilStatus(DashboardLogic logic) {
    if (!logic.isConnected || logic.currentReading == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
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
                buildStatusChip("N", logic.currentReading!.nitrogen, DashboardHelpers.getStatusN),
                const SizedBox(width: 6),
                buildStatusChip("P", logic.currentReading!.phosphorus, DashboardHelpers.getStatusP),
                const SizedBox(width: 6),
                buildStatusChip("K", logic.currentReading!.potassium, DashboardHelpers.getStatusK),
                const SizedBox(width: 6),
                buildStatusChip("pH", logic.currentReading!.ph, null, isPh: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // STATUS CHIP
  // ============================================
  static Widget buildStatusChip(String label, String value, Function(int)? statusFunc, {bool isPh = false}) {
    if (value == '--') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text("$label: --", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      );
    }

    int numVal = int.tryParse(value) ?? 0;
    double phVal = double.tryParse(value) ?? 0.0;

    int statusCode = isPh
        ? DashboardHelpers.getStatusPh(phVal)
        : (statusFunc != null ? statusFunc(numVal) : 0);

    String statusName = DashboardHelpers.getStatusName(statusCode, isPh ? 'ph' : '');
    Color statusColor = DashboardHelpers.getStatusColor(statusCode, isPh ? 'ph' : '');

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
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
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

  // ============================================
  // BLUETOOTH INDICATOR
  // ============================================
  static Widget buildBluetoothIndicator(DashboardLogic logic) {
    return Positioned(
      top: 12,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              color: logic.isConnected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              logic.isConnected ? "Connected" : "Disconnected",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: logic.isConnected ? Colors.blue : Colors.black54,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: logic.isConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // MOISTURE REMINDER
  // ============================================
  static Widget buildMoistureReminderIcon(
    BuildContext context,
    DashboardLogic logic,
    Animation<double> bounceAnimation,
  ) {
    return Positioned(
      bottom: 24,
      right: 20,
      child: GestureDetector(
        onTap: logic.showMoistureReminderDialog,
        child: AnimatedBuilder(
          animation: bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -bounceAnimation.value * 12),
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
                child: const Icon(Icons.water_drop, color: Colors.white, size: 30),
              ),
            );
          },
        ),
      ),
    );
  }
}
