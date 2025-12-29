// MathLab 앱의 기본 위젯 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mathlab/app/app.dart';

void main() {
  testWidgets('MathLab app loads successfully', (WidgetTester tester) async {
    // Build our app with ProviderScope for Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MathLabApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the auth screen loads (since user is not authenticated)
    // The auth screen should have login buttons
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('Google로 계속하기'), findsOneWidget);
    expect(find.text('Kakao로 계속하기'), findsOneWidget);
  });

  testWidgets('App initializes without errors', (WidgetTester tester) async {
    // Build our app with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MathLabApp(),
      ),
    );

    // Wait for initialization
    await tester.pumpAndSettle();

    // Verify no errors were thrown during initialization
    expect(tester.takeException(), isNull);
  });
}