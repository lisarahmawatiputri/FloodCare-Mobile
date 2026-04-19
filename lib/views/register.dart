import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 44),
              Text(
                "Full Name",
                style: TextStyle(
                  fontFamily: "interbold",
                  fontSize: 12,
                  color: bluetext,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
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
                  hintText: "Enter your fullname",
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
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Sign Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {},
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
              const SizedBox(height: 40),
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
                          builder: (context) => LoginView(),
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