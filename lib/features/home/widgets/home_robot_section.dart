// Home robot section — circular progress ring around a robot character.
import 'package:flutter/material.dart';

import '../../../shared/widgets/indicators/circular_progress_ring.dart';

class HomeRobotSection extends StatelessWidget {
  final double progress;

  const HomeRobotSection({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressRing(
            progress: progress,
            size: 190,
            strokeWidth: 8,
            child: const SizedBox.shrink(),
          ),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/robot_character.png',
                width: 100,
                height: 100,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/icons/character_design.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => const Text(
                    '🤖',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
