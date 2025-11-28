# MathLab Flutter App - Detailed Issues & Solutions

## CRITICAL ISSUES

### 1. Bloated Widget Files (>1000 lines)

#### Problem Files:
- **problem_screen.dart** (1,389 lines) - Problem solving interface
- **home_screen_figma.dart** (1,279 lines) - Home screen
- **errors_screen.dart** (1,001 lines) - Wrong answers display
- **profile_detail_screen_v3_new.dart** (881 lines) - User profile
- **lessons_screen_figma.dart** (822 lines) - Lessons/Units

#### Why It's a Problem:
- Difficult to understand complete file logic
- Hard to test individual components
- Slow build times during development
- Maintenance nightmare as features grow
- Line 1-200: _buildHeader(), _buildContent(), etc.

#### Solution:
Extract into separate widget files. Example for `problem_screen.dart`:

**Before (1,389 lines in one file):**
```
problem_screen.dart (all logic, all UI)
├── Class definitions
├── Build method (500+ lines)
├── Helper methods (800+ lines)
└── Widget methods (500+ lines)
```

**After (modular structure):**
```
problem/
├── problem_screen.dart (300 lines)
│   └── Main screen composition
├── widgets/
│   ├── problem_header.dart (150 lines)
│   │   └── Header with progress, XP, streak
│   ├── problem_content.dart (250 lines)
│   │   └── Problem display + options
│   ├── problem_controls.dart (150 lines)
│   │   └── Submit button, hint button
│   ├── result_animation.dart (200 lines)
│   │   └── Correct/incorrect feedback
│   ├── hint_section.dart (100 lines)
│   │   └── Hint display
│   └── exit_dialog.dart (80 lines)
│       └── Confirmation dialog
```

**Implementation Time**: 3-4 days

---

### 2. setState + Riverpod Anti-Pattern

#### Affected Files:
- `problem_screen.dart` (Lines 41-78)
- `settings_screen.dart` (Multiple setState calls)
- `messages_screen.dart` (Lines with builder setState)

#### The Problem:
```dart
// ❌ ANTI-PATTERN: Mixing both paradigms
class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  // Local state (setState)
  int _currentProblemIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  bool _isCorrect = false;
  
  // Session statistics (local state)
  int _totalCorrect = 0;
  int _totalXPEarned = 0;
  final List<ProblemResult> _results = [];
  
  // Then later:
  void _submitAnswer() {
    setState(() {  // ❌ Using setState
      _isAnswerSubmitted = true;
      _isCorrect = selectedIndex == problem.correctAnswerIndex;
    });
  }
  
  // Also using Riverpod:
  ref.watch(userProvider);  // ❌ Mixing paradigms
  ref.read(achievementProvider.notifier).checkAchievements();
}
```

#### Why It's Wrong:
1. **Testing Nightmare** - Can't mock Riverpod or setState independently
2. **State Consistency** - Two sources of truth
3. **Performance** - Multiple rebuild triggers
4. **Maintainability** - Confusing logic flow
5. **Memory** - setState listeners + Riverpod subscriptions

#### Solution:
Migrate to Riverpod-only approach:

**Step 1: Create Provider for Problem Progress**
```dart
// problem_progress_provider.dart
class ProblemProgress {
  final int currentProblemIndex;
  final int? selectedAnswerIndex;
  final bool isAnswerSubmitted;
  final bool isCorrect;
  final int totalCorrect;
  final int totalXPEarned;
  final List<ProblemResult> results;
  final int currentStreak;
  final int maxStreak;
  
  ProblemProgress({
    this.currentProblemIndex = 0,
    this.selectedAnswerIndex,
    this.isAnswerSubmitted = false,
    this.isCorrect = false,
    this.totalCorrect = 0,
    this.totalXPEarned = 0,
    this.results = const [],
    this.currentStreak = 0,
    this.maxStreak = 0,
  });
  
  ProblemProgress copyWith({
    int? currentProblemIndex,
    int? selectedAnswerIndex,
    bool? isAnswerSubmitted,
    bool? isCorrect,
    int? totalCorrect,
    int? totalXPEarned,
    List<ProblemResult>? results,
    int? currentStreak,
    int? maxStreak,
  }) => ProblemProgress(
    currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
    // ... other fields
  );
}

class ProblemProgressNotifier extends StateNotifier<ProblemProgress> {
  ProblemProgressNotifier() : super(ProblemProgress());
  
  void selectAnswer(int index) {
    state = state.copyWith(selectedAnswerIndex: index);
  }
  
  Future<void> submitAnswer(Problem problem, int? selectedIndex) async {
    final isCorrect = selectedIndex == problem.correctAnswerIndex;
    
    state = state.copyWith(
      isAnswerSubmitted: true,
      isCorrect: isCorrect,
    );
    
    if (isCorrect) {
      state = state.copyWith(
        totalCorrect: state.totalCorrect + 1,
        currentStreak: state.currentStreak + 1,
      );
    }
  }
  
  void nextProblem() {
    state = state.copyWith(
      currentProblemIndex: state.currentProblemIndex + 1,
      selectedAnswerIndex: null,
      isAnswerSubmitted: false,
    );
  }
  
  void reset() {
    state = ProblemProgress();
  }
}

final problemProgressProvider = StateNotifierProvider<
  ProblemProgressNotifier,
  ProblemProgress
>((ref) => ProblemProgressNotifier());
```

