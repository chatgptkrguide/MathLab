// Profile Detail Screen — Figma "05" 디자인
// 프로필 카드 + 통계 + 스트릭 + 과목 + 뱃지 + 통계 그리드 + 프리미엄 배너
//
// 세부 위젯은 widgets/ 하위로 분할됨:
//   - ProfileHeader
//   - ProfileStatsRow
//   - ProfileStreakCard
//   - ProfileSubjectSection
//   - ProfileBadgesSection
//   - ProfileStatisticsSection
//   - ProfilePremiumBanner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/user/user_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/profile_streak_card.dart';
import 'widgets/profile_subject_section.dart';
import 'widgets/profile_badges_section.dart';
import 'widgets/profile_statistics_section.dart';
import 'widgets/profile_premium_banner.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  /// 코치마크용 GlobalKey
  static final profileCardKey = GlobalKey(debugLabel: 'profileCard');
  static final badgesSectionKey = GlobalKey(debugLabel: 'badgesSection');
  static final statsSectionKey = GlobalKey(debugLabel: 'statsSection');

  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ProfileHeader(
              user: user,
              profileCardKey: ProfileDetailScreen.profileCardKey,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileStatsRow(user: user),
                  const SizedBox(height: 16),
                  ProfileStreakCard(user: user),
                  const SizedBox(height: 20),
                  const ProfileSubjectSection(),
                  const SizedBox(height: 24),
                  ProfileBadgesSection(
                    user: user,
                    sectionKey: ProfileDetailScreen.badgesSectionKey,
                  ),
                  const SizedBox(height: 24),
                  ProfileStatisticsSection(
                    user: user,
                    sectionKey: ProfileDetailScreen.statsSectionKey,
                  ),
                  const SizedBox(height: 24),
                  const ProfilePremiumBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
