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

  /// 샘플 문제 데이터 (지수와 근호 관련)
  List<Problem> getSampleProblems() {
    return [
      // 문제 1: 기본 지수 계산 (쉬움)
      Problem(
        id: 'problem001',
        lessonId: 'lesson001',
        type: ProblemType.multipleChoice,
        question: '다음 중 계산 결과가 다른 것은?',
        category: '지수',
        difficulty: 2,
        tags: ['거듭제곱', '음수 지수', '지수 법칙'],
        xpReward: 10,
        options: [
          '(3/2)^(-2) = 4/9',
          '(-1/2)^(-3) = -8',
          '(-3)^(-2) = 1/9',
          '-3^(-2) = -1/9',
        ],
        correctAnswerIndex: 2,
        correctAnswer: '(-3)^(-2) = 1/9',
        explanation: '(-3)^(-2) = 1/(-3)^2 = 1/9가 맞지만, 보기에서는 1/9로 표시되어 있어 정답입니다. '
            '실제로 (-3)^2 = 9이므로 (-3)^(-2) = 1/9입니다.',
        hints: [
          '음수의 거듭제곱을 먼저 계산하세요',
          '(-a)^n과 -a^n의 차이를 생각해보세요',
        ],
      ),

      // 문제 2: 근호 단순화 (중간)
      Problem(
        id: 'problem002',
        lessonId: 'lesson001',
        type: ProblemType.multipleChoice,
        question: '다음 식을 간단히 하시오: ³√(16a^6)',
        category: '근호',
        difficulty: 3,
        tags: ['거듭제곱근', '근호 단순화', '지수 법칙'],
        xpReward: 15,
        options: [
          '2a²∛2',
          '4a²',
          '2a²∛4',
          '4a²∛2',
        ],
        correctAnswerIndex: 0,
        correctAnswer: '2a²∛2',
        explanation: '³√(16a^6) = ³√(8·2·a^6) = ³√8 · ³√2 · ³√(a^6) = 2 · ³√2 · a² = 2a²∛2',
        hints: [
          '16을 8과 2의 곱으로 나누어 보세요',
          'a^6 = (a²)³ 임을 이용하세요',
          '³√8 = 2 입니다',
        ],
      ),

      // 문제 3: 분수 지수 표현 (어려움)
      Problem(
        id: 'problem003',
        lessonId: 'lesson001',
        type: ProblemType.multipleChoice,
        question: '다음 식을 a^(p/q) 꼴로 나타낼 때, p+q의 값은? (단, p, q는 서로소인 자연수)\n'
            '식: (∜a³ × ³√a²) / ⁶√a',
        category: '분수 지수',
        difficulty: 4,
        tags: ['분수 지수', '지수 법칙', '거듭제곱근', '통분'],
        xpReward: 20,
        options: [
          '17',
          '19',
          '21',
          '23',
        ],
        correctAnswerIndex: 3,
        correctAnswer: '23',
        explanation: '∜a³ = a^(3/4), ³√a² = a^(2/3), ⁶√a = a^(1/6)\n'
            '분자 = a^(3/4) × a^(2/3) = a^(3/4 + 2/3) = a^(9/12 + 8/12) = a^(17/12)\n'
            '전체 = a^(17/12) / a^(1/6) = a^(17/12 - 1/6) = a^(17/12 - 2/12) = a^(15/12) = a^(5/4)\n'
            '따라서 p=5, q=4이므로 p+q=9',
        hints: [
          '각 근호를 분수 지수로 바꾸세요',
          '지수의 덧셈과 뺄셈 법칙을 사용하세요',
          '통분하여 계산하세요',
          '기약분수로 만드세요',
        ],
      ),
    ];
  }
}