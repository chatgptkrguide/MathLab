/// 학업 성적 데이터 모델
/// 학교 성적, 모의고사 성적 등을 관리합니다.
class AcademicRecord {
  final String id;
  final String userId;
  final AcademicRecordType type;
  final DateTime date;
  final String semester; // 예: "2024-1학기"
  final Map<String, SubjectScore> scores; // 과목별 점수
  final double? averageScore;
  final int? rank; // 전체 순위
  final int? totalStudents; // 전체 학생 수
  final String? memo;

  AcademicRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.semester,
    required this.scores,
    this.averageScore,
    this.rank,
    this.totalStudents,
    this.memo,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'date': date.toIso8601String(),
      'semester': semester,
      'scores': scores.map((key, value) => MapEntry(key, value.toJson())),
      'averageScore': averageScore,
      'rank': rank,
      'totalStudents': totalStudents,
      'memo': memo,
    };
  }

  /// JSON에서 생성
  factory AcademicRecord.fromJson(Map<String, dynamic> json) {
    return AcademicRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: AcademicRecordType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AcademicRecordType.schoolExam,
      ),
      date: DateTime.parse(json['date'] as String),
      semester: json['semester'] as String,
      scores: (json['scores'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          SubjectScore.fromJson(value as Map<String, dynamic>),
        ),
      ),
      averageScore: json['averageScore'] as double?,
      rank: json['rank'] as int?,
      totalStudents: json['totalStudents'] as int?,
      memo: json['memo'] as String?,
    );
  }

  /// 복사 (업데이트용)
  AcademicRecord copyWith({
    String? id,
    String? userId,
    AcademicRecordType? type,
    DateTime? date,
    String? semester,
    Map<String, SubjectScore>? scores,
    double? averageScore,
    int? rank,
    int? totalStudents,
    String? memo,
  }) {
    return AcademicRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      date: date ?? this.date,
      semester: semester ?? this.semester,
      scores: scores ?? this.scores,
      averageScore: averageScore ?? this.averageScore,
      rank: rank ?? this.rank,
      totalStudents: totalStudents ?? this.totalStudents,
      memo: memo ?? this.memo,
    );
  }
}

/// 학업 성적 유형
enum AcademicRecordType {
  schoolExam('학교 시험'),
  mockExam('모의고사'),
  monthlyTest('월말평가'),
  midterm('중간고사'),
  final_('기말고사');

  final String label;
  const AcademicRecordType(this.label);
}

/// 과목 점수
class SubjectScore {
  final String subjectName;
  final double score;
  final double? maxScore; // 만점
  final String? grade; // 등급 (1등급, 2등급 등)
  final int? percentile; // 백분위

  SubjectScore({
    required this.subjectName,
    required this.score,
    this.maxScore = 100,
    this.grade,
    this.percentile,
  });

  /// 점수 비율 (%)
  double get scorePercentage {
    if (maxScore == null || maxScore == 0) return 0;
    return (score / maxScore!) * 100;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'score': score,
      'maxScore': maxScore,
      'grade': grade,
      'percentile': percentile,
    };
  }

  /// JSON에서 생성
  factory SubjectScore.fromJson(Map<String, dynamic> json) {
    return SubjectScore(
      subjectName: json['subjectName'] as String,
      score: (json['score'] as num).toDouble(),
      maxScore:
          json['maxScore'] != null ? (json['maxScore'] as num).toDouble() : 100,
      grade: json['grade'] as String?,
      percentile: json['percentile'] as int?,
    );
  }
}

/// 성적 통계
class AcademicStatistics {
  final double averageScore;
  final double highestScore;
  final double lowestScore;
  final Map<AcademicRecordType, double> averageByType;
  final List<SubjectTrend> subjectTrends;

  AcademicStatistics({
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.averageByType,
    required this.subjectTrends,
  });
}

/// 과목별 성적 추세
class SubjectTrend {
  final String subjectName;
  final List<double> scores;
  final double averageScore;
  final TrendDirection trend;

  SubjectTrend({
    required this.subjectName,
    required this.scores,
    required this.averageScore,
    required this.trend,
  });

  /// 추세 계산
  static TrendDirection calculateTrend(List<double> scores) {
    if (scores.length < 2) return TrendDirection.stable;

    final recent = scores.sublist(scores.length - 2);
    if (recent[1] > recent[0] + 5) return TrendDirection.improving;
    if (recent[1] < recent[0] - 5) return TrendDirection.declining;
    return TrendDirection.stable;
  }
}

/// 추세 방향
enum TrendDirection {
  improving,
  stable,
  declining,
}
