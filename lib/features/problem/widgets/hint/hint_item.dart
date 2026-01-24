import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../data/models/learning/problem.dart';
import '../../../../data/providers/learning/hint_provider_optimized.dart';

/// 개별 힌트 아이템 위젯
class HintItem extends StatefulWidget {
  final Problem problem;
  final int hintIndex;
  final String hintText;
  final bool isUnlocked;
  final bool canUnlock;
  final VoidCallback onUnlock;

  const HintItem({
    super.key,
    required this.problem,
    required this.hintIndex,
    required this.hintText,
    required this.isUnlocked,
    required this.canUnlock,
    required this.onUnlock,
  });

  @override
  State<HintItem> createState() => _HintItemState();
}

class _HintItemState extends State<HintItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: widget.isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.successGreen.withValues(alpha: 0.08),
                  AppColors.successGreen.withValues(alpha: 0.04),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.disabled.withValues(alpha: 0.05),
                  AppColors.disabled.withValues(alpha: 0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isUnlocked
              ? AppColors.successGreen.withValues(alpha: 0.3)
              : AppColors.borderLight.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: widget.isUnlocked ? _buildUnlockedHint() : _buildLockedHint(),
    );
  }

  Widget _buildUnlockedHint() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.successGreen,
                  Color(0xFF06A03C),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.successGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.surface,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 힌트 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '힌트 ${widget.hintIndex + 1}',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.hintText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    height: 1.6,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedHint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 자물쇠 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.disabled.withValues(alpha: 0.2),
                AppColors.disabled.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.lock,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        // 힌트 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '힌트 ${widget.hintIndex + 1}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.diamond,
                    color: AppColors.mathOrange.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${HintProviderOptimized.hintCost} XP로 잠금 해제',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 잠금 해제 버튼 - Duolingo 스타일 3D 버튼
        ScaleTransition(
          scale: _buttonAnimation,
          child: GestureDetector(
            onTapDown: (_) => _buttonController.forward(),
            onTapUp: (_) {
              _buttonController.reverse();
              if (widget.canUnlock) {
                widget.onUnlock();
              }
            },
            onTapCancel: () => _buttonController.reverse(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 3D 그림자
                if (widget.canUnlock)
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    bottom: -4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.mathOrangeDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                // 메인 버튼
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: widget.canUnlock
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.mathOrange,
                              Color(0xFFE67E22),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.disabled,
                              AppColors.disabled.withValues(alpha: 0.8),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.canUnlock
                          ? AppColors.mathOrangeDark
                          : AppColors.disabled.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: widget.canUnlock
                        ? [
                            BoxShadow(
                              color: AppColors.mathOrange.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.diamond,
                        color: AppColors.surface,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${HintProviderOptimized.hintCost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
