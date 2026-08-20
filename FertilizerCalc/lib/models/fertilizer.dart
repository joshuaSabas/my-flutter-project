class Fertilizer {
  final String name;
  final String image;
  final String alternative;
  final String amount;

  Fertilizer({
    required this.name,
    required this.image,
    required this.alternative,
    required this.amount,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      name: json['fertilizer'] ?? 'Unknown',
      image: json['image'] ?? 'assets/images/default.png',
      alternative: json['alternative'] ?? 'N/A',
      amount: json['amount'] ?? 'N/A',
    );
  }
}
