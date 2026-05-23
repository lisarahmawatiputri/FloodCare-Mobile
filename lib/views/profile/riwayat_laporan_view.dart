import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/views/dashboard/detail_laporan_view.dart';
import 'package:http/http.dart' as http;

class RiwayatLaporanView extends StatefulWidget {
  const RiwayatLaporanView({super.key});

  @override
  State<RiwayatLaporanView> createState() => _RiwayatLaporanViewState();
}

class _RiwayatLaporanViewState extends State<RiwayatLaporanView> {
  final AuthService authService = AuthService();

  late Future<List<Map<String, dynamic>>> _laporanFuture;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Menunggu', 'Valid', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _laporanFuture = _fetchRiwayat();
  }

  Future<List<Map<String, dynamic>>> _fetchRiwayat() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/riwayat-laporan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    throw Exception('Gagal memuat riwayat laporan');
  }

  void _refresh() {
    setState(() {
      _laporanFuture = _fetchRiwayat();
    });
  }

  List<Map<String, dynamic>> _filterLaporan(List<Map<String, dynamic>> data) {
    if (_selectedFilter == 'Semua') return data;
    return data.where((l) {
      final status = (l['status_laporan'] ?? '').toString().toLowerCase();
      return status == _selectedFilter.toLowerCase();
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return const Color(0xFF22C55E);
      case 'ditolak':
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
        return const Color(0xFFFEE2E2);
      case 'menunggu':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'menunggu':
      default:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Riwayat Laporan',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'jakartabold',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter tabs
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF6600)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'intermedium',
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _laporanFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6600),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 42,
                            color: Color(0xFFEF4444),
                          ),
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
                            onTap: _refresh,
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
                    );
                  }

                  final filtered = _filterLaporan(snapshot.data ?? []);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 52,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada laporan',
                            style: TextStyle(
                              fontFamily: 'intermedium',
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: const Color(0xFFFF6600),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final laporan = filtered[index];
                        final status =
                            (laporan['status_laporan'] ?? 'menunggu')
                                .toString();
                        final judul =
                            laporan['judul']?.toString() ?? 'Tanpa Judul';
                        final alamat =
                            laporan['alamat_lokasi']?.toString() ?? '-';
                        final tanggal =
                            laporan['created_at']?.toString() ?? '-';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailLaporanView(
                                  laporanId: laporan['id'],
                                  judulAwal: judul,
                                ),
                              ),
                            );
                          },
                          child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Icon status
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _statusBgColor(status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _statusIcon(status),
                                    color: _statusColor(status),
                                    size: 22,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        judul,
                                        style: const TextStyle(
                                          fontFamily: 'interbold',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F2933),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              alamat,
                                              style: const TextStyle(
                                                fontFamily: 'interregular',
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            tanggal,
                                            style: const TextStyle(
                                              fontFamily: 'interregular',
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Status badge
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusBgColor(status),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'interbold',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: _statusColor(status),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 20,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}