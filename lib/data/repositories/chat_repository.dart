import '../models/communication/chat_room.dart';
import 'base/base_repository.dart';

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
          return RepositoryResult.success(data: room);
        }
      }
    }
    return RepositoryResult.success(data: null);
  }

  Future<RepositoryResult<ChatRoom>> createChatRoom(
    List<String> participantIds,
  ) async {
    final chatRoom = ChatRoom(
      id: '',
      participantIds: participantIds,
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );
    return create(chatRoom);
  }
}
