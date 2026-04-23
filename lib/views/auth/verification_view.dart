import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/auth/forget_password_view.dart';
import 'package:floodcare_mobile/views/auth/reset_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  bool isHide = true;
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
                      builder: (context) => ForgetPasswordView(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: SvgPicture.asset('assets/icons/BackAuth.svg'),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: const Text(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: const Text(
                  'Enter the verification code to confirm your identity.',
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
                children: [
                  SizedBox(
                    height: 64.88,
                    width: 64.88,
                    child: TextField(
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: TextStyle(
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
                  ),
                  SizedBox(
                    height: 64.88,
                    width: 64.88,
                    child: TextField(
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: TextStyle(
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
                  ),
                  SizedBox(
                    height: 64.88,
                    width: 64.88,
                    child: TextField(
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: TextStyle(
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
                  ),
                  SizedBox(
                    height: 64.88,
                    width: 64.88,
                    child: TextField(
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: TextStyle(
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
                  ),
                ],
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordView()),
                  );
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Send Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight(800),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't get the code?",
                        style: TextStyle(
                          fontFamily: 'intermedium',
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6), 
                      GestureDetector(
                        onTap: () {
                          // TODO: resend OTP logic
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
