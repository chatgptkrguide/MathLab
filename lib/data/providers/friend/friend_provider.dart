// Friend Provider
//
// Manages friend relationships and social features using Firestore directly.
//
// This file owns the state class, notifier constructor / fields / shared helpers,
// and the provider registrations. Method implementations are split into part files
// by responsibility:
//   * friend_provider.requests.dart    — send / accept / reject / load requests
//   * friend_provider.management.dart  — load / remove / block / search
//   * friend_provider.activities.dart  — friend activity feed
// Splitting uses Dart `part` so that private fields (_firestore, refs, _parseTimestamp)
// remain accessible from extensions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/friend_model.dart';

part 'friend_provider.requests.dart';
part 'friend_provider.management.dart';
part 'friend_provider.activities.dart';

/// Friend State
class FriendState {
  final List<FriendModel> friends;
  final List<FriendRequestModel> pendingRequests;
  final List<FriendRequestModel> sentRequests;
  final List<FriendActivityModel> friendActivities;
  final bool isLoading;
  final String? error;

  const FriendState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.sentRequests = const [],
    this.friendActivities = const [],
    this.isLoading = false,
    this.error,
  });

  FriendState copyWith({
    List<FriendModel>? friends,
    List<FriendRequestModel>? pendingRequests,
    List<FriendRequestModel>? sentRequests,
    List<FriendActivityModel>? friendActivities,
    bool? isLoading,
    String? error,
  }) {
    return FriendState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      friendActivities: friendActivities ?? this.friendActivities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get total friend count
  int get friendCount => friends.length;

  /// Get pending request count
  int get pendingRequestCount => pendingRequests.length;

  /// Check if user is a friend
  bool isFriend(String userId) {
    return friends.any((f) => f.friendId == userId && f.isActive);
  }

  /// Check if friend request already sent
  bool hasRequestSent(String userId) {
    return sentRequests.any((r) => r.toUserId == userId && r.isPending);
  }

  /// Get friend by ID
  FriendModel? getFriend(String userId) {
    try {
      return friends.firstWhere((f) => f.friendId == userId);
    } catch (e) {
      return null;
    }
  }
}

/// Friend Notifier - uses Firestore directly
class FriendNotifier extends StateNotifier<FriendState> {
  final String userId;
  final FirebaseFirestore _firestore;

  FriendNotifier(this.userId, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const FriendState()) {
    loadFriends();
    loadFriendRequests();
    loadFriendActivities();
  }

  /// Reference helpers
  CollectionReference get _friendRequestsRef =>
      _firestore.collection('friend_requests');

  CollectionReference _userFriendsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('friends');

  /// Parse Firestore Timestamp or ISO string to DateTime
  DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}

/// Friend Provider
final friendProvider =
    StateNotifierProvider.family<FriendNotifier, FriendState, String>(
  (ref, userId) => FriendNotifier(userId),
);

/// Friend Suggestions Provider
final friendSuggestionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get current user's friend IDs
      final friendsSnapshot =
          await firestore.collection('users').doc(userId).collection('friends').get();
      final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toSet();
      friendIds.add(userId); // Exclude self

      // Get some users who are not yet friends
      final usersSnapshot = await firestore
          .collection('users')
          .limit(20)
          .get();

      final suggestions = usersSnapshot.docs
          .where((doc) => !friendIds.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return suggestions.take(10).toList();
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
      return [];
    }
  },
);

// ─── Leaderboard-oriented Friend Provider ───

/// 친구 요청 상태 (리더보드용)
enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  blocked,
}

/// 간소화된 친구 정보 (리더보드용)
class FriendInfo {
  final String userId;
  final String name;
  final int level;
  final int xp;
  final FriendRequestStatus status;

  const FriendInfo({
    required this.userId,
    required this.name,
    required this.level,
    required this.xp,
    required this.status,
  });
}

/// 친구 목록 Notifier (리더보드용)
class FriendsNotifier extends StateNotifier<List<FriendInfo>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FriendsNotifier(Ref ref) : super(const []) {
    _loadFriends();
  }

  /// 친구 목록 로드
  Future<void> _loadFriends() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await _firestore
          .collection('friends')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .get();

      final friends = snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendInfo(
          userId: data['toUserId'] as String? ?? '',
          name: data['name'] as String? ?? '',
          level: data['level'] as int? ?? 1,
          xp: data['xp'] as int? ?? 0,
          status: _parseStatus(data['status'] as String? ?? 'pending'),
        );
      }).toList();

      // 받은 요청도 추가
      final receivedSnapshot = await _firestore
          .collection('friends')
          .where('toUserId', isEqualTo: currentUser.uid)
          .get();

      final receivedFriends = receivedSnapshot.docs.map((doc) {
        final data = doc.data();
        return FriendInfo(
          userId: data['fromUserId'] as String? ?? '',
          name: data['name'] as String? ?? '',
          level: data['level'] as int? ?? 1,
          xp: data['xp'] as int? ?? 0,
          status: _parseStatus(data['status'] as String? ?? 'pending'),
        );
      }).toList();

      state = [...friends, ...receivedFriends];
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to load friends (leaderboard)',
        tag: 'Friend',
        error: e,
        stackTrace: stackTrace,
      );
      state = const [];
    }
  }

  /// 상태 문자열 파싱
  FriendRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      case 'blocked':
        return FriendRequestStatus.blocked;
      default:
        return FriendRequestStatus.pending;
    }
  }

  /// 친구 요청 보내기
  Future<void> sendFriendRequest({
    required String userId,
    required String name,
    required int level,
    required int xp,
  }) async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('로그인이 필요합니다');

      await _firestore.collection('friends').add({
        'fromUserId': currentUser.uid,
        'toUserId': userId,
        'name': name,
        'level': level,
        'xp': xp,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 로컬 상태 업데이트
      state = [
        ...state,
        FriendInfo(
          userId: userId,
          name: name,
          level: level,
          xp: xp,
          status: FriendRequestStatus.pending,
        ),
      ];
    } catch (e) {
      throw Exception('친구 요청을 보내는데 실패했습니다: $e');
    }
  }

  /// 친구 목록 새로고침
  Future<void> refresh() async {
    await _loadFriends();
  }
}

/// 친구 목록 Provider (리더보드용)
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, List<FriendInfo>>(
  (ref) => FriendsNotifier(ref),
);
