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


  String? _validatePassword({
    required String password,
    required String confirmation,
    String confirmationError = 'Password tidak sama',
  }) {
    if (password.isEmpty || confirmation.isEmpty) {
      return 'Semua field wajib diisi';
    }

    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus mengandung huruf besar';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password harus mengandung huruf kecil';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password harus mengandung simbol';
    }

    if (password != confirmation) {
      return confirmationError;
    }

    return null;
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

    final passwordError = _validatePassword(
      password: cleanPassword,
      confirmation: cleanConfirm,
    );

    if (passwordError != null) {
      _setError(passwordError);
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

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();

    if (cleanEmail.isEmpty) {
      _setError('Email tidak ditemukan');
      return false;
    }

    if (cleanOtp.isEmpty) {
      _setError('Kode OTP wajib diisi');
      return false;
    }

    if (cleanOtp.length != 4) {
      _setError('OTP harus 4 digit');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _authService.verifyOtp(
        email: cleanEmail,
        otp: cleanOtp,
      );

      return true;
    } catch (e) {
      _setError(_cleanError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    final cleanConfirm = passwordConfirmation.trim();

    if (cleanEmail.isEmpty) {
      _setError('Email tidak ditemukan');
      return false;
    }

    final passwordError = _validatePassword(
      password: cleanPassword,
      confirmation: cleanConfirm,
    );

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(
        email: cleanEmail,
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final cleanCurrent = currentPassword.trim();
    final cleanNew = newPassword.trim();
    final cleanConfirm = confirmPassword.trim();

    if (cleanCurrent.isEmpty || cleanNew.isEmpty || cleanConfirm.isEmpty) {
      _setError('Semua field wajib diisi');
      return false;
    }

    final passwordError = _validatePassword(
      password: cleanNew,
      confirmation: cleanConfirm,
      confirmationError: 'Konfirmasi password tidak sama',
    );

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _authService.changePassword(
        currentPassword: cleanCurrent,
        newPassword: cleanNew,
        confirmPassword: cleanConfirm,
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