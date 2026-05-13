// 회귀 가드: HeartsIndicator
//
// 힌트 버튼은 InlineHintTrigger(별도 위젯) 으로 분리됨 — HeartsIndicator
// 는 하트 표시·카운트 뱃지·회복 안내만 담당.
//
// 1. 채워진/빈 하트 개수가 currentHearts/maxHearts 와 정확히 일치
// 2. 카운트 뱃지 "X/N" 텍스트
// 3. 하트 부족 시 자동 회복 안내 노출, 0 일 때 메시지 분기
//
// 애니메이션 controller 는 TickerProvider 없이 dummy 로 주입.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

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
        heartAnimController: controller,
        heartScaleAnim: scale,
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
        heartAnimController: controller,
        heartScaleAnim: scale,
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
        heartAnimController: controller,
        heartScaleAnim: scale,
      )));

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(5));
      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('30분 후 1개 자동 회복'), findsOneWidget);
    });

    testWidgets('힌트 버튼은 더 이상 HeartsIndicator 내부에 없음 (분리됨)',
        (tester) async {
      await tester.pumpWidget(_wrap(HeartsIndicator(
        currentHearts: 5,
        maxHearts: 5,
        previousHearts: 5,
        heartAnimController: controller,
        heartScaleAnim: scale,
      )));

      expect(find.byType(HintButton), findsNothing);
      expect(find.byType(InlineHintTrigger), findsNothing);
    });
  });

  group('InlineHintTrigger — 분리된 힌트 트리거', () {
    testWidgets('표시: 라벨 "힌트 보기" + N/N 카운트', (tester) async {
      await tester.pumpWidget(_wrap(InlineHintTrigger(
        unlockedCount: 1,
        totalHints: 3,
        isEnabled: true,
        onTap: () {},
      )));

      expect(find.text('힌트 보기'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);
    });

    testWidgets('모든 힌트 열림 시 "모든 힌트 열림" + 체크 아이콘', (tester) async {
      await tester.pumpWidget(_wrap(InlineHintTrigger(
        unlockedCount: 3,
        totalHints: 3,
        isEnabled: true,
        onTap: () {},
      )));

      expect(find.text('모든 힌트 열림'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('isEnabled=true 시 탭 콜백 전달', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_wrap(InlineHintTrigger(
        unlockedCount: 0,
        totalHints: 2,
        isEnabled: true,
        onTap: () => tapped++,
      )));

      await tester.tap(find.byType(InlineHintTrigger));
      expect(tapped, 1);
    });
  });
}
