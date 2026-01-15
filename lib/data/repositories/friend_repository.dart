import '../models/user/friend.dart';
import 'base/base_repository.dart';

/// 친구 Repository
///
/// 친구 데이터 CRUD 및 관리
/// - 친구 목록 조회
/// - 친구 요청 송수신
/// - 친구 검색
class FriendRepository extends BaseRepository<Friend> {
  FriendRepository()
      : super(
          collectionPath: 'friends',
          fromFirestore: Friend.fromFirestore,
          repositoryName: 'FriendRepository',
          enableCache: true,
          cacheDuration: const Duration(minutes: 5),
        );

  /// 사용자의 친구 목록 조회 (수락된 친구만)
  Future<RepositoryResult<List<Friend>>> getUserFriends(String userId) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: FriendRequestStatus.accepted.name)
          .orderBy('acceptedAt', descending: true),
    );
  }

  /// 친구 요청 목록 조회 (받은 요청)
  Future<RepositoryResult<List<Friend>>> getReceivedFriendRequests(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: FriendRequestStatus.pending.name)
          .orderBy('createdAt', descending: true),
    );
  }

  /// 친구 요청 목록 조회 (보낸 요청)
  Future<RepositoryResult<List<Friend>>> getSentFriendRequests(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: FriendRequestStatus.pending.name)
          .orderBy('createdAt', descending: true),
    );
  }

  /// 친구 요청 보내기
  Future<RepositoryResult<Friend>> sendFriendRequest(
    String fromUserId,
    String toUserId,
    String toUserName, {
    String? photoUrl,
    int level = 1,
    int xp = 0,
  }) async {
    try {
      final friendRequest = Friend(
        id: '${fromUserId}_$toUserId',
        userId: toUserId,
        name: toUserName,
        profileImageUrl: photoUrl,
        level: level,
        xp: xp,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      return create(friendRequest);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to send friend request: $e',
      );
    }
  }

  /// 친구 요청 수락
  Future<RepositoryResult<Friend>> acceptFriendRequest(
    String friendRequestId,
  ) async {
    try {
      final result = await getById(friendRequestId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          error: result.error ?? 'Friend request not found',
        );
      }

      final request = result.data!;
      final accepted = request.copyWith(
        status: FriendRequestStatus.accepted,
        acceptedAt: DateTime.now(),
      );

      return update(accepted);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to accept friend request: $e',
      );
    }
  }

  /// 친구 요청 거절
  Future<RepositoryResult<Friend>> rejectFriendRequest(
    String friendRequestId,
  ) async {
    try {
      final result = await getById(friendRequestId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          error: result.error ?? 'Friend request not found',
        );
      }

      final request = result.data!;
      final rejected = request.copyWith(
        status: FriendRequestStatus.rejected,
      );

      return update(rejected);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to reject friend request: $e',
      );
    }
  }

  /// 친구 삭제
  Future<RepositoryResult<void>> removeFriend(String friendId) async {
    return delete(friendId);
  }

  /// 친구 검색 (이름으로)
  Future<RepositoryResult<List<Friend>>> searchFriends(
    String userId,
    String searchQuery,
  ) async {
    try {
      // Firebase에서 부분 검색은 제한적이므로, 전체 친구 목록을 가져와서 필터링
      final result = await getUserFriends(userId);

      if (!result.isSuccess || result.data == null) {
        return result;
      }

      final filtered = result.data!
          .where((friend) =>
              friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      return RepositoryResult.success(data: filtered);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to search friends: $e',
      );
    }
  }

  /// 친구 관계 확인
  Future<RepositoryResult<bool>> areFriends(
    String userId1,
    String userId2,
  ) async {
    try {
      final id1 = '${userId1}_$userId2';
      final id2 = '${userId2}_$userId1';

      final result1 = await getById(id1);
      if (result1.isSuccess &&
          result1.data != null &&
          result1.data!.status == FriendRequestStatus.accepted) {
        return RepositoryResult.success(data: true);
      }

      final result2 = await getById(id2);
      if (result2.isSuccess &&
          result2.data != null &&
          result2.data!.status == FriendRequestStatus.accepted) {
        return RepositoryResult.success(data: true);
      }

      return RepositoryResult.success(data: false);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to check friend relationship: $e',
      );
    }
  }

  /// 친구 수 조회
  Future<RepositoryResult<int>> getFriendCount(String userId) async {
    try {
      final result = await getUserFriends(userId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.success(data: 0);
      }

      return RepositoryResult.success(data: result.data!.length);
    } catch (e) {
      return RepositoryResult.failure(
        error: 'Failed to get friend count: $e',
      );
    }
  }
}
