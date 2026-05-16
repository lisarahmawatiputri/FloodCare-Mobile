import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  Widget _navItem({
    required String activeIcon,
    required String inactiveIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isActive ? activeIcon : inactiveIcon,
              width: 18,
              height: 20,
              
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'intersemibold',
                fontSize: 11,
                color: isActive
                    ? const Color(0xFFE86F00)
                    : const Color(0xFF8E92C9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
  final bool isActive = selectedIndex == 2;

  return GestureDetector(
    onTap: () => onTap(2),
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFE86F00),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/cam.svg',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Laporan',
          style: TextStyle(
            fontFamily: 'intersemibold',
            fontSize: 11,
            color: isActive
                ? const Color(0xFFE86F00)
                : const Color(0xFF8E92C9),
          ),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 95,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 78,
              padding: const EdgeInsets.only(left: 18, right: 18, top: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    // blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(activeIcon: 'assets/icons/home_fill.svg', 
                  inactiveIcon: 'assets/icons/home.svg', 
                  label: 'Beranda', 
                  index: 0),
                  _navItem(activeIcon: 'assets/icons/edukasi_fill.svg', 
                  inactiveIcon: 'assets/icons/edukasi.svg', 
                  label: 'Edukasi', 
                  index: 1),
                  const SizedBox(width: 60),
                  _navItem(activeIcon: 'assets/icons/donasi_fill.svg', 
                  inactiveIcon: 'assets/icons/donasi.svg', 
                  label: 'Donasi', 
                  index: 3),
                  _navItem(activeIcon: 'assets/icons/profil_fill.svg', 
                  inactiveIcon: 'assets/icons/profil.svg', 
                  label: 'Profil', 
                  index: 4),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: _centerButton())
        ],
      ),
    );
  }
}
