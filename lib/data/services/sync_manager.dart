import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_storage_service.dart';
import 'firestore_service.dart';
import '../models/sync/sync_status.dart';
import '../models/sync/sync_task.dart';
import '../models/user/user.dart';
import '../models/learning/wrong_answer.dart';
import '../models/learning/lesson.dart';
import '../models/gamification/league.dart';
import '../repositories/user_repository.dart';
import '../repositories/wrong_answer_repository.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/league_repository.dart';
import '../../shared/utils/logger.dart';

/// 동기화 관리자
///
/// 역할:
/// - 네트워크 상태 모니터링
/// - 오프라인 큐 관리
/// - 자동/수동 동기화 실행
/// - 충돌 해결
class SyncManager {
  // Singleton 패턴
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final LocalStorageService _localStorage = LocalStorageService();
  final FirestoreService _firestore = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  // Repository 인스턴스 (initialize에서 주입받음)
  // late final로 선언하여 초기화 보장 및 null 체크 제거
  late final UserRepository _userRepository;
  late final WrongAnswerRepository _wrongAnswerRepository;
  late final LessonRepository _lessonRepository;
  late final LeagueRepository _leagueRepository;

  // 동기화 상태 스트림
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  // 현재 동기화 상태
  SyncStatus _currentStatus = const SyncStatus(state: SyncState.idle);

  // 오프라인 큐
  final List<SyncTask> _pendingTasks = [];
  static const String _queueStorageKey = 'sync_queue';

  // 네트워크 상태
  bool _isOnline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // 동기화 실행 중 플래그
  bool _isSyncing = false;

  // ==================== 초기화 ====================

  /// 초기화
  Future<void> initialize({
    UserRepository? userRepository,
    WrongAnswerRepository? wrongAnswerRepository,
    LessonRepository? lessonRepository,
    LeagueRepository? leagueRepository,
  }) async {
    try {
      Logger.info('SyncManager 초기화 시작', tag: 'SyncManager');

      // Repository 주입
      _userRepository = userRepository ?? UserRepository();
      _wrongAnswerRepository = wrongAnswerRepository ??
          WrongAnswerRepository(
            localStorageService: _localStorage,
            firestoreService: _firestore,
          );
      _lessonRepository = lessonRepository ??
          LessonRepository(
            localStorageService: _localStorage,
            firestoreService: _firestore,
          );
      _leagueRepository = leagueRepository ??
          LeagueRepository(
            localStorageService: _localStorage,
            firestoreService: _firestore,
          );

      // 오프라인 큐 로드
      await _loadPendingTasks();

      // 네트워크 상태 모니터링 시작
      await _startNetworkMonitoring();

      Logger.info(
        'SyncManager 초기화 완료 (대기 중인 작업: ${_pendingTasks.length}개)',
        tag: 'SyncManager',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'SyncManager 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
    }
  }

  /// 정리
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _syncStatusController.close();
  }

  // ==================== 네트워크 모니터링 ====================

