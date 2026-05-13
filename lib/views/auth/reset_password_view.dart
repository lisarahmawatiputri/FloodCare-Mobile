import 'package:floodcare_mobile/viewmodels/auth_viewmodel.dart';
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

  final AuthViewModel authViewModel = AuthViewModel();

  bool isHide = true;

  @override
  void initState() {
    super.initState();

    authViewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> handleResetPassword() async {
    FocusScope.of(context).unfocus();

    final success = await authViewModel.resetPassword(
      email: widget.email,
      otp: widget.otp,
      password: passwordController.text,
      passwordConfirmation: confirmController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.errorMessage ?? 'Gagal reset password',
          ),
        ),
      );
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
            isHide ? 'assets/icons/Eyeoff.svg' : 'assets/icons/Eyeon.svg',
            width: 20,
            height: 17,
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.srcIn,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
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
    authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 40,
            left: 27,
            right: 27,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Reset Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'jakartabold',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create a new password for your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 44),

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
                onTap: authViewModel.isLoading ? null : handleResetPassword,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      authViewModel.isLoading ? "Loading..." : "Continue",
                      style: const TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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