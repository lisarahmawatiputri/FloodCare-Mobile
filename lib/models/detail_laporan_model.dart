class DetailLaporanModel {
  final int? id;
  final String judul;
  final String deskripsi;
  final String? fotoUrl;
  final String alamatLokasi;
  final String tinggiBanjirCm;
  final String tingkatRisiko;
  final String statusLaporan;
  final String createdAt;
  final double? latitude;
  final double? longitude;
  final PelaporModel? pelapor;

  DetailLaporanModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    this.fotoUrl,
    required this.alamatLokasi,
    required this.tinggiBanjirCm,
    required this.tingkatRisiko,
    required this.statusLaporan,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.pelapor,
  });

  factory DetailLaporanModel.fromJson(Map<String, dynamic> json) {
    return DetailLaporanModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      deskripsi: json['deskripsi']?.toString() ?? '',
      fotoUrl: json['foto_url']?.toString(),
      alamatLokasi: json['alamat_lokasi']?.toString() ?? '-',
      tinggiBanjirCm: json['tinggi_banjir_cm']?.toString() ?? '-',
      tingkatRisiko: json['tingkat_risiko']?.toString() ?? 'rendah',
      statusLaporan: json['status_laporan']?.toString() ?? 'menunggu',
      createdAt: json['created_at']?.toString() ?? '-',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      pelapor: json['pelapor'] is Map<String, dynamic>
          ? PelaporModel.fromJson(json['pelapor'])
          : null,
    );
  }
}

class PelaporModel {
  final int? id;
  final String nama;
  final String? foto;

  PelaporModel({
    this.id,
    required this.nama,
    this.foto,
  });

  factory PelaporModel.fromJson(Map<String, dynamic> json) {
    return PelaporModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      nama: json['nama']?.toString() ?? 'Anonim',
      foto: json['foto']?.toString(),
    );
  }
}