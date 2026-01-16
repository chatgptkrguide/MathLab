import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/communication/message.dart';

/// 메시지 Repository (간소화 버전)
/// 
/// BaseRepository를 사용하지 않고 직접 Firebase 통신을 처리합니다.
class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'messages';

  /// 사용자의 모든 메시지 가져오기
  Future<List<Message>> getUserMessages(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Message.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  /// 메시지 생성
  Future<String> createMessage(Message message) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(message.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  /// 메시지 업데이트
  Future<void> updateMessage(Message message) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(message.id)
          .update(message.toJson());
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  /// 메시지 삭제
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// 읽지 않은 메시지 개수 가져오기
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}
