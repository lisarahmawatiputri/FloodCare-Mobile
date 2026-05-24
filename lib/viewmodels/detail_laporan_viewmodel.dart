import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/detail_laporan_model.dart';
import 'package:floodcare_mobile/services/laporan_service.dart';

class DetailLaporanViewModel extends ChangeNotifier {
  final LaporanService _laporanService = LaporanService();

  DetailLaporanModel? _detail;
  bool _isLoading = false;
  String? _errorMessage;

  DetailLaporanModel? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDetail(int laporanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _detail = await _laporanService.getDetailLaporan(laporanId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}