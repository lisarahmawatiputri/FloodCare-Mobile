import 'package:flutter/material.dart';
import 'package:floodcare_mobile/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? currentUser;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  String _cleanError(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      _setError('Email dan password wajib diisi');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _authService.login(
        email: cleanEmail,
        password: cleanPassword,
      );

      return true;
    } catch (e) {
      _setError(_cleanError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.loginWithGoogle();

      return true;
    } catch (e) {
      _setError(_cleanError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String namaLengkap,
    required String email,
    required String noTelepon,
    required String password,
    required String passwordConfirmation,
  }) async {
    final cleanNama = namaLengkap.trim();
    final cleanEmail = email.trim();
    final cleanTelepon = noTelepon.trim();
    final cleanPassword = password.trim();
    final cleanConfirm = passwordConfirmation.trim();

    if (cleanNama.isEmpty ||
        cleanEmail.isEmpty ||
        cleanTelepon.isEmpty ||
        cleanPassword.isEmpty ||
        cleanConfirm.isEmpty) {
      _setError('Semua field wajib diisi');
      return false;
    }

    if (cleanPassword != cleanConfirm) {
      _setError('Konfirmasi password tidak cocok');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _authService.register(
        namaLengkap: cleanNama,
        email: cleanEmail,
        noTelepon: cleanTelepon,
        password: cleanPassword,
        passwordConfirmation: cleanConfirm,
      );

      return true;
    } catch (e) {
      _setError(_cleanError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> forgotPassword({
    required String email,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      _setError('Email wajib diisi');
      return null;
    }

    try {
      _setLoading(true);
      _setError(null);

      final data = await _authService.forgotPassword(email: cleanEmail);

      return data['message']?.toString() ?? 'Kode OTP berhasil dikirim ke email';
    } catch (e) {
      _setError(_cleanError(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  bool verifyOtp({
    required String otp,
  }) {
    final cleanOtp = otp.trim();

    if (cleanOtp.length != 4) {
      _setError('OTP harus 4 digit');
      return false;
    }

    _setError(null);
    return true;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final cleanPassword = password.trim();
    final cleanConfirm = passwordConfirmation.trim();

    if (cleanPassword.isEmpty || cleanConfirm.isEmpty) {
      _setError('Semua field wajib diisi');
      return false;
    }

    if (cleanPassword.length < 8) {
      _setError('Password minimal 8 karakter');
      return false;
    }

    if (cleanPassword != cleanConfirm) {
      _setError('Password tidak sama');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(
        email: email,
        otp: otp,
        password: cleanPassword,
        passwordConfirmation: cleanConfirm,
      );

      return true;
    } catch (e) {
      _setError(_cleanError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      _setLoading(true);
      _setError(null);

      currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError(_cleanError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.logout();
      currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(_cleanError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getToken() {
    return _authService.getToken();
  }
}