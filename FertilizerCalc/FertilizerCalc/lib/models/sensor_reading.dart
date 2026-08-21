class SensorReading {
  int? id;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String ph;
  final DateTime timestamp;
  bool? feedback;
  
  // 🔥 IDAGDAG ANG MGA ITO!
  String? fertilizerType;
  String? fertilizerImageUrl;
  String? alternativeType;
  int? recommendedSacks;
  String? amount;
  String? npkAnalysis;

  SensorReading({
    this.id,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.timestamp,
    this.feedback,
    this.fertilizerType,
    this.fertilizerImageUrl,
    this.alternativeType,
    this.recommendedSacks,
    this.amount,
    this.npkAnalysis,
  });

  // Create from JSON
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'],
      nitrogen: json['nitrogen'] ?? '--',
      phosphorus: json['phosphorus'] ?? '--',
      potassium: json['potassium'] ?? '--',
      ph: json['ph'] ?? '--',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      feedback: json['feedback'] == 1 ? true : false,
      fertilizerType: json['fertilizerType'],
      fertilizerImageUrl: json['fertilizerImageUrl'],
      alternativeType: json['alternativeType'],
      recommendedSacks: json['recommendedSacks'],
      amount: json['amount'],
      npkAnalysis: json['npkAnalysis'],
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
      'fertilizerType': fertilizerType,
      'fertilizerImageUrl': fertilizerImageUrl,
      'alternativeType': alternativeType,
      'recommendedSacks': recommendedSacks,
      'amount': amount,
      'npkAnalysis': npkAnalysis,
    };
  }

  // ... rest of existing code (getters, etc.)
}
