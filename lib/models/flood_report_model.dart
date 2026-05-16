class FloodReport {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final int waterLevelCm;
  final String riskLevel;
  final String status;
  final String createdAt;

  FloodReport({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.waterLevelCm,
    required this.riskLevel,
    required this.status,
    required this.createdAt,
  });

  factory FloodReport.fromJson(Map<String, dynamic> json) {
    return FloodReport(
      id: _toInt(json['id']),
      title: (json['judul'] ?? '').toString(),
      description: (json['deskripsi'] ?? '').toString(),
      imageUrl: (json['foto_url'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      address: (json['alamat_lokasi'] ?? '').toString(),
      waterLevelCm: _toInt(json['tinggi_banjir_cm']),
      riskLevel: (json['tingkat_risiko'] ?? 'rendah').toString(),
      status: (json['status_laporan'] ?? 'menunggu').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}