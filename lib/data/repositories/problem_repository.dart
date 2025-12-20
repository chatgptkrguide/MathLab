import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/problem.dart';
import '../models/school_level.dart';
import '../../shared/utils/logger.dart';

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
        Logger.error('문제 로드 오류: $e');
      }
    }

    return problems;
  }

  /// 모든 문제 로드 (학년별 폴더에서 로드)
  Future<List<Problem>> loadAllProblems() async {
    try {
      final allProblems = <Problem>[];

      // 고등학교 문제 로드
      final highSchoolProblems = await _loadGradeProblems('high', '고1', ['grade1']);
      allProblems.addAll(highSchoolProblems);

      // 중학교 문제 로드 (나중에 추가 가능)
      // final middleSchoolProblems = await _loadGradeProblems('middle', '중1', ['grade1', 'grade2', 'grade3']);
      // allProblems.addAll(middleSchoolProblems);

      // 초등학교 문제 로드 (나중에 추가 가능)
      // final elementaryProblems = await _loadGradeProblems('elementary', '초6', ['grade6']);
      // allProblems.addAll(elementaryProblems);

      if (allProblems.isEmpty) {
        Logger.debug('[ProblemRepository] 로드된 문제가 없습니다.');
      } else {
        Logger.debug('[ProblemRepository] 총 ${allProblems.length}개 문제 로드 (학년별 폴더)');
      }

      return allProblems;
    } catch (e) {
      Logger.error('전체 문제 로드 오류: $e');
      return [];
    }
  }

  /// 학년별 폴더에서 문제 로드 (새로운 구조)
  Future<List<Problem>> _loadGradeProblems(String schoolLevel, String defaultGrade, List<String> gradesFolders) async {
    final problems = <Problem>[];

    for (final gradeFolder in gradesFolders) {
      try {
        // 폴더별 파일 목록 (예: polynomials.json, equations.json 등)
        // 현재는 polynomials.json만 시도
        final filePath = 'assets/problems/$schoolLevel/$gradeFolder/polynomials.json';

        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;

        // 파일 레벨의 메타데이터
        final fileGrade = jsonData['grade'] as String? ?? defaultGrade;
        final fileSubject = jsonData['subject'] as String?;
        final fileChapter = jsonData['chapter'] as String?;

        final problemsJson = jsonData['problems'] as List<dynamic>;

        final loadedProblems = problemsJson.map((problemData) {
          final data = problemData as Map<String, dynamic>;

          // metadata 구성 (학년 정보 추가)
          final metadata = <String, dynamic>{};

          // 파일 레벨 메타데이터 우선 적용
          metadata['grade'] = fileGrade;
          if (fileSubject != null) metadata['subject'] = fileSubject;
          if (fileChapter != null) metadata['chapter'] = fileChapter;

          // 개별 문제 메타데이터
          final subject = data['subject'] as String?;
          if (subject != null) {
            metadata['subject'] = subject;
          }

          if (data.containsKey('chapter')) metadata['chapter'] = data['chapter'];
          if (data.containsKey('section')) metadata['section'] = data['section'];
          if (data.containsKey('problemCode')) metadata['problemCode'] = data['problemCode'];
          if (data.containsKey('difficultyLevel')) metadata['difficultyLevel'] = data['difficultyLevel'];
          if (data.containsKey('assessmentElements')) metadata['assessmentElements'] = data['assessmentElements'];
          if (data.containsKey('tags')) metadata['tags'] = data['tags'];
          if (data.containsKey('xpReward')) metadata['xpReward'] = data['xpReward'];
          if (data.containsKey('lessonId')) metadata['lessonId'] = data['lessonId'];
          if (data.containsKey('solution')) metadata['solution'] = data['solution'];

          return Problem(
            id: data['id'] as String,
            title: (data['chapter'] as String?) ?? (data['category'] as String? ?? fileChapter ?? '문제'),
            question: data['question'] as String,
            type: ProblemType.values.firstWhere(
              (e) => e.toString() == 'ProblemType.${data['type']}',
              orElse: () => ProblemType.multipleChoice,
            ),
            category: data['category'] as String? ?? fileChapter ?? '일반',
            difficulty: data['difficulty'] as int? ?? 2,
            choices: (data['options'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
            answer: data['correctAnswerIndex'] ?? 0,
            hints: (data['hints'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
            explanation: data['explanation'] as String?,
            metadata: metadata.isNotEmpty ? metadata : null,
          );
        }).toList();

        problems.addAll(loadedProblems);
        Logger.debug('[ProblemRepository] $schoolLevel/$gradeFolder에서 ${loadedProblems.length}개 문제 로드');
      } catch (e) {
        // 파일이 없으면 스킵 (정상 동작)
        Logger.debug('[ProblemRepository] $schoolLevel/$gradeFolder 문제 파일 없음 (스킵)');
      }
    }

    return problems;
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

  /// 레슨 ID로 문제 목록 로드 (어려운 문제 우선)
  Future<List<Problem>> loadProblemsByLesson(String lessonId) async {
    // 1단계: 학년별 폴더 구조에서 모든 문제 로드 후 lessonId로 필터링
    final allProblems = await loadAllProblems();

    // lessonId로 필터링
    final filteredProblems = allProblems.where((problem) {
      final problemLessonId = problem.lessonId;
      return problemLessonId == lessonId;
    }).toList();

    if (filteredProblems.isNotEmpty) {
      Logger.debug('[ProblemRepository] 레슨 $lessonId에 ${filteredProblems.length}개 문제 로드 (학년별 폴더)');
      return filteredProblems;
    }

    // 2단계: 한국 교육과정 레거시 폴더에서 시도 (ms1_001 등)
    try {
      final koreanProblems = await _loadKoreanCurriculumProblems(lessonId);
      if (koreanProblems.isNotEmpty) {
        Logger.debug('[ProblemRepository] 한국 교육과정 문제 ${koreanProblems.length}개 로드: $lessonId');
        return koreanProblems;
      }
    } catch (e) {
      Logger.debug('[ProblemRepository] 한국 교육과정 문제 로드 실패: $e');
    }

    // 3단계: 적절한 문제가 없으면 "준비중" 메시지 표시
    Logger.debug('[ProblemRepository] 레슨 $lessonId에 적절한 문제가 없습니다. 준비중 메시지 표시');
    return [_generateSingleProblem(lessonId)];
  }

  /// 레슨 ID와 학년으로 문제 목록 로드 (학년별 필터링)
  Future<List<Problem>> loadProblemsByLessonAndGrade(String lessonId, String grade) async {
    try {
      // 1단계: 사용자 학년에 맞는 문제만 로드
      final schoolLevel = SchoolLevel.fromGrade(grade);
      final gradeProblems = await loadProblemsBySchoolLevelAndGrade(
        schoolLevel: schoolLevel,
        grade: grade,
      );

      // 2단계: lessonId로 필터링
      final filteredProblems = gradeProblems.where((problem) {
        final problemLessonId = problem.lessonId;
        return problemLessonId == lessonId;
      }).toList();

      if (filteredProblems.isNotEmpty) {
        Logger.debug('[ProblemRepository] 레슨 $lessonId, 학년 $grade에 ${filteredProblems.length}개 문제 로드');
        return filteredProblems;
      }

      // 3단계: 학년에 맞는 문제가 없으면 레거시 폴더에서 시도
      try {
        final koreanProblems = await _loadKoreanCurriculumProblems(lessonId);
        if (koreanProblems.isNotEmpty) {
          Logger.debug('[ProblemRepository] 한국 교육과정 문제 ${koreanProblems.length}개 로드: $lessonId (학년: $grade)');
          return koreanProblems;
        }
      } catch (e) {
        Logger.debug('[ProblemRepository] 한국 교육과정 문제 로드 실패: $e');
      }

      // 4단계: 적절한 문제가 없으면 "준비중" 메시지 표시
      Logger.debug('[ProblemRepository] 레슨 $lessonId, 학년 $grade에 적절한 문제가 없습니다. 준비중 메시지 표시');
      return [_generateSingleProblem(lessonId)];
    } catch (e) {
      Logger.debug('[ProblemRepository] 문제 로드 오류 (레슨: $lessonId, 학년: $grade): $e');
      return [_generateSingleProblem(lessonId)];
    }
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

  /// 학교급별 문제 로드 (SchoolLevel enum 사용)
  Future<List<Problem>> loadProblemsBySchoolLevel(SchoolLevel schoolLevel) async {
    final problems = <Problem>[];

    // 학교급별로 학년 폴더 결정
    final gradesFolders = _getGradeFoldersForSchoolLevel(schoolLevel);
    final schoolLevelCode = schoolLevel.pathCode; // 'elementary', 'middle', 'high'
    final defaultGrade = schoolLevel.grades.first; // 첫 학년을 기본값으로

    final loadedProblems = await _loadGradeProblems(schoolLevelCode, defaultGrade, gradesFolders);
    problems.addAll(loadedProblems);

    return problems;
  }

  /// 학교급과 특정 학년으로 문제 로드
  Future<List<Problem>> loadProblemsBySchoolLevelAndGrade({
    required SchoolLevel schoolLevel,
    required String grade,
  }) async {
    // 학교급이 해당 학년을 포함하는지 확인
    if (!schoolLevel.containsGrade(grade)) {
      Logger.debug('[ProblemRepository] 학년 $grade은(는) ${schoolLevel.displayName}에 속하지 않습니다.');
      return [];
    }

    final allProblems = await loadAllProblems();

    return allProblems.where((problem) {
      // 문제의 학교급과 학년이 모두 일치하는지 확인
      return problem.schoolLevel == schoolLevel && problem.grade == grade;
    }).toList();
  }

  /// 학교급별 문제 필터링 (메모리에 로드된 문제 목록에서)
  List<Problem> filterBySchoolLevel(List<Problem> problems, SchoolLevel schoolLevel) {
    return problems.where((problem) {
      return problem.schoolLevel == schoolLevel;
    }).toList();
  }

  /// 학교급별 학년 폴더 목록 반환
  List<String> _getGradeFoldersForSchoolLevel(SchoolLevel schoolLevel) {
    switch (schoolLevel) {
      case SchoolLevel.elementary:
        return ['grade1', 'grade2', 'grade3', 'grade4', 'grade5', 'grade6'];
      case SchoolLevel.middle:
        return ['grade1', 'grade2', 'grade3'];
      case SchoolLevel.high:
        return ['grade1', 'grade2', 'grade3'];
    }
  }

  /// 사용자 학년에 맞는 문제만 로드 (User 객체의 currentGrade 사용)
  Future<List<Problem>> loadProblemsForUserGrade(String currentGrade) async {
    final schoolLevel = SchoolLevel.fromGrade(currentGrade);
    return await loadProblemsBySchoolLevelAndGrade(
      schoolLevel: schoolLevel,
      grade: currentGrade,
    );
  }
}
