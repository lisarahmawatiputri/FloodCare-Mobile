import 'package:floodcare_mobile/viewmodels/auth_viewmodel.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/dashboard/dashboard_view.dart';
import 'package:floodcare_mobile/views/onboarding/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:floodcare_mobile/views/auth/forget_password_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floodcare_mobile/views/auth/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isHide = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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

  Future<void> handleLogin() async {
    FocusScope.of(context).unfocus();

    final success = await authViewModel.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Login gagal'),
        ),
      );
    }
  }

  Future<void> handleGoogleLogin() async {
    FocusScope.of(context).unfocus();

    final success = await authViewModel.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Login Google gagal'),
        ),
      );
    }
  }

  Widget signInButton() {
    return GestureDetector(
      onTap: authViewModel.isLoading ? null : handleLogin,
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
                  "Sign In",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'interbold',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                      builder: (context) => const OnboardingView(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: SvgPicture.asset('assets/icons/BackAuth.svg'),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontFamily: 'jakartabold',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please enter your credentials to access the\nFloodCare dashboard.',
                style: TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black,
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

              const SizedBox(height: 19),

              Text(
                "Password",
                style: TextStyle(
                  fontFamily: "interbold",
                  fontSize: 12,
                  color: bluetext,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: passwordController,
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
                  fillColor: Colors.transparent,
                  filled: true,
                  hintText: "Enter your password",
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

              signInButton(),

              const SizedBox(height: 25),

              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordView(),
                      ),
                    );
                  },
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        orangeGradient.createShader(bounds),
                    child: const Text(
                      "Forgot the Password",
                      style: TextStyle(
                        fontFamily: 'intermedium',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                    child: Text(
                      'OR CONTINUE WITH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'intermedium',
                        fontSize: 12,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: authViewModel.isLoading ? null : handleGoogleLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13.5),
                  color: Colors.transparent,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/Google.svg'),
                        const SizedBox(width: 11),
                        Text(
                          "Sign In with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'intersemibold',
                            fontSize: 16,
                            color: bluegoogletext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
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
                          builder: (context) => const RegisterView(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
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