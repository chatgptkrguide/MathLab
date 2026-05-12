// 회귀 가드: HeartsIndicator
//
// 직전에 힌트 버튼 위치를 좌측 → 우측 끝으로 옮긴 UX 수정과 위젯 분할
// 작업 이후, 다음 항목이 깨지지 않도록 기본 동작을 핀으로 박는다.
//
// 1. 채워진/빈 하트 개수가 currentHearts/maxHearts 와 정확히 일치
// 2. 카운트 뱃지 "X/N" 텍스트
// 3. 하트 부족 시 자동 회복 안내 노출, 0 일 때 메시지 분기
// 4. hints 가 비어 있으면 HintButton 미노출
// 5. hints 가 있고 isAnswerChecked=false 일 때 HintButton 활성
//
// 애니메이션 controller 는 TickerProvider 없이 dummy 로 주입.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mathlab/data/models/problem/problem_model.dart';
import 'package:mathlab/features/problems/widgets/hearts_indicator.dart';
import 'package:mathlab/features/problems/widgets/hint_button.dart';

class _TestProvider extends TickerProvider {
  final List<Ticker> _tickers = [];
  @override
  Ticker createTicker(TickerCallback onTick) {
    final t = Ticker(onTick);
    _tickers.add(t);
    return t;
  }

  void disposeAll() {
    for (final t in _tickers) {
      t.dispose();
    }
  }
}

ProblemModel _problem({List<String> hints = const []}) => ProblemModel(
      id: 'p1',
      lessonId: 'l1',
      question: '1+1=?',
      type: ProblemType.multipleChoice,
      correctAnswer: '2',
      options: const ['1', '2', '3', '4'],
      hints: hints,
    );

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SafeArea(child: child)));

void main() {
  late _TestProvider vsync;
  late AnimationController controller;
  late Animation<double> scale;

  setUp(() {
    vsync = _TestProvider();
    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    scale = Tween<double>(begin: 1.0, end: 1.2).animate(controller);
  });

  tearDown(() {
    controller.dispose();
    vsync.disposeAll();
  });

  group('HeartsIndicator — 하트 표시', () {
    testWidgets('5/5 모두 채워짐, 회복 안내 없음', (tester) async {
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 5,
        maxHearts: 5,
        previousHearts: 5,
        isAnswerChecked: false,
        heartAnimController: controller,
        heartScaleAnim: scale,
        currentProblem: _problem(),
        unlockedHintCount: 0,
        totalHints: 0,
        onHintTap: () {},
      )));

      expect(find.byIcon(Icons.favorite), findsNWidgets(5));
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsNothing);
    });

    testWidgets('3/5 — 3개 채움 + 2개 빈, 회복 안내 노출', (tester) async {
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 3,
        maxHearts: 5,
        previousHearts: 3,
        isAnswerChecked: false,
        heartAnimController: controller,
        heartScaleAnim: scale,
        currentProblem: _problem(),
        unlockedHintCount: 0,
        totalHints: 0,
        onHintTap: () {},
      )));

      expect(find.byIcon(Icons.favorite), findsNWidgets(3));
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
      expect(find.text('3/5'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(find.textContaining('2개 부족'), findsOneWidget);
    });

    testWidgets('0/5 — 모두 빔, 0개일 때 회복 메시지가 단일 회복 형태', (tester) async {
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 0,
        maxHearts: 5,
        previousHearts: 0,
        isAnswerChecked: false,
        heartAnimController: controller,
        heartScaleAnim: scale,
        currentProblem: _problem(),
        unlockedHintCount: 0,
        totalHints: 0,
        onHintTap: () {},
      )));

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(5));
      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('30분 후 1개 자동 회복'), findsOneWidget);
    });
  });

  group('HeartsIndicator — 힌트 버튼', () {
    testWidgets('hints 비어 있으면 HintButton 미노출', (tester) async {
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 5,
        maxHearts: 5,
        previousHearts: 5,
        isAnswerChecked: false,
        heartAnimController: controller,
        heartScaleAnim: scale,
        currentProblem: _problem(hints: const []),
        unlockedHintCount: 0,
        totalHints: 0,
        onHintTap: () {},
      )));

      expect(find.byType(HintButton), findsNothing);
    });

    testWidgets('hints 가 있으면 HintButton 노출 + 콜백 전달', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 5,
        maxHearts: 5,
        previousHearts: 5,
        isAnswerChecked: false,
        heartAnimController: controller,
        heartScaleAnim: scale,
        currentProblem: _problem(hints: const ['힌트1', '힌트2']),
        unlockedHintCount: 1,
        totalHints: 2,
        onHintTap: () => tapped++,
      )));

      final hintButton = find.byType(HintButton);
      expect(hintButton, findsOneWidget);
      final widget = tester.widget<HintButton>(hintButton);
      expect(widget.unlockedCount, 1);
      expect(widget.totalHints, 2);
      expect(widget.isEnabled, isTrue);

      widget.onTap();
      expect(tapped, 1);
    });

    testWidgets('isAnswerChecked=true 면 HintButton 비활성', (tester) async {
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 5,
        maxHearts: 5,
        previousHearts: 5,
        isAnswerChecked: true,
        heartAnimController: controller,
        heartScaleAnim: scale,
        currentProblem: _problem(hints: const ['힌트']),
        unlockedHintCount: 0,
        totalHints: 1,
        onHintTap: () {},
      )));

      final widget =
          tester.widget<HintButton>(find.byType(HintButton));
      expect(widget.isEnabled, isFalse);
    });
  });
}