**Step 2: Update Widget**
```dart
// ✅ CORRECT: Riverpod-only approach
class ProblemScreen extends ConsumerWidget {
  const ProblemScreen({
    required this.lessonId,
    required this.problems,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(problemProgressProvider);
    final user = ref.watch(userProvider);
    
    final currentProblem = problems[progress.currentProblemIndex];
    
    return Scaffold(
      body: Column(
        children: [
          ProblemHeader(
            progress: progress.currentProblemIndex + 1,
            total: problems.length,
            xp: user?.xp ?? 0,
            streak: progress.currentStreak,
          ),
          ProblemContent(
            problem: currentProblem,
            selectedIndex: progress.selectedAnswerIndex,
            isSubmitted: progress.isAnswerSubmitted,
            isCorrect: progress.isCorrect,
            onSelectAnswer: (index) {
              ref.read(problemProgressProvider.notifier)
                  .selectAnswer(index);
            },
            onSubmitAnswer: () async {
              await ref.read(problemProgressProvider.notifier)
                  .submitAnswer(currentProblem, progress.selectedAnswerIndex);
            },
          ),
        ],
      ),
    );
  }
}
```

**Implementation Time**: 5-7 days (3 screens)

---

### 3. Timer Memory Leak

#### Location:
`lib/data/providers/user_provider.dart:67-81`

#### The Problem:
```dart
void _startHeartRegeneration() {
  _heartRegenTimer?.cancel();  // Good cleanup, but...
  
  _heartRegenTimer = Timer.periodic(
    const Duration(minutes: GameConstants.heartRecoveryMinutes),
    (timer) {
      if (state != null && state!.hearts < GameConstants.maxHearts) {
        _regenerateOneHeart();  // ❌ Callback holds reference
      }
    },
  );
  
  Logger.info('하트 재생 타이머 시작 (30분마다)', tag: 'UserProvider');
}

@override
void dispose() {
  _heartRegenTimer?.cancel();  // ✅ Cleanup exists
  super.dispose();
}
```

#### Why It's a Problem:
1. **If app is backgrounded**, notifier may not be immediately garbage collected
2. **Timer continues running** in background (drains battery)
3. **Callback keeps strong reference** to notifier
4. **Multiple instances** could accumulate if provider is recreated

#### Scenario That Causes Leak:
```
1. App opens → UserNotifier created → Timer starts
2. User navigates away (screen pops) → _dispose() called
3. BUT: App remains in memory (provider cached)
4. Timer continues running every 30 minutes
5. App backgrounded → Timer still runs
6. Battery drains, memory leaks occur
```

#### Solution:

**Option 1: Make Timer Cleanup Explicit**
```dart
class UserNotifier extends StateNotifier<User?> {
  Timer? _heartRegenTimer;
  bool _disposed = false;  // Add flag
  
  void _startHeartRegeneration() {
    _heartRegenTimer?.cancel();
    _heartRegenTimer = null;  // Clear reference
    
    _heartRegenTimer = Timer.periodic(
      const Duration(minutes: GameConstants.heartRecoveryMinutes),
      (timer) {
        if (_disposed) {  // Check before accessing state
          timer.cancel();
          return;
        }
        
        if (state != null && state!.hearts < GameConstants.maxHearts) {
          _regenerateOneHeart();
        }
      },
    );
  }
  
  @override
  void dispose() {
    _disposed = true;
    _heartRegenTimer?.cancel();
    _heartRegenTimer = null;  // Explicitly null
    super.dispose();
  }
}
```

