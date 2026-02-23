// 🏅 Achievement Unlock Dialog
//
// Dialog shown when a new achievement is unlocked

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/achievement_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class AchievementUnlockDialog extends StatefulWidget {
  final AchievementModel achievement;

  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
  });

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background overlay
        FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            color: Colors.black54,
          ),
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
        // Achievement card
        ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radius20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(widget.achievement.rarityColor).withValues(alpha: 0.85),
                    Color(widget.achievement.rarityColor).withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radius20),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(widget.achievement.rarityColor).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppDimensions.spacing24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Color(widget.achievement.rarityColor),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  // "Achievement Unlocked" text
                  Text(
                    '업적 달성!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  // Achievement name
                  Text(
                    widget.achievement.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  // Achievement description
                  Text(
                    widget.achievement.description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  // Rarity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing16,
                      vertical: AppDimensions.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radius16),
                    ),
                    child: Text(
                      widget.achievement.rarityLabel,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  // Rewards
                  if (widget.achievement.rewards.isNotEmpty)
                    _buildRewards(),
                  const SizedBox(height: AppDimensions.spacing24),
                  // Close button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(widget.achievement.rarityColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing32,
                        vertical: AppDimensions.spacing12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radius24),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewards() {
    final rewards = widget.achievement.rewards;
    final rewardTexts = <String>[];

    if (rewards.containsKey('xp')) {
      rewardTexts.add('⭐ +${rewards['xp']} XP');
    }

    if (rewards.containsKey('gems')) {
      rewardTexts.add('💎 +${rewards['gems']} 젬');
    }

    if (rewards.containsKey('title')) {
      rewardTexts.add('🏷️ ${rewards['title']}');
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Column(
        children: [
          Text(
            '보상',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          ...rewardTexts.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing4),
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Show the achievement unlock dialog
  // ignore: unused_element
  static void show(BuildContext context, AchievementModel achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
      ),
    );
  }
}
