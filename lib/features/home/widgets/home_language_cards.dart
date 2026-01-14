import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/services/korean_math_curriculum.dart';
import '../../../shared/constants/duolingo_styles.dart';
import '../../../shared/widgets/styled/duolingo_card.dart';
import 'modals/grade_selection_modal.dart';
import 'modals/lesson_selection_modal.dart';

/// 홈 화면 학년/단원 선택 카드
///
/// 포함 내용:
/// - 학년 선택 버튼 (모달 표시)
/// - 단원 선택 버튼 (모달 표시)
/// - 화살표 아이콘
class HomeLanguageCards extends ConsumerWidget {
  const HomeLanguageCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final currentGrade = user?.currentGrade ?? '중1';

    final lessons = KoreanMathCurriculum.getLessonsByGrade(currentGrade);
    final selectedLesson = lessons.isNotEmpty ? lessons[0] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DuolingoStyles.spacing24),
      child: Row(
        children: [
          // 왼쪽: 학년 선택 버튼
          _buildGradeCard(context, ref, currentGrade),

          // 가운데: 화살표
          _buildArrowIcon(),

          // 오른쪽: 단원 선택 버튼
          _buildLessonCard(context, ref, currentGrade, selectedLesson),
        ],
      ),
    );
  }

  /// 학년 카드 빌더
  Widget _buildGradeCard(
      BuildContext context, WidgetRef ref, String currentGrade) {
    return Expanded(
      child: DuolingoCard(
        theme: DuolingoCardTheme.blue,
        onTap: () => GradeSelectionModal.show(
          context,
          onGradeSelected: (grade) {
            LessonSelectionModal.show(context, grade: grade);
          },
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('학년', style: DuolingoStyles.cardLabelStyle),
              const SizedBox(height: DuolingoStyles.spacing4 / 2),
              Row(
                children: [
                  Text(currentGrade, style: DuolingoStyles.cardValueBlueStyle),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 화살표 아이콘 빌더
  Widget _buildArrowIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          size: 24,
          color: DuolingoStyles.duolingoBlue,
        ),
      ),
    );
  }

  /// 단원 카드 빌더
  Widget _buildLessonCard(
    BuildContext context,
    WidgetRef ref,
    String currentGrade,
    dynamic selectedLesson,
  ) {
    return Expanded(
      child: DuolingoCard(
        theme: DuolingoCardTheme.green,
        onTap: () => LessonSelectionModal.show(context, grade: currentGrade),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('단원', style: DuolingoStyles.cardLabelStyle),
              const SizedBox(height: DuolingoStyles.spacing4 / 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedLesson != null
                          ? selectedLesson.title.length > 8
                              ? '${selectedLesson.title.substring(0, 8)}...'
                              : selectedLesson.title
                          : '단원 선택',
                      style: DuolingoStyles.cardValueGreenStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20,
                    color: DuolingoStyles.duolingoGreen,
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
