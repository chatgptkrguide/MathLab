import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../base/base_notifier.dart';

import './assignment_provider.dart';


/// 과제 제출 상태 관리
class AssignmentSubmissionNotifier extends BaseNotifier<List<AssignmentSubmission>> {
  AssignmentSubmissionNotifier(this.ref) : super([], 'AssignmentSubmissionNotifier') {
    _loadSubmissions();
  }

  final Ref ref;
  static const String _storageKey = 'assignment_submissions';

  /// 앱 시작 시 제출 목록 로드
  Future<void> _loadSubmissions() async {
    try {
      final submissions = await storage.loadList<AssignmentSubmission>(
        key: _storageKey,
        fromJson: AssignmentSubmission.fromJson,
      );

      if (submissions.isNotEmpty) {
        state = submissions;
      }
    } catch (e, stackTrace) {
      logError(
        '과제 제출 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 제출 목록 저장
  Future<void> _saveSubmissions() async {
    try {
      await storage.saveList(
        key: _storageKey,
        data: state,
        toJson: (submission) => submission.toJson(),
      );
    } catch (e, stackTrace) {
      logError(
        '과제 제출 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 과제 제출 생성 (학생이 처음 과제를 할당받을 때)
  Future<void> createSubmission(AssignmentSubmission submission) async {
    state = [...state, submission];
    await _saveSubmissions();
  }

  /// 과제 제출 (학생)
  Future<void> submitAssignment({
    required String submissionId,
    required List<String> photoUrls,
  }) async {
    state = state.map((submission) {
      if (submission.id == submissionId) {
        final updated = submission.copyWith(
          status: SubmissionStatus.submitted,
          submittedAt: DateTime.now(),
          photoUrls: photoUrls,
        );

        // 과제 제출 수 업데이트
        _updateAssignmentSubmissionCount(submission.assignmentId);

        return updated;
      }
      return submission;
    }).toList();

    await _saveSubmissions();
  }

  /// 과제 확인 (선생님)
  Future<void> confirmSubmission({
    required String submissionId,
    String? feedback,
    int? score,
  }) async {
    state = state.map((submission) {
      if (submission.id == submissionId) {
        final updated = submission.copyWith(
          status: SubmissionStatus.confirmed,
          confirmedAt: DateTime.now(),
          feedback: feedback,
          score: score,
        );
        return updated;
      }
      return submission;
    }).toList();

    await _saveSubmissions();
  }

  /// 제출 취소 (학생 - 마감 전에만 가능)
  Future<void> cancelSubmission(String submissionId) async {
    state = state.map((submission) {
      if (submission.id == submissionId && submission.status == SubmissionStatus.submitted) {
        final updated = submission.copyWith(
          status: SubmissionStatus.notSubmitted,
          submittedAt: null,
          photoUrls: [],
        );

        // 과제 제출 수 업데이트
        _updateAssignmentSubmissionCount(submission.assignmentId);

        return updated;
      }
      return submission;
    }).toList();

    await _saveSubmissions();
  }

  /// 특정 과제의 모든 제출 조회
  List<AssignmentSubmission> getSubmissionsByAssignment(String assignmentId) {
    return state.where((submission) => submission.assignmentId == assignmentId).toList();
  }

  /// 특정 학생의 모든 제출 조회
  List<AssignmentSubmission> getSubmissionsByStudent(String studentId) {
    return state.where((submission) => submission.studentId == studentId).toList();
  }

  /// 미제출 학생 조회
  List<AssignmentSubmission> getNotSubmittedStudents(String assignmentId) {
    return state.where((submission) {
      return submission.assignmentId == assignmentId &&
             submission.status == SubmissionStatus.notSubmitted;
    }).toList();
  }

  /// 제출 완료했지만 확인 안 된 제출 조회 (선생님용)
  List<AssignmentSubmission> getUnconfirmedSubmissions(String assignmentId) {
    return state.where((submission) {
      return submission.assignmentId == assignmentId &&
             submission.status == SubmissionStatus.submitted;
    }).toList();
  }

  /// 특정 학생의 특정 과제 제출 조회
  AssignmentSubmission? getStudentSubmission(String assignmentId, String studentId) {
    try {
      return state.firstWhere(
        (submission) => submission.assignmentId == assignmentId && submission.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 과제 제출 수 업데이트 (내부용)
  void _updateAssignmentSubmissionCount(String assignmentId) {
    final submittedCount = state.where((submission) {
      return submission.assignmentId == assignmentId && submission.isSubmitted;
    }).length;

    // AssignmentProvider의 제출 수 업데이트
    ref.read(assignmentProvider.notifier).updateSubmissionCount(assignmentId, submittedCount);
  }

  /// 과제별 제출 통계
  Map<String, dynamic> getSubmissionStats(String assignmentId) {
    final submissions = getSubmissionsByAssignment(assignmentId);
    final submitted = submissions.where((s) => s.isSubmitted).length;
    final confirmed = submissions.where((s) => s.isConfirmed).length;
    final notSubmitted = submissions.where((s) => s.status == SubmissionStatus.notSubmitted).length;

    return {
      'total': submissions.length,
      'submitted': submitted,
      'confirmed': confirmed,
      'notSubmitted': notSubmitted,
      'submissionRate': submissions.isEmpty ? 0.0 : (submitted / submissions.length) * 100,
      'confirmationRate': submitted == 0 ? 0.0 : (confirmed / submitted) * 100,
    };
  }
}

/// Provider 선언
final assignmentSubmissionProvider = StateNotifierProvider<AssignmentSubmissionNotifier, List<AssignmentSubmission>>((ref) {
  return AssignmentSubmissionNotifier(ref);
});
