class SensorReading {
  int? id; // ← IDAGDAG ITO!
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String ph;
  final DateTime timestamp;
  bool? feedback; // ← IDAGDAG ITO!

  SensorReading({
    this.id, // ← IDAGDAG ITO!
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.timestamp,
    this.feedback, // ← IDAGDAG ITO!
  });

  // Create from JSON
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'],
      nitrogen: json['nitrogen'] ?? '--',
      phosphorus: json['phosphorus'] ?? '--',
      potassium: json['potassium'] ?? '--',
      ph: json['ph'] ?? '--',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      feedback: json['feedback'] == 1 ? true : false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'timestamp': timestamp.toIso8601String(),
      'feedback': feedback == true ? 1 : 0,
    };
  }

  // Check if all values are present
  bool get isValid {
    return nitrogen != '--' &&
        phosphorus != '--' &&
        potassium != '--' &&
        ph != '--';
  }

  // Get progress values for N (0-100)
  double get nitrogenProgress {
    final value = double.tryParse(nitrogen);
    if (value == null) return 0;
    return (value / 100).clamp(0.0, 1.0);
  }

  // Get progress values for P (0-100)
  double get phosphorusProgress {
    final value = double.tryParse(phosphorus);
    if (value == null) return 0;
    return (value / 100).clamp(0.0, 1.0);
  }

  // Get progress values for K (0-100)
  double get potassiumProgress {
    final value = double.tryParse(potassium);
    if (value == null) return 0;
    return (value / 100).clamp(0.0, 1.0);
  }

  // Get progress values for pH (0-14, ideal is 6-7)
  double get phProgress {
    final value = double.tryParse(ph);
    if (value == null) return 0;
    if (value >= 6 && value <= 7) return 1.0;
    if (value < 6) return (value / 6).clamp(0.0, 1.0);
    if (value > 7) return (1 - ((value - 7) / 7)).clamp(0.0, 1.0);
    return 0;
  }

  // Get recommendation based on values
  String getRecommendation() {
    if (!isValid) {
      return 'No data available for recommendation.';
    }

    List<String> recommendations = [];

    final n = double.tryParse(nitrogen);
    if (n != null) {
      if (n < 20) {
        recommendations.add(
            'Low Nitrogen: Apply nitrogen-rich fertilizer (Urea, Ammonium sulfate)');
      } else if (n > 60) {
        recommendations
            .add('High Nitrogen: Reduce nitrogen fertilizer application');
      } else {
        recommendations.add('Nitrogen level is optimal');
      }
    }

    final p = double.tryParse(phosphorus);
    if (p != null) {
      if (p < 10) {
        recommendations.add(
            'Low Phosphorus: Apply phosphate fertilizer (Superphosphate, DAP)');
      } else if (p > 40) {
        recommendations
            .add('High Phosphorus: Reduce phosphorus fertilizer application');
      } else {
        recommendations.add('Phosphorus level is optimal');
      }
    }

    final k = double.tryParse(potassium);
    if (k != null) {
      if (k < 20) {
        recommendations.add(
            'Low Potassium: Apply potassium fertilizer (Muriate of Potash)');
      } else if (k > 60) {
        recommendations
            .add('High Potassium: Reduce potassium fertilizer application');
      } else {
        recommendations.add('Potassium level is optimal');
      }
    }

    final pH = double.tryParse(ph);
    if (pH != null) {
      if (pH < 5.5) {
        recommendations
            .add('Soil is too acidic: Add lime or dolomite to increase pH');
      } else if (pH > 7.5) {
        recommendations.add(
            'Soil is too alkaline: Add sulfur or organic matter to decrease pH');
      } else {
        recommendations.add('Soil pH is optimal (6.0-7.0)');
      }
    }

    if (recommendations.isEmpty) {
      return 'All soil parameters are optimal. Maintain current fertilization practices.';
    }

    return recommendations.join('\n\n');
  }

  @override
  String toString() {
    return 'N: $nitrogen, P: $phosphorus, K: $potassium, pH: $ph (${timestamp.toString().substring(0, 19)})';
  }
}
