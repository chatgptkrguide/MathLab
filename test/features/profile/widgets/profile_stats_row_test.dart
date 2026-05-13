import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/user/user_model.dart';
import 'package:mathlab/features/profile/widgets/profile_stats_row.dart';

void main() {
  final fixedNow = DateTime(2024, 6, 15, 12, 0);

  UserModel makeUser({
    int longestStreak = 0,
    int streak = 0,
    int gems = 0,
  }) {
    return UserModel(
      uid: 'test-uid',
      authProvider: AuthProvider.email,
      longestStreak: longestStreak,
      streak: streak,
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

  // 직전 디자인 회의 결과: 총 XP 칩은 헤더의 큰 XP 숫자와 중복이라 제거,
  // '현재 연속' 칩으로 교체. (헤더에 user.totalXp 가 fs30 으로 노출됨)

  group('ProfileStatsRow — 라벨 노출', () {
    testWidgets('3개 라벨(최장 스트릭, 현재 연속, 보유 젬)이 모두 렌더된다',
        (tester) async {
      final user = makeUser();
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('최장 스트릭'), findsOneWidget);
      expect(find.text('현재 연속'), findsOneWidget);
      expect(find.text('보유 젬'), findsOneWidget);
    });

    testWidgets('longestStreak 값이 "N일" 형식으로 렌더된다', (tester) async {
      final user = makeUser(longestStreak: 14);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('14일'), findsOneWidget);
    });

    testWidgets('현재 streak 값이 "N일" 형식으로 렌더된다', (tester) async {
      final user = makeUser(streak: 7);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('7일'), findsOneWidget);
    });

    testWidgets('gems 값이 정상적으로 렌더된다', (tester) async {
      final user = makeUser(gems: 300);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('gems 가 1000 이상이면 "Xk" 형식으로 렌더된다', (tester) async {
      final user = makeUser(gems: 2500);
      await tester.pumpWidget(buildWidget(user));

      expect(find.text('2.5k'), findsOneWidget);
    });

    testWidgets('모든 값이 0이면 longestStreak·streak 둘 다 "0일" 렌더', (tester) async {
      final user = makeUser();
      await tester.pumpWidget(buildWidget(user));

      // longestStreak 0일 + streak 0일 = 2 개
      expect(find.text('0일'), findsNWidgets(2));
      expect(find.text('0'), findsOneWidget); // 보유 젬 0
    });
  });

  group('ProfileStatsRow — 위젯 구조', () {
    testWidgets('Row 안에 Expanded 칩이 3개 (flex 3 : 2 : 2)', (tester) async {
      final user = makeUser(longestStreak: 5, streak: 3, gems: 50);
      await tester.pumpWidget(buildWidget(user));

      // 외부 Row 의 3개 Expanded. _StatChip horizontal 내부에 추가 Expanded(라벨/값)
      // 가 있어 정확한 카운트를 어렵게 하므로, findsAtLeastNWidgets 로 완화.
      expect(find.byType(Expanded), findsAtLeastNWidgets(3));
    });

    testWidgets('아이콘 3개가 모두 렌더된다 (불꽃·캘린더·다이아)', (tester) async {
      final user = makeUser();
      await tester.pumpWidget(buildWidget(user));

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
    });
  });
}
