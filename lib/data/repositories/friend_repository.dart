import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/friend.dart';

/// 친구 관계 데이터 저장소
class FriendRepository {
  final FirebaseFirestore _firestore;

  FriendRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 친구 요청 보내기
  Future<void> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      await _firestore.collection('friends').add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('친구 요청 전송에 실패했습니다: $e');
    }
  }

  /// 친구 요청 수락
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _firestore.collection('friends').doc(friendshipId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('친구 요청 수락에 실패했습니다: $e');
    }
  }

  /// 친구 요청 거절
  Future<void> rejectFriendRequest(String friendshipId) async {
    try {
      await _firestore.collection('friends').doc(friendshipId).update({
        'status': 'rejected',
      });
    } catch (e) {
      throw Exception('친구 요청 거절에 실패했습니다: $e');
    }
  }

  /// 친구 삭제
  Future<void> removeFriend(String friendshipId) async {
    try {
      await _firestore.collection('friends').doc(friendshipId).delete();
    } catch (e) {
      throw Exception('친구 삭제에 실패했습니다: $e');
    }
  }

  /// 내 친구 목록 가져오기 (승인된 친구만)
  Future<List<Friend>> getMyFriends(String userId) async {
    try {
      // 내가 보낸 요청 중 승인된 것
      final sentSnapshot = await _firestore
          .collection('friends')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // 내가 받은 요청 중 승인된 것
      final receivedSnapshot = await _firestore
          .collection('friends')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final friends = <Friend>[];

      for (final doc in sentSnapshot.docs) {
        friends.add(Friend.fromFirestore(doc));
      }

      for (final doc in receivedSnapshot.docs) {
        friends.add(Friend.fromFirestore(doc));
      }

      return friends;
    } catch (e) {
      throw Exception('친구 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 받은 친구 요청 목록 가져오기 (대기 중인 것만)
  Future<List<Friend>> getPendingFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.map((doc) => Friend.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('친구 요청 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 보낸 친구 요청 목록 가져오기
  Future<List<Friend>> getSentFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.map((doc) => Friend.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('보낸 요청 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 친구 관계 확인
  Future<bool> isFriend(String userId, String friendId) async {
    try {
      // 내가 보낸 요청 확인
      final sentSnapshot = await _firestore
          .collection('friends')
          .where('fromUserId', isEqualTo: userId)
          .where('toUserId', isEqualTo: friendId)
          .where('status', isEqualTo: 'accepted')
          .get();

      if (sentSnapshot.docs.isNotEmpty) return true;

      // 내가 받은 요청 확인
      final receivedSnapshot = await _firestore
          .collection('friends')
          .where('fromUserId', isEqualTo: friendId)
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      return receivedSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 친구 요청 상태 확인
  Future<String?> getFriendRequestStatus(
      String fromUserId, String toUserId) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return snapshot.docs.first.data()['status'] as String?;
    } catch (e) {
      return null;
    }
  }
}
