import 'package:flutter/material.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/profile/change_password_view.dart';

class VerifyPasswordView extends StatefulWidget {
  const VerifyPasswordView({super.key});

  @override
  State<VerifyPasswordView> createState() => _VerifyPasswordViewState();
}

class _VerifyPasswordViewState extends State<VerifyPasswordView> {
  final AuthService authService = AuthService();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> handleVerifyPassword() async {
    if (isLoading) return;

    final currentPassword = passwordController.text.trim();

    if (currentPassword.isEmpty) {
      showMessage('Password lama wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.verifyCurrentPassword(
        currentPassword: currentPassword,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangePasswordView(
            currentPassword: currentPassword,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Widget passwordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontFamily: 'interbold',
            fontSize: 13,
            letterSpacing: 0.7,
            color: Color(0xFF7477B8),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => handleVerifyPassword(),
          style: const TextStyle(
            fontFamily: 'intersemibold',
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan password lama',
            hintStyle: const TextStyle(
              fontFamily: 'intermedium',
              fontSize: 13,
              color: Color(0xFFB8B8B8),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFFB8B8B8),
              size: 21,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFFB8B8B8),
                size: 21,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: Color(0xFF8F969C),
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: Color(0xFFFF6A00),
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget verifyButton() {
    return GestureDetector(
      onTap: isLoading ? null : handleVerifyPassword,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: orangeGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A00).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
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
                  'Verifikasi',
                  style: TextStyle(
                    fontFamily: 'interbold',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 52),
              const Center(
                child: Text(
                  'Ganti Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'jakartabold',
                    fontSize: 28,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Masukkan password saat ini untuk melanjutkan ke\nlangkah selanjutnya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'intermedium',
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 44),
              passwordInput(),
              const SizedBox(height: 26),
              verifyButton(),
            ],
          ),
        ),
      ),
    );
  }
}