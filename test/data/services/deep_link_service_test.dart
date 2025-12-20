import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/services/deep_link_service.dart';

void main() {
  group('DeepLinkService', () {
    late DeepLinkService deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkService();
    });

    group('NotificationType Parsing', () {
      test('should parse league_update notification type', () {
        final data = {'type': 'league_update'};
        final type = deepLinkService.parseNotificationType(data['type']);
        expect(type, NotificationType.leagueUpdate);
      });

      test('should parse friend_request notification type', () {
        final data = {'type': 'friend_request'};
        final type = deepLinkService.parseNotificationType(data['type']);
        expect(type, NotificationType.friendRequest);
      });

      test('should parse achievement notification type', () {
        final data = {'type': 'achievement'};
        final type = deepLinkService.parseNotificationType(data['type']);
        expect(type, NotificationType.achievement);
      });

      test('should parse streak_reminder notification type', () {
        final data = {'type': 'streak_reminder'};
        final type = deepLinkService.parseNotificationType(data['type']);
        expect(type, NotificationType.streakReminder);
      });

      test('should return unknown for invalid notification type', () {
        final data = {'type': 'invalid_type'};
        final type = deepLinkService.parseNotificationType(data['type']);
        expect(type, NotificationType.unknown);
      });

      test('should return unknown for null notification type', () {
        final type = deepLinkService.parseNotificationType(null);
        expect(type, NotificationType.unknown);
      });

      test('should handle case-insensitive notification types', () {
        final data = {'type': 'LEAGUE_UPDATE'};
        final type = deepLinkService.parseNotificationType(data['type']);
        expect(type, NotificationType.leagueUpdate);
      });
    });

    group('URL Parsing', () {
      test('should parse league deep link URL', () {
        final url = 'mathlab://app/league';
        final uri = Uri.parse(url);
        expect(uri.scheme, 'mathlab');
        expect(uri.host, 'app');
        expect(uri.path, '/league');
      });

      test('should parse friends URL with query parameters', () {
        final url = 'mathlab://app/friends?requestId=123';
        final uri = Uri.parse(url);
        expect(uri.path, '/friends');
        expect(uri.queryParameters['requestId'], '123');
      });

      test('should parse HTTPS universal link', () {
        final url = 'https://mathlab.app/app/premium?promoCode=WELCOME';
        final uri = Uri.parse(url);
        expect(uri.scheme, 'https');
        expect(uri.host, 'mathlab.app');
        expect(uri.path, '/app/premium');
        expect(uri.queryParameters['promoCode'], 'WELCOME');
      });

      test('should parse lesson URL with lesson ID', () {
        final url = 'mathlab://app/lesson?lessonId=basic-algebra-101';
        final uri = Uri.parse(url);
        expect(uri.path, '/lesson');
        expect(uri.queryParameters['lessonId'], 'basic-algebra-101');
      });
    });

    group('Deep Link Notification Handling', () {
      testWidgets('should handle league update notification', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    deepLinkService.handleNotification(
                      context,
                      {'type': 'league_update'},
                    );
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        );

        // Test should not throw error
        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();
      });

      testWidgets('should handle unknown notification gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    deepLinkService.handleNotification(
                      context,
                      {'type': 'invalid_type'},
                    );
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        );

        // Should not throw error and navigate to home
        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();
      });
    });

    group('Error Handling', () {
      testWidgets('should handle empty notification data', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    deepLinkService.handleNotification(context, {});
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        );

        // Should not throw error
        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();
      });

      testWidgets('should handle malformed URL gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    deepLinkService.handleDeepLinkUrl(
                      context,
                      'invalid-url-format',
                    );
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        );

        // Should not throw error and fallback to home
        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();
      });
    });
  });
}
