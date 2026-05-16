import 'dart:convert';
import 'dart:io';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/flood_report_model.dart';
import 'package:http/http.dart' as http;

class ReportService {
  Future<Map<String, dynamic>> createFloodReport({
    required File photo,
    required String judul,
    required String deskripsi,
    required double latitude,
    required double longitude,
    required String alamatLokasi,
    required int tinggiBanjirCm,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/laporan-banjir');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['alamat_lokasi'] = alamatLokasi;
    request.fields['tinggi_banjir_cm'] = tinggiBanjirCm.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto_laporan',
        photo.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final dynamic body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (body is Map<String, dynamic>) {
        return body;
      }

      return {
        'message': 'Laporan banjir berhasil dikirim',
        'data': body,
      };
    }

    if (body is Map<String, dynamic>) {
      throw Exception(
        body['message'] ?? 'Gagal mengirim laporan banjir',
      );
    }

    throw Exception('Gagal mengirim laporan banjir');
  }

  Future<List<FloodReport>> fetchFloodReports({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/laporan-banjir');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final dynamic body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      final List data;

      if (body is List) {
        data = body;
      } else if (body is Map<String, dynamic>) {
        data = body['data'] is List ? body['data'] : [];
      } else {
        data = [];
      }

      return data
          .map((item) => FloodReport.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (body is Map<String, dynamic>) {
      throw Exception(
        body['message'] ?? 'Gagal mengambil laporan banjir',
      );
    }

    throw Exception('Gagal mengambil laporan banjir');
  }
}