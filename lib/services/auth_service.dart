import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  String get baseUrl => ApiConfig.baseUrl;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '781367234018-gotkmg4astilmaltbplja7agcdecgigh.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      await _saveToken(data['token']);
      await updateFcmToken();
      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }
  Future<void> updateFcmToken() async {
  final token = await getToken();

  if (token == null || token.isEmpty) {
    return;
  }

  final fcmToken = await FirebaseMessaging.instance.getToken();

  if (fcmToken == null || fcmToken.isEmpty) {
    return;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fcm-token'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'fcm_token': fcmToken,
    }),
  );

  if (response.statusCode != 200) {
    final data = _decodeResponse(response);
    throw Exception(_extractErrorMessage(data));
  }
}
  Future<Map<String, dynamic>> updateProfilePhoto({
  required File photo,
    }) async {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/photo'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_profil',
          photo.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(_extractErrorMessage(data));
    }
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login Google dibatalkan');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      debugPrint('GOOGLE EMAIL: ${googleUser.email}');
      debugPrint('GOOGLE NAME: ${googleUser.displayName}');
      debugPrint('GOOGLE ID TOKEN: $idToken');
      debugPrint('GOOGLE ACCESS TOKEN: ${googleAuth.accessToken}');

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Gagal mendapatkan ID Token Google. Cek Web Client ID.',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: _jsonHeaders(),
        body: jsonEncode({
          'id_token': idToken,
        }),
      );

      final data = _decodeResponse(response);

      debugPrint('LARAVEL STATUS: ${response.statusCode}');
      debugPrint('LARAVEL RESPONSE: $data');

      if (response.statusCode == 200) {
        await _saveToken(data['token']);
        await updateFcmToken();
        return data;
      }

      throw Exception(_extractErrorMessage(data));
    } catch (e) {
      debugPrint('GOOGLE LOGIN ERROR: $e');
      rethrow;
    }
    
  }

  Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String email,
    required String noTelepon,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'nama_lengkap': namaLengkap,
        'email': email,
        'no_telepon': noTelepon,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }

      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<Map<String, dynamic>> getUser() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }
  Future<Map<String, dynamic>> createDonationPayment({
  required int programDonasiId,
  required int amount,
  String? pesan,
  bool isAnonymous = false,
}) async {
  final token = await getToken();

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

  if (response.statusCode == 200) {
    return data;
  }

  throw Exception(_extractErrorMessage(data));
}

  Future<String> getUserName() async {
    final data = await getUser();
    return data['user']?['nama_lengkap'] ?? 'User';
  }
  Future<Map<String, dynamic>> getCurrentUser() async {
    final data = await getUser();

    if (data['user'] != null) {
      return data['user'];
    }

    return data;
}
  Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }

    await googleSignOut();
    await clearToken();
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(dynamic token) async {
    if (token == null) {
      throw Exception('Token dari server kosong');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token.toString());
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> _jsonHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
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
  Future<void> verifyCurrentPassword({
  required String currentPassword,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    throw Exception('Token login tidak ditemukan. Silakan login ulang.');
  }

  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/verify-password'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'current_password': currentPassword,
    }),
  );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return;
    }

    if (body is Map<String, dynamic>) {
      if (body['errors'] != null) {
        final errors = body['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }

      throw Exception(body['message'] ?? 'Password lama tidak valid');
    }

    throw Exception('Password lama tidak valid');
  }
    Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token login tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(_extractErrorMessage(data));
  }
    Future<Map<String, dynamic>> resetPassword({
      required String email,
      required String otp,
      required String password,
      required String passwordConfirmation,
    }) async {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: _jsonHeaders(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(_extractErrorMessage(data));
    }
    Future<List<DonationProgram>> getDonationPrograms() async {
  final response = await http.get(
    Uri.parse('$baseUrl/program-donasi'),
    headers: {
      'Accept': 'application/json',
    },
  );

  final data = _decodeResponse(response);

  if (response.statusCode == 200) {
    final List list = data['data'];
    return list.map((e) => DonationProgram.fromJson(e)).toList();
  }

  throw Exception(_extractErrorMessage(data));
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