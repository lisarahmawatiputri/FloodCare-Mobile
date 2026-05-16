import 'dart:io';
import 'package:floodcare_mobile/services/report_service.dart';
import 'package:flutter/material.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> submitFloodReport({
    required File photo,
    required String judul,
    required String deskripsi,
    required double latitude,
    required double longitude,
    required String alamatLokasi,
    required int tinggiBanjirCm,
    required String token,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _reportService.createFloodReport(
        photo: photo,
        judul: judul,
        deskripsi: deskripsi,
        latitude: latitude,
        longitude: longitude,
        alamatLokasi: alamatLokasi,
        tinggiBanjirCm: tinggiBanjirCm,
        token: token,
      );

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
}