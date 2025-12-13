import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_account.dart';
import '../services/social_auth_service.dart';
import '../../shared/constants/game_constants.dart';
import 'base/base_notifier.dart';

/// 인증 시스템 상태 관리 (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - 소셜 로그인 공통 로직 통합
class AuthNotifier extends BaseNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial(), 'AuthProvider') {
    _initialize();
  }

  final SocialAuthService _socialAuth = SocialAuthService();

  /// 초기화
  Future<void> _initialize() async {
    await _initializeSocialAuth();
    await _checkExistingLogin();
    await _runMigrationIfNeeded();
  }

  /// 소셜 로그인 초기화
  Future<void> _initializeSocialAuth() async {
    await executeWithErrorHandling(
      () async {
        await _socialAuth.initializeGoogle();
        await _socialAuth.initializeKakao(
          nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',
        );
        logInfo('소셜 로그인 초기화 완료');
      },
      errorMessage: '소셜 로그인 초기화 실패',
    );
  }

  /// 기존 로그인 확인
  Future<void> _checkExistingLogin() async {
    await executeWithErrorHandling(
      () async {
        final currentAccountId = await storage.getString('currentAccountId');

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

          logInfo('기존 계정 로그인: ${account.displayName}');
        } else {
          state = AuthState(
            isAuthenticated: false,
            currentAccount: null,
            availableAccounts: await _loadAccounts(),
            isLoading: false,
          );

          logInfo('로그인되지 않은 상태');
        }
      },
      errorMessage: '기존 로그인 확인 실패',
      fallback: () {
        state = AuthState.initial().copyWith(isLoading: false);
      },
    );
  }

  /// 계정 목록 로드
  Future<List<UserAccount>> _loadAccounts() async {
    return await executeWithErrorHandling(
      () async {
        final accounts = await storage.loadList<UserAccount>(
          key: 'userAccounts',
          fromJson: UserAccount.fromJson,
        );
        logDebug('계정 ${accounts.length}개 로드 완료');
        return accounts;
      },
      errorMessage: '계정 목록 로드 실패',
      fallback: () => <UserAccount>[],
    ) ?? [];
  }

  /// 계정 목록 저장
  Future<void> _saveAccounts(List<UserAccount> accounts) async {
    await executeWithErrorHandling(
      () async {
        await storage.saveList<UserAccount>(
          key: 'userAccounts',
          data: accounts,
          toJson: (account) => account.toJson(),
        );
        logDebug('계정 ${accounts.length}개 저장 완료');
      },
      errorMessage: '계정 목록 저장 실패',
    );
  }

  /// 간단 회원가입
  Future<bool> signUp({
    required String email,
    required String displayName,
    required String grade,
    AccountType accountType = AccountType.student,
  }) async {
    return await executeWithErrorHandling(
      () async {
        state = state.copyWith(isLoading: true);

        final existingAccounts = await _loadAccounts();
        final emailExists = existingAccounts.any((acc) => acc.email == email);

        if (emailExists) {
          state = state.copyWith(isLoading: false, error: '이미 사용 중인 이메일입니다');
          return false;
        }

        final newAccount = UserAccount(
          id: _generateUserId(),
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          accountType: accountType,
          preferences: {'grade': grade},
        );

        final updatedAccounts = [...existingAccounts, newAccount];
        await _saveAccounts(updatedAccounts);
        await _setCurrentAccount(newAccount.id);

        state = AuthState(
          isAuthenticated: true,
          currentAccount: newAccount,
          availableAccounts: updatedAccounts,
          isLoading: false,
        );

        return true;
      },
      errorMessage: '회원가입 실패',
      fallback: () {
        state = state.copyWith(isLoading: false);
        return false;
      },
    ) ?? false;
  }

  /// 게스트로 시작
  Future<bool> signInAsGuest() async {
    return await executeWithErrorHandling(
      () async {
        state = state.copyWith(isLoading: true);

        final existingAccounts = await _loadAccounts();
        final guestNumber = existingAccounts
                .where((acc) => acc.email.startsWith('guest_'))
                .length +
            1;

        final guestAccount = UserAccount(
          id: _generateUserId(),
          email: 'guest_${DateTime.now().millisecondsSinceEpoch}@gomath.local',
          displayName: '게스트 $guestNumber',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          accountType: AccountType.student,
          preferences: {'grade': '미설정', 'isGuest': 'true'},
        );

        final updatedAccounts = [...existingAccounts, guestAccount];
        await _saveAccounts(updatedAccounts);
        await _setCurrentAccount(guestAccount.id);

        state = AuthState(
          isAuthenticated: true,
          currentAccount: guestAccount,
          availableAccounts: updatedAccounts,
          isLoading: false,
        );

        logInfo('게스트 로그인 완료: ${guestAccount.displayName}');
        return true;
      },
      errorMessage: '게스트 로그인 실패',
      fallback: () {
        state = state.copyWith(isLoading: false);
        return false;
      },
    ) ?? false;
  }

  /// 로그인
  Future<bool> signIn(String email) async {
    return await executeWithErrorHandling(
      () async {
        state = state.copyWith(isLoading: true);

        final accounts = await _loadAccounts();
        final account = accounts.firstWhere(
          (acc) => acc.email == email,
          orElse: () => throw Exception('계정을 찾을 수 없습니다'),
        );

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
      },
      errorMessage: '로그인 실패',
      fallback: () {
        state = state.copyWith(isLoading: false);
        return false;
      },
    ) ?? false;
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

  /// 소셜 로그인 공통 처리
  Future<bool> _handleSocialLogin(
    Future<SocialAuthResult?> Function() socialAuthMethod,
    String provider,
  ) async {
    return await executeWithErrorHandling(
      () async {
        state = state.copyWith(isLoading: true);
        logInfo('$provider 로그인 시도');

        final result = await socialAuthMethod();

        if (result == null) {
          state = state.copyWith(isLoading: false);
          logInfo('$provider 로그인 취소됨');
          return false;
        }

        final existingAccounts = await _loadAccounts();
        UserAccount? existingAccount;

        try {
          if (result.email.isNotEmpty) {
            existingAccount = existingAccounts.firstWhere(
              (acc) => acc.email == result.email,
            );
          } else {
            existingAccount = existingAccounts.firstWhere(
              (acc) => acc.id == '${provider.toLowerCase()}_${result.userId}',
            );
          }
        } catch (e) {
          // 기존 계정 없음
        }

        if (existingAccount != null) {
          return await signIn(existingAccount.email);
        } else {
          return await signUp(
            email: result.email.isNotEmpty
                ? result.email
                : '${provider.toLowerCase()}_${result.userId}@mathlab.com',
            displayName: result.displayName,
            grade: GameConstants.defaultGrade,
            accountType: AccountType.student,
          );
        }
      },
      errorMessage: '$provider 로그인 실패',
      fallback: () {
        state = state.copyWith(isLoading: false);
        return false;
      },
    ) ?? false;
  }

  /// Google 로그인
  Future<bool> signInWithGoogle() => _handleSocialLogin(
        _socialAuth.signInWithGoogle,
        'Google',
      );

  /// Kakao 로그인
  Future<bool> signInWithKakao() => _handleSocialLogin(
        _socialAuth.signInWithKakao,
        'Kakao',
      );

  /// Apple 로그인
  Future<bool> signInWithApple() => _handleSocialLogin(
        _socialAuth.signInWithApple,
        'Apple',
      );

  /// 로그아웃
  Future<void> signOut() async {
    await executeWithErrorHandling(
      () async {
        await storage.remove('currentAccountId');
        await _socialAuth.signOutAll();

        state = state.copyWith(
          isAuthenticated: false,
          currentAccount: null,
        );

        logInfo('로그아웃 완료');
      },
      errorMessage: '로그아웃 실패',
    );
  }

  /// 로그아웃 별칭
  Future<void> logout() => signOut();

  /// 계정 삭제
  Future<void> deleteAccount(String accountId) async {
    final accounts = state.availableAccounts;
    final updatedAccounts = accounts.where((acc) => acc.id != accountId).toList();

    await _saveAccounts(updatedAccounts);

    if (state.currentAccount?.id == accountId) {
      await signOut();
    }

    state = state.copyWith(availableAccounts: updatedAccounts);
    await _deleteUserData(accountId);
  }

  /// 현재 계정 설정
  Future<void> _setCurrentAccount(String accountId) async {
    await storage.setString('currentAccountId', accountId);
  }

  /// 사용자 ID 생성
  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // ==================== 데이터 마이그레이션 ====================

  /// 마이그레이션 실행
  Future<void> _runMigrationIfNeeded() async {
    await executeWithErrorHandling(
      () async {
        final migrationDone = await storage.getString('migration_v1_done');

        if (migrationDone == 'true') {
          logDebug('마이그레이션 이미 완료됨');
          return;
        }

        logInfo('데이터 마이그레이션 시작...');

        if (state.currentAccount != null) {
          await _migrateGlobalDataToAccountBased(state.currentAccount!.id);
        }

        await storage.setString('migration_v1_done', 'true');
        logInfo('데이터 마이그레이션 완료');
      },
      errorMessage: '데이터 마이그레이션 실패',
    );
  }

  /// 전역 데이터를 계정별 데이터로 마이그레이션
  Future<void> _migrateGlobalDataToAccountBased(String accountId) async {
    await executeWithErrorHandling(
      () async {
        logInfo('전역 데이터를 계정별로 마이그레이션: $accountId');

        final globalKeys = [
          'wrong_answers',
          'league',
          'messages',
          'friends',
          'achievements',
          'study_history',
          'lesson_progress',
        ];

        int migratedCount = 0;

        for (final oldKey in globalKeys) {
          final newKey = '${oldKey}_$accountId';

          if (await storage.containsKey(newKey)) {
            logDebug('이미 마이그레이션됨: $newKey');
            continue;
          }

          if (!await storage.containsKey(oldKey)) {
            logDebug('전역 데이터 없음: $oldKey');
            continue;
          }

          final data = await storage.getString(oldKey);
          if (data != null && data.isNotEmpty) {
            await storage.setString(newKey, data);
            migratedCount++;
            logInfo('마이그레이션: $oldKey → $newKey');
            await storage.remove(oldKey);
          }
        }

        logInfo('$migratedCount개 데이터 마이그레이션 완료');
      },
      errorMessage: '전역 데이터 마이그레이션 실패',
    );
  }

  /// 게스트 계정 데이터 이전
  Future<bool> migrateGuestToRegularAccount({
    required String guestAccountId,
    required String newAccountId,
  }) async {
    return await executeWithErrorHandling(
      () async {
        logInfo('게스트 데이터 이전: $guestAccountId → $newAccountId');

        final keysToMigrate = [
          'wrong_answers',
          'league',
          'messages',
          'friends',
          'achievements',
          'study_history',
          'lesson_progress',
        ];

        int migratedCount = 0;

        for (final key in keysToMigrate) {
          final oldKey = '${key}_$guestAccountId';
          final newKey = '${key}_$newAccountId';

          if (!await storage.containsKey(oldKey)) continue;

          final data = await storage.getString(oldKey);
          if (data != null && data.isNotEmpty) {
            if (await storage.containsKey(newKey)) {
              logWarning('이미 데이터 존재: $newKey (스킵)');
              continue;
            }

            await storage.setString(newKey, data);
            migratedCount++;
            logInfo('데이터 이전: $oldKey → $newKey');
            await storage.remove(oldKey);
          }
        }

        logInfo('$migratedCount개 데이터 이전 완료');
        await deleteAccount(guestAccountId);

        return true;
      },
      errorMessage: '게스트 데이터 이전 실패',
      fallback: () => false,
    ) ?? false;
  }

  /// 사용자 데이터 삭제
  Future<void> _deleteUserData(String accountId) async {
    await executeWithErrorHandling(
      () async {
        final keys = [
          'user_$accountId',
          'problemResults_$accountId',
          'achievements_$accountId',
          'learningStats_$accountId',
          'errorNotes_$accountId',
          'lessons_$accountId',
          'wrong_answers_$accountId',
          'league_$accountId',
          'messages_$accountId',
          'friends_$accountId',
          'study_history_$accountId',
          'lesson_progress_$accountId',
        ];

        int deletedCount = 0;

        for (final key in keys) {
          if (await storage.containsKey(key)) {
            await storage.remove(key);
            deletedCount++;
          }
        }

        logInfo('사용자 데이터 삭제 완료: $accountId ($deletedCount개)');
      },
      errorMessage: '사용자 데이터 삭제 실패',
    );
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

  bool get isGuest {
    if (currentAccount == null) return false;
    return currentAccount!.preferences['isGuest'] == 'true';
  }

  bool get hasMultipleAccounts => availableAccounts.length > 1;

  @override
  String toString() => 'AuthState{isAuth: $isAuthenticated, account: ${currentAccount?.displayName}}';
}

/// 프로바이더들
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentAccountProvider = Provider<UserAccount?>((ref) {
  return ref.watch(authProvider).currentAccount;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final availableAccountsProvider = Provider<List<UserAccount>>((ref) {
  return ref.watch(authProvider).availableAccounts;
});
