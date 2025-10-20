/// 에피소드 모델 (레슨 하위 단위)
/// 각 레슨은 여러 에피소드로 구성되며, 각 에피소드는 10개 문제를 포함
class Episode {
  final String id;
  final String lessonId; // 소속 레슨
  final int episodeNumber; // 에피소드 번호 (1-50)
  final String title;
  final String description;
  final String category; // 기초산술, 대수, 기하 등
  final List<String> concepts; // 학습 개념들
  final int targetProblems; // 목표 문제 수 (보통 10개)
  final int completedProblems; // 완료한 문제 수
  final bool isUnlocked; // 잠금 해제 여부
  final bool isCompleted; // 완료 여부
  final DateTime? completedAt; // 완료 날짜
  final int xpReward; // 완료 시 획득 XP
  final EpisodeDifficulty difficulty; // 에피소드 난이도

  const Episode({
    required this.id,
    required this.lessonId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.concepts,
    required this.targetProblems,
    required this.completedProblems,
    required this.isUnlocked,
    required this.isCompleted,
    this.completedAt,
    required this.xpReward,
    required this.difficulty,
  });

  /// JSON으로부터 Episode 객체 생성
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      episodeNumber: json['episodeNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      concepts: List<String>.from(json['concepts'] as List),
      targetProblems: json['targetProblems'] as int,
      completedProblems: json['completedProblems'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      xpReward: json['xpReward'] as int,
      difficulty: EpisodeDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => EpisodeDifficulty.beginner,
      ),
    );
  }

  /// Episode 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'episodeNumber': episodeNumber,
      'title': title,
      'description': description,
      'category': category,
      'concepts': concepts,
      'targetProblems': targetProblems,
      'completedProblems': completedProblems,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'xpReward': xpReward,
      'difficulty': difficulty.toString().split('.').last,
    };
  }

  /// Episode 객체 복사 (일부 값 변경)
  Episode copyWith({
    String? id,
    String? lessonId,
    int? episodeNumber,
    String? title,
    String? description,
    String? category,
    List<String>? concepts,
    int? targetProblems,
    int? completedProblems,
    bool? isUnlocked,
    bool? isCompleted,
    DateTime? completedAt,
    int? xpReward,
    EpisodeDifficulty? difficulty,
  }) {
    return Episode(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      concepts: concepts ?? this.concepts,
      targetProblems: targetProblems ?? this.targetProblems,
      completedProblems: completedProblems ?? this.completedProblems,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (targetProblems == 0) return 0.0;
    return completedProblems / targetProblems;
  }

  /// 진행률 퍼센트 (0 ~ 100)
  int get progressPercentage => (progress * 100).round();

  /// 남은 문제 수
  int get remainingProblems => targetProblems - completedProblems;

  /// 예상 소요 시간 (분)
  int get estimatedMinutes => remainingProblems * 3; // 문제당 3분

  /// 난이도 색상
  String get difficultyColor {
    switch (difficulty) {
      case EpisodeDifficulty.beginner:
        return '#4CAF50'; // 초록
      case EpisodeDifficulty.intermediate:
        return '#FF9800'; // 주황
      case EpisodeDifficulty.advanced:
        return '#F44336'; // 빨강
      case EpisodeDifficulty.expert:
        return '#9C27B0'; // 보라
    }
  }

  /// 난이도 텍스트
  String get difficultyText {
    switch (difficulty) {
      case EpisodeDifficulty.beginner:
        return '초급';
      case EpisodeDifficulty.intermediate:
        return '중급';
      case EpisodeDifficulty.advanced:
        return '고급';
      case EpisodeDifficulty.expert:
        return '전문가';
    }
  }

  /// 완료 조건 확인
  bool get canComplete => completedProblems >= targetProblems;

  /// 잠금 해제 조건 확인 (이전 에피소드 완료 필요)
  bool canUnlock(List<Episode> allEpisodes) {
    if (episodeNumber == 1) return true; // 첫 번째 에피소드는 항상 가능

    // 이전 에피소드가 완료되었는지 확인
    final previousEpisode = allEpisodes.where(
      (e) => e.lessonId == lessonId && e.episodeNumber == episodeNumber - 1,
    ).firstOrNull;

    return previousEpisode?.isCompleted ?? false;
  }

  @override
  String toString() {
    return 'Episode{id: $id, title: $title, progress: $progressPercentage%}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Episode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 에피소드 난이도
enum EpisodeDifficulty {
  beginner, // 초급
  intermediate, // 중급
  advanced, // 고급
  expert, // 전문가
}

/// 에피소드 세트 (테마별 그룹)
class EpisodeSet {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<Episode> episodes;
  final SetTheme theme;

  const EpisodeSet({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.episodes,
    required this.theme,
  });

  /// 세트 전체 진행률
  double get overallProgress {
    if (episodes.isEmpty) return 0.0;
    final totalProblems = episodes.fold(0, (sum, ep) => sum + ep.targetProblems);
    final completedProblems = episodes.fold(0, (sum, ep) => sum + ep.completedProblems);
    return totalProblems > 0 ? completedProblems / totalProblems : 0.0;
  }

  /// 완료된 에피소드 수
  int get completedEpisodes => episodes.where((ep) => ep.isCompleted).length;

  /// 잠금 해제된 에피소드 수
  int get unlockedEpisodes => episodes.where((ep) => ep.isUnlocked).length;

  /// 다음 에피소드
  Episode? get nextEpisode {
    return episodes.where((ep) => ep.isUnlocked && !ep.isCompleted).firstOrNull;
  }

  /// 세트 완료 여부
  bool get isCompleted => episodes.every((ep) => ep.isCompleted);

  /// 세트 잠금 해제 여부
  bool get isUnlocked => episodes.any((ep) => ep.isUnlocked);
}

/// 세트 테마
enum SetTheme {
  arithmetic, // 기초 산술
  algebra, // 대수
  geometry, // 기하
  statistics, // 통계
  calculus, // 미적분
  special, // 특별 과정
}

/// extension for firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }
}