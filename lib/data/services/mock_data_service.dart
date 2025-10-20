import '../models/models.dart';

/// 목 데이터 서비스
/// 실제 백엔드가 없어도 앱을 테스트할 수 있도록 하는 서비스
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  /// 샘플 사용자 데이터
  User getSampleUser() {
    return User(
      id: 'user001',
      name: '학습자',
      email: 'student@mathlab.com',
      joinDate: DateTime(2025, 10, 13),
      level: 1,
      xp: 0,
      streakDays: 0,
      currentGrade: '중1',
      avatarUrl: '',
      hearts: 5,
    );
  }

  /// 샘플 레슨 데이터
  List<Lesson> getSampleLessons() {
    return [
      Lesson(
        id: 'lesson001',
        title: '1. 소인수분해',
        description: '자연수의 성질과 소인수분해를 학습합니다',
        icon: '🔢',
        order: 1,
        grade: '중1',
        category: '기초산술',
        topics: ['자연수', '소수', '합성수', '소인수분해'],
        totalProblems: 20,
        completedProblems: 0,
        isUnlocked: true,
        xpReward: 100,
      ),
      Lesson(
        id: 'lesson002',
        title: '2. 정수와 유리수',
        description: '정수와 유리수의 개념과 연산을 학습합니다',
        icon: '➕',
        order: 2,
        grade: '중1',
        category: '기초산술',
        topics: ['정수', '유리수', '사칙연산', '절댓값'],
        totalProblems: 25,
        completedProblems: 0,
        isUnlocked: false,
        xpReward: 120,
      ),
      Lesson(
        id: 'lesson003',
        title: '3. 문자와 식',
        description: '문자를 사용한 식의 표현과 계산을 학습합니다',
        icon: '📝',
        order: 3,
        grade: '중1',
        category: '대수',
        topics: ['문자의 사용', '일차식', '다항식', '식의 값'],
        totalProblems: 30,
        completedProblems: 0,
        isUnlocked: false,
        xpReward: 150,
      ),
      Lesson(
        id: 'lesson004',
        title: '4. 일차방정식',
        description: '일차방정식의 풀이와 활용을 학습합니다',
        icon: '⚖️',
        order: 4,
        grade: '중1',
        category: '대수',
        topics: ['일차방정식', '등식의 성질', '방정식의 활용'],
        totalProblems: 35,
        completedProblems: 0,
        isUnlocked: false,
        xpReward: 180,
      ),
      Lesson(
        id: 'lesson005',
        title: '5. 좌표평면과 그래프',
        description: '좌표평면에서 점의 위치와 그래프를 학습합니다',
        icon: '📊',
        order: 5,
        grade: '중1',
        category: '기하',
        topics: ['좌표평면', '순서쌍', '그래프', '함수'],
        totalProblems: 28,
        completedProblems: 0,
        isUnlocked: false,
        xpReward: 140,
      ),
    ];
  }

  /// 샘플 업적 데이터
  List<Achievement> getSampleAchievements() {
    return [
      Achievement(
        id: 'achievement001',
        title: '첫 걸음',
        description: '첫 번째 문제를 풀어보세요',
        icon: '⭐',
        type: AchievementType.problems,
        requiredValue: 1,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 50,
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'achievement002',
        title: '일주일 연속',
        description: '7일 연속으로 학습하세요',
        icon: '🔥',
        type: AchievementType.streak,
        requiredValue: 7,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 200,
        rarity: AchievementRarity.uncommon,
      ),
      Achievement(
        id: 'achievement003',
        title: '레벨 5 달성',
        description: '레벨 5에 도달하세요',
        icon: '🏆',
        type: AchievementType.xp,
        requiredValue: 500,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 300,
        rarity: AchievementRarity.rare,
      ),
      Achievement(
        id: 'achievement004',
        title: '완벽한 퀴즈',
        description: '한 번도 틀리지 않고 퀴즈를 완료하세요',
        icon: '✨',
        type: AchievementType.perfect,
        requiredValue: 1,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 150,
        rarity: AchievementRarity.uncommon,
      ),
      Achievement(
        id: 'achievement005',
        title: '한 달 연속',
        description: '30일 연속으로 학습하세요',
        icon: '📚',
        type: AchievementType.streak,
        requiredValue: 30,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 500,
        rarity: AchievementRarity.epic,
      ),
      Achievement(
        id: 'achievement006',
        title: '레벨 10 달성',
        description: '레벨 10에 도달하세요',
        icon: '🎯',
        type: AchievementType.xp,
        requiredValue: 1000,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 500,
        rarity: AchievementRarity.epic,
      ),
    ];
  }

  /// 샘플 학습 통계 데이터
  LearningStats getSampleLearningStats() {
    return LearningStats(
      userId: 'user001',
      totalXP: 0,
      completedEpisodes: 0,
      maxStreak: 0,
      currentStreak: 0,
      totalStudyTime: 0,
      totalProblems: 0,
      correctAnswers: 0,
      totalSessions: 0,
      lastStudyDate: DateTime.now(),
      categoryStats: {
        '기초산술': 0,
        '대수': 0,
        '기하': 0,
        '통계': 0,
      },
    );
  }

  /// 샘플 오답 노트 데이터
  List<ErrorNote> getSampleErrorNotes() {
    // 초기에는 빈 리스트 반환
    return [];
  }

  /// 학년별 레슨 데이터
  Map<String, List<Lesson>> getLessonsByGrade() {
    final lessons = getSampleLessons();
    final lessonsByGrade = <String, List<Lesson>>{};

    for (final lesson in lessons) {
      if (!lessonsByGrade.containsKey(lesson.grade)) {
        lessonsByGrade[lesson.grade] = [];
      }
      lessonsByGrade[lesson.grade]!.add(lesson);
    }

    // 각 학년의 레슨을 순서대로 정렬
    lessonsByGrade.forEach((grade, lessons) {
      lessons.sort((a, b) => a.order.compareTo(b.order));
    });

    return lessonsByGrade;
  }

  /// 카테고리별 레슨 데이터
  Map<String, List<Lesson>> getLessonsByCategory() {
    final lessons = getSampleLessons();
    final lessonsByCategory = <String, List<Lesson>>{};

    for (final lesson in lessons) {
      if (!lessonsByCategory.containsKey(lesson.category)) {
        lessonsByCategory[lesson.category] = [];
      }
      lessonsByCategory[lesson.category]!.add(lesson);
    }

    return lessonsByCategory;
  }

  /// 오답 노트 통계
  Map<String, int> getErrorNoteStats(List<ErrorNote> errorNotes) {
    var totalErrors = errorNotes.length;
    var unreviewed = errorNotes.where((note) => note.reviewCount == 0).length;
    var reviewedOnce = errorNotes.where((note) => note.reviewCount == 1).length;
    var reviewedTwice = errorNotes.where((note) => note.reviewCount >= 2).length;

    return {
      'total': totalErrors,
      'unreviewed': unreviewed,
      'reviewedOnce': reviewedOnce,
      'reviewedTwice': reviewedTwice,
    };
  }

  /// 일일 목표 XP
  int getDailyTargetXP() {
    return 100; // 기본 일일 목표 100 XP
  }

  /// 현재 일일 XP
  int getCurrentDailyXP(User user) {
    // 실제로는 오늘 획득한 XP만 계산해야 하지만
    // 목 데이터에서는 전체 XP의 일부로 가정
    return user.xp % getDailyTargetXP();
  }
}