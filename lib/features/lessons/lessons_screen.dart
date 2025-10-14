import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/services/mock_data_service.dart';

/// 학습 로드맵 화면 (커리큘럼)
/// 실제 스크린샷과 동일한 레이아웃으로 구현
class LessonsScreen extends StatefulWidget {
  const LessonsScreen({Key? key}) : super(key: key);

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final MockDataService _dataService = MockDataService();
  final List<String> _grades = ['중1', '중2', '고1'];
  int _selectedGradeIndex = 0;
  Map<String, List<Lesson>> _lessonsByGrade = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _lessonsByGrade = _dataService.getLessonsByGrade();

    // 중2, 고1 더미 데이터 추가 (중1 데이터를 복사해서 수정)
    _lessonsByGrade['중2'] = _createDummyLessonsForGrade('중2');
    _lessonsByGrade['고1'] = _createDummyLessonsForGrade('고1');
  }

  List<Lesson> _createDummyLessonsForGrade(String grade) {
    // 중2 커리큘럼
    if (grade == '중2') {
      return [
        Lesson(
          id: '${grade}_lesson001',
          title: '1. 유리수와 순환소수',
          description: '유리수를 소수로 나타내고 순환소수의 성질을 학습합니다',
          icon: '🔢',
          order: 1,
          grade: grade,
          category: '수와 연산',
          topics: ['유리수', '순환소수', '근삿값'],
          totalProblems: 25,
          completedProblems: 0,
          isUnlocked: false,
          xpReward: 120,
        ),
        Lesson(
          id: '${grade}_lesson002',
          title: '2. 식의 계산',
          description: '다항식의 덧셈과 뺄셈, 단항식의 곱셈과 나눗셈을 학습합니다',
          icon: '🔤',
          order: 2,
          grade: grade,
          category: '문자와 식',
          topics: ['다항식', '단항식', '식의 계산'],
          totalProblems: 30,
          completedProblems: 0,
          isUnlocked: false,
          xpReward: 150,
        ),
      ];
    }

    // 고1 커리큘럼
    if (grade == '고1') {
      return [
        Lesson(
          id: '${grade}_lesson001',
          title: '1. 다항식의 연산',
          description: '다항식의 곱셈과 나눗셈, 나머지 정리를 학습합니다',
          icon: '📊',
          order: 1,
          grade: grade,
          category: '다항식',
          topics: ['다항식의 곱셈', '나머지 정리', '인수분해'],
          totalProblems: 35,
          completedProblems: 0,
          isUnlocked: false,
          xpReward: 180,
        ),
        Lesson(
          id: '${grade}_lesson002',
          title: '2. 방정식과 부등식',
          description: '이차방정식과 이차부등식의 해법을 학습합니다',
          icon: '⚖️',
          order: 2,
          grade: grade,
          category: '방정식',
          topics: ['이차방정식', '이차부등식', '연립방정식'],
          totalProblems: 40,
          completedProblems: 0,
          isUnlocked: false,
          xpReward: 200,
        ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('학습 로드맵'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildGradeTabs(),
          const SizedBox(height: AppDimensions.spacingL),
          Expanded(child: _buildLessonsList()),
          _buildLearningGuide(),
        ],
      ),
    );
  }

  /// 헤더 텍스트
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '체계적인 수학 학습을 시작하세요',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            '단계별로 구성된 커리큘럼을 통해 수학 실력을 체계적으로 향상시킬 수 있습니다.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 학년 선택 탭
  Widget _buildGradeTabs() {
    return GradeTabBar(
      grades: _grades,
      selectedIndex: _selectedGradeIndex,
      onTabChanged: (index) {
        setState(() {
          _selectedGradeIndex = index;
        });
      },
    );
  }

  /// 레슨 목록
  Widget _buildLessonsList() {
    final selectedGrade = _grades[_selectedGradeIndex];
    final lessons = _lessonsByGrade[selectedGrade] ?? [];

    if (lessons.isEmpty) {
      return EmptyState(
        icon: '📚',
        title: '준비 중입니다',
        message: '$selectedGrade 커리큘럼을 준비하고 있습니다.\n곧 만나볼 수 있어요!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        return LessonCard(
          icon: lesson.icon,
          title: lesson.title,
          description: lesson.description,
          progress: lesson.progress,
          isLocked: !lesson.isUnlocked,
          onTap: lesson.isUnlocked ? () => _navigateToLesson(lesson) : null,
        );
      },
    );
  }

  /// 학습 가이드
  Widget _buildLearningGuide() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.purpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.purpleAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.iconXL,
            height: AppDimensions.iconXL,
            decoration: BoxDecoration(
              color: AppColors.purpleAccent,
              borderRadius: BorderRadius.circular(AppDimensions.iconXL / 2),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: AppDimensions.iconM,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '학습 가이드',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.purpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Flexible(
                  child: Text(
                    '각 에피소드는 개념 학습 → 문제 풀이 → 총이 취약 순서로 진행됩니다. '
                    '난이도가 높은 문제는 오답 노트에 자동으로 저장됩니다.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이벤트 핸들러들

  void _navigateToLesson(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.description),
            const SizedBox(height: AppDimensions.spacingM),
            Text('📝 총 ${lesson.totalProblems}개 문제'),
            Text('⏱️ 예상 소요시간: ${lesson.estimatedMinutes}분'),
            Text('🎯 획득 XP: ${lesson.xpReward}'),
            const SizedBox(height: AppDimensions.spacingM),
            Text('주요 주제:', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppDimensions.spacingXS),
            ...lesson.topics.map(
              (topic) => Text('• $topic', style: AppTextStyles.bodySmall),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startLesson(lesson);
            },
            child: const Text('학습 시작'),
          ),
        ],
      ),
    );
  }

  void _startLesson(Lesson lesson) {
    // TODO: 실제 학습 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lesson.title} 학습을 시작합니다!'),
        action: SnackBarAction(
          label: '시작',
          onPressed: () {
            // 학습 화면으로 이동 로직
          },
        ),
      ),
    );
  }
}