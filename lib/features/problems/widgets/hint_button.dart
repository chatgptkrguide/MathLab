// Hint Button + Inline Hint Trigger
//
// HintButton: 상시 pulse 없는 정적 버튼, 탭 시 짧은 scale 인터랙션.
// InlineHintTrigger: 답안 입력 영역 위 inline 행에 배치되는 가로 wide
//   링크 형태. 우측 상단의 화이트 스페이스 대신 손가락 동선 가까운 위치.

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

/// 답안 입력 직전 inline 힌트 트리거 — border-left 강조 + 좌측 정렬 row.
/// 화면 폭 전체를 채우는 wide 카드 (HintButton 의 compact 버전과 의도적 대비).
class InlineHintTrigger extends StatelessWidget {
  final int unlockedCount;
  final int totalHints;
  final bool isEnabled;
  final VoidCallback onTap;

  const InlineHintTrigger({
    super.key,
    required this.unlockedCount,
    required this.totalHints,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnlockedAll = unlockedCount >= totalHints;
    final accent =
        hasUnlockedAll ? AppColors.mathGreen : AppColors.mathOrange;
    final disabled = !isEnabled;
    final labelColor = disabled ? AppColors.textTertiary : accent;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFF7F7F7)
              : accent.withValues(alpha: 0.08),
          border: Border(
            left: BorderSide(
              color: disabled
                  ? const Color(0xFFDDDDDD)
                  : accent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasUnlockedAll
                  ? Icons.check_circle_outline_rounded
                  : Icons.lightbulb_outline_rounded,
              color: labelColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              hasUnlockedAll ? '모든 힌트 열림' : '힌트 보기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$unlockedCount / $totalHints',
              style: TextStyle(
                fontSize: 12,
                color: labelColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (!hasUnlockedAll && !disabled)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accent.withValues(alpha: 0.6),
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
