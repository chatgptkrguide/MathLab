import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../../shared/utils/logger.dart';

/// 학업 성적 관리 서비스
class AcademicRecordService {
  static const String _recordsKey = 'academic_records';

  /// 모든 학업 성적 조회
  Future<List<AcademicRecord>> getAllRecords(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_recordsKey);

      if (recordsJson == null) return [];

      final List<dynamic> recordsList = jsonDecode(recordsJson);
      final allRecords = recordsList
          .map((json) => AcademicRecord.fromJson(json))
          .where((record) => record.userId == userId)
          .toList();

      // 날짜 기준 내림차순 정렬 (최신순)
      allRecords.sort((a, b) => b.date.compareTo(a.date));
      return allRecords;
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      return [];
    }
  }

  /// 학업 성적 추가
  Future<void> addRecord(AcademicRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_recordsKey);

      List<AcademicRecord> records = [];
      if (recordsJson != null) {
        final List<dynamic> recordsList = jsonDecode(recordsJson);
        records = recordsList.map((json) => AcademicRecord.fromJson(json)).toList();
      }

      records.add(record);
      await _saveAllRecords(records);

      Logger.info('학업 성적 추가 완료: ${record.id}', tag: 'AcademicRecordService');
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 추가 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      rethrow;
    }
  }

  /// 학업 성적 수정
  Future<void> updateRecord(AcademicRecord updatedRecord) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_recordsKey);

      if (recordsJson == null) {
        throw Exception('수정할 성적을 찾을 수 없습니다');
      }

      final List<dynamic> recordsList = jsonDecode(recordsJson);
      final records = recordsList.map((json) => AcademicRecord.fromJson(json)).toList();

      final index = records.indexWhere((r) => r.id == updatedRecord.id);
      if (index == -1) {
        throw Exception('수정할 성적을 찾을 수 없습니다');
      }

      records[index] = updatedRecord;
      await _saveAllRecords(records);

      Logger.info('학업 성적 수정 완료: ${updatedRecord.id}', tag: 'AcademicRecordService');
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 수정 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      rethrow;
    }
  }

  /// 학업 성적 삭제
  Future<void> deleteRecord(String recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_recordsKey);

      if (recordsJson == null) return;

      final List<dynamic> recordsList = jsonDecode(recordsJson);
      final records = recordsList.map((json) => AcademicRecord.fromJson(json)).toList();

      records.removeWhere((r) => r.id == recordId);
      await _saveAllRecords(records);

      Logger.info('학업 성적 삭제 완료: $recordId', tag: 'AcademicRecordService');
    } catch (e, stackTrace) {
      Logger.error(
        '학업 성적 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      rethrow;
    }
  }

  /// 유형별 학업 성적 조회
  Future<List<AcademicRecord>> getRecordsByType(
    String userId,
    AcademicRecordType type,
  ) async {
    final allRecords = await getAllRecords(userId);
    return allRecords.where((record) => record.type == type).toList();
  }

  /// 학기별 학업 성적 조회
  Future<List<AcademicRecord>> getRecordsBySemester(
    String userId,
    String semester,
  ) async {
    final allRecords = await getAllRecords(userId);
    return allRecords.where((record) => record.semester == semester).toList();
  }

  /// 학업 통계 계산
  Future<AcademicStatistics> calculateStatistics(String userId) async {
    try {
      final allRecords = await getAllRecords(userId);

      if (allRecords.isEmpty) {
        return AcademicStatistics(
          averageScore: 0.0,
          highestScore: 0.0,
          lowestScore: 0.0,
          averageByType: {},
          subjectTrends: [],
        );
      }

      // 전체 평균 점수 계산
      final scores = allRecords
          .where((r) => r.averageScore != null)
          .map((r) => r.averageScore!)
          .toList();

      final averageScore = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;

      final highestScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a > b ? a : b);
      final lowestScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a < b ? a : b);

      // 유형별 평균 계산
      final Map<AcademicRecordType, double> averageByType = {};
      for (final type in AcademicRecordType.values) {
        final typeRecords = allRecords
            .where((r) => r.type == type && r.averageScore != null)
            .map((r) => r.averageScore!)
            .toList();

        if (typeRecords.isNotEmpty) {
          averageByType[type] =
              typeRecords.reduce((a, b) => a + b) / typeRecords.length;
        }
      }

      // 과목별 추세 계산
      final Map<String, List<double>> subjectScoresMap = {};
      for (final record in allRecords) {
        for (final entry in record.scores.entries) {
          final subjectName = entry.key;
          final score = entry.value.score;

          if (!subjectScoresMap.containsKey(subjectName)) {
            subjectScoresMap[subjectName] = [];
          }
          subjectScoresMap[subjectName]!.add(score);
        }
      }

      final List<SubjectTrend> subjectTrends = [];
      for (final entry in subjectScoresMap.entries) {
        final subjectName = entry.key;
        final scores = entry.value;

        if (scores.isNotEmpty) {
          final averageScore = scores.reduce((a, b) => a + b) / scores.length;
          final trend = SubjectTrend.calculateTrend(scores);

          subjectTrends.add(SubjectTrend(
            subjectName: subjectName,
            scores: scores,
            averageScore: averageScore,
            trend: trend,
          ));
        }
      }

      return AcademicStatistics(
        averageScore: averageScore,
        highestScore: highestScore,
        lowestScore: lowestScore,
        averageByType: averageByType,
        subjectTrends: subjectTrends,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '학업 통계 계산 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      return AcademicStatistics(
        averageScore: 0.0,
        highestScore: 0.0,
        lowestScore: 0.0,
        averageByType: {},
        subjectTrends: [],
      );
    }
  }

  /// 특정 과목의 성적 추세 조회
  Future<SubjectTrend?> getSubjectTrend(String userId, String subjectName) async {
    try {
      final allRecords = await getAllRecords(userId);
      final scores = <double>[];

      for (final record in allRecords) {
        if (record.scores.containsKey(subjectName)) {
          scores.add(record.scores[subjectName]!.score);
        }
      }

      if (scores.isEmpty) return null;

      final averageScore = scores.reduce((a, b) => a + b) / scores.length;
      final trend = SubjectTrend.calculateTrend(scores);

      return SubjectTrend(
        subjectName: subjectName,
        scores: scores,
        averageScore: averageScore,
        trend: trend,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '과목 추세 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      return null;
    }
  }

  /// 모든 성적 저장
  Future<void> _saveAllRecords(List<AcademicRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_recordsKey, recordsJson);
  }

  /// 모든 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recordsKey);
      Logger.info('학업 성적 데이터 초기화 완료', tag: 'AcademicRecordService');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'AcademicRecordService',
      );
      rethrow;
    }
  }
}
