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

  /// 모든 문제 로드
  Future<List<Problem>> loadAllProblems() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/problems.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final problemsJson = jsonData['problems'] as List<dynamic>;

      return problemsJson.where((problemData) {
        final data = problemData as Map<String, dynamic>;
        // 간단한 기초산술 문제 필터링 (난이도 1이고 카테고리가 기초산술인 경우 제외)
        final category = data['category'] as String? ?? '';
        final difficulty = data['difficulty'] as int? ?? 1;
        return !(category == '기초산술' && difficulty == 1);
      }).map((problemData) {
        final data = problemData as Map<String, dynamic>;

        // grade와 chapter를 metadata에 추가
        final metadata = <String, dynamic>{};
        if (data.containsKey('grade')) {
          metadata['grade'] = data['grade'];
        }
        if (data.containsKey('chapter')) {
          metadata['chapter'] = data['chapter'];
        }
        if (data.containsKey('lessonId')) {
          metadata['lessonId'] = data['lessonId'];
        }
        if (data.containsKey('tags')) {
          metadata['tags'] = data['tags'];
        }
        if (data.containsKey('xpReward')) {
          metadata['xpReward'] = data['xpReward'];
        }

        // Problem 객체 생성 (options -> choices, correctAnswerIndex -> answer 매핑)
        return Problem(
          id: data['id'] as String,
          title: (data['chapter'] as String?) ?? (data['category'] as String? ?? '문제'),
          question: data['question'] as String,
          type: ProblemType.values.firstWhere(
            (e) => e.toString() == 'ProblemType.${data['type']}',
            orElse: () => ProblemType.multipleChoice,
          ),
          category: data['category'] as String? ?? '기타',
          difficulty: data['difficulty'] as int? ?? 1,
          choices: (data['options'] as List<dynamic>?)?.map((e) => e as String).toList() ??
                   (data['choices'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
          answer: data['correctAnswerIndex'] ?? data['correctAnswer'] ?? data['answer'] ?? 0,
          hints: (data['hints'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
          explanation: data['explanation'] as String?,
          metadata: metadata.isNotEmpty ? metadata : null,
        );
      }).toList();
    } catch (e) {
      print('전체 문제 로드 오류: $e');
      return [];
    }
  }

  /// 학년과 단원으로 문제 필터링
  Future<List<Problem>> loadProblemsByGradeAndChapter({
    String? grade,
    String? chapter,
  }) async {
    final allProblems = await loadAllProblems();

    return allProblems.where((problem) {
      if (grade != null && problem.grade != grade) {
        return false;
      }
      if (chapter != null && problem.chapter != chapter) {
        return false;
      }
      return true;
    }).toList();
  }

  /// 레슨 ID로 문제 목록 로드
  Future<List<Problem>> loadProblemsByLesson(String lessonId) async {
    // 1단계: 한국 교육과정 문제 폴더에서 직접 로드 시도
    try {
      final koreanProblems = await _loadKoreanCurriculumProblems(lessonId);
      if (koreanProblems.isNotEmpty) {
        print('[ProblemRepository] 한국 교육과정 문제 ${koreanProblems.length}개 로드: $lessonId');
        return koreanProblems;
      }
    } catch (e) {
      print('[ProblemRepository] 한국 교육과정 문제 로드 실패: $e');
    }

    // 2단계: 기존 problems.json에서 필터링
    final allProblems = await loadAllProblems();
    final filteredProblems = allProblems.where((problem) {
      return problem.lessonId == lessonId;
    }).toList();

    if (filteredProblems.isNotEmpty) {
      return filteredProblems;
    }

    // 3단계: 샘플 문제 사용
    return [_generateSingleProblem(lessonId)];
  }

  /// 한국 교육과정 문제 로드 (assets/problems/ms1_소인수분해/ 등)
  Future<List<Problem>> _loadKoreanCurriculumProblems(String lessonId) async {
    final problems = <Problem>[];

    // lessonId 형식: ms1_001, ms1_002 등
    // 폴더 구조: assets/problems/ms1_소인수분해/ms1_001_001.json

    // lessonId에서 학년과 단원 번호 추출
    final parts = lessonId.split('_');
    if (parts.length < 2) return problems;

    final grade = parts[0]; // ms1, ms2 등
    final unitNum = parts[1]; // 001, 002 등

    // 단원별 폴더 맵핑
    final folderMap = {
      'ms1_001': 'ms1_소인수분해',
      'ms2_001': 'polynomials', // 다항식
      // 추가 단원 맵핑...
    };

    final folder = folderMap[lessonId];
    if (folder == null) return problems;

    // 해당 폴더의 모든 문제 파일 로드 (최대 10개)
    for (int i = 1; i <= 10; i++) {
      final fileNum = i.toString().padLeft(3, '0');
      final fileName = '${grade}_${unitNum}_$fileNum.json';
      final filePath = 'assets/problems/$folder/$fileName';

      try {
        final problem = await loadProblem(filePath);
        problems.add(problem);
      } catch (e) {
        // 파일이 없으면 중단
        break;
      }
    }

    return problems;
  }

  /// 레슨당 단일 문제 생성 (폴백용 - problems.json에서 문제를 찾을 수 없을 때)
  Problem _generateSingleProblem(String lessonId) {
    return Problem(
      id: '${lessonId}_fallback',
      title: '문제 준비 중',
      question: '이 레슨의 문제를 준비 중입니다. 잠시 후 다시 시도해주세요.',
      type: ProblemType.multipleChoice,
      category: '일반',
      choices: ['확인'],
      answer: 0,
      difficulty: 1,
      hints: ['곧 새로운 문제가 추가됩니다.'],
      explanation: '문제 데이터를 업데이트 중입니다.',
    );
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