**Option 2: Use Timer Once Instead**
```dart
// Better: Use async/await with Future.delayed
Future<void> _startHeartRegeneration() async {
  while (!_disposed) {
    await Future.delayed(
      const Duration(minutes: GameConstants.heartRecoveryMinutes),
    );
    
    if (!_disposed && state != null && 
        state!.hearts < GameConstants.maxHearts) {
      await _regenerateOneHeart();
    }
  }
}
```

**Option 3: Use Package (Recommended)**
```dart
// Add to pubspec.yaml:
dependencies:
  rxdart: ^0.27.0  # For interval-based streams

// In UserNotifier:
StreamSubscription<int>? _heartRegenSubscription;

void _startHeartRegeneration() {
  _heartRegenSubscription?.cancel();
  
  _heartRegenSubscription = Stream.periodic(
    const Duration(minutes: GameConstants.heartRecoveryMinutes),
    (count) => count,
  ).listen((_) {
    if (state != null && state!.hearts < GameConstants.maxHearts) {
      _regenerateOneHeart();
    }
  });
}

@override
void dispose() {
  _heartRegenSubscription?.cancel();
  super.dispose();
}
```

**Implementation Time**: 2-3 hours

---

### 4. Async in Constructor

#### Location:
`lib/data/providers/problem_provider.dart:10-39`

#### The Problem:
```dart
class ProblemNotifier extends StateNotifier<List<Problem>> {
  ProblemNotifier() : super([]) {
    _loadProblems();  // ❌ Async call in constructor
  }
  
  Future<void> _loadProblems() async {
    try {
      Logger.info('문제 데이터 로드 시작', tag: 'ProblemProvider');
      
      final String data = await rootBundle.loadString(
        'assets/data/problems.json',  // ❌ File I/O in constructor
      );
      final Map<String, dynamic> jsonData = jsonDecode(data);  // ❌ JSON parsing
      final List<dynamic> problemsData = jsonData['problems'];
      
      final problems = problemsData
          .map((problemData) => Problem.fromJson(problemData))
          .toList();
      
      state = problems;
    } catch (e, stackTrace) {
      Logger.error('문제 로드 실패', error: e, stackTrace: stackTrace);
      state = [];
    }
  }
}
```

#### Why It's Wrong:
1. **Constructor may not return immediately** if file large
2. **UI blocks** during JSON parsing
3. **No loading state** shown to user
4. **Error handling inadequate** - falls back silently

#### Impact:
- App freezes during startup
- If problems.json is 1MB+, freeze could be 1-2 seconds
- User sees blank screen

#### Solution:

**Change to FutureProvider:**
```dart
// problems_provider.dart
final problemProvider = FutureProvider<List<Problem>>((ref) async {
  try {
    Logger.info('문제 데이터 로드 시작', tag: 'ProblemProvider');
    
    final String data = await rootBundle.loadString(
      'assets/data/problems.json',
    );
    final Map<String, dynamic> jsonData = jsonDecode(data);
    final List<dynamic> problemsData = jsonData['problems'];
    
    final problems = problemsData
        .map((problemData) => Problem.fromJson(problemData))
        .toList();
    
    Logger.info('문제 ${problems.length}개 로드 완료', tag: 'ProblemProvider');
    return problems;
  } catch (e, stackTrace) {
    Logger.error('문제 로드 실패', error: e, stackTrace: stackTrace);
    return [];
  }
});

// In UI, handle AsyncValue:
class ProblemSelectionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(problemProvider);
    
    return problemsAsync.when(
      data: (problems) => _buildContent(problems),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorWidget(error: error),
    );
  }
  
  Widget _buildContent(List<Problem> problems) {
    return ListView(
      children: problems.map((p) => ProblemTile(problem: p)).toList(),
    );
  }
}
```

**For large files, add pagination:**
```dart
final problemPageProvider = FutureProvider.family<
  List<Problem>,
  int
>((ref, pageNumber) async {
  const pageSize = 50;
  final allProblems = await ref.watch(problemProvider.future);
  
  final startIndex = pageNumber * pageSize;
  final endIndex = (pageNumber + 1) * pageSize;
  
  return allProblems.sublist(
    startIndex,
    endIndex.clamp(0, allProblems.length),
  );
});
```

**Implementation Time**: 4-5 hours

---

## HIGH-PRIORITY ISSUES

### 5. Code Duplication - Date Logic

#### Location:
`lib/data/providers/user_provider.dart` - Lines 225-238, 276-280, 332-342

