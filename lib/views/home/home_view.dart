import 'package:floodcare_mobile/models/edukasi_article_model.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:floodcare_mobile/models/flood_report_model.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/home_viewmodel.dart';
import 'package:floodcare_mobile/views/donasi/donation_detail_view.dart';
import 'package:floodcare_mobile/views/dashboard/detail_laporan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MapController mapController = MapController();
  final HomeViewModel homeViewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();

    homeViewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    homeViewModel.initHome().then((_) {
      final location = homeViewModel.currentLocation;

      if (!mounted || location == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mapController.move(location, 16);
        }
      });
    });
  }

  @override
  void dispose() {
    homeViewModel.dispose();
    super.dispose();
  }

  void moveToCurrentLocation() {
    final location = homeViewModel.currentLocation;

    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum tersedia'),
        ),
      );
      return;
    }

    mapController.move(location, 16);
  }

  Color _riskColor(String riskLevel) {
    final risk = riskLevel.toLowerCase();

    if (risk == 'tinggi' || risk == 'sangat_tinggi') {
      return const Color(0xFFD94A4A);
    }

    if (risk == 'sedang') {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF3B82F6);
  }

  IconData _riskIcon(String riskLevel) {
    final risk = riskLevel.toLowerCase();

    if (risk == 'tinggi' || risk == 'sangat_tinggi') {
      return Icons.warning_amber_rounded;
    }

    if (risk == 'sedang') {
      return Icons.water_drop;
    }

    return Icons.check_circle_outline;
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];

    if (homeViewModel.currentLocation != null) {
      markers.add(
        Marker(
          point: homeViewModel.currentLocation!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 34,
          ),
        ),
      );
    }

    for (final report in homeViewModel.floodReports) {
      if (report.latitude == 0 || report.longitude == 0) continue;

      markers.add(
        Marker(
          point: LatLng(report.latitude, report.longitude),
          width: 42,
          height: 42,
          child: Icon(
            _riskIcon(report.riskLevel),
            color: _riskColor(report.riskLevel),
            size: 34,
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildLaporanCard(FloodReport item) {
    final color = _riskColor(item.riskLevel);
    final icon = _riskIcon(item.riskLevel);

    return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailLaporanView(
          laporanId: item.id,
          judulAwal: item.title,
        ),
      ),
    );
  },
  child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.createdAt.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'interbold',
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.address.isNotEmpty ? item.address : item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'jakartabold',
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.waterLevelCm > 0
                        ? 'Ketinggian ${item.waterLevelCm} cm • Risiko ${item.riskLevel.replaceAll('_', ' ')}'
                        : item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'intermedium',
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              icon,
              size: 18,
              color: color,
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildLaporanSection() {
    if (homeViewModel.isLoadingReports &&
        homeViewModel.floodReports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (homeViewModel.reportError != null &&
        homeViewModel.floodReports.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              'Gagal memuat laporan banjir',
              style: TextStyle(
                fontFamily: 'jakartabold',
                fontSize: 14,
                color: Color(0xFFD94A4A),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: homeViewModel.fetchFloodReports,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'interbold',
                  fontSize: 13,
                  color: Color(0xFFC65A1E),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (homeViewModel.floodReports.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Belum ada laporan banjir terbaru',
          style: TextStyle(
            fontFamily: 'intersemibold',
            fontSize: 14,
            color: Color(0xFF6D6D6D),
          ),
        ),
      );
    }

    return Column(
      children: homeViewModel.floodReports
          .take(3)
          .map(_buildLaporanCard)
          .toList(),
    );
  }

  Widget _buildEduCard({
    required Color backgroundColor,
    required Color iconColor,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badgeText,
  }) {
    return Container(
      width: 182,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor,
                ),
              ),
              const Spacer(),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'interbold',
                      color: Color(0xFF3F8E57),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'jakartabold',
              color: Color(0xFF28553A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'intermedium',
              color: Color(0xFF4C8A5F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(EdukasiArticle? article) {
    if (homeViewModel.isLoadingLatestArticle && article == null) {
      return _buildEduCard(
        backgroundColor: const Color(0xFFE6F3E8),
        iconColor: const Color(0xFF6BCB77),
        badgeColor: const Color(0xFFDDF7E3),
        title: 'Memuat artikel...',
        subtitle: 'Artikel',
        icon: Icons.description_outlined,
        badgeText: 'BARU',
      );
    }

    return _buildEduCard(
      backgroundColor: const Color(0xFFE6F3E8),
      iconColor: const Color(0xFF6BCB77),
      badgeColor: const Color(0xFFDDF7E3),
      title: article?.title ?? 'Belum ada artikel terbaru',
      subtitle: 'Artikel • ${article?.date ?? '-'}',
      icon: Icons.description_outlined,
      badgeText: 'BARU',
    );
  }

  Widget _buildVideoCard(EdukasiVideo? video) {
    if (homeViewModel.isLoadingLatestVideo && video == null) {
      return _buildEduCard(
        backgroundColor: const Color(0xFFFFEFE2),
        iconColor: const Color(0xFFF28C28),
        badgeColor: const Color(0xFFFFF1E6),
        title: 'Memuat video...',
        subtitle: 'Video',
        icon: Icons.play_circle_outline_rounded,
      );
    }

    return _buildEduCard(
      backgroundColor: const Color(0xFFFFEFE2),
      iconColor: const Color(0xFFF28C28),
      badgeColor: const Color(0xFFFFF1E6),
      title: video?.title ?? 'Belum ada video terbaru',
      subtitle: 'Video • ${video?.duration ?? '-'}',
      icon: Icons.play_circle_outline_rounded,
    );
  }

  Widget _buildEdukasiSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildArticleCard(homeViewModel.latestArticle),
          const SizedBox(width: 14),
          _buildVideoCard(homeViewModel.latestVideo),
        ],
      ),
    );
  }

  Widget _buildDonasiCard(BuildContext context) {
    if (homeViewModel.isLoadingDonation &&
        homeViewModel.donationPrograms.isEmpty) {
      return Container(
        width: double.infinity,
        height: 170,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (homeViewModel.donationError != null &&
        homeViewModel.donationPrograms.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text(
              'Gagal memuat donasi',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'jakartabold',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: homeViewModel.fetchDonationPrograms,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Color(0xFFC65A1E),
                  fontFamily: 'interbold',
                ),
              ),
            ),
          ],
        ),
      );
    }

    final program = homeViewModel.featuredDonationProgram;

    if (program == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Belum ada program donasi aktif',
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'jakartabold',
            color: Colors.black,
          ),
        ),
      );
    }

    final progress = homeViewModel.donationProgress(program);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            program.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'jakartabold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Terkumpul: ${homeViewModel.formatRupiah(program.collectedAmount)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'intersemibold',
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                'Target: ${homeViewModel.formatRupiah(program.targetAmount)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'intersemibold',
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE0E0E0),
              color: lightorange,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Container(
              decoration: BoxDecoration(
                gradient: orangeGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationDetailView(
                        program: program,
                      ),
                    ),
                  );

                  if (!mounted) return;

                  await homeViewModel.fetchDonationPrograms();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Donasi sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'interbold',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng fallbackLocation = const LatLng(-6.2088, 106.8456);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: homeViewModel.refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${homeViewModel.userName}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'jakartaextrabold',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  homeViewModel.environmentStatusText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'interregular',
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 255,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter:
                              homeViewModel.currentLocation ?? fallbackLocation,
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.drag |
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.doubleTapZoom,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                            userAgentPackageName:
                                'com.example.floodcare_mobile',
                            maxZoom: 22,
                          ),
                          MarkerLayer(
                            markers: _buildMapMarkers(),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: Color(0xFF65D46E),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Peta Live Aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'intersemibold',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: moveToCurrentLocation,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location_rounded,
                              color: Color(0xFFFF7A1A),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Stack(
                          children: [
                            Text(
                              'Pantauan Wilayah\n${homeViewModel.wilayahText}',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.2,
                                fontFamily: 'jakartabold',
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = Colors.black,
                              ),
                            ),
                            Text(
                              'Pantauan Wilayah\n${homeViewModel.wilayahText}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.2,
                                fontFamily: 'jakartabold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildLaporanSection(),
                const SizedBox(height: 10),
                _buildEdukasiSection(),
                const SizedBox(height: 24),
                _buildDonasiCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}