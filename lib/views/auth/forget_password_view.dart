import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/auth/login_view.dart';
import 'package:floodcare_mobile/views/auth/verification_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final emailController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> handleForgotPassword() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await authService.forgotPassword(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Kode OTP berhasil dikirim ke email',
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationView(
            email: email,
          ),
        ),
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(1000),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: SvgPicture.asset('assets/icons/BackAuth.svg'),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'jakartabold',
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'Reset your password quickly and securely to regain access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'interregular',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 44),

              Text(
                "Email Address",
                style: TextStyle(
                  fontFamily: "interbold",
                  fontSize: 12,
                  color: bluetext,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
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
                  fillColor: Colors.transparent,
                  filled: true,
                  hintText: "Enter your email",
                  hintStyle: TextStyle(
                    fontFamily: 'interregular',
                    fontSize: 14,
                    color: grayhint,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 23, right: 11),
                    child: SvgPicture.asset(
                      'assets/icons/Email.svg',
                      width: 20,
                      height: 20,
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
              ),

              const SizedBox(height: 36),

              GestureDetector(
                onTap: isLoading ? null : handleForgotPassword,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      isLoading ? "Sending..." : "Continue",
                      textAlign: TextAlign.center,
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