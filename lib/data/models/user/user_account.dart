/// 사용자 계정 모델 (다중 사용자 지원)
class UserAccount {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final AccountType accountType;
  final bool isActive;
  final Map<String, dynamic> preferences;

  const UserAccount({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    required this.accountType,
    this.isActive = true,
    this.preferences = const {},
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      accountType: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['accountType'],
        orElse: () => AccountType.student,
      ),
      isActive: json['isActive'] as bool? ?? true,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'accountType': accountType.toString().split('.').last,
      'isActive': isActive,
      'preferences': preferences,
    };
  }

  UserAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    AccountType? accountType,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }

  /// 아바타 이미지 또는 이니셜
  String get avatarText => displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  /// 계정 타입별 색상
  String get accountColor {
    switch (accountType) {
      case AccountType.student:
        return '#4CAF50'; // 초록
      case AccountType.parent:
        return '#2196F3'; // 파랑
      case AccountType.teacher:
        return '#FF9800'; // 주황
      case AccountType.admin:
        return '#9C27B0'; // 보라
    }
  }

  /// 계정 타입 텍스트
  String get accountTypeText {
    switch (accountType) {
      case AccountType.student:
        return '학생';
      case AccountType.parent:
        return '학부모';
      case AccountType.teacher:
        return '선생님';
      case AccountType.admin:
        return '관리자';
    }
  }

  @override
  String toString() => 'UserAccount{id: $id, name: $displayName}';

  @override
  bool operator ==(Object other) => other is UserAccount && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 계정 타입
enum AccountType {
  student, // 학생
  parent, // 학부모
  teacher, // 선생님
  admin, // 관리자
}

/// 사용자 세션 정보
class UserSession {
  final String accountId;
  final String sessionToken;
  final DateTime startTime;
  final DateTime? endTime;
  final String deviceId;
  final Map<String, dynamic> sessionData;

  const UserSession({
    required this.accountId,
    required this.sessionToken,
    required this.startTime,
    this.endTime,
    required this.deviceId,
    this.sessionData = const {},
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      accountId: json['accountId'] as String,
      sessionToken: json['sessionToken'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      deviceId: json['deviceId'] as String,
      sessionData: Map<String, dynamic>.from(json['sessionData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'sessionToken': sessionToken,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'deviceId': deviceId,
      'sessionData': sessionData,
    };
  }

  /// 세션 지속 시간
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// 세션이 활성화되어 있는지
  bool get isActive => endTime == null;

  /// 세션 종료
  UserSession endSession() {
    return UserSession(
      accountId: accountId,
      sessionToken: sessionToken,
      startTime: startTime,
      endTime: DateTime.now(),
      deviceId: deviceId,
      sessionData: sessionData,
    );
  }
}

/// 학습 프로필 (사용자별 학습 데이터)
class LearningProfile {
  final String accountId;
  final String currentGrade; // 중1, 중2, 고1 등
  final List<String> favoriteSubjects;
  final Map<String, int> categoryProgress; // 카테고리별 진행률
  final LearningGoal goal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearningProfile({
    required this.accountId,
    required this.currentGrade,
    required this.favoriteSubjects,
    required this.categoryProgress,
    required this.goal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningProfile.fromJson(Map<String, dynamic> json) {
    return LearningProfile(
      accountId: json['accountId'] as String,
      currentGrade: json['currentGrade'] as String,
      favoriteSubjects: List<String>.from(json['favoriteSubjects'] ?? []),
      categoryProgress: Map<String, int>.from(json['categoryProgress'] ?? {}),
      goal: LearningGoal.values.firstWhere(
        (e) => e.toString().split('.').last == json['goal'],
        orElse: () => LearningGoal.casual,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'currentGrade': currentGrade,
      'favoriteSubjects': favoriteSubjects,
      'categoryProgress': categoryProgress,
      'goal': goal.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 학습 목표
enum LearningGoal {
  casual, // 가벼운 학습 (5-10분/일)
  regular, // 규칙적 학습 (15-20분/일)
  intensive, // 집중 학습 (30분+/일)
  exam, // 시험 준비
}