import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/problem.dart';

/// 문제 데이터 저장소
class ProblemRepository {
  /// 특정 문제 로드
  Future<Problem> loadProblem(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return Problem.fromJson(jsonData);
    } catch (e) {
      throw Exception('문제 로드 실패: $e');
    }
  }

  /// 카테고리별 문제 목록 로드
  Future<List<Problem>> loadProblemsByCategory(String category) async {
    // TODO: 실제 구현 시 카테고리별 문제 목록 파일 경로 관리
    final problems = <Problem>[];

    // 예시: polynomials 카테고리
    if (category == 'polynomials') {
      try {
        final problem = await loadProblem('assets/problems/polynomials/polynomial_001.json');
        problems.add(problem);
      } catch (e) {
        print('문제 로드 오류: $e');
      }
    }

    return problems;
  }

  /// 레슨 ID로 문제 목록 로드
  Future<List<Problem>> loadProblemsByLesson(String lessonId) async {
    // TODO: 실제 구현 시 레슨별 문제 매핑 파일 관리
    final problems = <Problem>[];

    // 예시: lesson001
    if (lessonId == 'lesson001') {
      try {
        // polynomial_001.json과 polynomial_002.json 로드
        final problem1 = await loadProblem('assets/problems/polynomials/polynomial_001.json');
        final problem2 = await loadProblem('assets/problems/polynomials/polynomial_002.json');
        problems.add(problem1);
        problems.add(problem2);
      } catch (e) {
        print('문제 로드 오류: $e');
      }
    }

    return problems;
  }

  /// 난이도별 문제 필터링
  List<Problem> filterByDifficulty(List<Problem> problems, int difficulty) {
    return problems.where((p) => p.difficulty == difficulty).toList();
  }

  /// 태그별 문제 필터링
  List<Problem> filterByTag(List<Problem> problems, String tag) {
    return problems.where((p) {
      final tags = p.metadata?['tags'] as List<dynamic>?;
      return tags?.contains(tag) ?? false;
    }).toList();
  }
}