  /// 네트워크 상태 모니터링 시작
  Future<void> _startNetworkMonitoring() async {
    // 현재 네트워크 상태 확인
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    Logger.info('현재 네트워크 상태: ${_isOnline ? "온라인" : "오프라인"}', tag: 'SyncManager');

    // 네트워크 상태 변화 감지
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        Logger.info('네트워크 상태 변경: ${_isOnline ? "온라인" : "오프라인"}', tag: 'SyncManager');

        // 오프라인 → 온라인으로 전환 시 대기 중인 작업 실행
        if (!wasOnline && _isOnline) {
          _updateStatus(SyncState.idle, '온라인으로 전환됨');
          _processPendingTasks();
        } else if (wasOnline && !_isOnline) {
          _updateStatus(SyncState.offline, '오프라인 모드');
        }
      },
    );
  }

  /// 온라인 여부 확인
  bool get isOnline => _isOnline;

  // ==================== 동기화 상태 관리 ====================

  /// 동기화 상태 업데이트
  void _updateStatus(SyncState state, [String? message]) {
    _currentStatus = _currentStatus.copyWith(
      state: state,
      message: message,
      lastSyncAt: state == SyncState.success ? DateTime.now() : _currentStatus.lastSyncAt,
      pendingTasks: _pendingTasks.length,
    );

    _syncStatusController.add(_currentStatus);

    Logger.debug('동기화 상태 업데이트: $state - $message', tag: 'SyncManager');
  }

  /// 현재 동기화 상태
  SyncStatus get currentStatus => _currentStatus;

  // ==================== 오프라인 큐 관리 ====================

  /// 대기 중인 작업 로드
  Future<void> _loadPendingTasks() async {
    try {
      final json = await _localStorage.loadMap(_queueStorageKey);
      if (json == null || json.isEmpty) return;

      final tasksJson = json['tasks'] as List<dynamic>? ?? [];
      _pendingTasks.clear();
      _pendingTasks.addAll(
        tasksJson.map((item) => SyncTask.fromJson(item as Map<String, dynamic>)),
      );

      Logger.info('대기 중인 작업 로드: ${_pendingTasks.length}개', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '대기 중인 작업 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
    }
  }

  /// 대기 중인 작업 저장
  Future<void> _savePendingTasks() async {
    try {
      final json = {
        'tasks': _pendingTasks.map((task) => task.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _localStorage.saveMap(_queueStorageKey, json);

      Logger.debug('대기 중인 작업 저장: ${_pendingTasks.length}개', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '대기 중인 작업 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
    }
  }

  /// 작업 큐에 추가
  Future<void> addTask(SyncTask task) async {
    _pendingTasks.add(task);
    await _savePendingTasks();

    _updateStatus(_currentStatus.state, '작업 추가됨: ${task.type.name}');

    // 온라인이면 즉시 실행
    if (_isOnline && !_isSyncing) {
      await _processPendingTasks();
    }
  }

  /// 대기 중인 작업 실행
  Future<void> _processPendingTasks() async {
    if (_isSyncing || _pendingTasks.isEmpty || !_isOnline) return;

    _isSyncing = true;
    _updateStatus(SyncState.syncing, '동기화 중 (${_pendingTasks.length}개 작업)');

    final tasksToProcess = List<SyncTask>.from(_pendingTasks);
    final failedTasks = <SyncTask>[];

    for (final task in tasksToProcess) {
      try {
        await _executeTask(task);
        _pendingTasks.remove(task);
        Logger.info('작업 완료: ${task.id} (${task.type.name})', tag: 'SyncManager');
      } catch (e) {
        Logger.warning('작업 실패: ${task.id} - $e', tag: 'SyncManager');

        // 재시도 가능하면 재시도 카운트 증가
        if (task.canRetry) {
          final retriedTask = task.copyWith(retryCount: task.retryCount + 1);
          failedTasks.add(retriedTask);
          _pendingTasks.remove(task);
        } else {
          Logger.error('작업 최대 재시도 초과: ${task.id}', tag: 'SyncManager');
          _pendingTasks.remove(task);
        }
      }
    }

    // 실패한 작업 다시 큐에 추가
    _pendingTasks.addAll(failedTasks);
    await _savePendingTasks();

    _isSyncing = false;

    if (_pendingTasks.isEmpty) {
      _updateStatus(SyncState.success, '모든 작업 완료');
    } else {
      _updateStatus(SyncState.error, '일부 작업 실패 (${_pendingTasks.length}개 대기 중)');
    }
  }

  /// 단일 작업 실행
  Future<void> _executeTask(SyncTask task) async {
    switch (task.type) {
      case SyncTaskType.uploadUserProfile:
        await _uploadUserProfile(task);
        break;

      case SyncTaskType.uploadWrongAnswer:
        await _uploadWrongAnswer(task);
        break;

      case SyncTaskType.uploadStudyHistory:
        await _uploadLessons(task);
        break;

      case SyncTaskType.uploadLeague:
        await _uploadLeague(task);
        break;

      case SyncTaskType.downloadUserProfile:
        await _downloadUserProfile(task);
        break;

      case SyncTaskType.downloadWrongAnswers:
        await _downloadWrongAnswers(task);
        break;

      case SyncTaskType.downloadStudyHistory:
        await _downloadLessons(task);
        break;
    }
  }

  /// 레슨 데이터 업로드
  Future<void> _uploadLessons(SyncTask task) async {
    try {
      final lessonsData = task.data['lessons'] as List<dynamic>;
      final lessons = lessonsData
          .map((lessonJson) => Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList();

      await _lessonRepository.saveToFirebase(task.accountId, lessons);

      Logger.info('레슨 데이터 업로드 완료: ${lessons.length}개', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 데이터 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  /// 리그 데이터 업로드
  Future<void> _uploadLeague(SyncTask task) async {
    try {
      final leagueData = task.data['league'] as Map<String, dynamic>;
      final league = League.fromJson(leagueData);

      await _leagueRepository.saveToFirebase(task.accountId, league);

      Logger.info('리그 데이터 업로드 완료: ${league.tier}', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 데이터 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  /// 레슨 데이터 다운로드
  Future<void> _downloadLessons(SyncTask task) async {
    try {
      final remoteLessons = await _lessonRepository.getFromFirebase(task.accountId);

      if (remoteLessons != null && remoteLessons.isNotEmpty) {
        final localLessons = await _lessonRepository.getFromLocal('lessons_${task.accountId}');

        // 병합: 기본 정보는 Firebase, 진행률은 로컬 우선
        if (localLessons != null) {
          final merged = await _lessonRepository.mergeData(localLessons, remoteLessons);
          if (merged != null) {
            await _lessonRepository.saveToLocal('lessons_${task.accountId}', merged);
          }
        } else {
          await _lessonRepository.saveToLocal('lessons_${task.accountId}', remoteLessons);
        }
        Logger.info('레슨 데이터 다운로드 완료: ${remoteLessons.length}개', tag: 'SyncManager');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 데이터 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  /// 사용자 프로필 업로드
  Future<void> _uploadUserProfile(SyncTask task) async {
    try {
      // task.data에서 User 객체 복원
      final userData = task.data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      // Repository를 통해 Firebase에 업로드
      await _userRepository.saveToFirebase(task.accountId, user);

      Logger.info('사용자 프로필 업로드 완료: ${task.accountId}', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  /// 오답 업로드
  Future<void> _uploadWrongAnswer(SyncTask task) async {
    try {
      // task.data에서 WrongAnswer 객체 복원
      final wrongAnswerData = task.data['wrongAnswer'] as Map<String, dynamic>;
      final wrongAnswer = WrongAnswer.fromJson(wrongAnswerData);

      // Repository를 통해 Firebase에 업로드
      await _wrongAnswerRepository.saveToFirebase(task.accountId, wrongAnswer);

      Logger.info('오답 업로드 완료: ${wrongAnswer.id}', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '오답 업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  /// 사용자 프로필 다운로드
  Future<void> _downloadUserProfile(SyncTask task) async {
    try {
      // Repository를 통해 Firebase에서 다운로드
      final user = await _userRepository.getFromFirebase(task.accountId);

      if (user != null) {
        // 로컬에 저장
        await _userRepository.saveToLocal(task.accountId, user);
        Logger.info('사용자 프로필 다운로드 완료: ${task.accountId}', tag: 'SyncManager');
      } else {
        Logger.warning('Firebase에 사용자 프로필 없음: ${task.accountId}', tag: 'SyncManager');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  /// 오답 목록 다운로드
  Future<void> _downloadWrongAnswers(SyncTask task) async {
    try {
      // Repository를 통해 Firebase에서 다운로드
      final wrongAnswers = await _wrongAnswerRepository.getFromFirebase(task.accountId);

      if (wrongAnswers.isNotEmpty) {
        // 로컬에 저장
        await _wrongAnswerRepository.saveToLocal(task.accountId, wrongAnswers);
        Logger.info('오답 목록 다운로드 완료: ${wrongAnswers.length}개', tag: 'SyncManager');
      } else {
        Logger.debug('Firebase에 오답 목록 없음: ${task.accountId}', tag: 'SyncManager');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '오답 목록 다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      rethrow;
    }
  }

  // ==================== 수동 동기화 ====================

  /// 초기 동기화 (앱 시작 시)
  Future<void> initialSync(String accountId) async {
    if (!_isOnline) {
      Logger.warning('오프라인 상태 - 동기화 건너뜀', tag: 'SyncManager');
      _updateStatus(SyncState.offline, '오프라인 모드');
      return;
    }

    try {
      _updateStatus(SyncState.syncing, '초기 동기화 중');

      // Repository를 사용하여 모든 데이터 다운로드
      await downloadChanges(accountId);

      _updateStatus(SyncState.success, '초기 동기화 완료');
    } catch (e, stackTrace) {
      Logger.error(
        '초기 동기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      _updateStatus(SyncState.error, '초기 동기화 실패: $e');
    }
  }

  /// 양방향 동기화
  Future<void> bidirectionalSync(String accountId) async {
    if (!_isOnline) {
      Logger.warning('오프라인 상태 - 동기화 건너뜀', tag: 'SyncManager');
      return;
    }

    try {
      _updateStatus(SyncState.syncing, '양방향 동기화 중');

      // 1. 로컬 → Firebase 업로드
      await uploadChanges(accountId);

      // 2. Firebase → 로컬 다운로드
      await downloadChanges(accountId);

      _updateStatus(SyncState.success, '양방향 동기화 완료');
    } catch (e, stackTrace) {
      Logger.error(
        '양방향 동기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      _updateStatus(SyncState.error, '양방향 동기화 실패: $e');
    }
  }

  /// 단방향 업로드
  Future<void> uploadChanges(String accountId) async {
    if (!_isOnline) return;

    try {
      Logger.info('로컬 → Firebase 업로드 시작', tag: 'SyncManager');

      // 1. 사용자 프로필 업로드
      final user = await _userRepository.getFromLocal(accountId);
      if (user != null) {
        await _userRepository.saveToFirebase(accountId, user);
        Logger.debug('사용자 프로필 업로드 완료', tag: 'SyncManager');
      }

      // 2. 오답 목록 업로드
      final wrongAnswers = await _wrongAnswerRepository.getFromLocal(accountId);
      for (final wrongAnswer in wrongAnswers) {
        try {
          await _wrongAnswerRepository.saveToFirebase(accountId, wrongAnswer);
        } catch (e) {
          Logger.warning('오답 업로드 실패: ${wrongAnswer.id} - $e', tag: 'SyncManager');
        }
      }
      Logger.debug('오답 목록 업로드 완료: ${wrongAnswers.length}개', tag: 'SyncManager');

      // 3. 레슨 데이터 업로드
      final lessons = await _lessonRepository.getFromLocal('lessons_$accountId');
      if (lessons != null && lessons.isNotEmpty) {
        await _lessonRepository.saveToFirebase(accountId, lessons);
        Logger.debug('레슨 데이터 업로드 완료: ${lessons.length}개', tag: 'SyncManager');
      }

      // 4. 리그 데이터 업로드
      final league = await _leagueRepository.getFromLocal('league_$accountId');
      if (league != null) {
        await _leagueRepository.saveToFirebase(accountId, league);
        Logger.debug('리그 데이터 업로드 완료: ${league.tier}', tag: 'SyncManager');
      }

      Logger.info('업로드 완료', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '업로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      throw Exception('업로드 실패: $e');
    }
  }

  /// 단방향 다운로드
  Future<void> downloadChanges(String accountId) async {
    if (!_isOnline) return;

    try {
      Logger.info('Firebase → 로컬 다운로드 시작', tag: 'SyncManager');

      // 1. 사용자 프로필 다운로드
      final remoteUser = await _userRepository.getFromFirebase(accountId);
      if (remoteUser != null) {
        final localUser = await _userRepository.getFromLocal(accountId);

        // 충돌 해결 (Local-First: 로컬 우선, Remote가 더 최신이면 덮어쓰기)
        if (localUser != null) {
          final merged = _userRepository.mergeData(localUser, remoteUser);
          await _userRepository.saveToLocal(accountId, merged);
        } else {
          await _userRepository.saveToLocal(accountId, remoteUser);
        }
        Logger.debug('사용자 프로필 다운로드 완료', tag: 'SyncManager');
      }

      // 2. 오답 목록 다운로드
      final remoteAnswers = await _wrongAnswerRepository.getFromFirebase(accountId);
      if (remoteAnswers.isNotEmpty) {
        final localAnswers = await _wrongAnswerRepository.getFromLocal(accountId);

        // 병합: 양쪽 데이터 통합 (중복 제거)
        final merged = _mergeWrongAnswers(localAnswers, remoteAnswers);
        await _wrongAnswerRepository.saveToLocal(accountId, merged);
        Logger.debug('오답 목록 다운로드 완료: ${merged.length}개', tag: 'SyncManager');
      }

      // 3. 레슨 데이터 다운로드
      final remoteLessons = await _lessonRepository.getFromFirebase(accountId);
      if (remoteLessons != null && remoteLessons.isNotEmpty) {
        final localLessons = await _lessonRepository.getFromLocal('lessons_$accountId');

        // 병합: 기본 정보는 Firebase, 진행률은 로컬 우선
        if (localLessons != null) {
          final mergedLessons = await _lessonRepository.mergeData(localLessons, remoteLessons);
          if (mergedLessons != null) {
            await _lessonRepository.saveToLocal('lessons_$accountId', mergedLessons);
          }
        } else {
          await _lessonRepository.saveToLocal('lessons_$accountId', remoteLessons);
        }
        Logger.debug('레슨 데이터 다운로드 완료: ${remoteLessons.length}개', tag: 'SyncManager');
      }

      // 4. 리그 데이터 다운로드
      final remoteLeague = await _leagueRepository.getFromFirebase(accountId);
      if (remoteLeague != null) {
        final localLeague = await _leagueRepository.getFromLocal('league_$accountId');

        // 병합: 리그 데이터는 Firebase 우선 (서버 데이터가 항상 최신)
        if (localLeague != null) {
          final mergedLeague = await _leagueRepository.mergeData(localLeague, remoteLeague);
          if (mergedLeague != null) {
            await _leagueRepository.saveToLocal('league_$accountId', mergedLeague);
          }
        } else {
          await _leagueRepository.saveToLocal('league_$accountId', remoteLeague);
        }
        Logger.debug('리그 데이터 다운로드 완료: ${remoteLeague.tier}', tag: 'SyncManager');
      }

      Logger.info('다운로드 완료', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '다운로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
      throw Exception('다운로드 실패: $e');
    }
  }

  /// 오답 목록 병합 (중복 제거)
  List<WrongAnswer> _mergeWrongAnswers(List<WrongAnswer> local, List<WrongAnswer> remote) {
    final Map<String, WrongAnswer> merged = {};

    // 로컬 데이터 추가
    for (final answer in local) {
      merged[answer.id] = answer;
    }

    // 원격 데이터 추가 (중복 시 최신 것 사용)
    for (final answer in remote) {
      final existing = merged[answer.id];
      if (existing == null) {
        merged[answer.id] = answer;
      } else {
        // 복습 횟수가 많은 것 우선
        if (answer.reviewCount > existing.reviewCount) {
          merged[answer.id] = answer;
        }
      }
    }

    return merged.values.toList();
  }

  // ==================== 실시간 스트림 ====================

  /// 사용자 프로필 실시간 감지
  Stream<User?> watchUserProfile(String userId) {
    return _userRepository.watchUserProfile(userId);
  }

  /// 레슨 데이터 실시간 감지
  Stream<List<Lesson>> watchLessons() {
    return _lessonRepository.watchLessons();
  }

  /// 리그 순위 실시간 감지
  Stream<League?> watchLeague(String userId) {
    return _leagueRepository.watchCurrentLeague(userId);
  }

  /// 전체 실시간 동기화 시작 (앱 시작 시 호출)
  ///
  /// User, Lesson, League 데이터를 실시간으로 감지하고 자동 업데이트
  Future<void> startRealtimeSync(String userId) async {
    if (!_isOnline) {
      Logger.warning('오프라인 상태 - 실시간 동기화 건너뜀', tag: 'SyncManager');
      return;
    }

    try {
      Logger.info('실시간 동기화 시작: $userId', tag: 'SyncManager');

      // 사용자 프로필 실시간 감지 및 로컬 저장
      watchUserProfile(userId).listen((user) async {
        if (user != null) {
          await _userRepository.saveToLocal('user_$userId', user);
          Logger.debug('사용자 프로필 실시간 업데이트', tag: 'SyncManager');
        }
      });

      // 레슨 데이터 실시간 감지 및 로컬 저장
      watchLessons().listen((lessons) async {
        if (lessons.isNotEmpty) {
          await _lessonRepository.saveToLocal('lessons_$userId', lessons);
          Logger.debug('레슨 데이터 실시간 업데이트: ${lessons.length}개', tag: 'SyncManager');
        }
      });

      // 리그 순위 실시간 감지 및 로컬 저장
      watchLeague(userId).listen((league) async {
        if (league != null) {
          await _leagueRepository.saveToLocal('league_$userId', league);
          Logger.debug('리그 데이터 실시간 업데이트: ${league.tier}', tag: 'SyncManager');
        }
      });

      Logger.info('실시간 동기화 활성화 완료', tag: 'SyncManager');
    } catch (e, stackTrace) {
      Logger.error(
        '실시간 동기화 시작 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncManager',
      );
    }
  }
}
