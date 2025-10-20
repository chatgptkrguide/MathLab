/// 수업/레슨 정보 모델
class Lesson {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int order; // 순서
  final String grade; // 중1, 중2, 고1 등
  final String category; // 기초산술, 대수, 기하 등
  final List<String> topics; // 세부 주제들
  final int totalProblems; // 전체 문제 수
  final int completedProblems; // 완료한 문제 수
  final bool isUnlocked; // 잠금 해제 여부
  final DateTime? completedAt; // 완료 날짜
  final int xpReward; // 완료 시 획득 XP

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    required this.grade,
    required this.category,
    required this.topics,
    required this.totalProblems,
    required this.completedProblems,
    required this.isUnlocked,
    this.completedAt,
    required this.xpReward,
  });

  /// JSON으로부터 Lesson 객체 생성
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      order: json['order'] as int,
      grade: json['grade'] as String,
      category: json['category'] as String,
      topics: List<String>.from(json['topics'] as List),
      totalProblems: json['totalProblems'] as int,
      completedProblems: json['completedProblems'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      xpReward: json['xpReward'] as int,
    );
  }

  /// Lesson 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'order': order,
      'grade': grade,
      'category': category,
      'topics': topics,
      'totalProblems': totalProblems,
      'completedProblems': completedProblems,
      'isUnlocked': isUnlocked,
      'completedAt': completedAt?.toIso8601String(),
      'xpReward': xpReward,
    };
  }

  /// Lesson 객체 복사 (일부 값 변경)
  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? order,
    String? grade,
    String? category,
    List<String>? topics,
    int? totalProblems,
    int? completedProblems,
    bool? isUnlocked,
    DateTime? completedAt,
    int? xpReward,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      grade: grade ?? this.grade,
      category: category ?? this.category,
      topics: topics ?? this.topics,
      completedProblems: completedProblems ?? this.completedProblems,
      totalProblems: totalProblems ?? this.totalProblems,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      completedAt: completedAt ?? this.completedAt,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (totalProblems == 0) return 0.0;
    return completedProblems / totalProblems;
  }

  /// 완료 여부
  bool get isCompleted => completedProblems >= totalProblems;

  /// 진행 상태 문자열
  String get statusText {
    if (isCompleted) return '완료';
    if (completedProblems > 0) return '진행중';
    if (isUnlocked) return '시작 가능';
    return '잠김';
  }

  /// 남은 문제 수
  int get remainingProblems => totalProblems - completedProblems;

  /// 예상 소요 시간 (분) - 문제당 2분으로 가정
  int get estimatedMinutes => remainingProblems * 2;

  @override
  String toString() {
    return 'Lesson{id: $id, title: $title, progress: ${(progress * 100).toInt()}%}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}