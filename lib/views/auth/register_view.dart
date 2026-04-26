import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool isHide = true;
  bool isHideConfirm = true;
  bool isLoading = false;

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noTeleponController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  Future<void> handleRegister() async {
    FocusScope.of(context).unfocus();

    if (namaController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        noTeleponController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.register(
        namaLengkap: namaController.text.trim(),
        email: emailController.text.trim(),
        noTelepon: noTeleponController.text.trim(),
        password: passwordController.text.trim(),
        passwordConfirmation: confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil, silakan login')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginView(),
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

  Widget buildInputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: "interbold",
        fontSize: 12,
        color: bluetext,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration buildInputDecoration({
    required String hintText,
    required String assetIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 20,
      ),
      fillColor: Colors.transparent,
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(
        fontFamily: 'interregular',
        fontSize: 14,
        color: grayhint,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 23, right: 11),
        child: SvgPicture.asset(
          assetIcon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.srcIn,
          ),
        ),
      ),
      suffixIcon: suffixIcon,
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
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noTeleponController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  padding: const EdgeInsets.all(1.0),
                  child: SvgPicture.asset('assets/icons/BackAuth.svg'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create Account!',
                style: TextStyle(
                  fontFamily: 'jakartabold',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Step into the FloodCare network.',
                style: TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 44),

              buildInputLabel("Full Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                style: const TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: buildInputDecoration(
                  hintText: "Enter your fullname",
                  assetIcon: 'assets/icons/User.svg',
                ),
              ),

              const SizedBox(height: 19),
              buildInputLabel("Email Address"),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: buildInputDecoration(
                  hintText: "Enter your email",
                  assetIcon: 'assets/icons/Email.svg',
                ),
              ),

              const SizedBox(height: 19),
              buildInputLabel("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: noTeleponController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: buildInputDecoration(
                  hintText: "Enter your phone number",
                  assetIcon: 'assets/icons/User.svg',
                ),
              ),

              const SizedBox(height: 19),
              buildInputLabel("Password"),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                obscureText: isHide,
                style: const TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: buildInputDecoration(
                  hintText: "Enter your password",
                  assetIcon: 'assets/icons/Password.svg',
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
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
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 19),
              buildInputLabel("Confirm Password"),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: isHideConfirm,
                style: const TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: buildInputDecoration(
                  hintText: "Confirm your password",
                  assetIcon: 'assets/icons/Password.svg',
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        isHideConfirm = !isHideConfirm;
                      });
                    },
                    icon: SvgPicture.asset(
                      isHideConfirm
                          ? 'assets/icons/Eyeoff.svg'
                          : 'assets/icons/Eyeon.svg',
                      width: 20,
                      height: 17,
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),
              GestureDetector(
                onTap: isLoading ? null : handleRegister,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      isLoading ? "Loading..." : "Sign Up",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'interbold',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // const SizedBox(height: 30),
              // Row(
              //   children: const [
              //     Expanded(child: Divider()),
              //     Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              //       child: Text(
              //         'OR CONTINUE WITH',
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //           fontFamily: 'intermedium',
              //           fontSize: 12,
              //           color: Colors.brown,
              //         ),
              //       ),
              //     ),
              //     Expanded(child: Divider()),
              //   ],
              // ),
              // const SizedBox(height: 32),
              // GestureDetector(
              //   onTap: () {},
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(vertical: 13.5),
              //     color: Colors.transparent,
              //     child: Center(
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           SvgPicture.asset('assets/icons/Google.svg'),
              //           const SizedBox(width: 11),
              //           Text(
              //             "Sign In with Google",
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //               fontFamily: 'intersemibold',
              //               fontSize: 16,
              //               color: bluegoogletext,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontFamily: 'interregular',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontFamily: 'interregular',
                        fontSize: 14,
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