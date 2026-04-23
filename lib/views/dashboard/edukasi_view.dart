import 'package:flutter/material.dart';

class EdukasiView extends StatelessWidget {
  const EdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Edukasi View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}