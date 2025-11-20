import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_account.dart';
import '../services/local_storage_service.dart';
import '../services/social_auth_service.dart';
// TODO: Firebase 연결 시 활성화
// import '../services/firebase_auth_service.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/utils/logger.dart';

/// 인증 시스템 상태 관리
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _initialize();
  }

  final LocalStorageService _storage = LocalStorageService();
  final SocialAuthService _socialAuth = SocialAuthService();
  // TODO: Firebase 연결 시 활성화
  // final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  /// 초기화
  Future<void> _initialize() async {
    await _initializeSocialAuth();
    await _checkExistingLogin();
  }

  /// 소셜 로그인 초기화
  Future<void> _initializeSocialAuth() async {
    try {
      await _socialAuth.initializeGoogle();

      // Kakao Native App Key는 실제 앱에서 환경변수나 설정 파일에서 불러와야 함
      // TODO: 실제 Kakao Native App Key로 교체 필요
      await _socialAuth.initializeKakao(
        nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY', // 실제 키로 교체 필요
      );

      Logger.info('소셜 로그인 초기화 완료', tag: 'AuthProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '소셜 로그인 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
    }
  }

  /// 기존 로그인 확인
  Future<void> _checkExistingLogin() async {
    try {
      final currentAccountId = await _storage.getString('currentAccountId');

      if (currentAccountId != null) {
        final accounts = await _loadAccounts();
        final account = accounts.firstWhere(
          (acc) => acc.id == currentAccountId,
          orElse: () => throw StateError('계정을 찾을 수 없습니다'),
        );

        state = AuthState(
          isAuthenticated: true,
          currentAccount: account,
          availableAccounts: accounts,
          isLoading: false,
        );

        Logger.info(
          '기존 계정 로그인: ${account.displayName}',
          tag: 'AuthProvider',
        );
      } else {
        state = AuthState(
          isAuthenticated: false,
          currentAccount: null,
          availableAccounts: await _loadAccounts(),
          isLoading: false,
        );

        Logger.info('로그인되지 않은 상태', tag: 'AuthProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '기존 로그인 확인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );

      state = AuthState.initial().copyWith(isLoading: false);
    }
  }

  /// 계정 목록 로드
  Future<List<UserAccount>> _loadAccounts() async {
    try {
      final accounts = await _storage.loadList<UserAccount>(
        key: 'userAccounts',
        fromJson: UserAccount.fromJson,
      );

      Logger.debug('계정 ${accounts.length}개 로드 완료', tag: 'AuthProvider');
      return accounts;
    } catch (e, stackTrace) {
      Logger.error(
        '계정 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
      return [];
    }
  }

  /// 계정 목록 저장
  Future<void> _saveAccounts(List<UserAccount> accounts) async {
    try {
      await _storage.saveList<UserAccount>(
        key: 'userAccounts',
        data: accounts,
        toJson: (account) => account.toJson(),
      );

      Logger.debug('계정 ${accounts.length}개 저장 완료', tag: 'AuthProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '계정 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
    }
  }

  /// 간단 회원가입 (이메일 + 이름)
  Future<bool> signUp({
    required String email,
    required String displayName,
    required String grade,
    AccountType accountType = AccountType.student,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // 중복 이메일 확인
      final existingAccounts = await _loadAccounts();
      final emailExists = existingAccounts.any((acc) => acc.email == email);

      if (emailExists) {
        state = state.copyWith(isLoading: false, error: '이미 사용 중인 이메일입니다');
        return false;
      }

      // 새 계정 생성
      final newAccount = UserAccount(
        id: _generateUserId(),
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        accountType: accountType,
        preferences: {'grade': grade},
      );

      // 계정 저장
      final updatedAccounts = [...existingAccounts, newAccount];
      await _saveAccounts(updatedAccounts);

      // 즉시 로그인
      await _setCurrentAccount(newAccount.id);

      state = AuthState(
        isAuthenticated: true,
        currentAccount: newAccount,
        availableAccounts: updatedAccounts,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '회원가입에 실패했습니다: $e');
      return false;
    }
  }

  /// 게스트로 시작
  Future<bool> signInAsGuest() async {
    try {
      state = state.copyWith(isLoading: true);

      final existingAccounts = await _loadAccounts();
      final guestNumber = existingAccounts
              .where((acc) => acc.email.startsWith('guest_'))
              .length +
          1;

      // 게스트 계정 생성
      final guestAccount = UserAccount(
        id: _generateUserId(),
        email: 'guest_${DateTime.now().millisecondsSinceEpoch}@gomath.local',
        displayName: '게스트 $guestNumber',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        accountType: AccountType.student, // 게스트는 student 타입으로 처리
        preferences: {'grade': '미설정', 'isGuest': 'true'},
      );

      // 계정 저장
      final updatedAccounts = [...existingAccounts, guestAccount];
      await _saveAccounts(updatedAccounts);

      // 즉시 로그인
      await _setCurrentAccount(guestAccount.id);

      state = AuthState(
        isAuthenticated: true,
        currentAccount: guestAccount,
        availableAccounts: updatedAccounts,
        isLoading: false,
      );

      Logger.info('게스트 로그인 완료: ${guestAccount.displayName}', tag: 'AuthProvider');
      return true;
    } catch (e, stackTrace) {
      Logger.error(
        '게스트 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
      state = state.copyWith(isLoading: false, error: '게스트 로그인에 실패했습니다: $e');
      return false;
    }
  }

  /// 로그인 (이메일로)
  Future<bool> signIn(String email) async {
    try {
      state = state.copyWith(isLoading: true);

      final accounts = await _loadAccounts();
      final account = accounts.firstWhere(
        (acc) => acc.email == email,
        orElse: () => throw Exception('계정을 찾을 수 없습니다'),
      );

      // 마지막 로그인 시간 업데이트
      final updatedAccount = account.copyWith(lastLoginAt: DateTime.now());
      final updatedAccounts = accounts.map((acc) {
        return acc.id == account.id ? updatedAccount : acc;
      }).toList();

      await _saveAccounts(updatedAccounts);
      await _setCurrentAccount(updatedAccount.id);

      state = AuthState(
        isAuthenticated: true,
        currentAccount: updatedAccount,
        availableAccounts: updatedAccounts,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '로그인에 실패했습니다: $e');
      return false;
    }
  }

  /// 계정 전환
  Future<void> switchAccount(String accountId) async {
    final accounts = state.availableAccounts;
    final account = accounts.firstWhere(
      (acc) => acc.id == accountId,
      orElse: () => throw Exception('계정을 찾을 수 없습니다'),
    );

    await _setCurrentAccount(accountId);

    state = state.copyWith(
      currentAccount: account.copyWith(lastLoginAt: DateTime.now()),
    );
  }

  // ==================== 소셜 로그인 ====================

  /// Google 로그인 (Mock - Firebase 연결 전)
  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true);
      Logger.info('Google 로그인 시도 (Mock)', tag: 'AuthProvider');

      // Mock: 소셜 로그인 결과 시뮬레이션
      final result = await _socialAuth.signInWithGoogle();

      if (result == null) {
        state = state.copyWith(isLoading: false);
        Logger.info('Google 로그인 취소됨', tag: 'AuthProvider');
        return false;
      }

      // Google 계정으로 기존 계정이 있는지 확인
      final existingAccounts = await _loadAccounts();
      UserAccount? existingAccount;

      try {
        existingAccount = existingAccounts.firstWhere(
          (acc) => acc.email == result.email,
        );
      } catch (e) {
        // 기존 계정 없음
      }

      if (existingAccount != null) {
        // 기존 계정으로 로그인
        return await signIn(existingAccount.email);
      } else {
        // 새 계정 생성
        return await signUp(
          email: result.email,
          displayName: result.displayName,
          grade: GameConstants.defaultGrade,
          accountType: AccountType.student,
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Google 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Google 로그인에 실패했습니다',
      );
      return false;
    }
  }

  /// Kakao 로그인
  Future<bool> signInWithKakao() async {
    try {
      state = state.copyWith(isLoading: true);
      Logger.info('Kakao 로그인 시도', tag: 'AuthProvider');

      final result = await _socialAuth.signInWithKakao();

      if (result == null) {
        state = state.copyWith(isLoading: false);
        Logger.info('Kakao 로그인 취소됨', tag: 'AuthProvider');
        return false;
      }

      // Kakao 계정으로 기존 계정이 있는지 확인
      final existingAccounts = await _loadAccounts();
      UserAccount? existingAccount;

      // 이메일이 있으면 이메일로 찾고, 없으면 user ID로 찾기
      try {
        if (result.email.isNotEmpty) {
          existingAccount = existingAccounts.firstWhere(
            (acc) => acc.email == result.email,
          );
        } else {
          existingAccount = existingAccounts.firstWhere(
            (acc) => acc.id == 'kakao_${result.userId}',
          );
        }
      } catch (e) {
        // 기존 계정 없음
      }

      if (existingAccount != null) {
        // 기존 계정으로 로그인
        return await signIn(existingAccount.email);
      } else {
        // 새 계정 생성
        return await signUp(
          email: result.email.isNotEmpty ? result.email : 'kakao_${result.userId}@mathlab.com',
          displayName: result.displayName,
          grade: GameConstants.defaultGrade,
          accountType: AccountType.student,
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Kakao 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Kakao 로그인에 실패했습니다',
      );
      return false;
    }
  }

  /// Apple 로그인 (Mock - Firebase 연결 전)
  Future<bool> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true);
      Logger.info('Apple 로그인 시도 (Mock)', tag: 'AuthProvider');

      // Mock: 소셜 로그인 결과 시뮬레이션
      final result = await _socialAuth.signInWithApple();

      if (result == null) {
        state = state.copyWith(isLoading: false);
        Logger.info('Apple 로그인 취소됨', tag: 'AuthProvider');
        return false;
      }

      // Apple 계정으로 기존 계정이 있는지 확인
      final existingAccounts = await _loadAccounts();
      UserAccount? existingAccount;

      try {
        if (result.email.isNotEmpty) {
          existingAccount = existingAccounts.firstWhere(
            (acc) => acc.email == result.email,
          );
        } else {
          existingAccount = existingAccounts.firstWhere(
            (acc) => acc.id == 'apple_${result.userId}',
          );
        }
      } catch (e) {
        // 기존 계정 없음
      }

      if (existingAccount != null) {
        // 기존 계정으로 로그인
        return await signIn(existingAccount.email);
      } else {
        // 새 계정 생성
        return await signUp(
          email: result.email.isNotEmpty ? result.email : 'apple_${result.userId}@mathlab.com',
          displayName: result.displayName,
          grade: GameConstants.defaultGrade,
          accountType: AccountType.student,
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Apple 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Apple 로그인에 실패했습니다',
      );
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _storage.remove('currentAccountId');

      // TODO: Firebase 연결 시 활성화
      // await _firebaseAuth.signOut();

      // 소셜 로그인도 함께 로그아웃
      await _socialAuth.signOutAll();

      state = state.copyWith(
        isAuthenticated: false,
        currentAccount: null,
      );

      Logger.info('로그아웃 완료', tag: 'AuthProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '로그아웃 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthProvider',
      );
    }
  }

  /// 로그아웃 (signOut의 별칭)
  Future<void> logout() => signOut();

  /// 계정 삭제
  Future<void> deleteAccount(String accountId) async {
    final accounts = state.availableAccounts;
    final updatedAccounts = accounts.where((acc) => acc.id != accountId).toList();

    await _saveAccounts(updatedAccounts);

    // 현재 계정이 삭제되는 경우 로그아웃
    if (state.currentAccount?.id == accountId) {
      await signOut();
    }

    state = state.copyWith(availableAccounts: updatedAccounts);

    // 관련된 모든 사용자 데이터 삭제
    await _deleteUserData(accountId);
  }

  /// 현재 계정 설정
  Future<void> _setCurrentAccount(String accountId) async {
    await _storage.setString('currentAccountId', accountId);
  }

  /// 사용자 ID 생성
  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// 사용자 데이터 삭제
  Future<void> _deleteUserData(String accountId) async {
    // 해당 사용자의 모든 데이터 키를 삭제
    final keys = [
      'user_$accountId',
      'problemResults_$accountId',
      'achievements_$accountId',
      'learningStats_$accountId',
      'errorNotes_$accountId',
      'lessons_$accountId',
    ];

    for (final key in keys) {
      await _storage.remove(key);
    }

    Logger.info('사용자 데이터 삭제 완료: $accountId', tag: 'AuthProvider');
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 인증 상태
class AuthState {
  final bool isAuthenticated;
  final UserAccount? currentAccount;
  final List<UserAccount> availableAccounts;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    required this.currentAccount,
    required this.availableAccounts,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      currentAccount: null,
      availableAccounts: [],
      isLoading: true,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    UserAccount? currentAccount,
    List<UserAccount>? availableAccounts,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentAccount: currentAccount ?? this.currentAccount,
      availableAccounts: availableAccounts ?? this.availableAccounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 게스트 모드인지 확인
  bool get isGuest {
    if (currentAccount == null) return false;
    return currentAccount!.preferences['isGuest'] == 'true';
  }

  /// 다중 계정이 있는지 확인
  bool get hasMultipleAccounts => availableAccounts.length > 1;

  @override
  String toString() => 'AuthState{isAuth: $isAuthenticated, account: ${currentAccount?.displayName}}';
}

/// 프로바이더들
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// 편의 프로바이더들
final currentAccountProvider = Provider<UserAccount?>((ref) {
  return ref.watch(authProvider).currentAccount;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final availableAccountsProvider = Provider<List<UserAccount>>((ref) {
  return ref.watch(authProvider).availableAccounts;
});