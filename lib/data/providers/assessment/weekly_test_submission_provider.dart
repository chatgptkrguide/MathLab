import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import './weekly_test_provider.dart';
import '../base/base_notifier.dart';

/// 주간테스트 제출 상태 관리 (BaseNotifier 최적화 버전)
class WeeklyTestSubmissionNotifier
    extends BaseNotifier<List<WeeklyTestSubmission>> {
  WeeklyTestSubmissionNotifier(this.ref)
      : super([], 'WeeklyTestSubmissionProvider') {
    _loadSubmissions();
  }

  final Ref ref;
  static const String _storageKey = 'weekly_test_submissions';

  /// 앱 시작 시 제출 목록 로드
  Future<void> _loadSubmissions() async {
    try {
      logInfo('주간테스트 제출 목록 로드 시작');

      final submissions = await loadList<WeeklyTestSubmission>(
        key: _storageKey,
        fromJson: WeeklyTestSubmission.fromJson,
      );

      state = submissions;
      logInfo('주간테스트 제출 목록 로드 성공: ${submissions.length}개');
    } catch (e, stackTrace) {
      logError(
        '주간테스트 제출 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 제출 목록 저장
  Future<void> _saveSubmissions() async {
    try {
      await saveList(
        key: _storageKey,
        items: state,
        toJson: (submission) => submission.toJson(),
      );
      logInfo('주간테스트 제출 목록 저장 완료: ${state.length}개');
    } catch (e, stackTrace) {
      logError(
        '주간테스트 제출 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 제출 생성 (학생이 처음 주간테스트를 할당받을 때)
  Future<void> createSubmission(WeeklyTestSubmission submission) async {
    state = [...state, submission];
    await _saveSubmissions();
    logInfo(
        '주간테스트 제출 생성: ${submission.studentName} - ${submission.weeklyTestId}');
  }

  /// OMR 제출 (학생)
  Future<void> submitOMR({
    required String submissionId,
    required String omrPhotoUrl,
  }) async {
    state = state.map((submission) {
      if (submission.id == submissionId) {
        final updated = submission.copyWith(
          isSubmitted: true,
          submittedAt: DateTime.now(),
          omrPhotoUrl: omrPhotoUrl,
        );
        logInfo('OMR 제출: ${submission.studentName}');

        // 주간테스트 제출 수 업데이트
        _updateTestSubmissionCount(submission.weeklyTestId);

        return updated;
      }
      return submission;
    }).toList();

    await _saveSubmissions();
  }

  /// 채점 완료 (선생님)
  Future<void> gradeSubmission({
    required String submissionId,
    required int score,
    String? feedback,
  }) async {
    state = state.map((submission) {
      if (submission.id == submissionId) {
        final updated = submission.copyWith(
          score: score,
          gradedAt: DateTime.now(),
          feedback: feedback,
        );
        logInfo('채점 완료: ${submission.studentName} - $score점');
        return updated;
      }
      return submission;
    }).toList();

    await _saveSubmissions();
  }

  /// 제출 취소 (학생 - 마감 전에만 가능)
  Future<void> cancelSubmission(String submissionId) async {
    state = state.map((submission) {
      if (submission.id == submissionId && submission.isSubmitted) {
        final updated = submission.copyWith(
          isSubmitted: false,
          submittedAt: null,
          omrPhotoUrl: null,
        );
        logInfo('제출 취소: ${submission.studentName}');

        // 주간테스트 제출 수 업데이트
        _updateTestSubmissionCount(submission.weeklyTestId);

        return updated;
      }
      return submission;
    }).toList();

    await _saveSubmissions();
  }

  /// 특정 주간테스트의 모든 제출 조회
  List<WeeklyTestSubmission> getSubmissionsByTest(String weeklyTestId) {
    return state
        .where((submission) => submission.weeklyTestId == weeklyTestId)
        .toList();
  }

  /// 특정 학생의 모든 제출 조회
  List<WeeklyTestSubmission> getSubmissionsByStudent(String studentId) {
    return state
        .where((submission) => submission.studentId == studentId)
        .toList();
  }

  /// 미제출 학생 조회
  List<WeeklyTestSubmission> getNotSubmittedStudents(String weeklyTestId) {
    return state.where((submission) {
      return submission.weeklyTestId == weeklyTestId && !submission.isSubmitted;
    }).toList();
  }

  /// 제출했지만 채점 안 된 제출 조회 (선생님용)
  List<WeeklyTestSubmission> getUngradedSubmissions(String weeklyTestId) {
    return state.where((submission) {
      return submission.weeklyTestId == weeklyTestId &&
          submission.isSubmitted &&
          !submission.isGraded;
    }).toList();
  }

  /// 특정 학생의 특정 주간테스트 제출 조회
  WeeklyTestSubmission? getStudentSubmission(
      String weeklyTestId, String studentId) {
    try {
      return state.firstWhere(
        (submission) =>
            submission.weeklyTestId == weeklyTestId &&
            submission.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 주간테스트 제출 수 업데이트 (내부용)
  void _updateTestSubmissionCount(String weeklyTestId) {
    final submittedCount = state.where((submission) {
      return submission.weeklyTestId == weeklyTestId && submission.isSubmitted;
    }).length;

    // WeeklyTestProvider의 제출 수 업데이트
    ref
        .read(weeklyTestProvider.notifier)
        .updateSubmissionCount(weeklyTestId, submittedCount);
  }

  /// 주간테스트별 제출 통계
  Map<String, dynamic> getSubmissionStats(String weeklyTestId) {
    final submissions = getSubmissionsByTest(weeklyTestId);
    final submitted = submissions.where((s) => s.isSubmitted).length;
    final graded = submissions.where((s) => s.isGraded).length;
    final notSubmitted = submissions.where((s) => !s.isSubmitted).length;

    // 평균 점수 계산
    final gradedSubmissions = submissions.where((s) => s.isGraded).toList();
    final averageScore = gradedSubmissions.isEmpty
        ? 0.0
        : gradedSubmissions.fold<int>(0, (sum, s) => sum + (s.score ?? 0)) /
            gradedSubmissions.length;

    // 최고/최저 점수
    final scores = gradedSubmissions.map((s) => s.score ?? 0).toList();
    final highestScore =
        scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);
    final lowestScore =
        scores.isEmpty ? 0 : scores.reduce((a, b) => a < b ? a : b);

    return {
      'total': submissions.length,
      'submitted': submitted,
      'graded': graded,
      'notSubmitted': notSubmitted,
      'submissionRate':
          submissions.isEmpty ? 0.0 : (submitted / submissions.length) * 100,
      'gradingRate': submitted == 0 ? 0.0 : (graded / submitted) * 100,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
    };
  }

  /// 학생 성적 조회 (시간순 정렬)
  List<WeeklyTestSubmission> getStudentGrades(String studentId) {
    final submissions =
        getSubmissionsByStudent(studentId).where((s) => s.isGraded).toList();

    // 제출일 기준 최신순 정렬
    submissions.sort((a, b) => (b.submittedAt ?? DateTime(2000))
        .compareTo(a.submittedAt ?? DateTime(2000)));

    return submissions;
  }

  /// 성적 추이 분석 (최근 N회)
  Map<String, dynamic> analyzeGradeTrend(String studentId,
      {int recentCount = 5}) {
    final grades = getStudentGrades(studentId).take(recentCount).toList();

    if (grades.isEmpty) {
      return {
        'count': 0,
        'average': 0.0,
        'trend': 'no_data',
        'improvement': 0.0,
      };
    }

    final scores = grades.map((g) => g.scorePercentage ?? 0.0).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;

    // 추세 분석 (최근 점수 - 과거 평균)
    String trend = 'stable';
    double improvement = 0.0;

    if (scores.length >= 2) {
      final recent = scores.first; // 최신
      final oldAverage =
          scores.skip(1).reduce((a, b) => a + b) / (scores.length - 1);
      improvement = recent - oldAverage;

      if (improvement > 5.0) {
        trend = 'improving';
      } else if (improvement < -5.0) {
        trend = 'declining';
      }
    }

    return {
      'count': grades.length,
      'average': average,
      'trend': trend,
      'improvement': improvement,
    };
  }
}

/// Provider 선언
final weeklyTestSubmissionProvider = StateNotifierProvider<
    WeeklyTestSubmissionNotifier, List<WeeklyTestSubmission>>((ref) {
  return WeeklyTestSubmissionNotifier(ref);
});
