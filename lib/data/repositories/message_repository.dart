import '../models/communication/message.dart';
import 'base/base_repository.dart';

/// 메시지 Repository
///
/// 메시지 데이터 CRUD 및 관리
/// - 메시지 송수신
/// - 메시지 목록 조회
/// - 읽음 처리
class MessageRepository extends BaseRepository<Message> {
  MessageRepository()
      : super(
          collectionPath: 'messages',
          fromFirestore: Message.fromFirestore,
          repositoryName: 'MessageRepository',
          enableCache: false, // 실시간 메시지는 캐싱하지 않음
        );

  /// 사용자의 받은 메시지함 조회
  Future<RepositoryResult<List<Message>>> getInboxMessages(
    String userId, {
    int limit = 50,
  }) async {
    return query(
      (ref) => ref
          .where('receiverId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(limit),
    );
  }

  /// 사용자의 보낸 메시지함 조회
  Future<RepositoryResult<List<Message>>> getSentMessages(
    String userId, {
    int limit = 50,
  }) async {
    return query(
      (ref) => ref
          .where('senderId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(limit),
    );
  }

  /// 특정 사용자와의 메시지 내역 조회
  Future<RepositoryResult<List<Message>>> getConversation(
    String userId1,
    String userId2, {
    int limit = 100,
  }) async {
    try {
      // userId1이 보낸 메시지
      final sentResult = await query(
        (ref) => ref
            .where('senderId', isEqualTo: userId1)
            .where('receiverId', isEqualTo: userId2)
            .orderBy('sentAt', descending: true)
            .limit(limit),
      );

      // userId1이 받은 메시지
      final receivedResult = await query(
        (ref) => ref
            .where('senderId', isEqualTo: userId2)
            .where('receiverId', isEqualTo: userId1)
            .orderBy('sentAt', descending: true)
            .limit(limit),
      );

      final allMessages = <Message>[];
      if (sentResult.isSuccess && sentResult.data != null) {
        allMessages.addAll(sentResult.data!);
      }
      if (receivedResult.isSuccess && receivedResult.data != null) {
        allMessages.addAll(receivedResult.data!);
      }

      // 시간순 정렬
      allMessages.sort((a, b) => b.sentAt.compareTo(a.sentAt));

      return RepositoryResult.success(data: allMessages);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to get conversation: $e',
      );
    }
  }

  /// 읽지 않은 메시지 수 조회
  Future<RepositoryResult<int>> getUnreadCount(String userId) async {
    try {
      final snapshot = await firestore
          .collection(collectionPath)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return RepositoryResult.success(data: snapshot.count ?? 0);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to get unread count: $e',
      );
    }
  }

  /// 메시지 읽음 처리
  Future<RepositoryResult<Message>> markAsRead(String messageId) async {
    try {
      final result = await getById(messageId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          error: result.error ?? 'Message not found',
        );
      }

      final message = result.data!;
      if (message.isRead) {
        return RepositoryResult.success(data: message);
      }

      final read = message.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );

      return update(read);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to mark message as read: $e',
      );
    }
  }

  /// 메시지 전송
  Future<RepositoryResult<Message>> sendMessage(
    String senderId,
    String receiverId,
    String content, {
    String? subject,
  }) async {
    try {
      final message = Message(
        id: '', // Firestore가 자동 생성
        senderId: senderId,
        receiverId: receiverId,
        subject: subject ?? '',
        content: content,
        sentAt: DateTime.now(),
        isRead: false,
      );

      return create(message);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to send message: $e',
      );
    }
  }

  /// 메시지 삭제 (소프트 삭제)
  Future<RepositoryResult<Message>> markAsDeleted(
    String messageId,
    String userId,
  ) async {
    try {
      final result = await getById(messageId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          error: result.error ?? 'Message not found',
        );
      }

      final message = result.data!;

      // 발신자인 경우
      if (message.senderId == userId) {
        final deleted = message.copyWith(deletedBySender: true);
        return update(deleted);
      }
      // 수신자인 경우
      else if (message.receiverId == userId) {
        final deleted = message.copyWith(deletedByReceiver: true);
        return update(deleted);
      }

      return RepositoryResult.failure(
        error: 'User is not sender or receiver of this message',
      );
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to delete message: $e',
      );
    }
  }

  /// 사용자가 볼 수 있는 메시지만 필터링
  List<Message> filterVisibleMessages(List<Message> messages, String userId) {
    return messages.where((message) {
      if (message.senderId == userId && message.deletedBySender == true) {
        return false;
      }
      if (message.receiverId == userId && message.deletedByReceiver == true) {
        return false;
      }
      return true;
    }).toList();
  }

  /// 특정 발신자의 모든 메시지 읽음 처리
  Future<RepositoryResult<int>> markAllAsReadFromSender(
    String receiverId,
    String senderId,
  ) async {
    try {
      final unreadMessages = await query(
        (ref) => ref
            .where('receiverId', isEqualTo: receiverId)
            .where('senderId', isEqualTo: senderId)
            .where('isRead', isEqualTo: false),
      );

      if (!unreadMessages.isSuccess || unreadMessages.data == null) {
        return RepositoryResult.success(data: 0);
      }

      int count = 0;
      for (final message in unreadMessages.data!) {
        final result = await markAsRead(message.id);
        if (result.isSuccess) count++;
      }

      return RepositoryResult.success(data: count);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to mark all as read: $e',
      );
    }
  }
}
