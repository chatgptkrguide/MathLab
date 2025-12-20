import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_repository.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../../shared/utils/logger.dart';

/// 사용자 프로필 Repository
///
/// 역할:
/// - 사용자 프로필 CRUD
/// - 로컬 + Firebase 동기화
/// - 충돌 해결 (Last-Write-Wins)
class UserRepository extends BaseRepository<User> {
  UserRepository({
    required LocalStorageService localStorageService,
    required FirestoreService firestoreService,
  }) : super(
          localStorageService: localStorageService,
          firestoreService: firestoreService,
        );

  // ==================== 로컬 스토리지 ====================

  @override
  Future<User?> getFromLocal(String storageKey) async {
    try {
      final json = await localStorageService.loadMap(storageKey);

      if (json == null || json.isEmpty) {
        Logger.debug('로컬에 사용자 프로필 없음: $storageKey', tag: 'UserRepository');
        return null;
      }

      return User.fromJson(json);
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 사용자 프로필 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToLocal(String storageKey, User data) async {
    try {
      await localStorageService.saveMap(storageKey, data.toJson());
      Logger.debug('로컬에 사용자 프로필 저장 완료: $storageKey', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 사용자 프로필 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      throw Exception('로컬 사용자 프로필 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromLocal(String storageKey) async {
    try {
      await localStorageService.remove(storageKey);
      Logger.debug('로컬 사용자 프로필 삭제 완료: $storageKey', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 사용자 프로필 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
    }
  }

  // ==================== Firebase ====================

  @override
  Future<User?> getFromFirebase(String accountId) async {
    try {
      final userDoc = await firestoreService.getUserProfile(accountId);

      if (userDoc == null) {
        Logger.debug('Firestore에 사용자 프로필 없음: $accountId', tag: 'UserRepository');
        return null;
      }

      // Firestore 데이터를 User 모델로 변환
      return User.fromJson(userDoc.toFirestoreMap());
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 사용자 프로필 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToFirebase(String accountId, User data) async {
    try {
      // User 모델을 Firestore 형식으로 변환
      final firestoreData = {
        'uid': data.id,
        'email': data.email,
        'name': data.name,
        'photoURL': data.photoUrl,
        'avatarUrl': data.avatarUrl,
        'level': data.level,
        'totalXP': data.xp,
        'xp': data.xp,
        'streak': data.streakDays,
        'streakDays': data.streakDays,
        'lastStudyDate': data.lastStudyDate?.toIso8601String(),
        'currentGrade': data.currentGrade,
        'hearts': data.hearts,
        'dailyXP': data.dailyXP,
        'isPremium': data.isPremium,
        'premiumTier': data.premiumTier.value,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await firestoreService.updateUserProfile(accountId, firestoreData);
      Logger.debug('Firestore에 사용자 프로필 저장 완료: $accountId', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 사용자 프로필 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      throw Exception('Firebase 사용자 프로필 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromFirebase(String accountId) async {
    try {
      // Firestore에는 사용자 프로필 삭제 메서드가 없으므로
      // 필요 시 구현
      Logger.warning(
        'Firebase 사용자 프로필 삭제는 구현되지 않음',
        tag: 'UserRepository',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 사용자 프로필 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
    }
  }

  // ==================== 충돌 해결 ====================

  @override
  Future<User?> mergeData(User local, User remote) async {
    // Last-Write-Wins 전략
    // lastStudyDate 필드로 비교해서 최신 것 사용

    final localDate = local.lastStudyDate ?? local.joinDate;
    final remoteDate = remote.lastStudyDate ?? remote.joinDate;

    if (remoteDate.isAfter(localDate)) {
      Logger.debug('사용자 프로필 충돌 해결: remote 우선', tag: 'UserRepository');
      return remote;
    } else {
      Logger.debug('사용자 프로필 충돌 해결: local 우선', tag: 'UserRepository');
      return local;
    }
  }

  // ==================== 추가 메서드 ====================

  /// 사용자 프로필 실시간 감지 (Firebase Stream)
  Stream<User?> watchUserProfile(String uid) {
    try {
      return firestoreService.watchUserProfile(uid).map((userDoc) {
        if (userDoc == null) return null;

        try {
          return User.fromJson(userDoc.toFirestoreMap());
        } catch (e) {
          Logger.error(
            'User 모델 변환 실패',
            error: e,
            tag: 'UserRepository',
          );
          return null;
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 실시간 감지 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      return Stream.value(null);
    }
  }

  /// XP 업데이트 (낙관적 업데이트)
  Future<void> updateXP(String uid, int xpToAdd) async {
    try {
      // 로컬 업데이트
      final storageKey = 'user_$uid';
      final user = await getFromLocal(storageKey);

      if (user != null) {
        final updatedUser = user.copyWith(xp: user.xp + xpToAdd);
        await saveToLocal(storageKey, updatedUser);
      }

      // Firestore 업데이트
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final currentXP = userDoc.data()?['totalXP'] ?? 0;
        final newLevel = User.calculateLevel(currentXP + xpToAdd);

        await userDocRef.update({
          'totalXP': currentXP + xpToAdd,
          'xp': currentXP + xpToAdd,
          'level': newLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      Logger.info('XP 업데이트 완료: +$xpToAdd', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'XP 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      throw Exception('XP 업데이트 실패: $e');
    }
  }

  /// 스트릭 업데이트
  Future<void> updateStreak(String uid, int newStreak) async {
    try {
      await firestoreService.updateUserProfile(uid, {
        'streak': newStreak,
        'lastStudyDate': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      Logger.info('스트릭 업데이트 완료: $newStreak', tag: 'UserRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '스트릭 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserRepository',
      );
      throw Exception('스트릭 업데이트 실패: $e');
    }
  }
}
