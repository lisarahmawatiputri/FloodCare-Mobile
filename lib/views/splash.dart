import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:floodcare_mobile/views/onboarding.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _isNavigated = false;

  void _navigate() {
    if (_isNavigated) return;
    _isNavigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/animations/floodsplash2.json', 
          fit: BoxFit.cover,
          onLoaded: (composition) {
            Future.delayed(composition.duration, _navigate);
          },
        ),
      ),
    );
  }
}