import 'dart:convert';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/detail_laporan_model.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;

class LaporanService {
  final AuthService _authService = AuthService();

  Future<DetailLaporanModel> getDetailLaporan(int laporanId) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/laporan-banjir/$laporanId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      if (data == null) {
        throw Exception('Data laporan kosong dari server');
      }

      return DetailLaporanModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Gagal memuat detail laporan (${response.statusCode})');
  }
}