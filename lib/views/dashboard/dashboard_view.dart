import 'package:flutter/material.dart';
import 'package:floodcare_mobile/views/dashboard/home_view.dart';
import 'package:floodcare_mobile/views/dashboard/edukasi_view.dart';
import 'package:floodcare_mobile/views/dashboard/camera_view.dart';
import 'package:floodcare_mobile/views/dashboard/donasi_view.dart';
import 'package:floodcare_mobile/views/dashboard/profile_view.dart';
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
    CameraView(),
    DonasiView(),
    ProfileView(),
  ];

  void changePage(int index) {
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