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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DATE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF2E7D32), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.reading.timestamp.toLocal().toString().substring(0, 19),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SOIL PARAMETERS
            const Text(
              "SOIL PARAMETERS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildParamCard("N", "Nitrogen", widget.reading.nitrogen, "mg/kg", Colors.green),
                const SizedBox(width: 10),
                _buildParamCard("P", "Phosphorus", widget.reading.phosphorus, "mg/kg", Colors.orange),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildParamCard("K", "Potassium", widget.reading.potassium, "mg/kg", Colors.blue),
                const SizedBox(width: 10),
                _buildParamCard("pH", "pH Level", widget.reading.ph, "pH", Colors.purple),
              ],
            ),

            const SizedBox(height: 24),

            // RECOMMENDED FERTILIZER
            const Text(
              "RECOMMENDED FERTILIZER",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: googleSearch.isNotEmpty ? () => _launchUrl(googleSearch) : null,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF43A047), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
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
                                  size: 30,
                                  color: Color(0xFF43A047),
                                ),
                              ),
                            )
                          : const Icon(Icons.shopping_bag, size: 30, color: Color(0xFF43A047)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fertilizer,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          if (googleSearch.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: const [
                                Icon(Icons.search, size: 14, color: Color(0xFF43A047)),
                                SizedBox(width: 4),
                                Text(
                                  "Click Here to see more",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF43A047),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (googleSearch.isNotEmpty)
                      const Icon(Icons.chevron_right, size: 20, color: Color(0xFF43A047)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ALTERNATIVE
            const Text(
              "ALTERNATIVE FERTILIZER",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFB8C00), width: 1.5),
              ),
              child: Text(
                alternative,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AMOUNT
            const Text(
              "RECOMMENDED AMOUNT",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E88E5), width: 1.5),
              ),
              child: Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),

            // APPLICATION DETAILS
            if (applicationRate.isNotEmpty ||
                modeOfApplication.isNotEmpty ||
                applicationTiming.isNotEmpty) ...[
              const SizedBox(height: 16),
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
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildAppDetail(
                      "Application Rate",
                      applicationRate,
                      Icons.speed,
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
                // THUMBS UP
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
                      color: _feedback == true ? Colors.white : const Color(0xFF43A047),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                // THUMBS DOWN
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
                      color: _feedback == false ? Colors.white : const Color(0xFFFB8C00),
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

  // HELPER: Application detail row (vertical, centered)
  Widget _buildAppDetail(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildParamCard(String label, String name, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
