import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 프로필 모델
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String currentGrade; // 현재 학년 (예: "중1", "중2", "중3")
  final int totalXP; // 총 경험치
  final int level; // 레벨
  final int streak; // 연속 학습 일수
  final DateTime? lastStudyDate; // 마지막 학습 날짜
  final int totalProblemsCompleted; // 완료한 총 문제 수
  final int correctAnswers; // 정답 수
  final Map<String, int> categoryXP; // 카테고리별 XP
  final List<String> achievements; // 획득한 업적 목록
  final String league; // 리그 (Bronze, Silver, Gold, Diamond)
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.currentGrade = '중1',
    this.totalXP = 0,
    this.level = 1,
    this.streak = 0,
    this.lastStudyDate,
    this.totalProblemsCompleted = 0,
    this.correctAnswers = 0,
    this.categoryXP = const {},
    this.achievements = const [],
    this.league = 'Bronze',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore에서 데이터 가져오기
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      currentGrade: data['currentGrade'] as String? ?? '중1',
      totalXP: data['totalXP'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      streak: data['streak'] as int? ?? 0,
      lastStudyDate: (data['lastStudyDate'] as Timestamp?)?.toDate(),
      totalProblemsCompleted: data['totalProblemsCompleted'] as int? ?? 0,
      correctAnswers: data['correctAnswers'] as int? ?? 0,
      categoryXP: Map<String, int>.from(data['categoryXP'] as Map? ?? {}),
      achievements: List<String>.from(data['achievements'] as List? ?? []),
      league: data['league'] as String? ?? 'Bronze',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'currentGrade': currentGrade,
      'totalXP': totalXP,
      'level': level,
      'streak': streak,
      'lastStudyDate': lastStudyDate != null ? Timestamp.fromDate(lastStudyDate!) : null,
      'totalProblemsCompleted': totalProblemsCompleted,
      'correctAnswers': correctAnswers,
      'categoryXP': categoryXP,
      'achievements': achievements,
      'league': league,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 레벨 계산 (XP 기반)
  static int calculateLevel(int xp) {
    // 레벨 = sqrt(XP / 100) + 1
    return (xp / 100).floor() + 1;
  }

  /// 다음 레벨까지 필요한 XP
  int get xpToNextLevel {
    final nextLevel = level + 1;
    final nextLevelXP = (nextLevel - 1) * (nextLevel - 1) * 100;
    return nextLevelXP - totalXP;
  }

  /// 정답률
  double get accuracy {
    if (totalProblemsCompleted == 0) return 0.0;
    return correctAnswers / totalProblemsCompleted;
  }

  /// copyWith 메서드
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? currentGrade,
    int? totalXP,
    int? level,
    int? streak,
    DateTime? lastStudyDate,
    int? totalProblemsCompleted,
    int? correctAnswers,
    Map<String, int>? categoryXP,
    List<String>? achievements,
    String? league,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      currentGrade: currentGrade ?? this.currentGrade,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalProblemsCompleted: totalProblemsCompleted ?? this.totalProblemsCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      categoryXP: categoryXP ?? this.categoryXP,
      achievements: achievements ?? this.achievements,
      league: league ?? this.league,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
