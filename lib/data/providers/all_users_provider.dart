import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'base/base_notifier.dart';

/// 전체 사용자 목록 상태 관리 (BaseNotifier 최적화 버전)
///
/// 앱의 모든 사용자를 관리하고 검색, 필터링, 추천 기능을 제공합니다.
/// 친구 시스템, 리더보드, 리그에서 실제 사용자를 연동할 수 있도록 지원합니다.
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - LocalStorageService 상속으로 필드 제거
class AllUsersNotifier extends BaseNotifier<List<User>> {
  static const String _storageKey = 'all_users';

  AllUsersNotifier() : super([], 'AllUsersProvider') {
    _loadAllUsers();
  }

  /// 앱 시작 시 모든 사용자 로드
  Future<void> _loadAllUsers() async {
    await executeWithErrorHandling(
      () async {
        logInfo('전체 사용자 목록 로드 시작');

        final users = await loadList<User>(
          key: _storageKey,
          fromJson: User.fromJson,
        );

        if (users != null && users.isNotEmpty) {
          state = users;
          logInfo('전체 사용자 목록 로드 성공: ${users.length}명');
        } else {
          // 데이터가 없으면 샘플 사용자 생성
          await _generateSampleUsers();
        }
      },
      errorMessage: '전체 사용자 목록 로드 실패',
      fallback: () => _generateSampleUsers(),
    );
  }

