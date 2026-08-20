import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_reading.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _key = 'recommendations';

  Future<void> insertRecommendation(SensorReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? existing = prefs.getStringList(_key);
    if (existing == null) existing = [];

    Map<String, dynamic> data = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'nitrogen': reading.nitrogen,
      'phosphorus': reading.phosphorus,
      'potassium': reading.potassium,
      'ph': reading.ph,
      'timestamp': reading.timestamp.toIso8601String(),
      'feedback': 0,
    };

    existing.add(jsonEncode(data));
    await prefs.setStringList(_key, existing);
  }

  Future<List<SensorReading>> getAllRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? existing = prefs.getStringList(_key);
    if (existing == null) return [];

    List<SensorReading> readings = [];
    for (String item in existing) {
      try {
        Map<String, dynamic> data = jsonDecode(item);
        readings.add(SensorReading(
          id: data['id'],
          nitrogen: data['nitrogen'] ?? '--',
          phosphorus: data['phosphorus'] ?? '--',
          potassium: data['potassium'] ?? '--',
          ph: data['ph'] ?? '--',
          timestamp: DateTime.parse(data['timestamp']),
          feedback: data['feedback'] == 1 ? true : false,
        ));
      } catch (e) {}
    }
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings;
  }

  Future<void> updateFeedback(int id, bool isThumbsUp) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? existing = prefs.getStringList(_key);
    if (existing == null) return;

    List<String> updated = [];
    for (String item in existing) {
      Map<String, dynamic> data = jsonDecode(item);
      if (data['id'] == id) data['feedback'] = isThumbsUp ? 1 : 0;
      updated.add(jsonEncode(data));
    }
    await prefs.setStringList(_key, updated);
  }

  Future<void> deleteRecommendation(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? existing = prefs.getStringList(_key);
    if (existing == null) return;

    existing.removeWhere((item) {
      Map<String, dynamic> data = jsonDecode(item);
      return data['id'] == id;
    });
    await prefs.setStringList(_key, existing);
  }

  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
