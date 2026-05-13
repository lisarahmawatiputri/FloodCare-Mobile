import 'package:floodcare_mobile/viewmodels/auth_viewmodel.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/auth/forget_password_view.dart';
import 'package:floodcare_mobile/views/auth/reset_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerificationView extends StatefulWidget {
  final String email;

  const VerificationView({super.key, required this.email});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final AuthViewModel authViewModel = AuthViewModel();

  final otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();

    authViewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String getOtp() {
    return otpControllers.map((e) => e.text).join();
  }

  Future<void> handleVerifyOtp() async {
    FocusScope.of(context).unfocus();

    final otp = getOtp();

    final success = authViewModel.verifyOtp(
      otp: otp,
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordView(
            email: widget.email,
            otp: otp,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.errorMessage ?? 'OTP tidak valid',
          ),
        ),
      );
    }
  }

  Future<void> handleResendOtp() async {
    final message = await authViewModel.forgotPassword(
      email: widget.email,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? authViewModel.errorMessage ?? 'Gagal mengirim ulang OTP',
        ),
      ),
    );
  }

  Widget otpBox(int index) {
    return SizedBox(
      height: 64.88,
      width: 64.88,
      child: TextField(
        controller: otpControllers[index],
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).nextFocus();
          }

          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        style: const TextStyle(
          fontFamily: 'intermedium',
          fontSize: 25,
          color: Colors.black,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.81),
            borderSide: BorderSide(
              color: grayhint,
              width: 1.3,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.81),
            borderSide: BorderSide(
              color: grayhint,
              width: 1.8,
            ),
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(1000),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPasswordView(),
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
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Verification Code',
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
                  'Enter the verification code sent to your email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'interregular',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 44),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, otpBox),
              ),

              const SizedBox(height: 36),

              GestureDetector(
                onTap: authViewModel.isLoading ? null : handleVerifyOtp,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      authViewModel.isLoading ? "Checking..." : "Verify OTP",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't get the code?",
                    style: TextStyle(
                      fontFamily: 'intermedium',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: authViewModel.isLoading ? null : handleResendOtp,
                    child: Text(
                      "Resend",
                      style: TextStyle(
                        fontFamily: 'intermedium',
                        fontSize: 12,
                        color: lightorange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}