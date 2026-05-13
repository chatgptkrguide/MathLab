// Wrong Answer Card — Anti-AI 재설계
//
// 변경 사항:
// - StatefulWidget: 탭으로 해설 펼침/접기 (AnimatedCrossFade)
// - 비대칭 답 비교: 오답(3) : 정답(5) — 정답에 강조 위계
// - 상태별 강조선 두께 차별화: 미해결 긴급 4px, 복습 3px, 해결 2px + 무채색
// - 상단 헤더에 단원명 실제 텍스트 노출 (lessonTitle)
// - 해결된 카드는 배경 회색 + opacity 처리로 시각 위계 분리
// - 버튼: 해결 카드는 '다시 틀렸어요' 텍스트 링크만, 미해결은 OutlinedButton + 채움 버튼 혼용

import 'package:flutter/material.dart';
import '../../../data/models/wrong_answer_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/math/math_renderer.dart';

class WrongAnswerCard extends StatefulWidget {
  final WrongAnswerModel wrongAnswer;
  final VoidCallback onRetry;
  final VoidCallback onMarkResolved;

  const WrongAnswerCard({
    super.key,
    required this.wrongAnswer,
    required this.onRetry,
    required this.onMarkResolved,
  });

  @override
  State<WrongAnswerCard> createState() => _WrongAnswerCardState();
}

class _WrongAnswerCardState extends State<WrongAnswerCard> {
  bool _explanationExpanded = false;

  // 상태별 강조선 두께와 색상 — 균일하지 않게 의도적으로 차별화
  double get _stripeWidth {
    if (widget.wrongAnswer.isResolved) return 3.0;
    if (widget.wrongAnswer.shouldReview()) return 4.0;
    return 5.0;
  }

  Color get _stripeColor {
    if (widget.wrongAnswer.isResolved) return AppColors.borderDark;
    if (widget.wrongAnswer.shouldReview()) return AppColors.mathOrange;
    return AppColors.mathRed;
  }

  // 해결된 카드는 시각적으로 뒤로 물러나게
  Color get _cardBackground {
    if (widget.wrongAnswer.isResolved) return const Color(0xFFF9F9F9);
    return Colors.white;
  }

  double get _cardOpacity {
    return widget.wrongAnswer.isResolved ? 0.78 : 1.0;
  }

  String get _typeLabel {
    switch (widget.wrongAnswer.problemType) {
      case 'multipleChoice':
        return '객관식';
      case 'trueFalse':
        return '참/거짓';
      case 'fillInBlank':
        return '주관식';
      case 'dragAndDrop':
        return '드래그';
      case 'matching':
        return '매칭';
      default:
        return '문제';
    }
  }

  Color get _typeBadgeColor {
    switch (widget.wrongAnswer.problemType) {
      case 'fillInBlank':
        return AppColors.mathPurple;
      case 'dragAndDrop':
      case 'matching':
        return AppColors.mathOrange;
      default:
        return AppColors.primary;
    }
  }

  String get _dateLabel {
    final days = widget.wrongAnswer.daysSinceAttempt;
    if (days == 0) return '오늘';
    if (days == 1) return '어제';
    return '$days일 전';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _cardOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          boxShadow: widget.wrongAnswer.isResolved
              ? null
              : [
                  BoxShadow(
                    color: _stripeColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 좌측 상태 강조선 — 두께와 색상이 상태마다 다름
                Container(
                  width: _stripeWidth,
                  color: _stripeColor,
                ),
                // 카드 본문
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildProblemBody(),
                      _buildAnswerComparison(),
                      if (widget.wrongAnswer.explanation != null)
                        _buildExplanationToggle(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 헤더: 단원명(왼쪽) + 날짜 + 상태(오른쪽)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 유형 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _typeBadgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius6),
            ),
            child: Text(
              _typeLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: _typeBadgeColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 7),
          // 단원명 — 실제 lessonTitle 표시
          Expanded(
            child: Text(
              widget.wrongAnswer.lessonTitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // 날짜
          Text(
            _dateLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
          // 상태 표시 — 해결됨 체크, 복습 알람
          if (widget.wrongAnswer.isResolved) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: AppColors.mathGreen,
            ),
          ] else if (widget.wrongAnswer.shouldReview()) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.alarm_rounded,
              size: 14,
              color: AppColors.mathOrange,
            ),
          ],
          // 재시도 횟수 (2회 이상만)
          if (widget.wrongAnswer.attemptCount > 1) ...[
            const SizedBox(width: 6),
            Text(
              '${widget.wrongAnswer.attemptCount}×',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 문제 본문 — 수학식 지원, 최대 2줄 자르지 않음
  Widget _buildProblemBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: MathRichText(
        text: widget.wrongAnswer.problemText,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.45,
          color: widget.wrongAnswer.isResolved
              ? AppColors.textSecondary
              : AppColors.textPrimary,
        ),
        mathFontSize: 16.0,
      ),
    );
  }

  // 오답/정답 비교 — 비대칭 3:5 레이아웃, 정답에 더 큰 강조
  Widget _buildAnswerComparison() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오답 (3/8 비율)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.mathRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                border: Border.all(
                  color: AppColors.mathRed.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 답',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.mathRed.withValues(alpha: 0.6),
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  MathRichText(
                    text: widget.wrongAnswer.userAnswer,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathRed,
                      fontWeight: FontWeight.w600,
                    ),
                    mathFontSize: 13.0,
                    mathColor: AppColors.mathRed,
                  ),
                ],
              ),
            ),
          ),
          // 화살표 — 좌우 비대칭 중앙 마커
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.textTertiary.withValues(alpha: 0.7),
            ),
          ),
          // 정답 (5/8 비율) — 더 크고 강조된 테두리
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.mathGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                border: Border.all(
                  color: AppColors.mathGreen.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '정답',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.mathGreen.withValues(alpha: 0.7),
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  MathRichText(
                    text: widget.wrongAnswer.correctAnswer,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathGreenDark,
                      fontWeight: FontWeight.w700,
                    ),
                    mathFontSize: 13.0,
                    mathColor: AppColors.mathGreenDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 해설 펼침/접기 — 탭 인터랙션
  Widget _buildExplanationToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 구분선 겸 토글 버튼 — border-left 수작업 디테일 느낌
        GestureDetector(
          onTap: () => setState(() => _explanationExpanded = !_explanationExpanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 12,
                  color: AppColors.primary.withValues(alpha: 0.35),
                  margin: const EdgeInsets.only(right: 7),
                ),
                Text(
                  '해설',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _explanationExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 15,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 해설 내용 — AnimatedCrossFade로 부드럽게
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
              decoration: BoxDecoration(
                color: AppColors.beigBlue,
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: MathRichText(
                text: widget.wrongAnswer.explanation!,
                textStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                mathFontSize: 13.0,
              ),
            ),
          ),
          crossFadeState: _explanationExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }

  // 푸터: 액션 버튼 — 해결/미해결 상태별로 다른 버튼 스타일
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.wrongAnswer.isResolved) ...[
            // 해결된 카드: 텍스트 링크만 (소극적 액션)
            GestureDetector(
              onTap: widget.onRetry,
              child: Text(
                '다시 풀기',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textTertiary,
                ),
              ),
            ),
          ] else ...[
            // 미해결 카드: OutlinedButton (다시 풀기) + 채움 버튼 (해결)
            SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: widget.onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                  textStyle: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                child: const Text('다시 풀기'),
              ),
            ),
            const SizedBox(width: 7),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: widget.onMarkResolved,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mathGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                  textStyle: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                child: const Text('해결 완료'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
