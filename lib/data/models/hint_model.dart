// 💡 Hint Model
//
// Represents a step-by-step hint for a problem

class HintModel {
  final String id;
  final String problemId;
  final int level;
  final String content;
  final HintType type;
  final int xpCost;
  final int? gemCost;

  const HintModel({
    required this.id,
    required this.problemId,
    required this.level,
    required this.content,
    required this.type,
    this.xpCost = 10,
    this.gemCost,
  });

  factory HintModel.fromJson(Map<String, dynamic> json) {
    return HintModel(
      id: json['id'] as String,
      problemId: json['problemId'] as String,
      level: json['level'] as int,
      content: json['content'] as String,
      type: HintType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HintType.text,
      ),
      xpCost: json['xpCost'] as int? ?? 10,
      gemCost: json['gemCost'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'problemId': problemId,
        'level': level,
        'content': content,
        'type': type.name,
        'xpCost': xpCost,
        'gemCost': gemCost,
      };

  /// Get hint level description
  String get levelDescription {
    switch (level) {
      case 1:
        return '기본 힌트';
      case 2:
        return '상세 힌트';
      case 3:
        return '해결 방법';
      default:
        return '힌트 $level';
    }
  }

  /// Get hint icon
  String get icon {
    switch (type) {
      case HintType.text:
        return '💬';
      case HintType.concept:
        return '📚';
      case HintType.example:
        return '📝';
      case HintType.visualization:
        return '🎨';
      case HintType.step:
        return '👣';
    }
  }

  /// Check if this hint costs gems
  bool get requiresGems => gemCost != null && gemCost! > 0;

  HintModel copyWith({
    String? id,
    String? problemId,
    int? level,
    String? content,
    HintType? type,
    int? xpCost,
    int? gemCost,
  }) {
    return HintModel(
      id: id ?? this.id,
      problemId: problemId ?? this.problemId,
      level: level ?? this.level,
      content: content ?? this.content,
      type: type ?? this.type,
      xpCost: xpCost ?? this.xpCost,
      gemCost: gemCost ?? this.gemCost,
    );
  }
}

/// Type of hint
enum HintType {
  text, // Text-based hint
  concept, // Concept explanation
  example, // Example problem
  visualization, // Visual explanation
  step, // Step-by-step guide
}

/// Hint usage record
class HintUsageModel {
  final String id;
  final String userId;
  final String problemId;
  final String hintId;
  final DateTime usedAt;
  final int xpCost;
  final int? gemCost;

  const HintUsageModel({
    required this.id,
    required this.userId,
    required this.problemId,
    required this.hintId,
    required this.usedAt,
    required this.xpCost,
    this.gemCost,
  });

  factory HintUsageModel.fromJson(Map<String, dynamic> json) {
    return HintUsageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      problemId: json['problemId'] as String,
      hintId: json['hintId'] as String,
      usedAt: DateTime.parse(json['usedAt'] as String),
      xpCost: json['xpCost'] as int,
      gemCost: json['gemCost'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'problemId': problemId,
        'hintId': hintId,
        'usedAt': usedAt.toIso8601String(),
        'xpCost': xpCost,
        'gemCost': gemCost,
      };
}
