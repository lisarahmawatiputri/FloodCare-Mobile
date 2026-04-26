class DonationProgram {
  final int id;
  final String title;
  final String location;
  final String image;
  final bool isEmergency;
  final int collectedAmount;
  final int targetAmount;
  final String category;

  DonationProgram({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.isEmergency,
    required this.collectedAmount,
    required this.targetAmount,
    required this.category,
  });

  factory DonationProgram.fromJson(Map<String, dynamic> json) {
    return DonationProgram(
      id: json['id'],
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      isEmergency: json['is_emergency'] ?? false,
      collectedAmount: json['collected_amount'] ?? 0,
      targetAmount: json['target_amount'] ?? 0,
      category: json['category'] ?? 'Semua',
    );
  }
}