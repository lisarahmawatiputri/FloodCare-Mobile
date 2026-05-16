import 'package:flutter/material.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/views/auth/login_view.dart';

class LogoutConfirmView extends StatefulWidget {
  const LogoutConfirmView({super.key});

  @override
  State<LogoutConfirmView> createState() => _LogoutConfirmViewState();
}

class _LogoutConfirmViewState extends State<LogoutConfirmView> {
  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> handleLogout() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    await authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
      (route) => false,
    );
  }

  void handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC6CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF1E2D),
                  size: 40,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2933),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda akan log out dari akun FloodCare. Data dan\nprogress Anda akan tetap tersimpan dengan aman.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1E2D),
                    disabledBackgroundColor: const Color(0xFFFF8A93),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}