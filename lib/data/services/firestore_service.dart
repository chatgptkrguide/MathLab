import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore/user_firestore_service.dart';
import 'firestore/progress_firestore_service.dart';
import 'firestore/league_firestore_service.dart';
import '../models/user/user.dart';
import '../models/learning/progress_model.dart';
import '../models/learning/wrong_answer.dart';
import '../models/gamification/league.dart';

/// Firestore 데이터베이스 서비스 (통합 Facade)
///
/// 역할:
/// - 전문 Firestore 서비스들의 통합 인터페이스 제공
/// - 기존 코드와의 하위 호환성 유지
class FirestoreService {
  // Singleton 패턴
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 전문 Firestore 서비스 인스턴스
  late final UserFirestoreService _userService;
  late final ProgressFirestoreService _progressService;
  late final LeagueFirestoreService _leagueService;

  /// 초기화 (필요 시 호출)
  void initialize() {
    _userService = UserFirestoreService(firestore: _firestore);
    _progressService = ProgressFirestoreService(firestore: _firestore);
    _leagueService = LeagueFirestoreService(firestore: _firestore);
  }

  /// 전문 서비스 접근자 (지연 초기화)
  UserFirestoreService get userService {
    try {
      return _userService;
    } catch (_) {
      initialize();
      return _userService;
    }
  }

  ProgressFirestoreService get progressService {
    try {
      return _progressService;
    } catch (_) {
      initialize();
      return _progressService;
    }
  }

  LeagueFirestoreService get leagueService {
    try {
      return _leagueService;
    } catch (_) {
      initialize();
      return _leagueService;
    }
  }

  // ==================== 사용자 프로필 (UserFirestoreService 위임) ====================

  /// 사용자 프로필 저장 (생성 또는 업데이트)
  Future<void> saveUserProfile(String uid, User user) async {
    return userService.saveUserProfile(uid, user);
  }

  /// 사용자 프로필 조회
  Future<User?> getUserProfile(String uid) async {
    return userService.getUserProfile(uid);
  }

  /// 사용자 프로필 실시간 감지
  Stream<User?> watchUserProfile(String uid) {
    return userService.watchUserProfile(uid);
  }

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    return userService.updateUserProfile(userId, data);
  }

  /// XP 추가
  Future<void> addXP(String userId, int xp, {String? category}) async {
    return userService.addXP(userId, xp, category: category);
  }

  /// 스트릭 업데이트
  Future<void> updateStreak(String userId) async {
    return userService.updateStreak(userId);
  }

  /// 업적 추가
  Future<void> addAchievement(String userId, String achievementId) async {
    return userService.addAchievement(userId, achievementId);
  }

  /// 주간 리더보드 가져오기
  Future<List<User>> getWeeklyLeaderboard({int limit = 50}) async {
    return userService.getWeeklyLeaderboard(limit: limit);
  }

  /// 사용자 순위 가져오기
  Future<int> getUserRank(String userId) async {
    return userService.getUserRank(userId);
  }

  // ==================== 학습 진행상황 (ProgressFirestoreService 위임) ====================

  /// 진행상황 생성 또는 업데이트
  Future<void> saveProgress(ProgressModel progress) async {
    return progressService.saveProgress(progress);
  }

  /// 사용자의 진행상황 가져오기
  Future<List<ProgressModel>> getUserProgress(String userId,
      {String? grade}) async {
    return progressService.getUserProgress(userId, grade: grade);
  }

  /// 특정 레슨 진행상황 가져오기
  Future<ProgressModel?> getLessonProgress(
      String userId, String lessonId) async {
    return progressService.getLessonProgress(userId, lessonId);
  }

  /// 문제 완료 기록
  Future<void> recordProblemCompletion({
    required String userId,
    required String grade,
    required String chapter,
    required String lessonId,
    required bool isCorrect,
    required int xpEarned,
  }) async {
    return progressService.recordProblemCompletion(
      userId: userId,
      grade: grade,
      chapter: chapter,
      lessonId: lessonId,
      isCorrect: isCorrect,
      xpEarned: xpEarned,
      addXP: addXP,
      updateStreak: updateStreak,
    );
  }

  /// 사용자의 일일 학습 기록 가져오기
  Future<List<DailyStudyModel>> getDailyStudies(String userId,
      {int days = 7}) async {
    return progressService.getDailyStudies(userId, days: days);
  }

  // ==================== 오답 노트 (ProgressFirestoreService 위임) ====================

  /// 오답 저장 (서브컬렉션)
  Future<void> saveWrongAnswer(String uid, WrongAnswer wrongAnswer) async {
    return progressService.saveWrongAnswer(uid, wrongAnswer);
  }

  /// 오답 목록 조회
  Future<List<Map<String, dynamic>>> getWrongAnswers(String uid) async {
    return progressService.getWrongAnswers(uid);
  }

  /// 오답 실시간 감지
  Stream<List<Map<String, dynamic>>> watchWrongAnswers(String uid) {
    return progressService.watchWrongAnswers(uid);
  }

  // ==================== 리그 (LeagueFirestoreService 위임) ====================

  /// 현재 리그 조회
  Future<League?> getCurrentLeague(String leagueId) async {
    return leagueService.getCurrentLeague(leagueId);
  }

  /// 리그 실시간 감지
  Stream<League?> watchLeague(String leagueId) {
    return leagueService.watchLeague(leagueId);
  }

  /// 리그 참가자 업데이트 (트랜잭션 사용)
  Future<void> updateLeagueParticipant(
    String leagueId,
    String userId,
    Map<String, dynamic> participantData,
  ) async {
    return leagueService.updateLeagueParticipant(
      leagueId,
      userId,
      participantData,
    );
  }

  /// 리그 생성
  Future<void> createLeague(League league) async {
    return leagueService.createLeague(league);
  }

  /// 리그 종료 처리
  Future<void> finalizeLeague(String leagueId) async {
    return leagueService.finalizeLeague(leagueId);
  }

  /// 사용자를 리그에 할당
  Future<void> assignUserToLeague(String userId, String leagueId) async {
    return leagueService.assignUserToLeague(userId, leagueId);
  }
}
