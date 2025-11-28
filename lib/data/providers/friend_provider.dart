import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';

/// 친구 목록 프로바이더
final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  return FriendsNotifier();
});

/// 친구 목록 관리 노티파이어
class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier() : super([]) {
    _loadFriends();
  }

  final LocalStorageService _storage = LocalStorageService();
  static const String _storageKey = 'friends';

  /// 친구 목록 로드
  Future<void> _loadFriends() async {
    try {
      final friendsList = await _storage.loadList<Friend>(
        key: _storageKey,
        fromJson: (json) => Friend.fromJson(json),
      );
      if (friendsList.isNotEmpty) {
        state = friendsList;
      }
    } catch (e) {
      print('Failed to load friends: $e');
    }
  }

  /// 친구 목록 저장
  Future<void> _saveFriends() async {
    try {
      await _storage.saveList<Friend>(
        key: _storageKey,
        data: state,
        toJson: (friend) => friend.toJson(),
      );
    } catch (e) {
      print('Failed to save friends: $e');
    }
  }

  /// 친구 요청 보내기
  Future<void> sendFriendRequest({
    required String userId,
    required String name,
    int level = 1,
    int xp = 0,
  }) async {
    final now = DateTime.now();
    final newFriend = Friend(
      id: 'friend_${now.millisecondsSinceEpoch}',
      userId: userId,
      name: name,
      level: level,
      xp: xp,
      status: FriendRequestStatus.pending,
      createdAt: now,
    );

    state = [...state, newFriend];
    await _saveFriends();
  }

  /// 친구 요청 수락
  Future<void> acceptFriendRequest(String friendId) async {
    state = state.map((friend) {
      if (friend.id == friendId) {
        return friend.copyWith(
          status: FriendRequestStatus.accepted,
          acceptedAt: DateTime.now(),
        );
      }
      return friend;
    }).toList();

    await _saveFriends();
  }

  /// 친구 요청 거절
  Future<void> rejectFriendRequest(String friendId) async {
    state = state.map((friend) {
      if (friend.id == friendId) {
        return friend.copyWith(status: FriendRequestStatus.rejected);
      }
      return friend;
    }).toList();

    await _saveFriends();
  }

  /// 친구 삭제
  Future<void> removeFriend(String friendId) async {
    state = state.where((friend) => friend.id != friendId).toList();
    await _saveFriends();
  }

  /// 수락된 친구 목록만 필터링
  List<Friend> get acceptedFriends {
    return state.where((f) => f.status == FriendRequestStatus.accepted).toList();
  }

  /// 대기 중인 친구 요청 목록
  List<Friend> get pendingRequests {
    return state.where((f) => f.status == FriendRequestStatus.pending).toList();
  }

  /// 새로고침
  Future<void> refresh() async {
    await _loadFriends();
  }
}
