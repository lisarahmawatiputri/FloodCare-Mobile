import 'package:floodcare_mobile/services/auth_service.dart';
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
  final AuthService authService = AuthService();

  final otpControllers = List.generate(4, (_) => TextEditingController());

  bool isLoading = false;

  String getOtp() {
    return otpControllers.map((e) => e.text).join();
  }

  Future<void> handleVerifyOtp() async {
    FocusScope.of(context).unfocus();

    final otp = getOtp();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP harus 4 digit')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordView(
            email: widget.email,
            otp: otp,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
            borderSide: BorderSide(color: grayhint, width: 1.3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.81),
            borderSide: BorderSide(color: grayhint, width: 1.8),
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
    for (var c in otpControllers) {
      c.dispose();
    }
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
                onTap: isLoading ? null : handleVerifyOtp,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      isLoading ? "Checking..." : "Verify OTP",
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
                    onTap: () async {
                      await authService.forgotPassword(email: widget.email);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("OTP dikirim ulang")),
                      );
                    },
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