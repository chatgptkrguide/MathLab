import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/providers/learning/problem_provider.dart';
import '../../../data/services/korean_math_curriculum.dart';
import '../../../shared/constants/game_constants.dart';
import '../../problem/problem_screen.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 왼쪽: 학년 선택 버튼
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showGradeSelectionModal(context, ref),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '학년',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentGrade,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 가운데: 화살표
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.arrow_forward,
              size: 24,
              color: Color(0xFF4A90E2),
            ),
          ),

          // 오른쪽: 단원 선택 버튼
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLessonSelectionModal(context, ref, currentGrade),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '단원',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedLesson != null
                          ? selectedLesson.title.length > 8
                            ? '${selectedLesson.title.substring(0, 8)}...'
                            : selectedLesson.title
                          : '단원 선택',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 학년 선택 모달 표시
  void _showGradeSelectionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 제목
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '학년을 선택하세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // 학년 목록
            ...['중1', '중2', '중3', '고1', '고2', '고3'].map((grade) {
              final gradeInfo = _getGradeInfo(grade);
              return _buildGradeOption(context, ref, grade, gradeInfo['emoji']!, gradeInfo['fullName']!);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 학년 정보 반환
  Map<String, String> _getGradeInfo(String grade) {
    final info = {
      '중1': {'emoji': '📚', 'fullName': '중학교 1학년'},
      '중2': {'emoji': '📖', 'fullName': '중학교 2학년'},
      '중3': {'emoji': '📕', 'fullName': '중학교 3학년'},
      '고1': {'emoji': '📘', 'fullName': '고등학교 1학년'},
      '고2': {'emoji': '📙', 'fullName': '고등학교 2학년'},
      '고3': {'emoji': '📗', 'fullName': '고등학교 3학년'},
    };
    return info[grade] ?? {'emoji': '📚', 'fullName': grade};
  }

  /// 학년 옵션 아이템
  Widget _buildGradeOption(BuildContext context, WidgetRef ref, String grade, String emoji, String fullName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // 학년 업데이트
          ProviderScope.containerOf(context).read(userProvider.notifier).updateGrade(grade);
          // 단원 선택 모달 표시
          Future.delayed(const Duration(milliseconds: GameConstants.normalAnimationMs), () {
            if (!context.mounted) return;
            _showLessonSelectionModal(context, ref, grade);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 단원 선택 모달 표시
  void _showLessonSelectionModal(BuildContext context, WidgetRef ref, String grade) {
    final lessons = KoreanMathCurriculum.getLessonsByGrade(grade);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 제목
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '$grade 단원 선택',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // 단원 목록
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildLessonOption(context, ref, lesson);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 단원 옵션 아이템
  Widget _buildLessonOption(BuildContext context, WidgetRef ref, Lesson lesson) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);

          // 문제 데이터 가져오기
          final problems = ref.read(problemProvider);

          if (problems.isEmpty) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('해당 단원의 문제가 없습니다')),
            );
            return;
          }

          if (!context.mounted) return;
          // 학습 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemScreen(
                lessonId: lesson.id,
                problems: problems,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    lesson.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