#### The Problem:
```dart
// ❌ Pattern repeated 3+ times

// First occurrence (lines 225-238)
final lastStudyDate = state!.lastStudyDate;
final lastStudyDateOnly = DateTime(
  lastStudyDate.year,
  lastStudyDate.month,
  lastStudyDate.day,
);

// Second occurrence (lines 276-280)
final lastStudyDateOnly = DateTime(
  lastStudyDate.year,
  lastStudyDate.month,
  lastStudyDate.day,
);

// Third occurrence (similar pattern)
// ...
```

#### Solution:
Extract utility functions:

```dart
// date_utils.dart
class DateUtils {
  /// Convert DateTime to date-only (strips time component)
  static DateTime dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime d1, DateTime d2) =>
    dateOnly(d1) == dateOnly(d2);
  
  /// Check if d1 is the day before d2
  static bool isConsecutiveDay(DateTime d1, DateTime d2) {
    final yesterday = dateOnly(d2).subtract(const Duration(days: 1));
    return isSameDay(d1, yesterday);
  }
  
  /// Get today's date (time stripped)
  static DateTime getToday() => dateOnly(DateTime.now());
}

// Then in user_provider.dart:
Future<void> checkAndUpdateStreak() async {
  if (state == null) return;
  
  final now = DateUtils.getToday();
  final lastStudyDate = state!.lastStudyDate;
  
  if (lastStudyDate == null) {
    Logger.info('첫 사용자, 스트릭 대기 중', tag: 'UserProvider');
    return;
  }
  
  final lastStudyDateOnly = DateUtils.dateOnly(lastStudyDate);
  
  // Cleaner code
  if (DateUtils.isSameDay(lastStudyDateOnly, now)) {
    Logger.debug('오늘 이미 학습 완료', tag: 'UserProvider');
    return;
  }
  
  if (!DateUtils.isConsecutiveDay(lastStudyDateOnly, now)) {
    // Streak reset logic
  }
}
```

**Implementation Time**: 2-3 hours

---

### 6. Inefficient Provider Watching

#### Location:
`lib/features/home/home_screen_figma.dart:31`

#### The Problem:
```dart
class HomeScreenFigma extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);  // ❌ Watches ENTIRE user object
    
    return Column(
      children: [
        Text('안녕하세요, ${user?.name}!'),  // Only uses name
        Text('Level ${user?.level}'),          // Only uses level
        Text('${user?.xp} XP'),                // Only uses XP
      ],
    );
  }
}
```

#### Why It's Bad:
- Screen rebuilds when **ANY** user property changes
- Even if just `hearts` updates, entire screen rebuilds
- Inefficient for large screens

#### Solution:
Use `.select()` for granular watching:

```dart
class HomeScreenFigma extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only specific properties
    final userName = ref.watch(
      userProvider.select((user) => user?.name ?? '학습자'),
    );
    final userLevel = ref.watch(
      userProvider.select((user) => user?.level ?? 1),
    );
    final userXP = ref.watch(
      userProvider.select((user) => user?.xp ?? 0),
    );
    
    return Column(
      children: [
        Text('안녕하세요, $userName!'),      // Only rebuilds if name changes
        Text('Level $userLevel'),             // Only rebuilds if level changes
        Text('$userXP XP'),                   // Only rebuilds if XP changes
      ],
    );
  }
}
```

**Alternative: Create Derived Providers** (Already exists in codebase)
```dart
// In user_provider.dart (Lines 506-529)
final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.name ?? '학습자';
});

final userLevelProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  return user?.level ?? 1;
});

// Then in widget:
final userName = ref.watch(userNameProvider);
final userLevel = ref.watch(userLevelProvider);
```

**Implementation Time**: 4-6 hours for entire codebase

---

### 7. Unencrypted Local Storage

#### Location:
All `_storage.saveObject()` calls throughout codebase

#### The Problem:
```dart
// ❌ User data saved unencrypted
await _storage.saveObject<User>(
  key: GameConstants.userStorageKey,
  data: state!,
  toJson: (user) => user.toJson(),
);

// Data saved as plain JSON in SharedPreferences
// Any app can read this via Android shell commands:
// adb shell
// > cat /data/data/com.example.mathlab/shared_prefs/userData.xml
```

#### Solution:
Use `flutter_secure_storage`:

