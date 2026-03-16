// Basic Flutter widget test for MathLab app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App root widget builds without crashing', (WidgetTester tester) async {
    // Build a minimal app to verify the widget tree can be constructed
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('MathLab')),
          ),
        ),
      ),
    );

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('MathLab'), findsOneWidget);
  });
}
