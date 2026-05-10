import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/auth/login_view.dart';
import 'package:flutter/material.dart';

List onboardingData = [
  {
    "images": "assets/images/Onboarding1.png",
    "title": "Pantau Banjir Real-Time",
    "desc":
        "Dapatkan informasi kondisi banjir di sekitarmu dengan cepat dan akurat untuk membantu menghadapi situasi darurat.",
  },
  {
    "images": "assets/images/Onboarding2.png",
    "title": "Peringatan Dini Otomatis",
    "desc":
        "Terima notifikasi saat risiko banjir meningkat di lokasimu untuk mengetahui kondisi lebih awal dan mengambil langkah yang diperlukan.",
  },
  {
    "images": "assets/images/Onboarding3.png",
    "title": "Akses Bantuan Darurat",
    "desc":
        "Dapatkan informasi kondisi banjir di sekitarmu dengan cepat dan akurat untuk membantu menghadapi situasi darurat.",
  },
];

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (v) {
                debugPrint(v.toString());
                setState(() {
                  currentPage = v;
                });
              },
              itemBuilder: (_, i) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 70,
                        left: 20,
                        right: 29,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          i == 0
                              ? SizedBox(width: 18)
                              : GestureDetector(
                                  onTap: () {
                                    pageController.previousPage(
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {
                              pageController.animateToPage(
                                2,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                              debugPrint('Skip');
                            },
                            child: Text(
                              currentPage == 2 ? '' : 'Skip',
                              style: TextStyle(
                                fontFamily: 'intermedium',
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 75,
                        left: 222,
                        right: 222,
                        bottom: 35,
                      ),
                    ),
                    Image.asset(
                      onboardingData[i]['images'],
                      height: 331,
                      width: 349,
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(27, 20, 27, 0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(
                                  onboardingData[i]['title'],
                                  style: TextStyle(
                                    fontFamily: 'jakartaextrabold',
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              Text(
                                onboardingData[i]['desc'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'interregular',
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 35),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Wrap(
                  spacing: 6,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: currentPage == 0 ? lightorange : graybullet,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      height: 9,
                      width: 9,
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: currentPage == 1 ? lightorange : graybullet,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      height: 9,
                      width: 9,
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: currentPage == 2 ? lightorange : graybullet,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      height: 9,
                      width: 9,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: GestureDetector(
                  onTap: () {
                    if (currentPage == 2) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (BuildContext context) => const LoginView(),
                        ),
                      );
                    } else {
                      pageController.animateToPage(
                        currentPage + 1,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                      debugPrint('Continue');
                    }
                  },

                  child: Container(
                    width: 325,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: orangeGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        currentPage == 2 ? "Get Started" : "Continue",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'intermedium',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
