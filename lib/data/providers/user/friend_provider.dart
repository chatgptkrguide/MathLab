/// 👥 User Friend Provider
///
/// Provides friend-related state for the leaderboard and user features.
/// This file bridges the friend system with the leaderboard UI.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 친구 요청 상태
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
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FriendsNotifier(this._ref) : super(const []) {
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
    } catch (e) {
      // 오류 시 빈 목록 유지
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
