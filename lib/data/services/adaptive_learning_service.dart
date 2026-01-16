import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../shared/utils/logger.dart';
import '../models/models.dart';

/// AI 기반 적응형 학습 서비스
/// Khan Academy Khanmigo, Duolingo AI 스타일
class AdaptiveLearningService {
  // 싱글톤 패턴
  static final AdaptiveLearningService _instance =
      AdaptiveLearningService._internal();
  factory AdaptiveLearningService() => _instance;
  AdaptiveLearningService._internal();

  /// OpenAI API 키 (환경변수에서 로드)
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  static const String _apiEndpoint =
      'https://api.openai.com/v1/chat/completions';

  /// 사용자의 취약 영역 분석
  ///
  /// 오답 노트와 학습 기록을 분석하여 취약한 주제를 파악합니다.
  Future<List<String>> analyzeWeakAreas(String userId) async {
    try {
      // TODO: 실제 구현에서는 사용자의 학습 기록을 분석
      // 현재는 예시 데이터 반환

      Logger.info('Analyzing weak areas for user: $userId',
          tag: 'AdaptiveLearning');

      // 예시: 오답 패턴 분석
      final weakAreas = <String>[
        '소인수분해',
        '방정식 풀이',
        '도형의 넓이',
      ];

      return weakAreas;
    } catch (e) {
      Logger.error('Failed to analyze weak areas',
          error: e, tag: 'AdaptiveLearning');
      return [];
    }
  }

  /// 난이도 자동 조절
  ///
  /// 사용자의 정답률과 학습 패턴을 분석하여 적절한 난이도를 추천합니다.
  Future<DifficultyLevel> recommendDifficulty(
    String userId,
    String topic,
  ) async {
    try {
      Logger.info('Recommending difficulty for user: $userId, topic: $topic',
          tag: 'AdaptiveLearning');

      // TODO: 실제 구현에서는 사용자의 정답률, 학습 속도 등을 분석
      // 현재는 기본 난이도 반환

      return DifficultyLevel.medium;
    } catch (e) {
      Logger.error('Failed to recommend difficulty',
          error: e, tag: 'AdaptiveLearning');
      return DifficultyLevel.medium;
    }
  }

  /// AI 기반 힌트 생성 (OpenAI GPT-4)
  ///
  /// 문제와 현재 힌트 레벨을 기반으로 적절한 힌트를 생성합니다.
  Future<String> generateHint(Problem problem, int hintLevel) async {
    try {
      Logger.info('Generating AI hint for problem: ${problem.id}, level: $hintLevel',
          tag: 'AdaptiveLearning');

      // 프롬프트 생성
      final prompt = _buildHintPrompt(problem, hintLevel);

      // OpenAI API 호출
      final response = await _callOpenAI(prompt);

      Logger.info('AI hint generated successfully', tag: 'AdaptiveLearning');
      return response;
    } catch (e) {
      Logger.error('Failed to generate AI hint',
          error: e, tag: 'AdaptiveLearning');

      // 폴백: 기본 힌트 반환
      return _getFallbackHint(hintLevel);
    }
  }

  /// AI 기반 문제 설명 생성
  ///
  /// 틀린 문제에 대한 개인화된 설명을 생성합니다.
  Future<String> generateExplanation(Problem problem) async {
    try {
      Logger.info('Generating AI explanation for problem: ${problem.id}',
          tag: 'AdaptiveLearning');

      final prompt = _buildExplanationPrompt(problem);
      final response = await _callOpenAI(prompt);

      Logger.info('AI explanation generated successfully',
          tag: 'AdaptiveLearning');
      return response;
    } catch (e) {
      Logger.error('Failed to generate AI explanation',
          error: e, tag: 'AdaptiveLearning');

      // 폴백: 기본 설명 반환
      return problem.explanation ?? '정답은 ${problem.correctAnswer}입니다.';
    }
  }

  /// 개인화된 학습 경로 생성
  ///
  /// 사용자의 학습 기록과 목표를 기반으로 최적의 학습 경로를 제안합니다.
  Future<List<String>> generateLearningPath(String userId) async {
    try {
      Logger.info('Generating learning path for user: $userId',
          tag: 'AdaptiveLearning');

      // TODO: 실제 구현에서는 사용자의 학습 기록, 목표, 취약점을 분석
      // 현재는 예시 경로 반환

      final learningPath = <String>[
        '소인수분해 기초 복습',
        '소인수분해 심화',
        '최대공약수와 최소공배수',
        '약수와 배수',
        '정수와 유리수',
      ];

      return learningPath;
    } catch (e) {
      Logger.error('Failed to generate learning path',
          error: e, tag: 'AdaptiveLearning');
      return [];
    }
  }

  /// OpenAI API 호출
  Future<String> _callOpenAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': '당신은 친절한 수학 선생님입니다. 초등학생도 이해할 수 있도록 쉽게 설명해주세요.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('OpenAI API call failed', error: e, tag: 'AdaptiveLearning');
      rethrow;
    }
  }

  /// 힌트 프롬프트 생성
  String _buildHintPrompt(Problem problem, int hintLevel) {
    final levelDescription = hintLevel == 1
        ? '아주 작은 힌트만 주세요 (문제를 푸는 방향만 알려주세요)'
        : hintLevel == 2
            ? '중간 정도의 힌트를 주세요 (풀이 과정의 일부를 알려주세요)'
            : '상세한 힌트를 주세요 (정답에 가까운 힌트를 주세요)';

    return '''
문제: ${problem.question}

선택지:
${problem.options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

정답: ${problem.correctAnswer}

$levelDescription
힌트는 100자 이내로 작성해주세요.
''';
  }

  /// 설명 프롬프트 생성
  String _buildExplanationPrompt(Problem problem) {
    return '''
문제: ${problem.question}

선택지:
${problem.options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

정답: ${problem.correctAnswer}

이 문제의 정답이 왜 "${problem.correctAnswer}"인지 초등학생도 이해할 수 있도록 쉽고 친절하게 설명해주세요.
설명은 200자 이내로 작성해주세요.
''';
  }

  /// 폴백 힌트 (OpenAI 실패 시)
  String _getFallbackHint(int hintLevel) {
    switch (hintLevel) {
      case 1:
        return '문제를 천천히 다시 읽어보세요. 주어진 조건을 잘 확인해보세요.';
      case 2:
        return '비슷한 문제를 풀었던 방법을 떠올려보세요. 단계적으로 접근해봅시다.';
      case 3:
        return '문제의 핵심 개념을 복습해보세요. 공식이나 규칙을 적용해봅시다.';
      default:
        return '힌트를 생성할 수 없습니다. 나중에 다시 시도해주세요.';
    }
  }
}

/// 난이도 레벨
enum DifficultyLevel {
  veryEasy,
  easy,
  medium,
  hard,
  veryHard,
}
