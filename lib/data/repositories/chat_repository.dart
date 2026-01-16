import '../models/communication/chat_room.dart';
import 'base/base_repository.dart';

export '../models/communication/chat_room.dart' show ChatRoomType;

class ChatRepository extends BaseRepository<ChatRoom> {
  ChatRepository()
      : super(
          collectionPath: 'chat_rooms',
          fromFirestore: ChatRoom.fromFirestore,
          repositoryName: 'ChatRepository',
          enableCache: false,
        );

  Future<RepositoryResult<List<ChatRoom>>> getUserChatRooms(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true),
    );
  }

  Future<RepositoryResult<ChatRoom?>> getChatRoomBetweenUsers(
    String userId1,
    String userId2,
  ) async {
    final result = await query(
      (ref) => ref.where('participantIds', arrayContainsAny: [userId1, userId2]),
    );

    if (result.isSuccess && result.data != null) {
      for (final room in result.data!) {
        if (room.participantIds.contains(userId1) &&
            room.participantIds.contains(userId2)) {
          return RepositoryResult.success(room);
        }
      }
    }
    return RepositoryResult.success(null);
  }

  Future<RepositoryResult<ChatRoom>> createChatRoom(
    List<String> participantIds, {
    String? name,
    ChatRoomType type = ChatRoomType.direct,
  }) async {
    final now = DateTime.now();
    final chatRoomId = '${participantIds.join('_')}_${now.millisecondsSinceEpoch}';

    final chatRoom = ChatRoom(
      id: chatRoomId,
      name: name ?? '채팅방',
      type: type,
      participantIds: participantIds,
      createdAt: now,
      updatedAt: now,
    );

    final createResult = await create(chatRoom);
    if (!createResult.isSuccess) {
      return RepositoryResult.failure(
        createResult.error ?? 'Failed to create chat room',
      );
    }

    return RepositoryResult.success(chatRoom);
  }
}
