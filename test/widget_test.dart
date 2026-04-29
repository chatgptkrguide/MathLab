import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Widget smoke tests', () {
    testWidgets('ProviderScope wraps MaterialApp without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('MathLab')),
            ),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('MathLab'), findsOneWidget);
    });

    testWidgets('Error state widget renders correctly', (WidgetTester tester) async {
      // 오류 상태 UI가 올바르게 렌더링되는지 검증
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48),
                  SizedBox(height: 16),
                  Text('오류가 발생했습니다'),
                  Text('다시 시도해주세요'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도해주세요'), findsOneWidget);
    });

    testWidgets('Loading indicator renders correctly', (WidgetTester tester) async {
      // 로딩 상태 UI 검증
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProviderScope provides Consumer access to providers', (WidgetTester tester) async {
      final testProvider = Provider<String>((ref) => 'hello from provider');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final value = ref.watch(testProvider);
                  return Text(value);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('hello from provider'), findsOneWidget);
    });

    testWidgets('ProviderScope override works correctly', (WidgetTester tester) async {
      final countProvider = StateProvider<int>((ref) => 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // 초기값을 42로 override
            countProvider.overrideWith((ref) => 42),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final count = ref.watch(countProvider);
                  return Text('count: $count');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('count: 42'), findsOneWidget);
    });
  });
}
