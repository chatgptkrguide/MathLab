import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/problem/problem_model.dart';

void main() {
  // 최소 필수 필드를 포함한 기본 JSON 팩토리
  Map<String, dynamic> baseJson({
    String id = 'p-001',
    String lessonId = 'lesson-01',
    String question = '1 + 1 = ?',
    String type = 'multipleChoice',
    String correctAnswer = '2',
  }) {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'type': type,
      'correctAnswer': correctAnswer,
    };
  }

  group('ProblemModel.fromJson — 레거시 hint(단수) 흡수', () {
    test('hint 단수 키를 hints 리스트에 흡수한다', () {
      final json = baseJson()..addAll({'hint': '먼저 덧셈을 생각해보세요'});
      final model = ProblemModel.fromJson(json);

      expect(model.hints, ['먼저 덧셈을 생각해보세요']);
    });

    test('hints 복수 키가 있으면 hint 단수 키를 무시한다', () {
      final json = baseJson()
        ..addAll({
          'hints': ['힌트A', '힌트B'],
          'hint': '이건 무시돼야 함',
        });
      final model = ProblemModel.fromJson(json);

      expect(model.hints, ['힌트A', '힌트B']);
      expect(model.hints, isNot(contains('이건 무시돼야 함')));
    });

    test('hint 가 빈 문자열이면 흡수하지 않는다', () {
      final json = baseJson()..addAll({'hint': ''});
      final model = ProblemModel.fromJson(json);

      expect(model.hints, isEmpty);
    });

    test('hint / hints 모두 없으면 hints 는 빈 리스트', () {
      final json = baseJson();
      final model = ProblemModel.fromJson(json);

      expect(model.hints, isEmpty);
    });
  });

  group('ProblemModel.fromJson — 레거시 imageUrl(단수) 흡수', () {
    test('imageUrl 단수 키를 imageUrls 리스트에 흡수한다', () {
      final json = baseJson()..addAll({'imageUrl': 'https://example.com/img.png'});
      final model = ProblemModel.fromJson(json);

      expect(model.imageUrls, ['https://example.com/img.png']);
    });

    test('imageUrls 복수 키가 있으면 imageUrl 단수 키를 무시한다', () {
      final json = baseJson()
        ..addAll({
          'imageUrls': ['https://a.com/1.png', 'https://a.com/2.png'],
          'imageUrl': 'https://ignored.com/old.png',
        });
      final model = ProblemModel.fromJson(json);

      expect(model.imageUrls, ['https://a.com/1.png', 'https://a.com/2.png']);
      expect(model.imageUrls, isNot(contains('https://ignored.com/old.png')));
    });

    test('imageUrl 이 빈 문자열이면 흡수하지 않는다', () {
      final json = baseJson()..addAll({'imageUrl': ''});
      final model = ProblemModel.fromJson(json);

      expect(model.imageUrls, isEmpty);
    });
  });

  group('ProblemModel.toJson — 단수 키 미포함', () {
    test('toJson 에 hint 단수 키가 없다', () {
      final model = ProblemModel(
        id: 'p-001',
        lessonId: 'l-01',
        question: '문제',
        type: ProblemType.multipleChoice,
        correctAnswer: '42',
        hints: ['힌트1'],
      );

      final json = model.toJson();
      expect(json.containsKey('hint'), isFalse);
    });

    test('toJson 에 imageUrl 단수 키가 없다', () {
      final model = ProblemModel(
        id: 'p-002',
        lessonId: 'l-01',
        question: '문제',
        type: ProblemType.multipleChoice,
        correctAnswer: '42',
        imageUrls: ['https://a.com/img.png'],
      );

      final json = model.toJson();
      expect(json.containsKey('imageUrl'), isFalse);
    });

    test('toJson 은 hints 와 imageUrls 복수 키를 포함한다', () {
      final model = ProblemModel(
        id: 'p-003',
        lessonId: 'l-01',
        question: '문제',
        type: ProblemType.shortAnswer,
        correctAnswer: '7',
        hints: ['힌트1', '힌트2'],
        imageUrls: ['https://a.com/1.png'],
      );

      final json = model.toJson();
      expect(json['hints'], ['힌트1', '힌트2']);
      expect(json['imageUrls'], ['https://a.com/1.png']);
    });
  });

  group('ProblemModel.fromJson — 기본 필드', () {
    test('필드가 정상적으로 파싱된다', () {
      final json = baseJson(id: 'p-abc', lessonId: 'l-xyz', question: '2 * 3 = ?',
          correctAnswer: '6')
        ..addAll({
          'difficulty': 'medium',
          'options': ['3', '5', '6', '9'],
          'explanation': '곱셈입니다',
          'points': 20,
        });

      final model = ProblemModel.fromJson(json);

      expect(model.id, 'p-abc');
      expect(model.lessonId, 'l-xyz');
      expect(model.question, '2 * 3 = ?');
      expect(model.correctAnswer, '6');
      expect(model.difficulty, ProblemDifficulty.medium);
      expect(model.options, ['3', '5', '6', '9']);
      expect(model.explanation, '곱셈입니다');
      expect(model.points, 20);
    });

    test('미정의 type 은 multipleChoice 로 fallback 된다', () {
      final json = baseJson()..['type'] = 'nonExistentType';
      final model = ProblemModel.fromJson(json);

      expect(model.type, ProblemType.multipleChoice);
    });

    test('미정의 difficulty 는 easy 로 fallback 된다', () {
      final json = baseJson()..addAll({'difficulty': 'impossible'});
      final model = ProblemModel.fromJson(json);

      expect(model.difficulty, ProblemDifficulty.easy);
    });

    test('points 누락 시 기본값 10을 사용한다', () {
      final json = baseJson();
      final model = ProblemModel.fromJson(json);

      expect(model.points, 10);
    });
  });

  group('ProblemModel — allHints / allImages 접근자', () {
    test('allHints 는 hints 와 동일하다', () {
      final model = ProblemModel(
        id: 'p-1',
        lessonId: 'l-1',
        question: 'q',
        type: ProblemType.trueFalse,
        correctAnswer: 'true',
        hints: ['h1', 'h2'],
      );

      expect(model.allHints, model.hints);
    });

    test('allImages 는 imageUrls 와 동일하다', () {
      final model = ProblemModel(
        id: 'p-2',
        lessonId: 'l-1',
        question: 'q',
        type: ProblemType.trueFalse,
        correctAnswer: 'false',
        imageUrls: ['https://x.com/a.png'],
      );

      expect(model.allImages, model.imageUrls);
    });
  });
}
