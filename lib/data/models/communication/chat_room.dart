import 'package:flutter/foundation.dart';

/// 채팅방 타입
enum ChatRoomType {
  /// 1:1 대화
  direct,
  /// 그룹 채팅
  group,
  /// 학습 도우미 (AI 챗봇)
  assistant,
}

/// 채팅방 모델
@immutable
class ChatRoom {
  /// 채팅방 ID
  final String id;

  /// 채팅방 이름
  final String name;

  /// 채팅방 타입
  final ChatRoomType type;

  /// 참여자 ID 목록
  final List<String> participantIds;

  /// 채팅방 아이콘 URL (옵션)
  final String? iconUrl;

  /// 마지막 메시지
  final String? lastMessage;

  /// 마지막 메시지 시간
  final DateTime? lastMessageTime;

  /// 읽지 않은 메시지 개수
  final int unreadCount;

  /// 생성 시간
  final DateTime createdAt;

  /// 마지막 활동 시간
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.participantIds,
    this.iconUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON으로부터 생성
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ChatRoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatRoomType.direct,
      ),
      participantIds: List<String>.from(json['participantIds'] as List),
      iconUrl: json['iconUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'participantIds': participantIds,
      'iconUrl': iconUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 복사 생성자
  ChatRoom copyWith({
    String? id,
    String? name,
    ChatRoomType? type,
    List<String>? participantIds,
    String? iconUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      iconUrl: iconUrl ?? this.iconUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoom && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatRoom(id: $id, name: $name, type: $type, unreadCount: $unreadCount)';
  }
}

/// 채팅 메시지 모델
@immutable
class ChatMessage {
  /// 메시지 ID
  final String id;

  /// 채팅방 ID
  final String roomId;

  /// 발신자 ID
  final String senderId;

  /// 발신자 이름
  final String senderName;

  /// 메시지 내용
  final String content;

  /// 메시지 타입 (text, image, file 등)
  final String type;

  /// 전송 시간
  final DateTime sentAt;

  /// 읽음 여부
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = 'text',
    required this.sentAt,
    this.isRead = false,
  });

  /// JSON으로부터 생성
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// 복사 생성자
  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? content,
    String? type,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, content: $content)';
  }
}
