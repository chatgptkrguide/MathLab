/// 📚 Concept Card Model
///
/// Represents an educational concept explanation card

class ConceptCardModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<String> keyPoints;
  final List<ConceptExample> examples;
  final List<String> relatedConcepts;
  final String? visualizationUrl;
  final ConceptDifficulty difficulty;
  final List<String> tags;

  const ConceptCardModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.keyPoints,
    required this.examples,
    this.relatedConcepts = const [],
    this.visualizationUrl,
    this.difficulty = ConceptDifficulty.medium,
    this.tags = const [],
  });

  factory ConceptCardModel.fromJson(Map<String, dynamic> json) {
    return ConceptCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      keyPoints: (json['keyPoints'] as List).map((e) => e as String).toList(),
      examples: (json['examples'] as List)
          .map((e) => ConceptExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedConcepts: json['relatedConcepts'] != null
          ? (json['relatedConcepts'] as List).map((e) => e as String).toList()
          : [],
      visualizationUrl: json['visualizationUrl'] as String?,
      difficulty: ConceptDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ConceptDifficulty.medium,
      ),
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => e as String).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'keyPoints': keyPoints,
        'examples': examples.map((e) => e.toJson()).toList(),
        'relatedConcepts': relatedConcepts,
        'visualizationUrl': visualizationUrl,
        'difficulty': difficulty.name,
        'tags': tags,
      };

  /// Get difficulty icon
  String get difficultyIcon {
    switch (difficulty) {
      case ConceptDifficulty.easy:
        return '🟢';
      case ConceptDifficulty.medium:
        return '🟡';
      case ConceptDifficulty.hard:
        return '🔴';
    }
  }

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficulty) {
      case ConceptDifficulty.easy:
        return '기초';
      case ConceptDifficulty.medium:
        return '중급';
      case ConceptDifficulty.hard:
        return '고급';
    }
  }

  ConceptCardModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    List<String>? keyPoints,
    List<ConceptExample>? examples,
    List<String>? relatedConcepts,
    String? visualizationUrl,
    ConceptDifficulty? difficulty,
    List<String>? tags,
  }) {
    return ConceptCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      keyPoints: keyPoints ?? this.keyPoints,
      examples: examples ?? this.examples,
      relatedConcepts: relatedConcepts ?? this.relatedConcepts,
      visualizationUrl: visualizationUrl ?? this.visualizationUrl,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }
}

/// Concept example
class ConceptExample {
  final String question;
  final String solution;
  final String? explanation;

  const ConceptExample({
    required this.question,
    required this.solution,
    this.explanation,
  });

  factory ConceptExample.fromJson(Map<String, dynamic> json) {
    return ConceptExample(
      question: json['question'] as String,
      solution: json['solution'] as String,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'solution': solution,
        'explanation': explanation,
      };
}

/// Concept difficulty level
enum ConceptDifficulty {
  easy,
  medium,
  hard,
}

/// User's concept card progress
class ConceptCardProgressModel {
  final String id;
  final String userId;
  final String conceptCardId;
  final bool isViewed;
  final bool isBookmarked;
  final DateTime? viewedAt;
  final DateTime? bookmarkedAt;
  final int viewCount;

  const ConceptCardProgressModel({
    required this.id,
    required this.userId,
    required this.conceptCardId,
    this.isViewed = false,
    this.isBookmarked = false,
    this.viewedAt,
    this.bookmarkedAt,
    this.viewCount = 0,
  });

  factory ConceptCardProgressModel.fromJson(Map<String, dynamic> json) {
    return ConceptCardProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      conceptCardId: json['conceptCardId'] as String,
      isViewed: json['isViewed'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      viewedAt: json['viewedAt'] != null
          ? DateTime.parse(json['viewedAt'] as String)
          : null,
      bookmarkedAt: json['bookmarkedAt'] != null
          ? DateTime.parse(json['bookmarkedAt'] as String)
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'conceptCardId': conceptCardId,
        'isViewed': isViewed,
        'isBookmarked': isBookmarked,
        'viewedAt': viewedAt?.toIso8601String(),
        'bookmarkedAt': bookmarkedAt?.toIso8601String(),
        'viewCount': viewCount,
      };

  ConceptCardProgressModel copyWith({
    String? id,
    String? userId,
    String? conceptCardId,
    bool? isViewed,
    bool? isBookmarked,
    DateTime? viewedAt,
    DateTime? bookmarkedAt,
    int? viewCount,
  }) {
    return ConceptCardProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conceptCardId: conceptCardId ?? this.conceptCardId,
      isViewed: isViewed ?? this.isViewed,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      viewedAt: viewedAt ?? this.viewedAt,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
