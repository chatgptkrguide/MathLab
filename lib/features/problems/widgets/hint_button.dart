// 💡 Duolingo-style Hint Button
//
// Animated hint button with pulse effect and XP cost indicator

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

class HintButton extends StatefulWidget {
  final int unlockedCount;
  final int totalHints;
  final int xpCost;
  final VoidCallback onTap;
  final bool isEnabled;

  const HintButton({
    super.key,
    required this.unlockedCount,
    required this.totalHints,
    required this.xpCost,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnlockedAll = widget.unlockedCount >= widget.totalHints;

    return GestureDetector(
      onTap: widget.isEnabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: hasUnlockedAll
                    ? [
                        AppColors.mathGreen.withValues(alpha: 0.15),
                        AppColors.mathGreen.withValues(alpha: 0.08),
                      ]
                    : [
                        AppColors.mathOrange.withValues(alpha: 0.15),
                        AppColors.mathOrange.withValues(alpha: 0.08),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasUnlockedAll
                    ? AppColors.mathGreen.withValues(alpha: 0.3)
                    : AppColors.mathOrange.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasUnlockedAll
                      ? AppColors.mathGreen.withValues(alpha: _glowAnimation.value)
                      : AppColors.mathOrange.withValues(alpha: _glowAnimation.value),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated lightbulb icon
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: hasUnlockedAll
                            ? [AppColors.mathGreen, const Color(0xFF06A03C)]
                            : [AppColors.mathOrange, const Color(0xFFE67E22)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: hasUnlockedAll
                              ? AppColors.mathGreen.withValues(alpha: 0.4)
                              : AppColors.mathOrange.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      hasUnlockedAll ? Icons.check : Icons.lightbulb_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Hint count and cost
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '힌트',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: hasUnlockedAll
                            ? AppColors.mathGreen
                            : AppColors.mathOrange,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${widget.unlockedCount}/${widget.totalHints}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!hasUnlockedAll) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mathOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '무료',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mathOrange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
