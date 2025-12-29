/// 레벨 테스트 모델
class LevelTest {
  final String id;
  final List<LevelTestQuestion> questions;
  final DateTime createdAt;
  final bool isCompleted;
  final int? finalLevel;
  final double? accuracy;

  const LevelTest({
    required this.id,
    required this.questions,
    required this.createdAt,
    this.isCompleted = false,
    this.finalLevel,
    this.accuracy,
  });

  LevelTest copyWith({
    String? id,
    List<LevelTestQuestion>? questions,
    DateTime? createdAt,
    bool? isCompleted,
    int? finalLevel,
    double? accuracy,
  }) {
    return LevelTest(
      id: id ?? this.id,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      finalLevel: finalLevel ?? this.finalLevel,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'finalLevel': finalLevel,
      'accuracy': accuracy,
    };
  }

  factory LevelTest.fromJson(Map<String, dynamic> json) {
    return LevelTest(
      id: json['id'],
      questions: (json['questions'] as List<dynamic>)
          .map((q) => LevelTestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      finalLevel: json['finalLevel'],
      accuracy: json['accuracy']?.toDouble(),
    );
  }
}

/// 레벨 테스트 문제
class LevelTestQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final int difficulty; // 1-5 (쉬움-어려움)
  final String? category;
  final int? userAnswerIndex;
  final bool? isCorrect;

  const LevelTestQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    this.category,
    this.userAnswerIndex,
    this.isCorrect,
  });

  LevelTestQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    int? difficulty,
    String? category,
    int? userAnswerIndex,
    bool? isCorrect,
  }) {
    return LevelTestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      userAnswerIndex: userAnswerIndex ?? this.userAnswerIndex,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'difficulty': difficulty,
      'category': category,
      'userAnswerIndex': userAnswerIndex,
      'isCorrect': isCorrect,
    };
  }

  factory LevelTestQuestion.fromJson(Map<String, dynamic> json) {
    return LevelTestQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      difficulty: json['difficulty'],
      category: json['category'],
      userAnswerIndex: json['userAnswerIndex'],
      isCorrect: json['isCorrect'],
    );
  }
}

/// 레벨 테스트 결과
class LevelTestResult {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final int recommendedLevel;
  final Map<String, int> categoryScores; // 카테고리별 점수

  const LevelTestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.recommendedLevel,
    required this.categoryScores,
  });

  String get performanceMessage {
    if (accuracy >= 0.9) {
      return '완벽합니다! 수학 실력이 뛰어나시네요!';
    } else if (accuracy >= 0.7) {
      return '잘하셨어요! 탄탄한 기초가 있으시네요!';
    } else if (accuracy >= 0.5) {
      return '좋아요! 조금만 더 노력하면 됩니다!';
    } else if (accuracy >= 0.3) {
      return '괜찮아요! 천천히 시작해봐요!';
    } else {
      return '함께 기초부터 차근차근 배워봐요!';
    }
  }

  String get levelDescription {
    if (recommendedLevel >= 8) {
      return '고급 레벨 - 복잡한 문제 해결 가능';
    } else if (recommendedLevel >= 6) {
      return '중급 레벨 - 기본 개념 숙지';
    } else if (recommendedLevel >= 4) {
      return '초급 레벨 - 기초 다지기';
    } else {
      return '입문 레벨 - 기초부터 시작';
    }
  }
}
