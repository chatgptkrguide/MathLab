// Friend provider — friend activity feed
//
// part of friend_provider.dart. Owns loadFriendActivities.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'friend_provider.dart';

extension FriendActivities on FriendNotifier {
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
}
