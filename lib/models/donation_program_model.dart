import 'dart:convert';

class DonationProgram {
  final int id;
  final String title;
  final String location;
  final String image;
  final bool isEmergency;
  final int collectedAmount;
  final int targetAmount;
  final String category;
  final String description;

  DonationProgram({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.isEmergency,
    required this.collectedAmount,
    required this.targetAmount,
    required this.category,
    required this.description,
  });

  factory DonationProgram.fromJson(Map<String, dynamic> json) {
    return DonationProgram(
      id: _toInt(json['id']),

      title: (json['title'] ??
              json['nama_program'] ??
              json['name'] ??
              '')
          .toString(),

      description: (json['description'] ??
              json['deskripsi'] ??
              json['detail'] ??
              json['donasi_detail'] ??
              '')
          .toString(),

      location: (json['location'] ??
              json['lokasi'] ??
              '')
          .toString(),

      image: (json['image'] ??
              json['foto'] ??
              json['gambar'] ??
              '')
          .toString(),

      isEmergency: json['is_emergency'] == true ||
          json['isEmergency'] == true ||
          (json['category'] ?? '').toString().toLowerCase() == 'darurat' ||
          (json['kategori'] ?? '').toString().toLowerCase() == 'darurat',

      collectedAmount: _toInt(
        json['collected_amount'] ??
            json['terkumpul'] ??
            json['dana_terkumpul'] ??
            0,
      ),

      targetAmount: _toInt(
        json['target_amount'] ??
            json['target_dana'] ??
            0,
      ),

      category: (json['category'] ??
              json['kategori'] ??
              'Semua')
          .toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      return int.tryParse(value.split('.').first) ?? 0;
    }

    return 0;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'location': location,
      'image': image,
      'isEmergency': isEmergency,
      'collectedAmount': collectedAmount,
      'targetAmount': targetAmount,
      'category': category,
      'description': description,
    };
  }

  factory DonationProgram.fromMap(Map<String, dynamic> map) {
    return DonationProgram(
      id: _toInt(map['id']),
      title: (map['title'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      isEmergency: map['isEmergency'] == true,
      collectedAmount: _toInt(map['collectedAmount']),
      targetAmount: _toInt(map['targetAmount']),
      category: (map['category'] ?? 'Semua').toString(),
      description: (map['description'] ?? '').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DonationProgram.fromJsonString(String source) {
    return DonationProgram.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }
}