import 'dart:convert';
import 'package:flutter/services.dart';

class RecommendationService {
  List<Map<String, dynamic>> _rules = [];

  Future<void> loadRules() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/fertilizer_rules.json');
      final List<dynamic> data = json.decode(jsonString);
      _rules = data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error loading rules: $e');
      _rules = [];
    }
  }

  Map<String, dynamic> getRecommendation({
    required int n,
    required int p,
    required int k,
    required double ph,
    required int statusN,
    required int statusP,
    required int statusK,
    required int statusPh,
  }) {
    for (var rule in _rules) {
      final conditions = rule['conditions'];

      bool matches = n >= conditions['n'][0] &&
          n <= conditions['n'][1] &&
          p >= conditions['p'][0] &&
          p <= conditions['p'][1] &&
          k >= conditions['k'][0] &&
          k <= conditions['k'][1] &&
          ph >= conditions['ph'][0] &&
          ph <= conditions['ph'][1] &&
          statusN == conditions['status_n'] &&
          statusP == conditions['status_p'] &&
          statusK == conditions['status_k'] &&
          statusPh == conditions['status_ph'];

      if (matches) {
        return {
          'fertilizer': rule['fertilizer'] ?? 'Unknown',
          'image': rule['image'] ?? '',
          'google_search': rule['google_search'] ?? '',
          'alternative': rule['alternative'] ?? 'N/A',
          'amount': rule['amount'] ?? 'N/A',
          'sacks': rule['sacks'] ?? 0,
          'npk': rule['npk'] ?? '',
          'application_rate': rule['application_rate'] ?? '',
          'mode_of_application': rule['mode_of_application'] ?? '',
          'application_timing': rule['application_timing'] ?? '',
        };
      }
    }

    return {
      'fertilizer': 'No recommendation available',
      'image': '',
      'google_search': '',
      'alternative': 'N/A',
      'amount': 'N/A',
      'sacks': 0,
      'npk': '',
      'application_rate': '',
      'mode_of_application': '',
      'application_timing': '',
    };
  }
}