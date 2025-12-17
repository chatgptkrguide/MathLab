import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'base/base_notifier.dart';



/// 과제 상태 관리
class AssignmentNotifier extends BaseNotifier<List<Assignment>> {
  AssignmentNotifier() : super([], 'AssignmentNotifier') {
    _loadAssignments();
  }

  static const String _storageKey = 'assignments';

  /// 앱 시작 시 과제 목록 로드
  Future<void> _loadAssignments() async {
    try {
      final assignments = await storage.loadList<Assignment>(
        key: _storageKey,
        fromJson: Assignment.fromJson,
      );

      if (assignments.isNotEmpty) {
        state = assignments;
      }
    } catch (e, stackTrace) {
      logError(
        '과제 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 과제 목록 저장
  Future<void> _saveAssignments() async {
    try {
      await storage.saveList(
        key: _storageKey,
        data: state,
        toJson: (assignment) => assignment.toJson(),
      );
    } catch (e, stackTrace) {
      logError(
        '과제 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 과제 생성 (선생님)
  Future<void> createAssignment(Assignment assignment) async {
    state = [...state, assignment];
    await _saveAssignments();
  }

  /// 과제 수정
  Future<void> updateAssignment(Assignment updatedAssignment) async {
    state = state.map((assignment) {
      return assignment.id == updatedAssignment.id ? updatedAssignment : assignment;
    }).toList();
    await _saveAssignments();
  }

  /// 과제 삭제
  Future<void> deleteAssignment(String assignmentId) async {
    state = state.where((a) => a.id != assignmentId).toList();
    await _saveAssignments();
  }

  /// 특정 학급의 과제 조회
  List<Assignment> getAssignmentsByClass(String classId) {
    return state.where((assignment) => assignment.classId == classId).toList();
  }

  /// 진행 중인 과제 조회
  List<Assignment> getActiveAssignments() {
    return state.where((assignment) => assignment.status == AssignmentStatus.active).toList();
  }

  /// 마감된 과제 조회
  List<Assignment> getClosedAssignments() {
    return state.where((assignment) => assignment.status == AssignmentStatus.closed).toList();
  }

  /// 마감 임박 과제 조회 (3일 이내)
  List<Assignment> getUpcomingDueAssignments() {
    final now = DateTime.now();
    return state.where((assignment) {
      if (assignment.status != AssignmentStatus.active) return false;
      final daysUntilDue = assignment.dueDate.difference(now).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= 3;
    }).toList();
  }

  /// 과제 마감일 지난 것 자동 마감
  Future<void> autoCloseOverdueAssignments() async {
    bool hasChanges = false;

    state = state.map((assignment) {
      if (assignment.status == AssignmentStatus.active && assignment.isOverdue) {
        hasChanges = true;
        return assignment.copyWith(status: AssignmentStatus.closed);
      }
      return assignment;
    }).toList();

    if (hasChanges) {
      await _saveAssignments();
    }
  }

  /// 과제 제출 수 업데이트
  Future<void> updateSubmissionCount(String assignmentId, int newCount) async {
    state = state.map((assignment) {
      if (assignment.id == assignmentId) {
        return assignment.copyWith(submittedCount: newCount);
      }
      return assignment;
    }).toList();
    await _saveAssignments();
  }
}

/// Provider 선언
final assignmentProvider = StateNotifierProvider<AssignmentNotifier, List<Assignment>>((ref) {
  return AssignmentNotifier();
});
