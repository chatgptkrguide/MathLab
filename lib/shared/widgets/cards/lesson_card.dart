import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../../data/models/models.dart';

/// 레슨 카드 위젯 (데이터 모델 기반)
/// Lessons 화면에서 각 레슨을 표시하는데 사용
class LessonCard extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.lesson.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = !widget.lesson.isUnlocked;
    final double progress = widget.lesson.progress;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isLocked
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(),
                ),
          color: isLocked ? AppColors.disabled.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: isLocked
                ? AppColors.borderLight
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isLocked
              ? null
              : [
                  BoxShadow(
                    color: _getPrimaryColor().withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 아이콘
                  _buildIcon(isLocked),
                  const Spacer(),
                  // 제목
                  Text(
                    widget.lesson.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isLocked ? AppColors.disabled : AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  // 진행률
                  _buildProgress(isLocked, progress),
                ],
              ),
            ),
            // 잠금 아이콘
            if (isLocked)
              Positioned(
                top: AppDimensions.paddingS,
                right: AppDimensions.paddingS,
                child: Icon(
                  Icons.lock,
                  color: AppColors.disabled,
                  size: 20,
                ),
              ),
            // 완료 체크마크 - 펄스 애니메이션 추가
            if (widget.lesson.isCompleted)
              Positioned(
                top: AppDimensions.paddingS,
                right: AppDimensions.paddingS,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.15),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingXS),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successGreen
                                  .withValues(alpha: 0.6 * _pulseController.value),
                              blurRadius: 8 + (4 * _pulseController.value),
                              spreadRadius: 1 + (2 * _pulseController.value),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.surface,
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 아이콘 빌드
  Widget _buildIcon(bool isLocked) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.disabled.withValues(alpha: 0.2)
            : AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          widget.lesson.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  /// 진행률 빌드
  Widget _buildProgress(bool isLocked, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.lesson.completedProblems}/${widget.lesson.totalProblems} 문제',
              style: AppTextStyles.bodySmall.copyWith(
                color: isLocked
                    ? AppColors.disabled
                    : AppColors.surface.withValues(alpha: 0.9),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: isLocked
                    ? AppColors.disabled
                    : AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isLocked
                ? AppColors.disabled.withValues(alpha: 0.2)
                : AppColors.surface.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation(
              isLocked ? AppColors.disabled : AppColors.surface,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// 카테고리별 그라디언트 색상
  List<Color> _getGradientColors() {
    switch (widget.lesson.category) {
      case '기초산술':
        return AppColors.mathButtonGradient;
      case '대수':
        return AppColors.orangeGradient;
      case '기하':
        return AppColors.mathTealGradient;
      case '통계':
        return AppColors.purpleGradient;
      default:
        return AppColors.blueGradient;
    }
  }

  /// 카테고리별 메인 색상
  Color _getPrimaryColor() {
    switch (widget.lesson.category) {
      case '기초산술':
        return AppColors.mathButtonBlue;
      case '대수':
        return AppColors.mathOrange;
      case '기하':
        return AppColors.mathTeal;
      case '통계':
        return AppColors.mathPurple;
      default:
        return AppColors.mathBlue;
    }
  }
}
