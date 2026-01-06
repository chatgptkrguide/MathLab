import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user/user_account.dart';
import '../../services/social_auth_service.dart';
import '../../services/temp_profile_storage.dart';
import '../../../shared/constants/game_constants.dart';
import '../base/base_notifier.dart';

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
    try {
      // Google 초기화 시도 (실패해도 계속 진행)
      try {
        await _socialAuth.initializeGoogle();
        logInfo('Google 로그인 초기화 완료');
      } catch (e) {
        logWarning('Google 로그인 초기화 실패 (계속 진행): $e');
      }

      // Kakao 초기화 시도 (실패해도 계속 진행)
      try {
        await _socialAuth.initializeKakao(
          nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',
        );
        logInfo('Kakao 로그인 초기화 완료');
      } catch (e) {
        logWarning('Kakao 로그인 초기화 실패 (계속 진행): $e');
      }

      logInfo('소셜 로그인 초기화 시도 완료');
    } catch (e) {
      logError('소셜 로그인 초기화 중 예상치 못한 오류', error: e);
      // 초기화 실패해도 앱은 계속 동작
    }
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

  /// 소셜 로그인 공통 처리 (재시도 로직 포함)
  Future<bool> _handleSocialLogin(
    Future<SocialAuthResult?> Function() socialAuthMethod,
    String provider, {
    int maxRetries = 2,
  }) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        state = state.copyWith(isLoading: true, error: null);
        logInfo('$provider 로그인 시도 (${retryCount + 1}/${maxRetries + 1})');

        final result = await socialAuthMethod();

        if (result == null) {
          state = state.copyWith(isLoading: false);
          logInfo('$provider 로그인 취소됨');
          return false;
        }

        // 토큰 유효성 검증
        if (provider == 'Google') {
          if (result.accessToken == null && result.idToken == null) {
            throw Exception('Google 인증 토큰이 없습니다');
          }
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
          final success = await signIn(existingAccount.email);
          if (success) {
            logInfo('$provider 기존 계정 로그인 성공');
          }
          return success;
        } else {
          final success = await signUp(
            email: result.email.isNotEmpty
                ? result.email
                : '${provider.toLowerCase()}_${result.userId}@mathlab.com',
            displayName: result.displayName,
            grade: GameConstants.defaultGrade,
            accountType: AccountType.student,
          );
          if (success) {
            logInfo('$provider 신규 계정 생성 및 로그인 성공');
          }
          return success;
        }
      } on TimeoutException catch (e) {
        logWarning('$provider 로그인 타임아웃: ${e.message}');

        if (retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount)); // 지수 백오프
          continue;
        }

        state = state.copyWith(
          isLoading: false,
          error: '$provider 로그인 시간이 초과되었습니다. 다시 시도해주세요.',
        );
        return false;
      } catch (e, stackTrace) {
        logError('$provider 로그인 실패', error: e, stackTrace: stackTrace);

        // 네트워크 오류인 경우 재시도
        final isNetworkError = e.toString().contains('network') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('Connection');

        if (isNetworkError && retryCount < maxRetries) {
          retryCount++;
          logInfo('네트워크 오류 - 재시도 $retryCount/$maxRetries');
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }

        // 사용자 친화적 에러 메시지
        String errorMessage = '$provider 로그인에 실패했습니다';

        if (e.toString().contains('SHA-1')) {
          errorMessage = 'Google 로그인 설정이 완료되지 않았습니다. 관리자에게 문의하세요.';
        } else if (isNetworkError) {
          errorMessage = '네트워크 연결을 확인해주세요';
        } else if (e.toString().contains('cancelled') || e.toString().contains('cancel')) {
          errorMessage = '로그인이 취소되었습니다';
        }

        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }
    }

    // 최대 재시도 초과
    state = state.copyWith(
      isLoading: false,
      error: '$provider 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.',
    );
    return false;
  }

  /// Google 로그인 (프로필 정보 연동 포함)
  Future<bool> signInWithGoogle({TempProfileData? tempProfile}) async {
    final success = await _handleSocialLogin(
      _socialAuth.signInWithGoogle,
      'Google',
    );

    // 로그인 성공 후 임시 프로필 정보가 있으면 연동
    if (success && tempProfile != null && state.currentAccount != null) {
      await _applyTempProfileToAccount(tempProfile);
    }

    return success;
  }

  /// 임시 프로필 정보를 실제 계정에 연동
  Future<void> _applyTempProfileToAccount(TempProfileData tempProfile) async {
    await executeWithErrorHandling(
      () async {
        if (state.currentAccount == null) {
          throw Exception('현재 로그인된 계정이 없습니다');
        }

        logInfo('임시 프로필 정보를 계정에 연동: ${state.currentAccount!.email}');

        // UserAccount preferences 업데이트
        final updatedPreferences = {
          ...state.currentAccount!.preferences,
          'name': tempProfile.name,
          'birthDate': tempProfile.birthDate?.toIso8601String(),
          'gender': tempProfile.gender,
          'grade': tempProfile.currentGrade,
          'schoolName': tempProfile.schoolName,
          'bio': tempProfile.bio,
          'isProfileComplete': 'true',
        };

        final updatedAccount = state.currentAccount!.copyWith(
          displayName: tempProfile.name,
          preferences: updatedPreferences,
        );

        // 계정 정보 저장
        final existingAccounts = await _loadAccounts();
        final updatedAccounts = existingAccounts.map((acc) {
          return acc.id == updatedAccount.id ? updatedAccount : acc;
        }).toList();

        await _saveAccounts(updatedAccounts);

        // 상태 업데이트
        state = state.copyWith(
          currentAccount: updatedAccount,
          availableAccounts: updatedAccounts,
        );

        logInfo('프로필 정보 연동 완료: ${tempProfile.name} (학년: ${tempProfile.currentGrade})');
      },
      errorMessage: '프로필 정보 연동 실패',
    );
  }

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

  /// 이메일/비밀번호 로그인
  Future<bool> signInWithEmailPassword({
    required String email,
    required String displayName,
    required String uid,
  }) async {
    return await executeWithErrorHandling(
      () async {
        state = state.copyWith(isLoading: true);

        final existingAccounts = await _loadAccounts();

        // 기존 계정 확인
        UserAccount? existingAccount;
        try {
          existingAccount = existingAccounts.firstWhere(
            (acc) => acc.email == email,
          );
        } catch (_) {
          // 계정이 없으면 null
        }

        final UserAccount account;
        if (existingAccount != null) {
          // 기존 계정 업데이트
          account = existingAccount.copyWith(
            lastLoginAt: DateTime.now(),
          );
        } else {
          // 새 계정 생성
          account = UserAccount(
            id: uid,
            email: email,
            displayName: displayName,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            accountType: AccountType.student,
            preferences: {'grade': '미설정'},
          );
        }

        // 계정 저장
        final updatedAccounts = existingAccount != null
            ? existingAccounts.map((acc) {
                return acc.id == account.id ? account : acc;
              }).toList()
            : [...existingAccounts, account];

        await _saveAccounts(updatedAccounts);
        await _setCurrentAccount(account.id);

        state = AuthState(
          isAuthenticated: true,
          currentAccount: account,
          availableAccounts: updatedAccounts,
          isLoading: false,
        );

        logInfo('이메일 로그인 성공: $email');
        return true;
      },
      errorMessage: '이메일 로그인 실패',
      fallback: () {
        state = state.copyWith(isLoading: false);
        return false;
      },
    ) ?? false;
  }

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
