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
    final problems = <Problem>[];

    // polynomial 문제 파일 로드 시도
    try {
      final problem1 = await loadProblem('assets/problems/polynomials/polynomial_001.json');
      problems.add(problem1);
    } catch (e) {
      print('polynomial_001.json 로드 실패: $e');
    }

    try {
      final problem2 = await loadProblem('assets/problems/polynomials/polynomial_002.json');
      problems.add(problem2);
    } catch (e) {
      print('polynomial_002.json 로드 실패: $e');
    }

    // JSON 파일 로드에 성공한 경우 반환
    if (problems.isNotEmpty) {
      return problems;
    }

    // JSON 파일이 없는 경우에만 샘플 문제 생성
    print('JSON 파일을 찾을 수 없어 샘플 문제를 생성합니다.');
    problems.addAll(_generateSampleProblems(lessonId));
    return problems;
  }

  /// 레슨별 샘플 문제 생성 (임시)
  List<Problem> _generateSampleProblems(String lessonId) {
    return [
      Problem(
        id: '${lessonId}_sample_001',
        title: '기본 덧셈',
        question: '다음 중 올바른 것을 고르세요.',
        type: ProblemType.multipleChoice,
        category: '기초 연산',
        choices: ['2 + 2 = 4', '2 + 2 = 5', '2 + 2 = 3', '2 + 2 = 6'],
        answer: 0, // 첫 번째 선택지가 정답
        difficulty: 1,
        hints: ['덧셈의 기본 원리를 생각해보세요.', '2를 두 번 더하면 얼마일까요?'],
        explanation: '2 + 2 = 4입니다. 기본적인 덧셈 문제입니다.',
      ),
      Problem(
        id: '${lessonId}_sample_002',
        title: '곱셈 계산',
        question: '5 × 3 = ?',
        type: ProblemType.multipleChoice,
        category: '기초 연산',
        choices: ['12', '15', '18', '20'],
        answer: 1, // 두 번째 선택지가 정답
        difficulty: 1,
        hints: ['5를 3번 더하면 됩니다.', '5 + 5 + 5를 계산해보세요.'],
        explanation: '5 × 3 = 15입니다. 5를 3번 더한 값입니다.',
      ),
      Problem(
        id: '${lessonId}_sample_003',
        title: '뺄셈 계산',
        question: '10 - 4 = ?',
        type: ProblemType.multipleChoice,
        category: '기초 연산',
        choices: ['4', '5', '6', '7'],
        answer: 2, // 세 번째 선택지가 정답
        difficulty: 1,
        hints: ['10에서 4를 빼면 됩니다.', '거꾸로 생각하면 4 + ? = 10입니다.'],
        explanation: '10 - 4 = 6입니다. 기본적인 뺄셈 문제입니다.',
      ),
      Problem(
        id: '${lessonId}_sample_004',
        title: '수 비교',
        question: '다음 중 가장 큰 수는?',
        type: ProblemType.multipleChoice,
        category: '수와 연산',
        choices: ['7', '12', '9', '5'],
        answer: 1, // 두 번째 선택지가 정답
        difficulty: 1,
        hints: ['각 숫자를 비교해보세요.', '10보다 큰 숫자가 있나요?'],
        explanation: '12가 가장 큰 수입니다.',
      ),
      Problem(
        id: '${lessonId}_sample_005',
        title: '나눗셈 계산',
        question: '8 ÷ 2 = ?',
        type: ProblemType.multipleChoice,
        category: '기초 연산',
        choices: ['2', '3', '4', '5'],
        answer: 2, // 세 번째 선택지가 정답
        difficulty: 2,
        hints: ['8을 2로 나누면 됩니다.', '2 × ? = 8을 생각해보세요.'],
        explanation: '8 ÷ 2 = 4입니다. 기본적인 나눗셈 문제입니다.',
      ),
    ];
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
