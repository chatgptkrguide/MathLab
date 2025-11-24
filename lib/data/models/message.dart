import 'package:flutter/foundation.dart';

/// 메시지 타입
enum MessageType {
  /// 시스템 메시지 (공지사항, 업데이트)
  system,
  /// 친구 메시지
  friend,
  /// 리그 관련 메시지
  league,
  /// 업적 달성 메시지
  achievement,
  /// 스트릭 관련 메시지
  streak,
  /// 이벤트/프로모션 메시지
  promotion,
}

/// 메시지 모델
@immutable
class Message {
  /// 메시지 고유 ID
  final String id;

  /// 메시지 타입
  final MessageType type;

  /// 발신자 ID (시스템 메시지는 'system')
  final String senderId;

  /// 발신자 이름
  final String senderName;

  /// 발신자 아바타 URL (옵션)
  final String? senderAvatarUrl;

  /// 메시지 제목
  final String title;

  /// 메시지 본문
  final String body;

  /// 액션 버튼 텍스트 (옵션)
  final String? actionText;

  /// 액션 라우트 (옵션)
  final String? actionRoute;

  /// 읽음 여부
  final bool isRead;

  /// 중요 메시지 여부
  final bool isImportant;

  /// 생성 시간
  final DateTime createdAt;

  /// 읽은 시간 (옵션)
  final DateTime? readAt;

  const Message({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.title,
    required this.body,
    this.actionText,
    this.actionRoute,
    this.isRead = false,
    this.isImportant = false,
    required this.createdAt,
    this.readAt,
  });

  /// JSON으로부터 생성
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.system,
      ),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      actionText: json['actionText'] as String?,
      actionRoute: json['actionRoute'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'title': title,
      'body': body,
      'actionText': actionText,
      'actionRoute': actionRoute,
      'isRead': isRead,
      'isImportant': isImportant,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// 복사 생성자
  Message copyWith({
    String? id,
    MessageType? type,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? title,
    String? body,
    String? actionText,
    String? actionRoute,
    bool? isRead,
    bool? isImportant,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      title: title ?? this.title,
      body: body ?? this.body,
      actionText: actionText ?? this.actionText,
      actionRoute: actionRoute ?? this.actionRoute,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}
