import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:floodcare_mobile/models/detail_laporan_model.dart';
import 'package:floodcare_mobile/viewmodels/detail_laporan_viewmodel.dart';

class DetailLaporanView extends StatelessWidget {
  final int laporanId;
  final String? judulAwal;

  const DetailLaporanView({
    super.key,
    required this.laporanId,
    this.judulAwal,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailLaporanViewModel()..fetchDetail(laporanId),
      child: Consumer<DetailLaporanViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(
              context: context,
              message: viewModel.errorMessage!,
            );
          }

          final laporan = viewModel.detail;

          if (laporan == null) {
            return _buildEmptyState(context);
          }

          return _buildDetailContent(context, laporan);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6600),
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required BuildContext context,
    required String message,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'interregular',
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<DetailLaporanViewModel>()
                              .fetchDetail(laporanId);
                        },
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Data laporan tidak ditemukan',
                  style: TextStyle(
                    fontFamily: 'interregular',
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    DetailLaporanModel laporan,
  ) {
    final hasLocation = laporan.latitude != null && laporan.longitude != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
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
                      color: Colors.black.withValues(alpha: 0.1),
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
              background: _buildHeaderImage(laporan.fotoUrl),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusAndRiskBadges(
                    status: laporan.statusLaporan,
                    risiko: laporan.tingkatRisiko,
                  ),
                  const SizedBox(height: 14),

                  Text(
                    laporan.judul,
                    style: const TextStyle(
                      fontFamily: 'jakartabold',
                      fontSize: 22,
                      color: Color(0xFF1F2933),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildDateRow(laporan.createdAt),

                  const SizedBox(height: 20),

                  _buildInfoCards(laporan),

                  const SizedBox(height: 20),

                  _buildLocationCard(laporan.alamatLokasi),

                  const SizedBox(height: 20),

                  if (hasLocation) ...[
                    _buildMapSection(
                      latitude: laporan.latitude!,
                      longitude: laporan.longitude!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (laporan.deskripsi.isNotEmpty) ...[
                    _buildDescriptionSection(laporan.deskripsi),
                    const SizedBox(height: 20),
                  ],

                  if (laporan.pelapor != null)
                    _buildReporterSection(laporan.pelapor!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(String? fotoUrl) {
    if (fotoUrl == null || fotoUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      fotoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStatusAndRiskBadges({
    required String status,
    required String risiko,
  }) {
    return Row(
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
            color: _risikoColor(risiko).withValues(alpha: 0.1),
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
    );
  }

  Widget _buildDateRow(String tanggal) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 13,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            tanggal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'interregular',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(DetailLaporanModel laporan) {
    final waktuDilaporkan = laporan.createdAt.contains('•')
        ? laporan.createdAt.split('•').last.trim()
        : laporan.createdAt;

    return Row(
      children: [
        Expanded(
          child: _infoCard(
            icon: Icons.water_drop_outlined,
            label: 'TINGGI AIR',
            value: '${laporan.tinggiBanjirCm} cm',
            iconColor: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoCard(
            icon: Icons.access_time_rounded,
            label: 'DILAPORKAN',
            value: waktuDilaporkan,
            iconColor: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoCard(
            icon: Icons.person_outline,
            label: 'PELAPOR',
            value: laporan.pelapor?.nama ?? 'Anonim',
            iconColor: const Color(0xFFFF6600),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(String alamat) {
    return Container(
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
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection({
    required double latitude,
    required double longitude,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                  userAgentPackageName: 'com.example.floodcare_mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
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
      ],
    );
  }

  Widget _buildDescriptionSection(String deskripsi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildReporterSection(PelaporModel pelapor) {
    final hasPhoto = pelapor.foto != null && pelapor.foto!.isNotEmpty;

    return Column(
      children: [
        const Divider(color: Color(0xFFF1F5F9)),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6600).withValues(alpha: 0.1),
              ),
              child: hasPhoto
                  ? ClipOval(
                      child: Image.network(
                        pelapor.foto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
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
            Expanded(
              child: Column(
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
                    pelapor.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'intermedium',
                      fontSize: 14,
                      color: Color(0xFFFF6600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
}