import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/models/edukasi_article_model.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:floodcare_mobile/models/flood_report_model.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/services/donation_service.dart';
import 'package:floodcare_mobile/services/edukasi_service.dart';
import 'package:floodcare_mobile/services/report_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DonationService _donationService = DonationService();
  final ReportService _reportService = ReportService();
  final EdukasiService _edukasiService = EdukasiService();

  LatLng? currentLocation;
  bool isLoadingLocation = true;
  String? locationError;

  String wilayahText = 'Memuat lokasi...';
  String userName = 'User';

  bool isLoadingDonation = false;
  String? donationError;
  List<DonationProgram> donationPrograms = [];

  bool isLoadingReports = false;
  String? reportError;
  List<FloodReport> floodReports = [];

  bool isLoadingLatestArticle = false;
  String? latestArticleError;
  EdukasiArticle? latestArticle;

  bool isLoadingLatestVideo = false;
  String? latestVideoError;
  EdukasiVideo? latestVideo;

  Future<void> initHome() async {
    await Future.wait([
      loadUserName(),
      getCurrentLocation(),
      fetchDonationPrograms(),
      fetchFloodReports(),
      fetchLatestArticle(),
      fetchLatestVideo(),
    ]);
  }

  Future<void> refreshHome() async {
    await Future.wait([
      getCurrentLocation(),
      fetchDonationPrograms(),
      fetchFloodReports(),
      fetchLatestArticle(),
      fetchLatestVideo(),
    ]);
  }

  Future<void> loadUserName() async {
    try {
      final name = await _authService.getUserName();
      userName = name;
      notifyListeners();
    } catch (_) {
      userName = 'User';
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation = true;
      locationError = null;
      notifyListeners();

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        isLoadingLocation = false;
        locationError = 'GPS belum aktif';
        wilayahText = 'Lokasi tidak tersedia';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        isLoadingLocation = false;
        locationError = 'Izin lokasi ditolak';
        wilayahText = 'Lokasi ditolak';
        notifyListeners();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingLocation = false;
        locationError = 'Izin lokasi ditolak permanen';
        wilayahText = 'Lokasi tidak tersedia';
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      final userLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      final wilayah = await getWilayahName(
        position.latitude,
        position.longitude,
      );

      currentLocation = userLatLng;
      wilayahText = wilayah;
      isLoadingLocation = false;
      locationError = null;
      notifyListeners();
    } catch (_) {
      isLoadingLocation = false;
      locationError = 'Gagal mengambil lokasi';
      wilayahText = 'Lokasi tidak diketahui';
      notifyListeners();
    }
  }

  Future<String> getWilayahName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return 'Wilayah Tidak Diketahui';
      }

      final place = placemarks.first;

      final area = place.subAdministrativeArea?.trim().isNotEmpty == true
          ? place.subAdministrativeArea!.trim()
          : null;

      final city = place.locality?.trim().isNotEmpty == true
          ? place.locality!.trim()
          : null;

      final district = place.subLocality?.trim().isNotEmpty == true
          ? place.subLocality!.trim()
          : null;

      final adminArea = place.administrativeArea?.trim().isNotEmpty == true
          ? place.administrativeArea!.trim()
          : null;

      return area ?? city ?? district ?? adminArea ?? 'Wilayah Tidak Diketahui';
    } catch (_) {
      return 'Wilayah Tidak Diketahui';
    }
  }

  Future<void> fetchDonationPrograms() async {
    try {
      isLoadingDonation = true;
      donationError = null;
      notifyListeners();

      donationPrograms = await _donationService.getDonationPrograms();
    } catch (e) {
      donationError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingDonation = false;
      notifyListeners();
    }
  }

  Future<void> fetchFloodReports() async {
    try {
      isLoadingReports = true;
      reportError = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token login tidak ditemukan');
      }

      floodReports = await _reportService.fetchFloodReports(
        token: token,
      );
    } catch (e) {
      reportError = e.toString().replaceFirst('Exception: ', '');
      floodReports = [];
    } finally {
      isLoadingReports = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestArticle() async {
    try {
      isLoadingLatestArticle = true;
      latestArticleError = null;
      notifyListeners();

      latestArticle = await _edukasiService.fetchLatestArticle();
    } catch (e) {
      latestArticleError = e.toString().replaceFirst('Exception: ', '');
      latestArticle = null;
    } finally {
      isLoadingLatestArticle = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestVideo() async {
    try {
      isLoadingLatestVideo = true;
      latestVideoError = null;
      notifyListeners();

      latestVideo = await _edukasiService.fetchLatestVideo();
    } catch (e) {
      latestVideoError = e.toString().replaceFirst('Exception: ', '');
      latestVideo = null;
    } finally {
      isLoadingLatestVideo = false;
      notifyListeners();
    }
  }

  DonationProgram? get featuredDonationProgram {
    if (donationPrograms.isEmpty) {
      return null;
    }

    return donationPrograms.firstWhere(
      (item) => item.isEmergency,
      orElse: () => donationPrograms.first,
    );
  }

  FloodReport? get latestFloodReport {
    if (floodReports.isEmpty) {
      return null;
    }

    return floodReports.first;
  }

  bool get hasHighRiskFloodReport {
    return floodReports.any((report) {
      final risk = report.riskLevel.toLowerCase();
      return risk == 'tinggi' || risk == 'sangat_tinggi';
    });
  }

  String get environmentStatusText {
    if (isLoadingReports) {
      return 'Memuat status lingkungan sekitar Anda...';
    }

    if (reportError != null) {
      return 'Status lingkungan sekitar belum dapat dimuat.';
    }

    if (floodReports.isEmpty) {
      return 'Status lingkungan sekitar Anda terpantau\naman hari ini.';
    }

    if (hasHighRiskFloodReport) {
      return 'Terdapat laporan banjir berisiko tinggi\ndi sekitar wilayah.';
    }

    return 'Status lingkungan sekitar Anda terpantau\naman hari ini.';
  }

  String get latestFloodSubtitle {
    final report = latestFloodReport;

    if (report == null) {
      return 'Belum ada laporan banjir terbaru';
    }

    final risk = report.riskLevel.replaceAll('_', ' ');

    if (report.waterLevelCm > 0) {
      return 'Ketinggian ${report.waterLevelCm} cm • Risiko $risk';
    }

    return 'Risiko banjir $risk';
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  double donationProgress(DonationProgram program) {
    if (program.targetAmount <= 0) {
      return 0;
    }

    return (program.collectedAmount / program.targetAmount).clamp(0.0, 1.0);
  }
}