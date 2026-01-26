import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';

/// 업적(Achievement) 데이터 저장소
class AchievementRepository {
  final FirebaseFirestore _firestore;

  AchievementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 모든 업적 목록 가져오기
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final snapshot = await _firestore.collection('achievements').get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('업적 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 특정 업적 가져오기
  Future<AchievementModel?> getAchievement(String achievementId) async {
    try {
      final doc =
          await _firestore.collection('achievements').doc(achievementId).get();

      if (!doc.exists) return null;

      return AchievementModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('업적을 가져오는데 실패했습니다: $e');
    }
  }

  /// 사용자의 언락된 업적 목록 가져오기
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('사용자 업적을 가져오는데 실패했습니다: $e');
    }
  }

  /// 업적 언락
  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      final achievementRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId);

      await achievementRef.set({
        'achievementId': achievementId,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('업적 언락에 실패했습니다: $e');
    }
  }

  /// 업적이 언락되었는지 확인
  Future<bool> isAchievementUnlocked(
      String userId, String achievementId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// 업적 진행도 업데이트
  Future<void> updateAchievementProgress(
    String userId,
    String achievementId,
    int progress,
  ) async {
    try {
      final achievementRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId);

      await achievementRef.update({
        'progress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('업적 진행도 업데이트에 실패했습니다: $e');
    }
  }

  /// 카테고리별 업적 가져오기
  Future<List<AchievementModel>> getAchievementsByCategory(
      String category) async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('카테고리별 업적을 가져오는데 실패했습니다: $e');
    }
  }
}
