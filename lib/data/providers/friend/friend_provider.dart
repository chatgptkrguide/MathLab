// 👥 Friend Provider
//
// Manages friend relationships and social features

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/friend_model.dart';
import '../api_provider.dart';

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

/// Friend Notifier
class FriendNotifier extends StateNotifier<FriendState> {
  final Ref _ref;
  final String userId;

  FriendNotifier(this._ref, this.userId) : super(const FriendState()) {
    loadFriends();
    loadFriendRequests();
    loadFriendActivities();
  }

  /// Load all friends
  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userAPI = _ref.read(userAPIProvider);

      final friendsData = await userAPI.getFriends(userId: userId);
      final friends = friendsData
          .map((data) => FriendModel.fromJson(data))
          .toList();

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

  /// Load friend requests
  Future<void> loadFriendRequests() async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      // Load pending requests (received)
      final pendingData =
          await userAPI.getPendingFriendRequests(userId: userId);
      final pendingRequests = pendingData
          .map((data) => FriendRequestModel.fromJson(data))
          .toList();

      // Load sent requests
      final sentData = await userAPI.getSentFriendRequests(userId: userId);
      final sentRequests = sentData
          .map((data) => FriendRequestModel.fromJson(data))
          .toList();

      state = state.copyWith(
        pendingRequests: pendingRequests,
        sentRequests: sentRequests,
      );

      AppLogger.info(
          'Loaded ${pendingRequests.length} pending and ${sentRequests.length} sent requests',
          tag: 'Friend');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Send friend request
  Future<bool> sendFriendRequest(String toUserId) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      await userAPI.sendFriendRequest(
        fromUserId: userId,
        toUserId: toUserId,
      );

      // Reload requests
      await loadFriendRequests();

      AppLogger.info('Friend request sent to $toUserId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      await userAPI.respondToFriendRequest(
        requestId: requestId,
        accept: true,
      );

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

  /// Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      await userAPI.respondToFriendRequest(
        requestId: requestId,
        accept: false,
      );

      // Reload requests
      await loadFriendRequests();

      AppLogger.info('Friend request rejected: $requestId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend(String friendId) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      await userAPI.removeFriend(
        userId: userId,
        friendId: friendId,
      );

      // Reload friends
      await loadFriends();

      AppLogger.info('Friend removed: $friendId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Block friend
  Future<bool> blockFriend(String friendId) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      await userAPI.blockFriend(
        userId: userId,
        friendId: friendId,
      );

      // Reload friends
      await loadFriends();

      AppLogger.info('Friend blocked: $friendId', tag: 'Friend');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Load friend activities
  Future<void> loadFriendActivities({int limit = 20}) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      final activitiesData = await userAPI.getFriendActivities(
        userId: userId,
        limit: limit,
      );

      final activities = activitiesData
          .map((data) => FriendActivityModel.fromJson(data))
          .toList();

      state = state.copyWith(friendActivities: activities);

      AppLogger.info('Loaded ${activities.length} friend activities', tag: 'Friend');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
    }
  }

  /// Search users by name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final userAPI = _ref.read(userAPIProvider);

      final results = await userAPI.searchUsers(
        query: query,
        excludeUserId: userId,
      );

      return results.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
      return [];
    }
  }
}

/// Friend Provider
final friendProvider =
    StateNotifierProvider.family<FriendNotifier, FriendState, String>(
  (ref, userId) => FriendNotifier(ref, userId),
);

/// Friend Suggestions Provider
final friendSuggestionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    final userAPI = ref.watch(userAPIProvider);

    try {
      final suggestions = await userAPI.getFriendSuggestions(
        userId: userId,
        limit: 10,
      );

      return suggestions.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
      return [];
    }
  },
);
