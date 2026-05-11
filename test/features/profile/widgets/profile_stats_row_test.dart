import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/user/user_model.dart';
import 'package:mathlab/features/profile/widgets/profile_stats_row.dart';

void main() {
  final fixedNow = DateTime(2024, 6, 15, 12, 0);

  UserModel makeUser({
    int longestStreak = 0,
    int totalXp = 0,
    int gems = 0,
  }) {
    return UserModel(
      uid: 'test-uid',
      authProvider: AuthProvider.email,
      longestStreak: longestStreak,
      totalXp: totalXp,
      gems: gems,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  Widget buildWidget(UserModel user) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: ProfileStatsRow(user: user),
        ),
      ),
    );
  }

  group('ProfileStatsRow — 라벨 노출', () {
    testWidgets('3개 라벨(최장 스트릭, 총 XP, 보유 젬)이 모두 렌더된다', (tester) async {
      final user = makeUser();
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('최장 스트릭'), findsOneWidget);
      expect(find.text('총 XP'), findsOneWidget);
      expect(find.text('보유 젬'), findsOneWidget);
    });

    testWidgets('longestStreak 값이 "N일" 형식으로 렌더된다', (tester) async {
      final user = makeUser(longestStreak: 14);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('14일'), findsOneWidget);
    });

    testWidgets('totalXp 가 1000 미만이면 숫자 그대로 렌더된다', (tester) async {
      final user = makeUser(totalXp: 850);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('850'), findsOneWidget);
    });

    testWidgets('totalXp 가 1000 이상이면 "Xk" 형식으로 렌더된다', (tester) async {
      final user = makeUser(totalXp: 2500);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('2.5k'), findsOneWidget);
    });

    testWidgets('totalXp 가 정확히 1000이면 "1k" 로 렌더된다', (tester) async {
      final user = makeUser(totalXp: 1000);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('1k'), findsOneWidget);
    });

    testWidgets('gems 값이 정상적으로 렌더된다', (tester) async {
      final user = makeUser(gems: 300);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('모든 값이 0이면 "0일", "0", "0" 이 렌더된다', (tester) async {
      final user = makeUser();
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('0일'), findsOneWidget);
      // "0" 텍스트는 총XP와 보유젬 두 곳 — 2개 이상이어야 함
      expect(find.text('0'), findsAtLeastNWidgets(2));
    });
  });

  group('ProfileStatsRow — 위젯 구조', () {
    testWidgets('Row 안에 Expanded 칩이 3개 렌더된다', (tester) async {
      final user = makeUser(longestStreak: 5, totalXp: 200, gems: 50);
      await tester.pumpWidget(buildWidget(user));

      expect(find.byType(Expanded), findsNWidgets(3));
    });

    testWidgets('아이콘 3개가 모두 렌더된다', (tester) async {
      final user = makeUser();
      await tester.pumpWidget(buildWidget(user));

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
    });
  });
}
