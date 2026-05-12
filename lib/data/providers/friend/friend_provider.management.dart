// Friend provider — friend list management
//
// part of friend_provider.dart. Owns loadFriends / removeFriend / blockFriend /
// searchUsers.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'friend_provider.dart';

extension FriendManagement on FriendNotifier {
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
}
