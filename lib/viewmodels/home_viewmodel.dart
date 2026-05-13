import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/services/donation_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DonationService _donationService = DonationService();

  LatLng? currentLocation;
  bool isLoadingLocation = true;
  String? locationError;

  String wilayahText = 'Memuat lokasi...';
  String userName = 'User';

  bool isLoadingDonation = false;
  String? donationError;
  List<DonationProgram> donationPrograms = [];

  Future<void> initHome() async {
    await Future.wait([
      loadUserName(),
      getCurrentLocation(),
      fetchDonationPrograms(),
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

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

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

  DonationProgram? get featuredDonationProgram {
    if (donationPrograms.isEmpty) {
      return null;
    }

    return donationPrograms.firstWhere(
      (item) => item.isEmergency,
      orElse: () => donationPrograms.first,
    );
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