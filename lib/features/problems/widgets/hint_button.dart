// Hint Button
//
// 힌트 요청 버튼. 상시 pulse 애니메이션 없이 정적으로 표시되며,
// 탭 시에만 짧은 scale down/up 인터랙션이 작동한다.

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
  late AnimationController _tapController;
  late Animation<double> _tapScaleAnim;

  @override
  void initState() {
    super.initState();
    // 탭할 때만 한 번 실행되는 짧은 scale 애니메이션
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _tapScaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.isEnabled) return;
    await _tapController.forward();
    await _tapController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnlockedAll = widget.unlockedCount >= widget.totalHints;
    final accentColor =
        hasUnlockedAll ? AppColors.mathGreen : AppColors.mathOrange;
    final isDisabled = !widget.isEnabled;

    return GestureDetector(
      onTap: isDisabled ? null : _handleTap,
      child: ScaleTransition(
        scale: _tapScaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled
                ? const Color(0xFFF2F2F2)
                : accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFFDDDDDD)
                  : accentColor.withValues(alpha: 0.28),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasUnlockedAll
                    ? Icons.check_circle_outline_rounded
                    : Icons.lightbulb_outline_rounded,
                color: isDisabled
                    ? AppColors.textTertiary
                    : accentColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '힌트',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? AppColors.textTertiary
                          : accentColor,
                    ),
                  ),
                  Text(
                    '${widget.unlockedCount}/${widget.totalHints}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDisabled
                          ? AppColors.textTertiary
                          : accentColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
