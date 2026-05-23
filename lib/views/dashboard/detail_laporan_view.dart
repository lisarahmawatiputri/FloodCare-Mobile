import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;

class DetailLaporanView extends StatefulWidget {
  final int laporanId;
  final String? judulAwal;

  const DetailLaporanView({
    super.key,
    required this.laporanId,
    this.judulAwal,
  });

  @override
  State<DetailLaporanView> createState() => _DetailLaporanViewState();
}

class _DetailLaporanViewState extends State<DetailLaporanView> {
  final AuthService authService = AuthService();
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail();
  }

  Future<Map<String, dynamic>> _fetchDetail() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/laporan-banjir/${widget.laporanId}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception('Gagal memuat detail laporan');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return const Color(0xFF22C55E);
      case 'ditolak':
      case 'tidak_valid':
        return const Color(0xFFEF4444);
      case 'menunggu':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return const Color(0xFFDCFCE7);
      case 'ditolak':
      case 'tidak_valid':
        return const Color(0xFFFEE2E2);
      case 'menunggu':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _risikoColor(String risiko) {
    switch (risiko.toLowerCase()) {
      case 'tinggi':
      case 'sangat_tinggi':
        return const Color(0xFFEF4444);
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _risikoLabel(String risiko) {
    return risiko.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6600)),
            );
          }

          if (snapshot.hasError) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.arrow_back, size: 24),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 42, color: Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.error
                                .toString()
                                .replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'interregular',
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => setState(() {
                              _detailFuture = _fetchDetail();
                            }),
                            child: const Text(
                              'Coba Lagi',
                              style: TextStyle(
                                fontFamily: 'interbold',
                                fontSize: 13,
                                color: Color(0xFFFF6600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final judul = data['judul']?.toString() ?? 'Tanpa Judul';
          final deskripsi = data['deskripsi']?.toString() ?? '';
          final fotoUrl = data['foto_url']?.toString();
          final alamat = data['alamat_lokasi']?.toString() ?? '-';
          final tinggi = data['tinggi_banjir_cm']?.toString() ?? '-';
          final risiko = data['tingkat_risiko']?.toString() ?? 'rendah';
          final status = data['status_laporan']?.toString() ?? 'menunggu';
          final tanggal = data['created_at']?.toString() ?? '-';
          final konfirmasi = data['jumlah_konfirmasi']?.toString() ?? '0';
          final pelapor = data['pelapor'] as Map<String, dynamic>?;
          final lat = double.tryParse(data['latitude']?.toString() ?? '');
          final lng = double.tryParse(data['longitude']?.toString() ?? '');

          return CustomScrollView(
            slivers: [
              // App Bar dengan foto
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1F2933),
                      size: 20,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: fotoUrl != null && fotoUrl.isNotEmpty
                      ? Image.network(
                          fotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Risiko badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBgColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'interbold',
                                fontSize: 11,
                                color: _statusColor(status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _risikoColor(risiko).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 13,
                                  color: _risikoColor(risiko),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _risikoLabel(risiko),
                                  style: TextStyle(
                                    fontFamily: 'interbold',
                                    fontSize: 11,
                                    color: _risikoColor(risiko),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Judul
                      Text(
                        judul,
                        style: const TextStyle(
                          fontFamily: 'jakartabold',
                          fontSize: 22,
                          color: Color(0xFF1F2933),
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tanggal
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tanggal,
                            style: const TextStyle(
                              fontFamily: 'interregular',
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Info cards (tinggi air, konfirmasi, pelapor)
                      Row(
                        children: [
                          Expanded(
                            child: _infoCard(
                              icon: Icons.water_drop_outlined,
                              label: 'TINGGI AIR',
                              value: '$tinggi cm',
                              iconColor: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _infoCard(
                              icon: Icons.access_time_rounded,
                              label: 'DILAPORKAN',
                              value: tanggal.split('•').last.trim(),
                              iconColor: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _infoCard(
                              icon: Icons.person_outline,
                              label: 'PELAPOR',
                              value: pelapor?['nama']?.toString() ?? 'Anonim',
                              iconColor: const Color(0xFFFF6600),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Lokasi
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFFF6600),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'LOKASI',
                                    style: TextStyle(
                                      fontFamily: 'interbold',
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    alamat,
                                    style: const TextStyle(
                                      fontFamily: 'intermedium',
                                      fontSize: 13,
                                      color: Color(0xFF1F2933),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Peta
                      if (lat != null && lng != null) ...[
                        const Text(
                          'Titik Lokasi',
                          style: TextStyle(
                            fontFamily: 'jakartabold',
                            fontSize: 16,
                            color: Color(0xFF1F2933),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 180,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(lat, lng),
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.floodcare_mobile',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Keterangan
                      if (deskripsi.isNotEmpty) ...[
                        const Text(
                          'Keterangan Laporan',
                          style: TextStyle(
                            fontFamily: 'jakartabold',
                            fontSize: 16,
                            color: Color(0xFF1F2933),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            deskripsi,
                            style: const TextStyle(
                              fontFamily: 'interregular',
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Pelapor
                      if (pelapor != null) ...[
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFF6600).withOpacity(0.1),
                              ),
                              child: pelapor['foto'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        pelapor['foto'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person_outline,
                                          color: Color(0xFFFF6600),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFFFF6600),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PELAPOR',
                                  style: TextStyle(
                                    fontFamily: 'interbold',
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  pelapor['nama']?.toString() ?? 'Anonim',
                                  style: const TextStyle(
                                    fontFamily: 'intermedium',
                                    fontSize: 14,
                                    color: Color(0xFFFF6600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'interregular',
              fontSize: 9,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'interbold',
              fontSize: 13,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}