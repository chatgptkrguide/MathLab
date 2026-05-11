// Feature Flags section (dev / admin only) — lists boolean feature flags
// loaded from the FeatureFlagProvider and offers a refresh action.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/infrastructure/feature_flag_provider.dart';
import '../../../shared/constants/constants.dart';
import 'setting_divider.dart';

class FeatureFlagsSection extends ConsumerWidget {
  const FeatureFlagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagProvider);
    final notifier = ref.read(featureFlagProvider.notifier);

    final flagItems = {
      'hearts_enabled': flags.heartsEnabled ? 'ON' : 'OFF',
      'srs_enabled': flags.srsEnabled ? 'ON' : 'OFF',
      'league_enabled': flags.leagueEnabled ? 'ON' : 'OFF',
      'daily_challenge_enabled': flags.dailyChallengeEnabled ? 'ON' : 'OFF',
      'premium_enabled': flags.premiumEnabled ? 'ON' : 'OFF',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...flagItems.entries.map((entry) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            fontSize: 13, fontFamily: 'monospace')),
                    Text(entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: entry.value == 'ON'
                              ? AppColors.mathGreen
                              : AppColors.mathRed,
                        )),
                  ],
                ),
              )),
          const SettingDivider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await notifier.refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feature flags refreshed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
