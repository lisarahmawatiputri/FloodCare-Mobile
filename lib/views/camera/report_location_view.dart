import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/report_viewmodel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportLocationView extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String waterLevel;
  final String? manualWaterLevel;

  const ReportLocationView({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.waterLevel,
    this.manualWaterLevel,
  });

  @override
  State<ReportLocationView> createState() => _ReportLocationViewState();
}

class _ReportLocationViewState extends State<ReportLocationView> {
  final MapController mapController = MapController();
  final TextEditingController locationNoteController = TextEditingController();
  final ReportViewModel reportViewModel = ReportViewModel();

  LatLng? selectedLocation;

  bool isLoadingLocation = true;
  bool isSubmitting = false;
  String? locationError;

  String detectedAddress = 'Memuat alamat...';
  String detectedRegion = 'Memuat wilayah...';

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    locationNoteController.dispose();
    super.dispose();
  }
int? parseWaterLevelCm() {
  final manual = widget.manualWaterLevel?.trim();

  if (manual != null && manual.isNotEmpty) {
    return int.tryParse(manual);
  }

  switch (widget.waterLevel) {
    case '<30':
      return 20;

    case '30-80':
      return 55;

    case '80-150':
      return 115;

    case '>150':
      return 160;

    default:
      return null;
  }
}

  Future<void> getCurrentLocation() async {
    try {
      setState(() {
        isLoadingLocation = true;
        locationError = null;
      });

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
          locationError = 'GPS belum aktif';
          detectedAddress = 'Lokasi tidak tersedia';
          detectedRegion = 'Aktifkan GPS untuk mendeteksi lokasi';
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
          detectedAddress = 'Lokasi ditolak';
          detectedRegion = 'Berikan izin lokasi untuk melanjutkan';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
          locationError = 'Izin lokasi ditolak permanen';
          detectedAddress = 'Lokasi tidak tersedia';
          detectedRegion = 'Ubah izin lokasi dari pengaturan aplikasi';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      final addressData = await getAddressFromLatLng(latLng);

      if (!mounted) return;

      setState(() {
        selectedLocation = latLng;
        detectedAddress = addressData['address'] ?? 'Alamat tidak diketahui';
        detectedRegion = addressData['region'] ?? 'Wilayah tidak diketahui';
        isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && selectedLocation != null) {
          mapController.move(selectedLocation!, 16);
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingLocation = false;
        locationError = 'Gagal mengambil lokasi';
        detectedAddress = 'Alamat tidak diketahui';
        detectedRegion = 'Wilayah tidak diketahui';
      });
    }
  }

 Future<Map<String, String>> getAddressFromLatLng(LatLng latLng) async {
  try {
    final placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    if (placemarks.isEmpty) {
      return {
        'address': 'Alamat tidak diketahui',
        'region': 'Wilayah tidak diketahui',
      };
    }

    final place = placemarks.first;

    bool isPlusCode(String text) {
      return RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,}').hasMatch(text.trim());
    }

    String? clean(String? value) {
      if (value == null) return null;

      final text = value.trim();

      if (text.isEmpty) return null;
      if (isPlusCode(text)) return null;

      return text;
    }

    final street = clean(place.street);
    final name = clean(place.name);
    final subLocality = clean(place.subLocality);
    final locality = clean(place.locality);
    final subAdministrativeArea = clean(place.subAdministrativeArea);
    final administrativeArea = clean(place.administrativeArea);

    final address = [
      street,
      name,
      subLocality,
    ].whereType<String>().toSet().join(', ');

    final region = [
      locality,
      subAdministrativeArea,
      administrativeArea,
    ].whereType<String>().toSet().join(', ');

    return {
      'address': address.isEmpty ? 'Alamat tidak diketahui' : address,
      'region': region.isEmpty ? 'Wilayah tidak diketahui' : region,
    };
  } catch (_) {
    return {
      'address': 'Alamat tidak diketahui',
      'region': 'Wilayah tidak diketahui',
    };
  }
}
  void moveToCurrentLocation() {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum tersedia'),
        ),
      );
      return;
    }

    mapController.move(selectedLocation!, 16);
  }

  Future<void> handleSubmitReport() async {
    if (isSubmitting) return;

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum tersedia'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token login tidak ditemukan. Silakan login ulang.'),
        ),
      );
      return;
    }

    final tinggiBanjirCm = parseWaterLevelCm();

    if (tinggiBanjirCm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tinggi banjir tidak valid'),
        ),
      );
      return;
    }

    final photoFile = File(widget.imagePath);

    if (!await photoFile.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File foto laporan tidak ditemukan'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final alamatLokasiRaw = [
      detectedAddress,
      detectedRegion,
      locationNoteController.text.trim(),
    ].where((item) => item.isNotEmpty).join(', ');

    final alamatLokasi = alamatLokasiRaw.length > 255
        ? alamatLokasiRaw.substring(0, 255)
        : alamatLokasiRaw;

    final success = await reportViewModel.submitFloodReport(
      photo: photoFile,
      judul: widget.title,
      deskripsi: widget.description,
      latitude: selectedLocation!.latitude,
      longitude: selectedLocation!.longitude,
      alamatLokasi: alamatLokasi,
      tinggiBanjirCm: tinggiBanjirCm,
      token: token,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan banjir berhasil dikirim'),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reportViewModel.errorMessage ?? 'Gagal mengirim laporan',
          ),
        ),
      );
    }
  }

  Widget stepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          stepItem(
            number: '✓',
            label: 'UNGGAH',
            isActive: false,
            isDone: true,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 22),
              color: const Color(0xFFE5EAF0),
            ),
          ),
          stepItem(
            number: '✓',
            label: 'DETAIL',
            isActive: false,
            isDone: true,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 22),
              color: const Color(0xFFE5EAF0),
            ),
          ),
          stepItem(
            number: '3',
            label: 'LOKASI',
            isActive: true,
            isDone: false,
          ),
        ],
      ),
    );
  }

  Widget stepItem({
    required String number,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final activeColor = const Color(0xFFFF6A00);
    final inactiveBorder = const Color(0xFFDDE6EE);
    final inactiveText = const Color(0xFFB3BDC9);

    return Column(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive || isDone ? activeColor : inactiveBorder,
              width: 1.6,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'interbold',
                fontSize: isDone ? 20 : 15,
                color: isActive ? Colors.white : activeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'interbold',
            fontSize: 10,
            letterSpacing: 0.4,
            color: isActive || isDone ? activeColor : inactiveText,
          ),
        ),
      ],
    );
  }

  Widget mapSection() {
    final fallbackLocation = const LatLng(-8.1724, 113.7008);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 235,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: selectedLocation ?? fallbackLocation,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
                onTap: (tapPosition, point) async {
                  setState(() {
                    selectedLocation = point;
                    isLoadingLocation = true;
                  });

                  final addressData = await getAddressFromLatLng(point);

                  if (!mounted) return;

                  setState(() {
                    detectedAddress =
                        addressData['address'] ?? 'Alamat tidak diketahui';
                    detectedRegion =
                        addressData['region'] ?? 'Wilayah tidak diketahui';
                    isLoadingLocation = false;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                  userAgentPackageName: 'com.example.floodcare_mobile',
                  maxZoom: 22,
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 54,
                        height: 54,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFC62828),
                          size: 48,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (isLoadingLocation)
              Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            Positioned(
              right: 14,
              bottom: 14,
              child: GestureDetector(
                onTap: moveToCurrentLocation,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFFFF6A00),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFFFD9C2),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFFF6A00),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALAMAT TERDETEKSI',
                  style: TextStyle(
                    fontFamily: 'interbold',
                    fontSize: 11,
                    letterSpacing: 0.4,
                    color: Color(0xFFFF6A00),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detectedAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'jakartabold',
                    fontSize: 18,
                    color: Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detectedRegion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'intermedium',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        
        ],
      ),
    );
  }

  Widget noteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan lokasi (opsional)',
          style: TextStyle(
            fontFamily: 'interbold',
            fontSize: 14,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: locationNoteController,
          maxLines: 3,
          style: const TextStyle(
            fontFamily: 'interregular',
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Di depan gerbang kompleks, samping minimarket...',
            hintStyle: const TextStyle(
              fontFamily: 'interregular',
              fontSize: 14,
              height: 1.4,
              color: Color(0xFFA8B3C3),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Color(0xFFFFD9C2),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Color(0xFFFF6A00),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget infoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFD9A8),
          width: 1.2,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFF6A00),
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lokasi ini akan digunakan untuk menandai titik banjir agar tim petugas dan warga sekitar dapat memantau area yang terdampak secara akurat.',
              style: TextStyle(
                fontFamily: 'interbold',
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF7A4B2A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton() {
    return GestureDetector(
      onTap: isSubmitting ? null : handleSubmitReport,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: orangeGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A00).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Text(
                  'Kirim Laporan',
                  style: TextStyle(
                    fontFamily: 'interbold',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              stepIndicator(),
              const SizedBox(height: 28),
              const Text(
                'Konfirmasi Lokasi',
                style: TextStyle(
                  fontFamily: 'jakartabold',
                  fontSize: 21,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pastikan titik lokasi kejadian sudah sesuai pada peta.',
                style: TextStyle(
                  fontFamily: 'intermedium',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 22),
              mapSection(),
              const SizedBox(height: 14),
              addressCard(),
              const SizedBox(height: 28),
              noteInput(),
              const SizedBox(height: 22),
              infoBox(),
              const SizedBox(height: 42),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }
}