import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../base/base_notifier.dart';

/// 채팅방 목록 프로바이더
final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>((ref) {
  return ChatRoomsNotifier();
});

/// 채팅방 목록 관리 노티파이어
class ChatRoomsNotifier extends BaseNotifier<List<ChatRoom>> {
  ChatRoomsNotifier() : super([], 'ChatRoomsNotifier') {
    _loadChatRooms();
  }

  static const String _storageKey = 'chat_rooms';

  /// 채팅방 목록 로드
  Future<void> _loadChatRooms() async {
    try {
      final roomsList = await storage.loadList<ChatRoom>(
        key: _storageKey,
        fromJson: (json) => ChatRoom.fromJson(json),
      );
      if (roomsList.isNotEmpty) {
        state = roomsList;
      } else {
        // 기본 채팅방 생성 (학습 도우미)
        await _createDefaultChatRooms();
      }
    } catch (e) {
      logError('Failed to load chat rooms', error: e);
      await _createDefaultChatRooms();
    }
  }

  /// 기본 채팅방 생성
  Future<void> _createDefaultChatRooms() async {
    final now = DateTime.now();
    final assistantRoom = ChatRoom(
      id: 'assistant_main',
      name: '학습 도우미',
      type: ChatRoomType.assistant,
      participantIds: ['user', 'assistant'],
      iconUrl: null,
      lastMessage: '안녕하세요! 무엇을 도와드릴까요?',
      lastMessageTime: now,
      unreadCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    state = [assistantRoom];
    await _saveChatRooms();
  }

  /// 채팅방 목록 저장
  Future<void> _saveChatRooms() async {
    try {
      await storage.saveList<ChatRoom>(
        key: _storageKey,
        data: state,
        toJson: (room) => room.toJson(),
      );
    } catch (e) {
      logError('Failed to save chat rooms', error: e);
    }
  }

  /// 새 채팅방 생성
  Future<void> createChatRoom(ChatRoom room) async {
    state = [...state, room];
    await _saveChatRooms();
  }

  /// 채팅방 업데이트 (마지막 메시지, 읽지 않은 개수 등)
  Future<void> updateChatRoom(
    String roomId, {
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) async {
    state = state.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          unreadCount: unreadCount,
          updatedAt: DateTime.now(),
        );
      }
      return room;
    }).toList();

    await _saveChatRooms();
  }

  /// 읽지 않은 메시지 개수 초기화
  Future<void> markAsRead(String roomId) async {
    await updateChatRoom(roomId, unreadCount: 0);
  }

  /// 채팅방 삭제
  Future<void> deleteChatRoom(String roomId) async {
    state = state.where((room) => room.id != roomId).toList();
    await _saveChatRooms();
  }

  /// 새로고침
  Future<void> refresh() async {
    await _loadChatRooms();
  }
}

/// 특정 채팅방의 메시지 목록 프로바이더
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier,
    List<ChatMessage>, String>(
  (ref, roomId) => ChatMessagesNotifier(roomId),
);

/// 채팅 메시지 관리 노티파이어
class ChatMessagesNotifier extends BaseNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this.roomId) : super([], 'ChatMessagesNotifier') {
    _loadMessages();
  }

  final String roomId;
  String get _storageKey => 'chat_messages_$roomId';

  /// 메시지 목록 로드
  Future<void> _loadMessages() async {
    try {
      final messagesList = await storage.loadList<ChatMessage>(
        key: _storageKey,
        fromJson: (json) => ChatMessage.fromJson(json),
      );
      if (messagesList.isNotEmpty) {
        state = messagesList;
      } else if (roomId == 'assistant_main') {
        // 학습 도우미 채팅방의 초기 메시지
        await _createDefaultMessages();
      }
    } catch (e) {
      logError('Failed to load messages', error: e);
    }
  }

  /// 기본 메시지 생성 (학습 도우미)
  Future<void> _createDefaultMessages() async {
    final welcomeMessage = ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'assistant',
      senderName: '학습 도우미',
      content:
          '안녕하세요! 저는 여러분의 수학 학습을 도와드리는 AI 도우미입니다.\n\n수학 문제에 대한 질문이나 개념 설명이 필요하시면 언제든 물어보세요! 😊',
      type: 'text',
      sentAt: DateTime.now(),
      isRead: true,
    );

    state = [welcomeMessage];
    await _saveMessages();
  }

  /// 메시지 목록 저장
  Future<void> _saveMessages() async {
    try {
      await storage.saveList<ChatMessage>(
        key: _storageKey,
        data: state,
        toJson: (msg) => msg.toJson(),
      );
    } catch (e) {
      logError('Failed to save messages', error: e);
    }
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  }) async {
    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      sentAt: DateTime.now(),
      isRead: false,
    );

    state = [...state, newMessage];
    await _saveMessages();
  }

  /// 메시지 읽음 처리
  Future<void> markMessagesAsRead() async {
    state = state.map((msg) {
      if (!msg.isRead) {
        return msg.copyWith(isRead: true);
      }
      return msg;
    }).toList();

    await _saveMessages();
  }

  /// 메시지 삭제
  Future<void> deleteMessage(String messageId) async {
    state = state.where((msg) => msg.id != messageId).toList();
    await _saveMessages();
  }

  /// 새로고침
  Future<void> refresh() async {
    await _loadMessages();
  }
}
