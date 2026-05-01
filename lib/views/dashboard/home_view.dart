import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/dashboard/donation_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MapController mapController = MapController();
  final AuthService authService = AuthService();

  LatLng? currentLocation;
  bool isLoadingLocation = true;
  String? locationError;

  String wilayahText = 'Memuat lokasi...';
  String userName = 'User';

  late Future<List<DonationProgram>> donationProgramsFuture;

  final List<Map<String, dynamic>> laporanList = [
    {
      'image':
          'https://images.unsplash.com/photo-1547683905-f686c993aae5?q=80&w=800&auto=format&fit=crop',
      'date': 'RABU, 15 APRIL 2025',
      'title': 'Patrang Regency',
      'subtitle': 'Genangan sedang teramati di jalan',
      'dateColor': const Color(0xFFD94A4A),
      'icon': Icons.water_drop,
      'iconColor': const Color(0xFFD94A4A),
    },
    {
      'image':
          'https://images.unsplash.com/photo-1547683905-f686c993aae5?q=80&w=800&auto=format&fit=crop',
      'date': 'RABU, 15 APRIL 2025',
      'title': 'Sekitar RS DR. Soebandi',
      'subtitle': 'Risiko luapan sungai tinggi',
      'dateColor': const Color(0xFFD94A4A),
      'icon': Icons.warning_amber_rounded,
      'iconColor': const Color(0xFFD94A4A),
    },
    {
      'image':
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=800&auto=format&fit=crop',
      'date': 'SELASA, 14 APRIL 2025',
      'title': 'Jalan Mastrip',
      'subtitle': 'Air sudah surut. Jalan sudah bersih',
      'dateColor': const Color(0xFF3B82F6),
      'icon': Icons.check_circle_outline,
      'iconColor': const Color(0xFF3B82F6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserName();
    donationProgramsFuture = authService.getDonationPrograms();
  }

  Future<void> _loadUserName() async {
    try {
      final name = await authService.getUserName();

      if (!mounted) return;

      setState(() {
        userName = name;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        userName = 'User';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
          locationError = 'GPS belum aktif';
          wilayahText = 'Lokasi tidak tersedia';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          isLoadingLocation = false;
          locationError = 'Izin lokasi ditolak';
          wilayahText = 'Lokasi ditolak';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
          locationError = 'Izin lokasi ditolak permanen';
          wilayahText = 'Lokasi tidak tersedia';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      final wilayah = await _getWilayahName(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        currentLocation = userLatLng;
        wilayahText = wilayah;
        isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mapController.move(userLatLng, 16);
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingLocation = false;
        locationError = 'Gagal mengambil lokasi';
        wilayahText = 'Lokasi tidak diketahui';
      });
    }
  }

  Future<String> _getWilayahName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return 'Wilayah Tidak Diketahui';
      }

      final place = placemarks.first;

      final area =
          place.subAdministrativeArea != null &&
                  place.subAdministrativeArea!.trim().isNotEmpty
              ? place.subAdministrativeArea!.trim()
              : null;

      final city =
          place.locality != null && place.locality!.trim().isNotEmpty
              ? place.locality!.trim()
              : null;

      final district =
          place.subLocality != null && place.subLocality!.trim().isNotEmpty
              ? place.subLocality!.trim()
              : null;

      final adminArea =
          place.administrativeArea != null &&
                  place.administrativeArea!.trim().isNotEmpty
              ? place.administrativeArea!.trim()
              : null;

      return area ?? city ?? district ?? adminArea ?? 'Wilayah Tidak Diketahui';
    } catch (_) {
      return 'Wilayah Tidak Diketahui';
    }
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  Widget _buildLaporanCard(Map<String, dynamic> item) {
    return Container(
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
            child: Image.network(
              item['image'],
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
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
                    item['date'],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'interbold',
                      color: item['dateColor'],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'jakartabold',
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle'],
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
              item['icon'],
              size: 18,
              color: item['iconColor'],
            ),
          ),
        ],
      ),
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
                  color: Colors.white.withOpacity(0.7),
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

  Widget _buildDonasiCard(BuildContext context) {
    return FutureBuilder<List<DonationProgram>>(
      future: donationProgramsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        if (snapshot.hasError) {
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
                  onTap: () {
                    setState(() {
                      donationProgramsFuture =
                          authService.getDonationPrograms();
                    });
                  },
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

        final programs = snapshot.data ?? [];

        if (programs.isEmpty) {
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

        final program = programs.firstWhere(
          (item) => item.isEmergency,
          orElse: () => programs.first,
        );

        final double progress = program.targetAmount == 0
            ? 0
            : (program.collectedAmount / program.targetAmount)
                .clamp(0.0, 1.0);

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
                      'Terkumpul: ${formatRupiah(program.collectedAmount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'intersemibold',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    'Target: ${formatRupiah(program.targetAmount)}',
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
                          builder: (context) => DonationDetailView(program: program),
                        ),
                      );

                      if (!mounted) return;

                      setState(() {
                        donationProgramsFuture = authService.getDonationPrograms();
                      });
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng fallbackLocation = const LatLng(-6.2088, 106.8456);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $userName',
                style: const TextStyle(
                  fontSize: 30,
                  fontFamily: 'jakartaextrabold',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Status lingkungan sekitar Anda terpantau\naman hari ini.',
                style: TextStyle(
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
                        initialCenter: currentLocation ?? fallbackLocation,
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
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.floodcare_mobile',
                        ),
                        if (currentLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 34,
                                ),
                              ),
                            ],
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
                              color: Colors.black.withOpacity(0.08),
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
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Stack(
                        children: [
                          Text(
                            'Pantauan Wilayah\n$wilayahText',
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
                            'Pantauan Wilayah\n$wilayahText',
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

                    if (isLoadingLocation)
                      Container(
                        color: Colors.black.withOpacity(0.15),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),

                    if (!isLoadingLocation && locationError != null)
                      Container(
                        color: Colors.black.withOpacity(0.20),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          locationError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'intermedium',
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ...laporanList.map(_buildLaporanCard),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildEduCard(
                      backgroundColor: const Color(0xFFE6F3E8),
                      iconColor: const Color(0xFF6BCB77),
                      badgeColor: const Color(0xFFDDF7E3),
                      title: 'Tips evakuasi saat banjir bandang',
                      subtitle: 'Artikel • 3 menit baca',
                      icon: Icons.description_outlined,
                      badgeText: 'BARU',
                    ),
                    const SizedBox(width: 14),
                    _buildEduCard(
                      backgroundColor: const Color(0xFFFFEFE2),
                      iconColor: const Color(0xFFF28C28),
                      badgeColor: const Color(0xFFFFF1E6),
                      title: 'Cara menghadapi bencana banjir',
                      subtitle: 'Video • 4:15 menit',
                      icon: Icons.play_circle_outline_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildDonasiCard(context),
            ],
          ),
        ),
      ),
    );
  }
}