import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/sensor_reading.dart';
import 'database/database_helper.dart';

class HistoryDetailScreen extends StatefulWidget {
  final SensorReading reading;
  final VoidCallback? onFeedback;

  const HistoryDetailScreen({
    Key? key,
    required this.reading,
    this.onFeedback,
  }) : super(key: key);

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late bool? _feedback;

  @override
  void initState() {
    super.initState();
    _feedback = widget.reading.feedback;
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('❌ Could not launch: $url');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> _updateFeedback(bool isThumbsUp) async {
    if (widget.reading.id == null) return;
    try {
      final db = DatabaseHelper();
      await db.updateFeedback(widget.reading.id!, isThumbsUp);
      setState(() {
        _feedback = isThumbsUp;
      });
      widget.onFeedback?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isThumbsUp ? '👍 Thanks for your feedback!' : '👎 Feedback recorded.',
            ),
            backgroundColor: isThumbsUp ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating feedback: $e');
    }
  }

  String _getNitrogenStatus(String value) {
    final v = double.tryParse(value) ?? 0;
    if (v < 30) return 'Deficient';
    if (v <= 60) return 'Optimal';
    return 'Excess';
  }

  String _getPhosphorusStatus(String value) {
    final v = double.tryParse(value) ?? 0;
    if (v < 20) return 'Deficient';
    if (v <= 40) return 'Optimal';
    return 'Excess';
  }

  String _getPotassiumStatus(String value) {
    final v = double.tryParse(value) ?? 0;
    if (v < 50) return 'Deficient';
    if (v <= 80) return 'Optimal';
    return 'Excess';
  }

  String _getPhStatus(String value) {
    final v = double.tryParse(value) ?? 7;
    if (v < 5.5) return 'Strongly Acidic';
    if (v < 6.5) return 'Slightly Acidic';
    if (v <= 7.5) return 'Neutral';
    if (v <= 8.5) return 'Slightly Alkaline';
    return 'Alkaline';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Deficient':
        return const Color(0xFFE65100);
      case 'Optimal':
      case 'Neutral':
        return const Color(0xFF2E7D32);
      case 'Excess':
      case 'Strongly Acidic':
      case 'Alkaline':
        return const Color(0xFFC62828);
      case 'Slightly Acidic':
      case 'Slightly Alkaline':
        return const Color(0xFFF57C00);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fertilizer = widget.reading.fertilizerType ?? 'Unknown';
    final imageUrl = widget.reading.fertilizerImageUrl ?? '';
    final alternative = widget.reading.alternativeType ?? 'N/A';
    final amount = widget.reading.amount ?? 'N/A';
    final googleSearch = widget.reading.googleSearchUrl ?? '';
    final applicationRate = widget.reading.applicationRate ?? '';
    final modeOfApplication = widget.reading.modeOfApplication ?? '';
    final applicationTiming = widget.reading.applicationTiming ?? '';
    final plotSize = widget.reading.plotSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Test Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOIL PARAMETERS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco,
                            color: Color(0xFF2E7D32), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Soil Parameters",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          Text(
                            "Current soil nutrient levels",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSoilParamRow(
                    label: "N",
                    name: "Soil Nitrogen",
                    value: widget.reading.nitrogen,
                    unit: "mg/kg",
                    maxValue: 100,
                    color: Colors.green,
                    status: _getNitrogenStatus(widget.reading.nitrogen),
                  ),
                  const SizedBox(height: 10),
                  _buildSoilParamRow(
                    label: "P",
                    name: "Soil Phosphorus",
                    value: widget.reading.phosphorus,
                    unit: "mg/kg",
                    maxValue: 100,
                    color: Colors.orange,
                    status: _getPhosphorusStatus(widget.reading.phosphorus),
                  ),
                  const SizedBox(height: 10),
                  _buildSoilParamRow(
                    label: "K",
                    name: "Soil Potassium",
                    value: widget.reading.potassium,
                    unit: "mg/kg",
                    maxValue: 100,
                    color: Colors.blue,
                    status: _getPotassiumStatus(widget.reading.potassium),
                  ),
                  const SizedBox(height: 10),
                  _buildSoilParamRow(
                    label: "pH",
                    name: "Soil pH Level",
                    value: widget.reading.ph,
                    unit: "pH",
                    maxValue: 14,
                    color: Colors.purple,
                    status: _getPhStatus(widget.reading.ph),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // RECOMMENDED FERTILIZER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco,
                            color: Color(0xFF2E7D32), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Recommended Fertilizer",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: googleSearch.isNotEmpty
                        ? () => _launchUrl(googleSearch)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.shopping_bag,
                                        size: 28,
                                        color: Color(0xFF43A047),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.shopping_bag,
                                    size: 28, color: Color(0xFF43A047)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fertilizer,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Recommended for Pechay",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          if (googleSearch.isNotEmpty)
                            const Icon(Icons.chevron_right,
                                size: 22, color: Color(0xFF43A047)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ALTERNATIVE FERTILIZER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sync_alt,
                            color: Color(0xFFE65100), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Alternative Fertilizer",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag,
                              size: 28, color: Color(0xFFFB8C00)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alternative,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Alternative option",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // RECOMMENDED AMOUNT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F2FD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.scale,
                            color: Color(0xFF1565C0), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Recommended Amount",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plotSize != null
                              ? "(For ${plotSize.toStringAsFixed(0)} sqm)"
                              : "(Fertilizer + Dolomitic Lime)",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PLOT SIZE (kung may na-select lang)
            if (plotSize != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.square_foot,
                          color: Color(0xFF2E7D32), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Plot Size: ${plotSize.toStringAsFixed(0)} sqm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // APPLICATION DETAILS
            if (applicationRate.isNotEmpty ||
                modeOfApplication.isNotEmpty ||
                applicationTiming.isNotEmpty) ...[
              const Text(
                "APPLICATION DETAILS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildAppDetail(
                      "Application Rate",
                      applicationRate,
                      Icons.scale,
                      const Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    _buildAppDetail(
                      "Mode of Application",
                      modeOfApplication,
                      Icons.water_drop,
                      const Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    _buildAppDetail(
                      "Application Timing",
                      applicationTiming,
                      Icons.calendar_month,
                      const Color(0xFF6A1B9A),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // FEEDBACK
            const Text(
              "WAS THIS RECOMMENDATION HELPFUL?",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _updateFeedback(true),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _feedback == true
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.thumb_up,
                      color: _feedback == true
                          ? Colors.white
                          : const Color(0xFF43A047),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () => _updateFeedback(false),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _feedback == false
                          ? const Color(0xFFE53935)
                          : const Color(0xFFFFF3E0),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.thumb_down,
                      color: _feedback == false
                          ? Colors.white
                          : const Color(0xFFFB8C00),
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilParamRow({
    required String label,
    required String name,
    required String value,
    required String unit,
    required double maxValue,
    required Color color,
    required String status,
  }) {
    final numVal = double.tryParse(value) ?? 0;
    final progress = (numVal / maxValue).clamp(0.0, 1.0);
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$value $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDetail(
      String label, String value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
