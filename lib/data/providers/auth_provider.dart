import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

/// 인증 시스템 상태 관리
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _checkExistingLogin();
  }

  /// 기존 로그인 확인
  Future<void> _checkExistingLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final currentAccountId = prefs.getString('currentAccountId');

    if (currentAccountId != null) {
      final accounts = await _loadAccounts();
      final account = accounts.firstWhere(
        (acc) => acc.id == currentAccountId,
        orElse: () => throw Exception('계정을 찾을 수 없습니다'),
      );

      state = AuthState(
        isAuthenticated: true,
        currentAccount: account,
        availableAccounts: accounts,
        isLoading: false,
      );
    } else {
      state = AuthState(
        isAuthenticated: false,
        currentAccount: null,
        availableAccounts: await _loadAccounts(),
        isLoading: false,
      );
    }
  }

  /// 계정 목록 로드
  Future<List<UserAccount>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList('userAccounts') ?? [];

    return accountsJson
        .map((json) => UserAccount.fromJson(jsonDecode(json)))
        .toList();
  }

  /// 계정 목록 저장
  Future<void> _saveAccounts(List<UserAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();

    await prefs.setStringList('userAccounts', accountsJson);
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

  /// 로그아웃
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentAccountId');

    state = state.copyWith(
      isAuthenticated: false,
      currentAccount: null,
    );
  }

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentAccountId', accountId);
  }

  /// 사용자 ID 생성
  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// 사용자 데이터 삭제
  Future<void> _deleteUserData(String accountId) async {
    final prefs = await SharedPreferences.getInstance();

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
      await prefs.remove(key);
    }
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
  bool get isGuest => !isAuthenticated;

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