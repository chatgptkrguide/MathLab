// Home logo — translucent GoMath logo shown at the bottom of the scroll view.
import 'package:flutter/material.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.7,
        child: Image.asset(
          'assets/icons/gomath_logo.png',
          width: 144,
          height: 56,
          errorBuilder: (_, __, ___) => const Text(
            'GoMath Lab',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
