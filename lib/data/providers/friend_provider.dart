import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_provider.dart';
import 'base/base_notifier.dart';

/// 친구 목록 관리 노티파이어 (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - LocalStorageService 상속으로 필드 제거
class FriendsNotifier extends BaseNotifier<List<Friend>> {
  final Ref ref;

  FriendsNotifier(this.ref) : super([], 'FriendProvider') {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      logWarning('계정 정보 없음');
      return null;
    }
    return 'friends_${currentAccount.id}';
  }

  /// 초기화 및 데이터 로드
  Future<void> _initialize() async {
    await _loadFriends();
  }

  /// 친구 목록 로드
  Future<void> _loadFriends() async {
    await executeWithErrorHandling(
      () async {
        final key = _storageKey;
        if (key == null) {
          state = [];
          return;
        }

        final data = await loadListFromStorage(key);
        if (data != null) {
          final friendsList = data
              .map((item) => Friend.fromJson(item as Map<String, dynamic>))
              .toList();

          state = friendsList;
          if (friendsList.isNotEmpty) {
            logInfo('친구 ${friendsList.length}명 로드 완료');
          }
        } else {
          state = [];
        }
      },
      errorMessage: '친구 목록 로드 실패',
      fallback: () => state = [],
    );
  }

  /// 친구 목록 저장
  Future<void> _saveFriends() async {
    await executeWithErrorHandling(
      () async {
        final key = _storageKey;
        if (key == null) {
          logWarning('친구 저장 불가 - 계정 없음');
          return;
        }

        await saveListToStorage(
          key,
          state.map((friend) => friend.toJson()).toList(),
        );
        logInfo('친구 ${state.length}명 저장 완료');
      },
      errorMessage: '친구 목록 저장 실패',
    );
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

/// 친구 목록 프로바이더
final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  return FriendsNotifier(ref);
});
