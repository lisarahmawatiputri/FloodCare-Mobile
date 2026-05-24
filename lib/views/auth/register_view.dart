import 'package:floodcare_mobile/viewmodels/auth_viewmodel.dart';
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

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noTeleponController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthViewModel authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();

    authViewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> handleRegister() async {
    FocusScope.of(context).unfocus();

    final success = await authViewModel.register(
      namaLengkap: namaController.text,
      email: emailController.text,
      noTelepon: noTeleponController.text,
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil, silakan login')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Register gagal'),
        ),
      );
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

  Widget signUpButton() {
    return GestureDetector(
      onTap: authViewModel.isLoading ? null : handleRegister,
      child: Container(
        height: 60,
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
          child: authViewModel.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Text(
                  "Sign Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'interbold',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
        ),
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

              signUpButton(),

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