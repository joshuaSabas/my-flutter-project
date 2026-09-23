  class SensorReading {
  int? id;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String ph;
  final DateTime timestamp;
  bool? feedback;

  String? fertilizerType;
  String? fertilizerImageUrl;
  String? alternativeType;
  int? recommendedSacks;
  String? amount;
  String? npkAnalysis;

  // BAGONG FIELDS
  String? googleSearchUrl;
  String? applicationRate;
  String? modeOfApplication;
  String? applicationTiming;

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
    this.googleSearchUrl,
    this.applicationRate,
    this.modeOfApplication,
    this.applicationTiming,
  });

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
      googleSearchUrl: json['googleSearchUrl'],
      applicationRate: json['applicationRate'],
      modeOfApplication: json['modeOfApplication'],
      applicationTiming: json['applicationTiming'],
    );
  }

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
      'googleSearchUrl': googleSearchUrl,
      'applicationRate': applicationRate,
      'modeOfApplication': modeOfApplication,
      'applicationTiming': applicationTiming,
    };
  }

  factory SensorReading.fromMap(Map<String, dynamic> map) {
    return SensorReading(
      id: map['id'],
      nitrogen: map['nitrogen'] ?? '--',
      phosphorus: map['phosphorus'] ?? '--',
      potassium: map['potassium'] ?? '--',
      ph: map['ph'] ?? '--',
      timestamp: DateTime.parse(map['timestamp']),
      feedback: map['feedback'] == 1 ? true : false,
      fertilizerType: map['fertilizerType'] ?? '',
      fertilizerImageUrl: map['fertilizerImageUrl'] ?? '',
      alternativeType: map['alternativeType'] ?? '',
      recommendedSacks: map['recommendedSacks'] ?? 0,
      amount: map['amount'] ?? '',
      npkAnalysis: map['npkAnalysis'] ?? '',
      googleSearchUrl: map['googleSearchUrl'] ?? '',
      applicationRate: map['applicationRate'] ?? '',
      modeOfApplication: map['modeOfApplication'] ?? '',
      applicationTiming: map['applicationTiming'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'timestamp': timestamp.toIso8601String(),
      'feedback': feedback == true ? 1 : 0,
      'fertilizerType': fertilizerType ?? '',
      'fertilizerImageUrl': fertilizerImageUrl ?? '',
      'alternativeType': alternativeType ?? '',
      'recommendedSacks': recommendedSacks ?? 0,
      'amount': amount ?? '',
      'npkAnalysis': npkAnalysis ?? '',
      'googleSearchUrl': googleSearchUrl ?? '',
      'applicationRate': applicationRate ?? '',
      'modeOfApplication': modeOfApplication ?? '',
      'applicationTiming': applicationTiming ?? '',
    };
  }
}
