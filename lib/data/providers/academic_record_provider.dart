import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/academic_record_service.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';

/// 학업 성적 서비스 프로바이더
final academicRecordServiceProvider = Provider<AcademicRecordService>((ref) {
  return AcademicRecordService();
});

/// 모든 학업 성적 프로바이더
final allAcademicRecordsProvider =
    FutureProvider.autoDispose<List<AcademicRecord>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(academicRecordServiceProvider);
  return await service.getAllRecords(user.id);
});

/// 유형별 학업 성적 프로바이더
final recordsByTypeProvider = FutureProvider.autoDispose
    .family<List<AcademicRecord>, AcademicRecordType>((ref, type) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(academicRecordServiceProvider);
  return await service.getRecordsByType(user.id, type);
});

/// 학기별 학업 성적 프로바이더
final recordsBySemesterProvider = FutureProvider.autoDispose
    .family<List<AcademicRecord>, String>((ref, semester) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(academicRecordServiceProvider);
  return await service.getRecordsBySemester(user.id, semester);
});

/// 학업 통계 프로바이더
final academicStatisticsProvider =
    FutureProvider.autoDispose<AcademicStatistics>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) {
    return AcademicStatistics(
      averageScore: 0.0,
      highestScore: 0.0,
      lowestScore: 0.0,
      averageByType: {},
      subjectTrends: [],
    );
  }

  final service = ref.read(academicRecordServiceProvider);
  return await service.calculateStatistics(user.id);
});

/// 과목별 추세 프로바이더
final subjectTrendProvider = FutureProvider.autoDispose
    .family<SubjectTrend?, String>((ref, subjectName) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.read(academicRecordServiceProvider);
  return await service.getSubjectTrend(user.id, subjectName);
});

/// 학업 성적 액션 프로바이더
final academicRecordActionsProvider = Provider((ref) {
  return AcademicRecordActions(ref);
});

/// 학업 성적 액션 클래스
class AcademicRecordActions {
  final Ref _ref;

  AcademicRecordActions(this._ref);

  /// 학업 성적 추가
  Future<void> addRecord({
    required AcademicRecordType type,
    required DateTime date,
    required String semester,
    required Map<String, SubjectScore> scores,
    double? averageScore,
    int? rank,
    int? totalStudents,
    String? memo,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'AcademicRecord');
        return;
      }

      final record = AcademicRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        type: type,
        date: date,
        semester: semester,
        scores: scores,
        averageScore: averageScore,
        rank: rank,
        totalStudents: totalStudents,
        memo: memo,
      );

      final service = _ref.read(academicRecordServiceProvider);
      await service.addRecord(record);

      // 관련 프로바이더 새로고침
      _ref.invalidate(allAcademicRecordsProvider);
      _ref.invalidate(academicStatisticsProvider);
      _ref.invalidate(recordsByTypeProvider(type));

      Logger.info(
        '학업 성적 추가 완료: ${record.id}',
        tag: 'AcademicRecord',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 추가 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecord',
      );
      rethrow;
    }
  }

  /// 학업 성적 수정
  Future<void> updateRecord(AcademicRecord record) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'AcademicRecord');
        return;
      }

      final service = _ref.read(academicRecordServiceProvider);
      await service.updateRecord(record);

      // 관련 프로바이더 새로고침
      _ref.invalidate(allAcademicRecordsProvider);
      _ref.invalidate(academicStatisticsProvider);
      _ref.invalidate(recordsByTypeProvider(record.type));

      Logger.info('학업 성적 수정 완료: ${record.id}', tag: 'AcademicRecord');
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 수정 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecord',
      );
      rethrow;
    }
  }

  /// 학업 성적 삭제
  Future<void> deleteRecord(String recordId) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'AcademicRecord');
        return;
      }

      final service = _ref.read(academicRecordServiceProvider);
      await service.deleteRecord(recordId);

      // 모든 프로바이더 새로고침
      _ref.invalidate(allAcademicRecordsProvider);
      _ref.invalidate(academicStatisticsProvider);

      Logger.info('학업 성적 삭제 완료: $recordId', tag: 'AcademicRecord');
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecord',
      );
      rethrow;
    }
  }

  /// 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'AcademicRecord');
        return;
      }

      final service = _ref.read(academicRecordServiceProvider);
      await service.clearAllData();

      // 모든 프로바이더 새로고침
      _ref.invalidate(allAcademicRecordsProvider);
      _ref.invalidate(academicStatisticsProvider);

      Logger.info('학업 성적 데이터 초기화 완료', tag: 'AcademicRecord');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecord',
      );
      rethrow;
    }
  }
}
