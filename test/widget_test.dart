// MathLab 앱의 기본 위젯 테스트
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mathlab/app/app.dart';

void main() {
  testWidgets('MathLab app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MathLabApp());

    // Verify that the home screen loads
    expect(find.text('안녕하세요, 학습자님!'), findsOneWidget);
    expect(find.text('학습 시작하기'), findsOneWidget);

    // Verify navigation tabs are present
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('학습'), findsOneWidget);
    expect(find.text('오답'), findsOneWidget);
    expect(find.text('이력'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });

  testWidgets('Navigation works correctly', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MathLabApp());

    // Tap on the 학습 tab
    await tester.tap(find.text('학습'));
    await tester.pumpAndSettle();

    // Verify we're on the lessons screen
    expect(find.text('학습 로드맵'), findsOneWidget);

    // Tap on the 프로필 tab
    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();

    // Should be able to find user profile elements
    expect(find.text('학습자'), findsOneWidget);
  });
}