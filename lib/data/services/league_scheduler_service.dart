// ⏰ League Scheduler Service
//
// Handles weekly league cycle scheduling and notifications

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../providers/league/league_provider.dart';
import '../../features/league/widgets/weekly_results_dialog.dart';

class LeagueSchedulerService {
  final Logger _logger = Logger();
  Timer? _checkTimer;
  bool _hasShownResults = false;
  DateTime? _lastCheckedLeagueEnd;

  /// Start periodic league end checks
  void startScheduler({
    required WidgetRef ref,
    required String userId,
    required BuildContext context,
    Duration checkInterval = const Duration(minutes: 5),
  }) {
    _logger.i('Starting league scheduler with ${checkInterval.inMinutes}min interval');

    // Initial check
    _checkLeagueEnd(ref: ref, userId: userId, context: context);

    // Periodic checks
    _checkTimer = Timer.periodic(checkInterval, (_) {
      _checkLeagueEnd(ref: ref, userId: userId, context: context);
    });
  }

  /// Stop scheduler
  void stopScheduler() {
    _checkTimer?.cancel();
    _checkTimer = null;
    _logger.i('Stopped league scheduler');
  }

  /// Check if league has ended and show results
  Future<void> _checkLeagueEnd({
    required WidgetRef ref,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      final leagueNotifier = ref.read(leagueProvider(userId).notifier);

      // Check if league has ended
      if (!leagueNotifier.hasLeagueEnded()) {
        _logger.d('League still active');
        return;
      }

      // Check if we already showed results for this league
      final currentLeagueEnd = ref
          .read(leagueProvider(userId))
          .userLeagueStatus
          ?.league
          .endDate;

      if (currentLeagueEnd != null &&
          _lastCheckedLeagueEnd == currentLeagueEnd &&
          _hasShownResults) {
        _logger.d('Results already shown for this league');
        return;
      }

      _logger.i('League has ended, calculating results...');

      // Calculate results
      final results = await leagueNotifier.calculateWeeklyResults();

      if (results.isEmpty) {
        _logger.w('No results to show');
        return;
      }

      // Show results dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WeeklyResultsDialog(results: results),
        );

        _hasShownResults = true;
        _lastCheckedLeagueEnd = currentLeagueEnd;

        _logger.i('Showed weekly results dialog');
      }
    } catch (e) {
      _logger.e('Failed to check league end: $e');
    }
  }

  /// Manually trigger league end check
  Future<void> checkNow({
    required WidgetRef ref,
    required String userId,
    required BuildContext context,
  }) async {
    _hasShownResults = false;
    await _checkLeagueEnd(ref: ref, userId: userId, context: context);
  }

  /// Reset flags (e.g., when user navigates to league screen)
  void reset() {
    _hasShownResults = false;
    _lastCheckedLeagueEnd = null;
  }

  void dispose() {
    stopScheduler();
  }
}
