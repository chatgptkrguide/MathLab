import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_auth_service.dart';
import '../models/user.dart';
import '../../shared/utils/logger.dart';

/// 인증 Repository
///
/// Firebase Authentication과 Firestore를 연동하여
/// 사용자 인증 및 프로필 관리를 담당합니다.
class AuthRepository {
  // Singleton 패턴
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  /// Firebase Auth 서비스
  final FirebaseAuthService _authService = FirebaseAuthService();

  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 로그인한 사용자
  firebase_auth.User? get currentUser => _authService.currentUser;

  /// 로그인 상태 스트림
  Stream<firebase_auth.User?> get authStateChanges => _authService.authStateChanges;

  /// 로그인 여부
  bool get isSignedIn => _authService.isSignedIn;

  // ==================== 회원가입 ====================

  /// 이메일/비밀번호로 회원가입
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Firebase Authentication 회원가입
      final userCredential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (userCredential == null || userCredential.user == null) {
        return null;
      }

      // Firestore에 사용자 문서 생성
      final user = await _createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        provider: 'email',
      );

      // 이메일 인증 메일 전송
      await _authService.sendEmailVerification();

      return user;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: 이메일 회원가입 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  // ==================== 로그인 ====================

  /// 이메일/비밀번호로 로그인
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (userCredential == null || userCredential.user == null) {
        return null;
      }

      // Firestore에서 사용자 정보 가져오기
      final user = await _getUserFromFirestore(userCredential.user!.uid);

      return user;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: 이메일 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  /// Google 로그인
  Future<User?> signInWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        return null;
      }

      // Firestore에 사용자 문서가 없으면 생성
      final user = await _getOrCreateUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? 'Google User',
        provider: 'google',
        photoUrl: userCredential.user!.photoURL,
      );

      return user;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: Google 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  /// Apple 로그인
  Future<User?> signInWithApple() async {
    try {
      final userCredential = await _authService.signInWithApple();

      if (userCredential == null || userCredential.user == null) {
        return null;
      }

      // Firestore에 사용자 문서가 없으면 생성
      final user = await _getOrCreateUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? 'Apple User',
        provider: 'apple',
        photoUrl: userCredential.user!.photoURL,
      );

      return user;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: Apple 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  /// 익명 로그인 (게스트)
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance.signInAnonymously();

      if (userCredential.user == null) {
        return null;
      }

      // Firestore에 사용자 문서 생성
      final user = await _createUserDocument(
        uid: userCredential.user!.uid,
        email: '',
        name: 'Guest',
        provider: 'anonymous',
        isAnonymous: true,
      );

      return user;
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: 익명 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  // ==================== 로그아웃 및 계정 관리 ====================

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Logger.info('AuthRepository: 로그아웃 완료', tag: 'AuthRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: 로그아웃 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      // Firestore에서 사용자 문서 삭제
      await _firestore.collection('users').doc(uid).delete();

      // Firebase Auth 계정 삭제
      await _authService.deleteAccount();

      Logger.info('AuthRepository: 계정 삭제 완료', tag: 'AuthRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: 계정 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  // ==================== Firestore 헬퍼 메서드 ====================

  /// Firestore에 사용자 문서 생성
  Future<User> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    required String provider,
    String? photoUrl,
    bool isAnonymous = false,
  }) async {
    try {
      final now = DateTime.now();
      final userDoc = _firestore.collection('users').doc(uid);

      // 기본 사용자 데이터
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'provider': provider,
        'photoUrl': photoUrl,
        'isAnonymous': isAnonymous,
        'level': 1,
        'xp': 0,
        'streak': 0,
        'lastStudyDate': null,
        'totalProblemsAttempted': 0,
        'totalProblemsCorrect': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await userDoc.set(userData);

      Logger.info(
        'AuthRepository: Firestore 사용자 문서 생성 완료: $uid',
        tag: 'AuthRepository',
      );

      return User(
        id: uid,
        email: email,
        name: name,
        avatarUrl: photoUrl ?? '',
        currentGrade: '중1', // 기본 학년
        joinDate: now,
        level: 1,
        xp: 0,
        streakDays: 0,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: Firestore 사용자 문서 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      rethrow;
    }
  }

  /// Firestore에서 사용자 정보 가져오기
  Future<User?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        Logger.warning(
          'AuthRepository: Firestore에 사용자 문서가 없습니다: $uid',
          tag: 'AuthRepository',
        );
        return null;
      }

      final data = doc.data()!;

      return User(
        id: uid,
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        avatarUrl: data['photoURL'] ?? data['avatarUrl'] ?? '',
        currentGrade: data['currentGrade'] ?? '중1',
        joinDate: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        level: data['level'] ?? 1,
        xp: data['totalXP'] ?? data['xp'] ?? 0,
        streakDays: data['streak'] ?? data['streakDays'] ?? 0,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: Firestore 사용자 정보 가져오기 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  /// Firestore에서 사용자 가져오기 또는 생성
  Future<User?> _getOrCreateUser({
    required String uid,
    required String email,
    required String name,
    required String provider,
    String? photoUrl,
  }) async {
    try {
      // 먼저 Firestore에서 사용자 정보 확인
      final existingUser = await _getUserFromFirestore(uid);

      if (existingUser != null) {
        return existingUser;
      }

      // 없으면 새로 생성
      return await _createUserDocument(
        uid: uid,
        email: email,
        name: name,
        provider: provider,
        photoUrl: photoUrl,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'AuthRepository: 사용자 가져오기/생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  /// 에러 메시지 변환
  String getErrorMessage(dynamic error) {
    return _authService.getErrorMessage(error);
  }
}
