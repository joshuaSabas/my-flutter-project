import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/sensor_reading.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<SensorReading> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseHelper();
      final data = await db.getAllRecommendations();
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHistory(int id) async {
    try {
      final db = DatabaseHelper();
      await db.deleteRecommendation(id);
      _loadHistory();
    } catch (e) {
      print('Error deleting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Row(
              children: [
                const Text(
                  "History",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF43A047)),
                  onPressed: _loadHistory,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF43A047)),
                  )
                : _history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 60,
              color: Color(0xFF43A047),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No History Records",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Connect to your soil sensor and get\nyour first recommendation!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF43A047),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recommendation #${item.id ?? index + 1}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.timestamp.toString().substring(0, 19),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () => _showDeleteDialog(item.id ?? 0),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Soil Parameters:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildParamChip("N", item.nitrogen, Colors.green),
                  const SizedBox(width: 6),
                  _buildParamChip("P", item.phosphorus, Colors.orange),
                  const SizedBox(width: 6),
                  _buildParamChip("K", item.potassium, Colors.blue),
                  const SizedBox(width: 6),
                  _buildParamChip("pH", item.ph, Colors.purple),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Recommendation:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF43A047).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.fertilizerType != null && item.fertilizerType!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.eco, size: 16, color: Color(0xFF43A047)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.fertilizerType!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (item.alternativeType != null && item.alternativeType!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.swap_horiz, size: 16, color: Color(0xFFFB8C00)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Alternative: ${item.alternativeType}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.amount != null && item.amount!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.scale, size: 16, color: Color(0xFF1565C0)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.amount!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParamChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Record"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteHistory(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
