/// 동기화 작업 타입
enum SyncTaskType {
  /// 사용자 프로필 업로드
  uploadUserProfile,

  /// 오답 노트 업로드
  uploadWrongAnswer,

  /// 학습 기록 업로드
  uploadStudyHistory,

  /// 리그 데이터 업로드
  uploadLeague,

  /// 사용자 프로필 다운로드
  downloadUserProfile,

  /// 오답 노트 다운로드
  downloadWrongAnswers,

  /// 학습 기록 다운로드
  downloadStudyHistory,
}

/// 동기화 작업
class SyncTask {
  final String id;
  final SyncTaskType type;
  final String accountId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncTask({
    required this.id,
    required this.type,
    required this.accountId,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 재시도 가능 여부
  bool get canRetry => retryCount < 3;

  /// 다음 재시도까지 대기 시간 (초)
  int get retryDelaySeconds {
    // Exponential backoff: 5초, 15초, 45초
    return 5 * (retryCount + 1) * (retryCount + 1);
  }

  SyncTask copyWith({
    String? id,
    SyncTaskType? type,
    String? accountId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return SyncTask(
      id: id ?? this.id,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'accountId': accountId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  /// JSON 역직렬화
  factory SyncTask.fromJson(Map<String, dynamic> json) {
    return SyncTask(
      id: json['id'] as String,
      type: SyncTaskType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      accountId: json['accountId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'SyncTask(id: $id, type: $type, accountId: $accountId, retryCount: $retryCount)';
  }
}
