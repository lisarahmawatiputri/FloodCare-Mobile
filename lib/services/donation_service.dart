import 'dart:convert';

import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DonationService {
  String get baseUrl => ApiConfig.baseUrl;

  Future<List<DonationProgram>> getDonationPrograms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/program-donasi'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      final List list = data['data'] ?? [];
      return list.map((item) => DonationProgram.fromJson(item)).toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<Map<String, dynamic>> createDonationPayment({
    required int programDonasiId,
    required int amount,
    String? pesan,
    bool isAnonymous = false,
  }) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/donations/pay'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'program_donasi_id': programDonasiId,
        'amount': amount,
        'pesan': pesan,
        'is_anonymous': isAnonymous,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {
        'message': 'Response server kosong',
      };
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'message': response.body,
      };
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['errors'] != null && data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;

        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstValue = errors[firstKey];

          if (firstValue is List && firstValue.isNotEmpty) {
            return firstValue.first.toString();
          }

          return firstValue.toString();
        }
      }
    }

    return 'Terjadi kesalahan';
  }
}