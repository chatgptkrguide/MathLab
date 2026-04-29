// Friend Provider
//
// Manages friend relationships and social features using Firestore directly.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/friend_model.dart';

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

  /// Load all friends from the user's friends subcollection
  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _userFriendsRef(userId).get();

      final friends = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FriendModel(
          id: doc.id,
          userId: userId,
          friendId: data['friendId'] as String? ?? doc.id,
          friendName: data['displayName'] as String? ?? '',
          friendAvatar: data['avatarUrl'] as String?,
          status: FriendshipStatus.accepted,
          createdAt: _parseTimestamp(data['addedAt']),
          acceptedAt: _parseTimestamp(data['addedAt']),
        );
      }).toList();

      state = state.copyWith(
        friends: friends,
        isLoading: false,
      );

      AppLogger.info('Loaded ${friends.length} friends', tag: 'Friend');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: appError.userMessage,
      );
    }
  }

  /// Load friend requests (both pending received and sent)
  Future<void> loadFriendRequests() async {
    try {
      // Load pending requests (received)
      final pendingSnapshot = await _friendRequestsRef
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final pendingRequests = await Future.wait(
        pendingSnapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          final fromUserId = data['fromUserId'] as String;

          // Fetch sender's display name (best-effort — 실패해도 요청 표시 자체는 진행)
          String fromUserName = '';
          String? fromUserAvatar;
          try {
            final userDoc =
                await _firestore.collection('users').doc(fromUserId).get();
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              fromUserName = userData['displayName'] as String? ?? '';
              fromUserAvatar = userData['avatarUrl'] as String?;
            }
          } catch (e) {
            AppLogger.warning(
              'Failed to fetch sender info for friend request',
              tag: 'Friend',
              error: e,
              data: {'fromUserId': fromUserId},
            );
          }

          return FriendRequestModel(
            id: doc.id,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
            fromUserAvatar: fromUserAvatar,
            toUserId: data['toUserId'] as String,
            status: RequestStatus.pending,
            createdAt: _parseTimestamp(data['createdAt']),
          );
        }),
      );

      // Load sent requests
      final sentSnapshot = await _friendRequestsRef
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final sentRequests = sentSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FriendRequestModel(
          id: doc.id,
          fromUserId: data['fromUserId'] as String,
          fromUserName: '',
          toUserId: data['toUserId'] as String,
          status: RequestStatus.pending,
          createdAt: _parseTimestamp(data['createdAt']),
        );
      }).toList();

      state = state.copyWith(
        pendingRequests: pendingRequests,
        sentRequests: sentRequests,
      );

      AppLogger.info(
        'Loaded ${pendingRequests.length} pending and ${sentRequests.length} sent requests',
        tag: 'Friend',
      );
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Send a friend request
  Future<bool> sendFriendRequest(String toUserId) async {
    try {
      // Check if request already exists
      final existing = await _friendRequestsRef
          .where('fromUserId', isEqualTo: userId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        state = state.copyWith(error: '이미 친구 요청을 보냈습니다.');
        return false;
      }

      // Check if already friends
      final friendDoc = await _userFriendsRef(userId).doc(toUserId).get();
      if (friendDoc.exists) {
        state = state.copyWith(error: '이미 친구입니다.');
        return false;
      }

      await _friendRequestsRef.add({
        'fromUserId': userId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadFriendRequests();

      AppLogger.info('Friend request sent to $toUserId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final requestDoc = await _friendRequestsRef.doc(requestId).get();
      if (!requestDoc.exists) {
        state = state.copyWith(error: '요청을 찾을 수 없습니다.');
        return false;
      }

      final requestData = requestDoc.data() as Map<String, dynamic>;
      final fromUserId = requestData['fromUserId'] as String;
      final toUserId = requestData['toUserId'] as String;

      // Fetch both users' info for the friend records
      String fromName = '';
      String? fromAvatar;
      String toName = '';
      String? toAvatar;

      try {
        final fromUserDoc =
            await _firestore.collection('users').doc(fromUserId).get();
        if (fromUserDoc.exists) {
          fromName = fromUserDoc.data()!['displayName'] as String? ?? '';
          fromAvatar = fromUserDoc.data()!['avatarUrl'] as String?;
        }
        final toUserDoc =
            await _firestore.collection('users').doc(toUserId).get();
        if (toUserDoc.exists) {
          toName = toUserDoc.data()!['displayName'] as String? ?? '';
          toAvatar = toUserDoc.data()!['avatarUrl'] as String?;
        }
      } catch (e) {
        // best-effort — 이름이 비어도 친구 관계 자체는 성립시킨다.
        AppLogger.warning(
          'Failed to fetch user profiles when accepting friend request',
          tag: 'Friend',
          error: e,
          data: {'fromUserId': fromUserId, 'toUserId': toUserId},
        );
      }

      // Use a batch write for atomicity
      final batch = _firestore.batch();

      // Update request status
      batch.update(_friendRequestsRef.doc(requestId), {
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Add to sender's friends subcollection
      batch.set(_userFriendsRef(fromUserId).doc(toUserId), {
        'friendId': toUserId,
        'displayName': toName,
        'avatarUrl': toAvatar,
        'addedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Add to receiver's friends subcollection
      batch.set(_userFriendsRef(toUserId).doc(fromUserId), {
        'friendId': fromUserId,
        'displayName': fromName,
        'avatarUrl': fromAvatar,
        'addedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      await batch.commit();

      // Reload friends and requests
      await Future.wait([
        loadFriends(),
        loadFriendRequests(),
      ]);

      AppLogger.info('Friend request accepted: $requestId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Reject a friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _friendRequestsRef.doc(requestId).update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await loadFriendRequests();

      AppLogger.info('Friend request rejected: $requestId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Remove a friend from both users' subcollections
  Future<bool> removeFriend(String friendId) async {
    try {
      final batch = _firestore.batch();

      // Remove from current user's friends
      batch.delete(_userFriendsRef(userId).doc(friendId));

      // Remove from friend's friends
      batch.delete(_userFriendsRef(friendId).doc(userId));

      await batch.commit();

      await loadFriends();

      AppLogger.info('Friend removed: $friendId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Block a friend (remove + add to blocked list)
  Future<bool> blockFriend(String friendId) async {
    try {
      final batch = _firestore.batch();

      // Remove from both users' friends
      batch.delete(_userFriendsRef(userId).doc(friendId));
      batch.delete(_userFriendsRef(friendId).doc(userId));

      // Add to blocked list
      batch.set(
        _firestore.collection('users').doc(userId).collection('blocked').doc(friendId),
        {
          'blockedUserId': friendId,
          'blockedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      await loadFriends();

      AppLogger.info('Friend blocked: $friendId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Load friend activities (recent lesson completions from friends)
  Future<void> loadFriendActivities({int limit = 20}) async {
    try {
      final friendIds = state.friends.map((f) => f.friendId).toList();
      if (friendIds.isEmpty) {
        state = state.copyWith(friendActivities: []);
        return;
      }

      // Firestore 'whereIn' supports max 30 items per query
      final chunks = <List<String>>[];
      for (var i = 0; i < friendIds.length; i += 30) {
        chunks.add(
          friendIds.sublist(
            i,
            i + 30 > friendIds.length ? friendIds.length : i + 30,
          ),
        );
      }

      final allActivities = <FriendActivityModel>[];

      for (final chunk in chunks) {
        final snapshot = await _firestore
            .collection('activities')
            .where('userId', whereIn: chunk)
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .get();

        final activities = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return FriendActivityModel.fromJson({
            ...data,
            'timestamp': _parseTimestamp(data['timestamp']).toIso8601String(),
          });
        }).toList();

        allActivities.addAll(activities);
      }

      // Sort by timestamp descending and take the limit
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final trimmed = allActivities.take(limit).toList();

      state = state.copyWith(friendActivities: trimmed);

      AppLogger.info(
        'Loaded ${trimmed.length} friend activities',
        tag: 'Friend',
      );
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Search users by display name (prefix search)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final trimmed = query.trim();
      // Prefix search: >= query and < query with last char incremented
      final endQuery = trimmed.substring(0, trimmed.length - 1) +
          String.fromCharCode(trimmed.codeUnitAt(trimmed.length - 1) + 1);

      final snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: trimmed)
          .where('displayName', isLessThan: endQuery)
          .limit(20)
          .get();

      final results = snapshot.docs
          .where((doc) => doc.id != userId) // Exclude self
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return results;
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
      return [];
    }
  }

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