  /// 샘플 사용자 20명 생성 (다양한 레벨과 학년)
  Future<void> _generateSampleUsers() async {
    final now = DateTime.now();

    final sampleUsers = <User>[
      // 초보자 (레벨 1-5)
      User(
        id: 'user_sample_001',
        name: '김민준',
        email: 'minjun.kim@example.com',
        joinDate: now.subtract(const Duration(days: 5)),
        level: 3,
        xp: 280,
        streakDays: 3,
        currentGrade: '중1',
        avatarUrl: '😊',
        hearts: 5,
        dailyXP: 50,
        lastStudyDate: now.subtract(const Duration(hours: 2)),
      ),
      User(
        id: 'user_sample_002',
        name: '이서윤',
        email: 'seoyun.lee@example.com',
        joinDate: now.subtract(const Duration(days: 10)),
        level: 5,
        xp: 480,
        streakDays: 7,
        currentGrade: '중1',
        avatarUrl: '🌟',
        hearts: 4,
        dailyXP: 80,
        lastStudyDate: now.subtract(const Duration(hours: 1)),
      ),
      User(
        id: 'user_sample_003',
        name: '박지호',
        email: 'jiho.park@example.com',
        joinDate: now.subtract(const Duration(days: 3)),
        level: 2,
        xp: 150,
        streakDays: 2,
        currentGrade: '초6',
        avatarUrl: '🎯',
        hearts: 5,
        dailyXP: 30,
        lastStudyDate: now.subtract(const Duration(hours: 5)),
      ),

      // 중급자 (레벨 6-15)
      User(
        id: 'user_sample_004',
        name: '최수아',
        email: 'sua.choi@example.com',
        joinDate: now.subtract(const Duration(days: 30)),
        level: 8,
        xp: 750,
        streakDays: 15,
        currentGrade: '중2',
        avatarUrl: '💫',
        hearts: 5,
        dailyXP: 100,
        lastStudyDate: now.subtract(const Duration(hours: 3)),
      ),
      User(
        id: 'user_sample_005',
        name: '정예준',
        email: 'yejun.jung@example.com',
        joinDate: now.subtract(const Duration(days: 45)),
        level: 12,
        xp: 1350,
        streakDays: 22,
        currentGrade: '중2',
        avatarUrl: '🚀',
        hearts: 4,
        dailyXP: 120,
        lastStudyDate: now.subtract(const Duration(minutes: 30)),
      ),
      User(
        id: 'user_sample_006',
        name: '강하은',
        email: 'haeun.kang@example.com',
        joinDate: now.subtract(const Duration(days: 25)),
        level: 10,
        xp: 980,
        streakDays: 12,
        currentGrade: '중3',
        avatarUrl: '✨',
        hearts: 5,
        dailyXP: 90,
        lastStudyDate: now.subtract(const Duration(hours: 4)),
      ),
      User(
        id: 'user_sample_007',
        name: '조민서',
        email: 'minseo.cho@example.com',
        joinDate: now.subtract(const Duration(days: 35)),
        level: 11,
        xp: 1180,
        streakDays: 18,
        currentGrade: '중3',
        avatarUrl: '🌈',
        hearts: 3,
        dailyXP: 110,
        lastStudyDate: now.subtract(const Duration(hours: 2)),
      ),
      User(
        id: 'user_sample_008',
        name: '윤지우',
        email: 'jiwoo.yoon@example.com',
        joinDate: now.subtract(const Duration(days: 20)),
        level: 9,
        xp: 850,
        streakDays: 10,
        currentGrade: '중2',
        avatarUrl: '🎨',
        hearts: 5,
        dailyXP: 95,
        lastStudyDate: now.subtract(const Duration(hours: 1)),
      ),

      // 고급자 (레벨 16-30)
      User(
        id: 'user_sample_009',
        name: '임도현',
        email: 'dohyun.lim@example.com',
        joinDate: now.subtract(const Duration(days: 60)),
        level: 18,
        xp: 2100,
        streakDays: 35,
        currentGrade: '고1',
        avatarUrl: '🏆',
        hearts: 5,
        dailyXP: 150,
        lastStudyDate: now.subtract(const Duration(minutes: 45)),
      ),
      User(
        id: 'user_sample_010',
        name: '한서준',
        email: 'seojun.han@example.com',
        joinDate: now.subtract(const Duration(days: 75)),
        level: 22,
        xp: 2850,
        streakDays: 42,
        currentGrade: '고1',
        avatarUrl: '⚡',
        hearts: 4,
        dailyXP: 170,
        lastStudyDate: now.subtract(const Duration(hours: 1)),
      ),
      User(
        id: 'user_sample_011',
        name: '오하영',
        email: 'hayoung.oh@example.com',
        joinDate: now.subtract(const Duration(days: 55)),
        level: 20,
        xp: 2400,
        streakDays: 30,
        currentGrade: '고2',
        avatarUrl: '🎓',
        hearts: 5,
        dailyXP: 160,
        lastStudyDate: now.subtract(const Duration(hours: 3)),
      ),
      User(
        id: 'user_sample_012',
        name: '신우진',
        email: 'woojin.shin@example.com',
        joinDate: now.subtract(const Duration(days: 50)),
        level: 17,
        xp: 1950,
        streakDays: 28,
        currentGrade: '고1',
        avatarUrl: '🔥',
        hearts: 4,
        dailyXP: 140,
        lastStudyDate: now.subtract(const Duration(hours: 2)),
      ),

      // 전문가 (레벨 31+)
      User(
        id: 'user_sample_013',
        name: '배지민',
        email: 'jimin.bae@example.com',
        joinDate: now.subtract(const Duration(days: 90)),
        level: 35,
        xp: 4200,
        streakDays: 60,
        currentGrade: '고2',
        avatarUrl: '👑',
        hearts: 5,
        dailyXP: 200,
        lastStudyDate: now.subtract(const Duration(minutes: 30)),
      ),
      User(
        id: 'user_sample_014',
        name: '송연우',
        email: 'yeonwoo.song@example.com',
        joinDate: now.subtract(const Duration(days: 100)),
        level: 42,
        xp: 5500,
        streakDays: 75,
        currentGrade: '고3',
        avatarUrl: '💎',
        hearts: 5,
        dailyXP: 250,
        lastStudyDate: now.subtract(const Duration(hours: 1)),
      ),
      User(
        id: 'user_sample_015',
        name: '양태양',
        email: 'taeyang.yang@example.com',
        joinDate: now.subtract(const Duration(days: 85)),
        level: 38,
        xp: 4650,
        streakDays: 65,
        currentGrade: '고3',
        avatarUrl: '🌟',
        hearts: 4,
        dailyXP: 220,
        lastStudyDate: now.subtract(const Duration(hours: 2)),
      ),

      // 다양한 활동 패턴의 사용자들
      User(
        id: 'user_sample_016',
        name: '노시온',
        email: 'sion.noh@example.com',
        joinDate: now.subtract(const Duration(days: 15)),
        level: 6,
        xp: 580,
        streakDays: 8,
        currentGrade: '중1',
        avatarUrl: '🎵',
        hearts: 3,
        dailyXP: 70,
        lastStudyDate: now.subtract(const Duration(hours: 6)),
      ),
      User(
        id: 'user_sample_017',
        name: '권나라',
        email: 'nara.kwon@example.com',
        joinDate: now.subtract(const Duration(days: 40)),
        level: 13,
        xp: 1420,
        streakDays: 20,
        currentGrade: '중3',
        avatarUrl: '🌺',
        hearts: 5,
        dailyXP: 130,
        lastStudyDate: now.subtract(const Duration(hours: 4)),
      ),
      User(
        id: 'user_sample_018',
        name: '홍준혁',
        email: 'junhyeok.hong@example.com',
        joinDate: now.subtract(const Duration(days: 70)),
        level: 25,
        xp: 3200,
        streakDays: 45,
        currentGrade: '고2',
        avatarUrl: '🎯',
        hearts: 4,
        dailyXP: 180,
        lastStudyDate: now.subtract(const Duration(hours: 1)),
      ),
      User(
        id: 'user_sample_019',
        name: '서다은',
        email: 'daeun.seo@example.com',
        joinDate: now.subtract(const Duration(days: 12)),
        level: 4,
        xp: 350,
        streakDays: 5,
        currentGrade: '초6',
        avatarUrl: '🌸',
        hearts: 5,
        dailyXP: 60,
        lastStudyDate: now.subtract(const Duration(hours: 3)),
      ),
      User(
        id: 'user_sample_020',
        name: '문재현',
        email: 'jaehyun.moon@example.com',
        joinDate: now.subtract(const Duration(days: 95)),
        level: 40,
        xp: 5100,
        streakDays: 70,
        currentGrade: '고3',
        avatarUrl: '🚀',
        hearts: 5,
        dailyXP: 230,
        lastStudyDate: now.subtract(const Duration(minutes: 20)),
      ),
    ];

    state = sampleUsers;
    await _saveAllUsers();

    logInfo('샘플 사용자 ${sampleUsers.length}명 생성 완료');
  }

