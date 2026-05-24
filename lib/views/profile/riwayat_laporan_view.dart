import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/home/detail_laporan_view.dart';
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

  final List<String> _filters = [
    'Semua',
    'Menunggu',
    'Valid',
    'Tidak Valid',
  ];

  @override
  void initState() {
    super.initState();
    _laporanFuture = _fetchRiwayat();
  }

  Future<List<Map<String, dynamic>>> _fetchRiwayat() async {
    final token = await authService.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

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

      return list.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    }

    throw Exception('Gagal memuat riwayat laporan');
  }

  void _refresh() {
    setState(() {
      _laporanFuture = _fetchRiwayat();
    });
  }

  String _normalizeStatus(String status) {
    return status.toLowerCase().trim().replaceAll(' ', '_');
  }

  String _filterToStatusValue(String filter) {
    switch (filter.toLowerCase()) {
      case 'valid':
        return 'valid';
      case 'tidak valid':
        return 'tidak_valid';
      case 'menunggu':
        return 'menunggu';
      case 'semua':
      default:
        return 'semua';
    }
  }

  String _statusLabel(String status) {
    switch (_normalizeStatus(status)) {
      case 'valid':
        return 'VALID';
      case 'tidak_valid':
        return 'TIDAK VALID';
      case 'menunggu':
      default:
        return 'MENUNGGU';
    }
  }

  List<Map<String, dynamic>> _filterLaporan(List<Map<String, dynamic>> data) {
    final selectedStatus = _filterToStatusValue(_selectedFilter);

    if (selectedStatus == 'semua') {
      return data;
    }

    return data.where((laporan) {
      final status = _normalizeStatus(
        (laporan['status_laporan'] ?? '').toString(),
      );

      return status == selectedStatus;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'valid':
        return const Color(0xFF22C55E);
      case 'tidak_valid':
        return const Color(0xFFEF4444);
      case 'menunggu':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _statusBgColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'valid':
        return const Color(0xFFDCFCE7);
      case 'tidak_valid':
        return const Color(0xFFFEE2E2);
      case 'menunggu':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  IconData _statusIcon(String status) {
    switch (_normalizeStatus(status)) {
      case 'valid':
        return Icons.check_circle_outline;
      case 'tidak_valid':
        return Icons.cancel_outlined;
      case 'menunggu':
      default:
        return Icons.access_time_rounded;
    }
  }

  void _openDetailLaporan(Map<String, dynamic> laporan) {
    final laporanId = int.tryParse(laporan['id']?.toString() ?? '');

    if (laporanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID laporan tidak valid'),
        ),
      );
      return;
    }

    final judul = laporan['judul']?.toString() ?? 'Tanpa Judul';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailLaporanView(
          laporanId: laporanId,
          judulAwal: judul,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                    color: Colors.black.withValues(alpha: 0.06),
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
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
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
                gradient: isSelected ? orangeGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE5EAF0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFF6600).withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'intermedium',
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFFF6600),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
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
            error.toString().replaceFirst('Exception: ', ''),
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

  Widget _buildEmptyState() {
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

  Widget _buildLaporanCard(Map<String, dynamic> laporan) {
    final status = (laporan['status_laporan'] ?? 'menunggu').toString();
    final judul = laporan['judul']?.toString() ?? 'Tanpa Judul';
    final alamat = laporan['alamat_lokasi']?.toString() ?? '-';
    final tanggal = laporan['created_at']?.toString() ?? '-';

    return GestureDetector(
      onTap: () => _openDetailLaporan(laporan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        Expanded(
                          child: Text(
                            tanggal,
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
                  ],
                ),
              ),

              const SizedBox(width: 8),

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
                      _statusLabel(status),
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
  }

  Widget _buildLaporanList(List<Map<String, dynamic>> filtered) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: const Color(0xFFFF6600),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildLaporanCard(filtered[index]);
        },
      ),
    );
  }

  Widget _buildBodyList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _laporanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          final filtered = _filterLaporan(snapshot.data ?? []);

          if (filtered.isEmpty) {
            return _buildEmptyState();
          }

          return _buildLaporanList(filtered);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            _buildBodyList(),
          ],
        ),
      ),
    );
  }
}