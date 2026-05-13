import 'package:flutter/material.dart';
import 'package:floodcare_mobile/views/home/home_view.dart';
import 'package:floodcare_mobile/views/edukasi/edukasi_view.dart';
import 'package:floodcare_mobile/views/camera/camera_view.dart';
import 'package:floodcare_mobile/views/donasi/donasi_view.dart';
import 'package:floodcare_mobile/views/profile/profile_view.dart';
import 'package:floodcare_mobile/widgets/custom_bottom_nav.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeView(),
    EdukasiView(),

    // Slot kamera dikosongkan supaya CameraView tidak masuk IndexedStack.
    // Kalau CameraView masuk IndexedStack, bottom navbar akan tetap tampil.
    SizedBox.shrink(),

    DonasiView(),
    ProfileView(),
  ];

  void changePage(int index) {
    // Index 2 adalah tombol kamera di bottom navbar.
    // Dibuka sebagai halaman baru agar fullscreen dan navbar tidak ikut.
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraView(),
        ),
      );
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: selectedIndex,
        onTap: changePage,
      ),
    );
  }
}