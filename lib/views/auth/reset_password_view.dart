import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordView({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final AuthService authService = AuthService();

  bool isHide = true;
  bool isLoading = false;

  Future<void> handleResetPassword() async {
    FocusScope.of(context).unfocus();

    final password = passwordController.text;
    final confirm = confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await authService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        password: password,
        passwordConfirmation: confirm,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Password berhasil diubah')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget passwordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isHide,
      style: const TextStyle(
        fontFamily: 'interregular',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'interregular',
          fontSize: 14,
          color: grayhint,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 23, right: 11),
          child: SvgPicture.asset(
            'assets/icons/Password.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.srcIn,
            ),
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isHide = !isHide;
            });
          },
          icon: SvgPicture.asset(
            isHide
                ? 'assets/icons/Eyeoff.svg'
                : 'assets/icons/Eyeon.svg',
            width: 20,
            height: 17,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(27),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                'Reset Password',
                style: TextStyle(
                  fontFamily: 'jakartabold',
                  fontSize: 30,
                ),
              ),

              const SizedBox(height: 30),

              passwordField(
                controller: passwordController,
                hint: "Enter your password",
              ),

              const SizedBox(height: 20),

              passwordField(
                controller: confirmController,
                hint: "Confirm your password",
              ),

              const SizedBox(height: 36),

              GestureDetector(
                onTap: isLoading ? null : handleResetPassword,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      isLoading ? "Loading..." : "Continue",
                      style: const TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}