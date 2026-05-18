// Friend provider — friend request flows
//
// part of friend_provider.dart. Owns send / accept / reject / load requests.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'friend_provider.dart';

extension FriendRequests on FriendNotifier {
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
            // exists 와 data() 사이의 race (동시 삭제 등) 로 data() 가 null 일 수 있어
            // ! 대신 null-safe 접근으로 변경.
            final userData = userDoc.data();
            if (userData != null) {
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
}
