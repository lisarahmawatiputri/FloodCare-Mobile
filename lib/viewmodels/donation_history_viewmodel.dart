import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:floodcare_mobile/models/donation_history_model.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonationHistoryViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isCheckingStatus = false;
  String? errorMessage;

  List<DonationHistory> histories = [];

  String get _baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token') ??
        prefs.getString('auth_token') ??
        prefs.getString('access_token');
  }

  Map<String, String> _headers(String? token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchDonationHistory() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/donations/history'),
        headers: _headers(token),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final rawData = decoded is Map<String, dynamic>
            ? decoded['data'] ?? decoded['donations'] ?? decoded['history']
            : decoded;

        if (rawData is List) {
          histories = rawData
              .whereType<Map>()
              .map(
                (item) => DonationHistory.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        } else {
          histories = [];
        }
      } else {
        errorMessage = decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? 'Gagal memuat riwayat donasi'
            : 'Gagal memuat riwayat donasi';
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPaymentStatus({
    required int donationId,
  }) async {
    try {
      isCheckingStatus = true;
      notifyListeners();

      final token = await _getToken();

      await http.get(
        Uri.parse('$_baseUrl/donations/$donationId/check-status'),
        headers: _headers(token),
      );

      await fetchDonationHistory();
    } catch (_) {
      await fetchDonationHistory();
    } finally {
      isCheckingStatus = false;
      notifyListeners();
    }
  }

  String formatRupiah(int value) {
    final number = value.toString();
    final buffer = StringBuffer();

    int count = 0;

    for (int i = number.length - 1; i >= 0; i--) {
      buffer.write(number[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return 'Rp${buffer.toString().split('').reversed.join()}';
  }

  String formatDate(String value) {
    if (value.trim().isEmpty) return '-';

    try {
      final date = DateTime.parse(value).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return value;
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'capture':
      case 'paid':
      case 'success':
      case 'berhasil':
        return const Color(0xFF16A34A);

      case 'pending':
      case 'menunggu':
      case 'unpaid':
      case 'belum_bayar':
        return const Color(0xFFFF6A00);

      case 'expire':
      case 'expired':
      case 'kedaluwarsa':
        return const Color(0xFF6B7280);

      case 'cancel':
      case 'cancelled':
      case 'canceled':
      case 'deny':
      case 'failed':
      case 'gagal':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFF6B7280);
    }
  }
}