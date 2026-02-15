import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../infrastructure/firebase_providers.dart';

class AdminStats {
  final int userCount;
  final int unitCount;
  final int lessonCount;
  final int problemCount;
  final int achievementCount;

  const AdminStats({
    this.userCount = 0,
    this.unitCount = 0,
    this.lessonCount = 0,
    this.problemCount = 0,
    this.achievementCount = 0,
  });
}

/// Aggregated admin statistics provider
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final firestore = ref.read(firestoreProvider);

  try {
    final results = await Future.wait([
      firestore.collection('users').count().get(),
      firestore.collection('units').count().get(),
      firestore.collectionGroup('lessons').count().get(),
      firestore.collection('problems').count().get(),
      firestore.collection('achievements').count().get(),
    ]);

    return AdminStats(
      userCount: results[0].count ?? 0,
      unitCount: results[1].count ?? 0,
      lessonCount: results[2].count ?? 0,
      problemCount: results[3].count ?? 0,
      achievementCount: results[4].count ?? 0,
    );
  } catch (e) {
    AppLogger.error('Failed to load admin stats', tag: 'AdminStats', error: e);
    rethrow;
  }
});
