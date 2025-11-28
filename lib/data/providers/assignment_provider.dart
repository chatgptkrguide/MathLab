import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import '../../shared/utils/logger.dart';

/// 과제 상태 관리
class AssignmentNotifier extends StateNotifier<List<Assignment>> {
  AssignmentNotifier() : super([]) {
    _loadAssignments();
  }

  final LocalStorageService _storage = LocalStorageService();
  static const String _storageKey = 'assignments';

  /// 앱 시작 시 과제 목록 로드
  Future<void> _loadAssignments() async {
    try {
      Logger.info('과제 목록 로드 시작', tag: 'AssignmentProvider');

      final assignments = await _storage.loadList<Assignment>(
        key: _storageKey,
        fromJson: Assignment.fromJson,
      );

      if (assignments != null) {
        state = assignments;
        Logger.info('과제 목록 로드 성공: ${assignments.length}개', tag: 'AssignmentProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '과제 목록 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AssignmentProvider',
      );
    }
  }

  /// 과제 목록 저장
  Future<void> _saveAssignments() async {
    try {
      await _storage.saveList(
        key: _storageKey,
        items: state,
        toJson: (assignment) => assignment.toJson(),
      );
      Logger.info('과제 목록 저장 완료: ${state.length}개', tag: 'AssignmentProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '과제 목록 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AssignmentProvider',
      );
    }
  }

  /// 과제 생성 (선생님)
  Future<void> createAssignment(Assignment assignment) async {
    state = [...state, assignment];
    await _saveAssignments();
    Logger.info('과제 생성: ${assignment.title}', tag: 'AssignmentProvider');
  }

  /// 과제 수정
  Future<void> updateAssignment(Assignment updatedAssignment) async {
    state = state.map((assignment) {
      return assignment.id == updatedAssignment.id ? updatedAssignment : assignment;
    }).toList();
    await _saveAssignments();
    Logger.info('과제 수정: ${updatedAssignment.title}', tag: 'AssignmentProvider');
  }

  /// 과제 삭제
  Future<void> deleteAssignment(String assignmentId) async {
    final assignment = state.firstWhere((a) => a.id == assignmentId);
    state = state.where((a) => a.id != assignmentId).toList();
    await _saveAssignments();
    Logger.info('과제 삭제: ${assignment.title}', tag: 'AssignmentProvider');
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
        Logger.info('자동 마감: ${assignment.title}', tag: 'AssignmentProvider');
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
    Logger.info('제출 수 업데이트: $assignmentId -> $newCount', tag: 'AssignmentProvider');
  }
}

/// Provider 선언
final assignmentProvider = StateNotifierProvider<AssignmentNotifier, List<Assignment>>((ref) {
  return AssignmentNotifier();
});