```dart
// pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0

// secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();
  
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  
  Future<void> saveObject<T>({
    required String key,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final jsonData = toJson(data);
      final jsonString = jsonEncode(jsonData);
      
      await _storage.write(
        key: key,
        value: jsonString,
      );
      
      Logger.debug('Saved encrypted object for key: $key', tag: 'SecureStorage');
    } catch (e, stackTrace) {
      Logger.error('Failed to save object', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  Future<T?> loadObject<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final jsonString = await _storage.read(key: key);
      
      if (jsonString == null) {
        Logger.debug('No data found for key: $key', tag: 'SecureStorage');
        return null;
      }
      
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final object = fromJson(jsonData);
      
      Logger.debug('Loaded encrypted object for key: $key', tag: 'SecureStorage');
      return object;
    } catch (e, stackTrace) {
      Logger.error('Failed to load object', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}

// Then replace LocalStorageService usage:
final _secureStorage = SecureStorageService();  // For sensitive data
final _localStorage = LocalStorageService();     // For non-sensitive data

// In UserNotifier:
await _secureStorage.saveObject<User>(
  key: GameConstants.userStorageKey,
  data: state!,
  toJson: (user) => user.toJson(),
);
```

**Implementation Time**: 1-2 days (includes testing)

---

### 8. Missing Error State

#### Locations:
- `auth_provider.dart` - Social login failures
- Problem screens - Network errors
- Settings screen - Profile update failures

#### The Problem:
```dart
// ❌ Error only logged, not shown to user
Future<bool> signUpWithGoogle() async {
  try {
    // ... auth flow
  } catch (e, stackTrace) {
    Logger.error('Google signup failed', error: e, stackTrace: stackTrace);
    return false;  // User has no idea what happened
  }
}

// ❌ No error UI:
state = state.copyWith(isLoading: false);  // Just stops loading, no error message
```

#### Solution:
Add error state to providers:

```dart
// auth_state.dart
class AuthState {
  final bool isAuthenticated;
  final UserAccount? currentAccount;
  final List<UserAccount> availableAccounts;
  final bool isLoading;
  final String? errorMessage;  // ✅ Add this
  final ErrorCode? errorCode;  // ✅ And this for machine-readable errors
  
  AuthState({
    required this.isAuthenticated,
    required this.currentAccount,
    required this.availableAccounts,
    required this.isLoading,
    this.errorMessage,
    this.errorCode,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    UserAccount? currentAccount,
    List<UserAccount>? availableAccounts,
    bool? isLoading,
    String? errorMessage,
    ErrorCode? errorCode,
  }) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    currentAccount: currentAccount ?? this.currentAccount,
    availableAccounts: availableAccounts ?? this.availableAccounts,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
    errorCode: errorCode ?? this.errorCode,
  );
}

enum ErrorCode {
  networkError,
  authenticationFailed,
  accountNotFound,
  emailAlreadyExists,
  invalidInput,
  unknown,
}

// auth_provider.dart
Future<bool> signUpWithGoogle() async {
  try {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // ... auth flow
    
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      currentAccount: newAccount,
    );
    return true;
  } catch (e, stackTrace) {
    Logger.error('Google signup failed', error: e, stackTrace: stackTrace);
    
    final errorMessage = _getErrorMessage(e);
    final errorCode = _getErrorCode(e);
    
    state = state.copyWith(
      isLoading: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
    
    return false;
  }
}

String _getErrorMessage(dynamic error) {
  if (error is PlatformException) {
    return 'Google 로그인 실패: ${error.message ?? '알 수 없는 오류'}';
  }
  return 'Google 로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
}

ErrorCode _getErrorCode(dynamic error) {
  // Map error types to ErrorCode enum
  if (error is PlatformException && error.code == 'NETWORK_ERROR') {
    return ErrorCode.networkError;
  }
  return ErrorCode.unknown;
}

// In UI:
class AuthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Column(
      children: [
        // ... form fields
        
        // ✅ Show error message
        if (authState.errorMessage != null)
          ErrorBanner(message: authState.errorMessage!),
        
        // ... buttons
      ],
    );
  }
}
```

**Implementation Time**: 3-4 days

---

## Continuation...

See full detailed issues in separate sections. This covers the 4 critical issues with complete solutions.

## QUICK FIX CHECKLIST

- [ ] Extract large widget files
- [ ] Remove setState from ConsumerStatefulWidget
- [ ] Fix timer lifecycle in UserNotifier
- [ ] Replace problem_provider async-in-constructor
- [ ] Extract date utilities
- [ ] Optimize provider watching
- [ ] Implement encrypted storage
- [ ] Add error state to providers
