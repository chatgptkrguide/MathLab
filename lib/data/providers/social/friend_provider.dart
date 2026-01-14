import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/logger.dart';
import '../../models/user/user.dart' as user_model;

/// 친구 관계 상태
enum FriendshipStatus {
  none, // 친구 아님
  pending, // 요청 대기중
  accepted, // 친구
  blocked, // 차단됨
}

/// 친구 요청 모델
class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserPhotoUrl;
  final String toUserId;
  final DateTime createdAt;
  final FriendshipStatus status;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserPhotoUrl,
    required this.toUserId,
    required this.createdAt,
    required this.status,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      fromUserPhotoUrl: data['fromUserPhotoUrl'] ?? '',
      toUserId: data['toUserId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => FriendshipStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'toUserId': toUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }
}

/// 친구 활동 모델
class FriendActivity {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String activityType; // 'level_up', 'achievement', 'lesson_complete'
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  FriendActivity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory FriendActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendActivity(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      activityType: data['activityType'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'activityType': activityType,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// 친구 시스템 Provider
class FriendProvider extends StateNotifier<AsyncValue<List<user_model.User>>> {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  FriendProvider({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        super(const AsyncValue.loading()) {
    _initialize();
  }

  String? get _currentUserId => _auth.currentUser?.uid;

  /// 초기화 및 친구 목록 로드
  Future<void> _initialize() async {
    if (_currentUserId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      await loadFriends();
    } catch (e, stack) {
      Logger.error('친구 목록 로드 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 친구 목록 로드
  Future<void> loadFriends() async {
    if (_currentUserId == null) return;

    try {
      state = const AsyncValue.loading();

      // 친구 관계 조회
      final friendshipsSnapshot = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'accepted')
          .get();

      if (friendshipsSnapshot.docs.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      // 친구 ID 목록 추출
      final friendIds = friendshipsSnapshot.docs
          .map((doc) => doc.data()['friendId'] as String)
          .toList();

      // 친구 정보 조회 (배치로 10개씩)
      final List<user_model.User> friends = [];
      for (var i = 0; i < friendIds.length; i += 10) {
        final batch = friendIds.skip(i).take(10).toList();
        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        friends.addAll(
          usersSnapshot.docs.map((doc) => user_model.User.fromFirestore(doc)),
        );
      }

      state = AsyncValue.data(friends);
      Logger.info('친구 목록 로드 완료: ${friends.length}명');
    } catch (e, stack) {
      Logger.error('친구 목록 로드 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 친구 요청 보내기
  Future<bool> sendFriendRequest(String targetUserId) async {
    if (_currentUserId == null) return false;
    if (_currentUserId == targetUserId) return false;

    try {
      // 현재 사용자 정보 가져오기
      final currentUserDoc =
          await _firestore.collection('users').doc(_currentUserId).get();
      final currentUser = user_model.User.fromFirestore(currentUserDoc);

      // 이미 요청이 있는지 확인
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: _currentUserId)
          .where('toUserId', isEqualTo: targetUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        Logger.warning('이미 친구 요청을 보냈습니다');
        return false;
      }

      // 친구 요청 생성
      final request = FriendRequest(
        id: '',
        fromUserId: _currentUserId!,
        fromUserName: currentUser.name,
        fromUserPhotoUrl: currentUser.photoUrl ?? '',
        toUserId: targetUserId,
        createdAt: DateTime.now(),
        status: FriendshipStatus.pending,
      );

      await _firestore.collection('friend_requests').add(request.toFirestore());

      Logger.analytics('friend_request_sent', parameters: {
        'target_user_id': targetUserId,
      });

      return true;
    } catch (e, stack) {
      Logger.error('친구 요청 실패', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 친구 요청 수락
  Future<bool> acceptFriendRequest(String requestId) async {
    if (_currentUserId == null) return false;

    try {
      // 요청 정보 가져오기
      final requestDoc = await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) return false;

      final request = FriendRequest.fromFirestore(requestDoc);

      // 친구 관계 생성 (양방향)
      final batch = _firestore.batch();

      // User A -> User B
      batch.set(
        _firestore.collection('friendships').doc(),
        {
          'userId': request.toUserId,
          'friendId': request.fromUserId,
          'status': 'accepted',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // User B -> User A
      batch.set(
        _firestore.collection('friendships').doc(),
        {
          'userId': request.fromUserId,
          'friendId': request.toUserId,
          'status': 'accepted',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // 요청 상태 업데이트
      batch.update(
        _firestore.collection('friend_requests').doc(requestId),
        {
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      // 친구 목록 새로고침
      await loadFriends();

      Logger.analytics('friend_request_accepted', parameters: {
        'from_user_id': request.fromUserId,
      });

      return true;
    } catch (e, stack) {
      Logger.error('친구 요청 수락 실패', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 친구 요청 거절
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e, stack) {
      Logger.error('친구 요청 거절 실패', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 친구 삭제
  Future<bool> removeFriend(String friendId) async {
    if (_currentUserId == null) return false;

    try {
      // 양방향 친구 관계 삭제
      final batch = _firestore.batch();

      // User -> Friend 관계 삭제
      final friendship1 = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .where('friendId', isEqualTo: friendId)
          .get();

      for (var doc in friendship1.docs) {
        batch.delete(doc.reference);
      }

      // Friend -> User 관계 삭제
      final friendship2 = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: friendId)
          .where('friendId', isEqualTo: _currentUserId)
          .get();

      for (var doc in friendship2.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // 친구 목록 새로고침
      await loadFriends();

      Logger.analytics('friend_removed', parameters: {
        'friend_id': friendId,
      });

      return true;
    } catch (e, stack) {
      Logger.error('친구 삭제 실패', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 받은 친구 요청 목록
  Stream<List<FriendRequest>> getPendingRequests() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FriendRequest.fromFirestore(doc)).toList());
  }

  /// 친구 활동 피드
  Stream<List<FriendActivity>> getFriendActivities() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return state.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Stream.value([]);
        }

        final friendIds = friends.map((f) => f.id).toList();

        return _firestore
            .collection('user_activities')
            .where('userId', whereIn: friendIds.take(10).toList())
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => FriendActivity.fromFirestore(doc))
                .toList());
      },
      loading: () => Stream.value([]),
      error: (_, __) => Stream.value([]),
    );
  }

  /// 활동 기록하기
  Future<void> recordActivity({
    required String activityType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUserId == null) return;

    try {
      final userDoc =
          await _firestore.collection('users').doc(_currentUserId).get();
      final user = user_model.User.fromFirestore(userDoc);

      final activity = FriendActivity(
        id: '',
        userId: _currentUserId!,
        userName: user.name,
        userPhotoUrl: user.photoUrl ?? '',
        activityType: activityType,
        description: description,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      await _firestore.collection('user_activities').add(activity.toFirestore());
    } catch (e, stack) {
      Logger.error('활동 기록 실패', error: e, stackTrace: stack);
    }
  }
}

/// Provider 정의
final friendProvider =
    StateNotifierProvider<FriendProvider, AsyncValue<List<user_model.User>>>((ref) {
  return FriendProvider();
});

/// 친구 요청 목록 Provider
final pendingFriendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final friendProviderInstance = ref.watch(friendProvider.notifier);
  return friendProviderInstance.getPendingRequests();
});

/// 친구 활동 피드 Provider
final friendActivitiesProvider = StreamProvider<List<FriendActivity>>((ref) {
  final friendProviderInstance = ref.watch(friendProvider.notifier);
  return friendProviderInstance.getFriendActivities();
});
