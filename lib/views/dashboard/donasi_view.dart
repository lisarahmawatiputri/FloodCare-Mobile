import 'package:flutter/material.dart';

class DonasiView extends StatelessWidget {
  const DonasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Donasi View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}