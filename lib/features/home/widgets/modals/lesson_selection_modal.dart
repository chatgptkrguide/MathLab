import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/models.dart';
import '../../../../data/providers/learning/problem_provider.dart';
import '../../../../data/services/korean_math_curriculum.dart';
import '../../../problem/problem_screen.dart';

/// 단원 선택 모달
///
/// 선택한 학년의 단원 목록을 표시하고 단원 선택 시 학습 화면으로 이동
class LessonSelectionModal extends ConsumerWidget {
  /// 현재 학년
  final String grade;

  const LessonSelectionModal({
    super.key,
    required this.grade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = KoreanMathCurriculum.getLessonsByGrade(grade);

    return Container(
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
    );
  }

  /// 단원 옵션 아이템 빌더
  Widget _buildLessonOption(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
  ) {
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

  /// 단원 선택 모달 표시 헬퍼 함수
  static Future<void> show(
    BuildContext context, {
    required String grade,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LessonSelectionModal(
        grade: grade,
      ),
    );
  }
}