  /// 모든 사용자 저장
  Future<void> _saveAllUsers() async {
    await executeWithErrorHandling(
      () async {
        await saveList<User>(
          key: _storageKey,
          items: state,
          toJson: (user) => user.toJson(),
        );
        logInfo('전체 사용자 목록 저장 완료: ${state.length}명');
      },
      errorMessage: '전체 사용자 목록 저장 실패',
    );
  }

  /// 모든 사용자 조회 (레벨순 정렬)
  List<User> getAllUsers({bool sortByLevel = true}) {
    if (sortByLevel) {
      final sorted = [...state];
      sorted.sort((a, b) => b.level.compareTo(a.level));
      return sorted;
    }
    return state;
  }

  /// 사용자 ID로 조회
  User? getUserById(String userId) {
    try {
      return state.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// 이름으로 사용자 검색
  List<User> searchByName(String query) {
    if (query.isEmpty) return state;

    final lowerQuery = query.toLowerCase();
    return state.where((user) {
      return user.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 학년별 사용자 필터링
  List<User> filterByGrade(String grade) {
    return state.where((user) => user.currentGrade == grade).toList();
  }

  /// 레벨 범위로 사용자 필터링
  List<User> filterByLevelRange(int minLevel, int maxLevel) {
    return state.where((user) {
      return user.level >= minLevel && user.level <= maxLevel;
    }).toList();
  }

  /// 같은 레벨 대 사용자 추천 (±2 레벨 범위)
  List<User> getRecommendedUsersByLevel(int userLevel, {int range = 2}) {
    final minLevel = (userLevel - range).clamp(1, 999);
    final maxLevel = userLevel + range;

    return filterByLevelRange(minLevel, maxLevel);
  }

  /// 같은 학년 사용자 추천
  List<User> getRecommendedUsersByGrade(String grade) {
    return filterByGrade(grade);
  }

  /// 활성 사용자 조회 (최근 24시간 이내 활동)
  List<User> getActiveUsers() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    return state.where((user) {
      if (user.lastStudyDate == null) return false;
      return user.lastStudyDate!.isAfter(yesterday);
    }).toList();
  }

  /// 스트릭 상위 사용자 조회
  List<User> getTopStreakUsers({int limit = 10}) {
    final sorted = [...state];
    sorted.sort((a, b) => b.streakDays.compareTo(a.streakDays));
    return sorted.take(limit).toList();
  }

  /// 새 사용자 추가
  Future<void> addUser(User user) async {
    // 중복 확인
    if (getUserById(user.id) != null) {
      logWarning('이미 존재하는 사용자: ${user.id}');
      return;
    }

    state = [...state, user];
    await _saveAllUsers();
    logInfo('새 사용자 추가: ${user.name} (${user.id})');
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(User updatedUser) async {
    state = state.map((user) {
      return user.id == updatedUser.id ? updatedUser : user;
    }).toList();

    await _saveAllUsers();
    logInfo('사용자 정보 업데이트: ${updatedUser.name}');
  }

  /// 사용자 삭제
  Future<void> removeUser(String userId) async {
    final user = getUserById(userId);
    if (user == null) {
      logWarning('존재하지 않는 사용자: $userId');
      return;
    }

    state = state.where((u) => u.id != userId).toList();
    await _saveAllUsers();
    logInfo('사용자 삭제: ${user.name} ($userId)');
  }

  /// 검색 및 필터 통합 (다중 조건)
  List<User> search({
    String? nameQuery,
    String? grade,
    int? minLevel,
    int? maxLevel,
    bool? activeOnly,
  }) {
    var results = state;

    // 이름 검색
    if (nameQuery != null && nameQuery.isNotEmpty) {
      final lowerQuery = nameQuery.toLowerCase();
      results = results.where((user) {
        return user.name.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // 학년 필터
    if (grade != null && grade.isNotEmpty) {
      results = results.where((user) => user.currentGrade == grade).toList();
    }

    // 레벨 범위 필터
    if (minLevel != null) {
      results = results.where((user) => user.level >= minLevel).toList();
    }
    if (maxLevel != null) {
      results = results.where((user) => user.level <= maxLevel).toList();
    }

    // 활성 사용자만
    if (activeOnly == true) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));
      results = results.where((user) {
        if (user.lastStudyDate == null) return false;
        return user.lastStudyDate!.isAfter(yesterday);
      }).toList();
    }

    return results;
  }

  /// 모든 데이터 초기화 (테스트용)
  Future<void> clearAllData() async {
    await executeWithErrorHandling(
      () async {
        state = [];
        await removeFromStorage(_storageKey);
        logInfo('전체 사용자 데이터 초기화 완료');
      },
      errorMessage: '전체 사용자 데이터 초기화 실패',
    );
  }

  /// 샘플 데이터 재생성
  Future<void> regenerateSampleUsers() async {
    await clearAllData();
    await _generateSampleUsers();
  }
}

/// Provider 선언
final allUsersProvider = StateNotifierProvider<AllUsersNotifier, List<User>>((ref) {
  return AllUsersNotifier();
});

/// 전체 사용자 수 Provider
final userCountProvider = Provider<int>((ref) {
  final users = ref.watch(allUsersProvider);
  return users.length;
});

/// 활성 사용자 수 Provider (24시간 이내 활동)
final activeUserCountProvider = Provider<int>((ref) {
  final allUsers = ref.watch(allUsersProvider);
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(hours: 24));

  return allUsers.where((user) {
    if (user.lastStudyDate == null) return false;
    return user.lastStudyDate!.isAfter(yesterday);
  }).length;
});
