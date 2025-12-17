import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/league.dart';
import '../../data/providers/league_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';

class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  LeagueTier selectedTier = LeagueTier.silver; // 현재 선택된 티어

  @override
  Widget build(BuildContext context) {
    final leagueState = ref.watch(leagueProvider);
    final currentUserRank = ref.watch(currentUserRankProvider);
    final canPromote = ref.watch(canPromoteProvider);
    final isRelegationZone = ref.watch(isRelegationZoneProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 공통 헤더 위젯 사용
            const CommonAppHeader(
              title: '리그',
              icon: Icons.emoji_events,
              iconColor: AppColors.mathYellow,
            ),

            // 🎯 듀오링고 스타일 티어 선택 바
            _buildTierSelector(leagueState.currentLeague?.tier),

            // 콘텐츠
            Expanded(
              child: leagueState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : leagueState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                              const SizedBox(height: 16),
                              Text(
                                '오류 발생',
                                style: AppTextStyles.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                leagueState.error!,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : leagueState.currentLeague == null
                          ? const Center(child: Text('리그 정보가 없습니다'))
                          : RefreshIndicator(
                              onRefresh: () => ref.read(leagueProvider.notifier).refreshLeague(),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),

                                    // 리그 정보 헤더
                                    _buildLeagueHeader(
                                      context,
                                      leagueState.currentLeague!,
                                      currentUserRank,
                                      canPromote,
                                      isRelegationZone,
                                    ),

                                    // 승급/강등 안내
                                    _buildPromotionInfo(context),

                                    // 리더보드
                                    _buildLeaderboard(
                                      context,
                                      leagueState.currentLeague!,
                                      currentUserRank,
                                    ),

                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueHeader(
    BuildContext context,
    League league,
    int? currentUserRank,
    bool canPromote,
    bool isRelegationZone,
  ) {
    final timeLeft = league.weekEndDate.difference(DateTime.now());
    final daysLeft = timeLeft.inDays;
    final hoursLeft = timeLeft.inHours % 24;
    final minutesLeft = timeLeft.inMinutes % 60;

    // 시간 문자열 생성
    String timeString = '';
    if (daysLeft > 0) {
      timeString = '$daysLeft일 ${hoursLeft}시간';
    } else if (hoursLeft > 0) {
      timeString = '$hoursLeft시간 ${minutesLeft}분';
    } else {
      timeString = '$minutesLeft분';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(league.tier.color),
            Color(league.tier.color).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(league.tier.color).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 데코레이션
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 리그 아이콘 & 이름 (듀오링고 스타일)
                Column(
                  children: [
                    // 큰 티어 아이콘
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          league.tier.iconPath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // 이미지 로드 실패 시 이모티콘 표시
                            return Text(
                              league.tier.iconEmoji,
                              style: const TextStyle(fontSize: 56),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 리그 이름
                    Text(
                      league.tier.displayName,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 타이머
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$timeString 후 승급/강등',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 현재 순위 카드
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '내 순위',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.mathYellow.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppColors.mathYellow,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${currentUserRank ?? '-'}위',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 승급/강등 상태 배지
                if (canPromote || isRelegationZone) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canPromote
                            ? AppColors.greenGradient
                            : [AppColors.mathRed, AppColors.mathRedDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (canPromote ? AppColors.mathGreen : AppColors.mathRed)
                              .withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          canPromote ? Icons.arrow_upward : Icons.warning,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          canPromote ? '승급 가능!' : '강등 위험',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 승급 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mathGreen.withOpacity(0.15),
                    AppColors.mathGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.mathGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mathGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: AppColors.mathGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '승급',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '상위 10명',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.mathGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 강등 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mathRed.withOpacity(0.15),
                    AppColors.mathRed.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.mathRed.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mathRed.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.mathRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '강등',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '하위 5명',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.mathRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(
    BuildContext context,
    League league,
    int? currentUserRank,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리더보드 제목
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.leaderboard, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  '리더보드',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 참가자 카드 목록
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: league.participants.length,
            itemBuilder: (context, index) {
              final participant = league.participants[index];
              final isCurrentUser = participant.userId == 'current_user';
              final isTop3 = participant.rank <= 3; // 듀오링고 스타일: 상위 3명 강조
              final isPromotionZone = participant.rank <= 10;
              final isRelegationZone = participant.rank > league.participants.length - 5 &&
                  league.tier != LeagueTier.bronze;

              // 듀오링고 스타일: 상위 3명 특별 배경색
              Color? topRankBgColor;
              if (isTop3) {
                topRankBgColor = participant.rank == 1
                    ? const Color(0xFFFFD700).withOpacity(0.15) // 금색
                    : participant.rank == 2
                        ? const Color(0xFFC0C0C0).withOpacity(0.15) // 은색
                        : const Color(0xFFCD7F32).withOpacity(0.15); // 동색
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  // 듀오링고 스타일: 현재 사용자와 상위 3명 그라데이션
                  gradient: isCurrentUser
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.12),
                            AppColors.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : topRankBgColor != null
                          ? LinearGradient(
                              colors: [
                                topRankBgColor,
                                topRankBgColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                  color: topRankBgColor == null && !isCurrentUser ? Colors.white : null,
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrentUser
                      ? Border.all(
                          color: AppColors.primary,
                          width: 3, // 듀오링고 스타일: 더 두꺼운 테두리
                        )
                      : isTop3
                          ? Border.all(
                              color: participant.rank == 1
                                  ? const Color(0xFFFFD700)
                                  : participant.rank == 2
                                      ? const Color(0xFFC0C0C0)
                                      : const Color(0xFFCD7F32),
                              width: 2,
                            )
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: isCurrentUser
                          ? AppColors.primary.withOpacity(0.3)
                          : isTop3
                              ? Colors.black.withOpacity(0.12)
                              : Colors.black.withOpacity(0.08),
                      blurRadius: isCurrentUser ? 15 : isTop3 ? 10 : 8,
                      offset: Offset(0, isCurrentUser ? 5 : isTop3 ? 4 : 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // 순위 아이콘
                      SizedBox(
                        width: 44,
                        child: _buildRankBadge(participant.rank),
                      ),
                      const SizedBox(width: 14),

                      // 이름과 뱃지
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    participant.userName,
                                    style: AppTextStyles.titleLarge.copyWith(
                                      fontWeight: isCurrentUser
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isCurrentUser
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '나',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 경험치와 상태
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.goldGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${participant.weeklyXp}',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isPromotionZone || isRelegationZone) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isPromotionZone
                                        ? AppColors.mathGreen
                                        : AppColors.mathRed)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isPromotionZone
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isPromotionZone
                                    ? AppColors.mathGreen
                                    : AppColors.mathRed,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    // 듀오링고 스타일: 상위 3명은 메달 아이콘
    if (rank <= 3) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: rank == 1
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)] // 금메달
                : rank == 2
                    ? [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)] // 은메달
                    : [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // 동메달
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (rank == 1
                      ? const Color(0xFFFFD700)
                      : rank == 2
                          ? const Color(0xFFC0C0C0)
                          : const Color(0xFFCD7F32))
                  .withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    // 4위 이하는 기존 이미지 또는 숫자
    String? rankIconPath;

    switch (rank) {
      case 4:
        rankIconPath = 'assets/images/ranks/gt_lv1.png';
        break;
      case 5:
        rankIconPath = 'assets/images/ranks/a_레전드.png';
        break;
      case 6:
        rankIconPath = 'assets/images/ranks/a_lv3.png';
        break;
      case 7:
        rankIconPath = 'assets/images/ranks/a_lv2.png';
        break;
      case 8:
        rankIconPath = 'assets/images/ranks/a_lv1.png';
        break;
      case 9:
        rankIconPath = 'assets/images/ranks/h_레전드.png';
        break;
      case 10:
        rankIconPath = 'assets/images/ranks/h_lv3.png';
        break;
      case 11:
        rankIconPath = 'assets/images/ranks/h_lv2.png';
        break;
      case 12:
        rankIconPath = 'assets/images/ranks/h_lv1.png';
        break;
    }

    return rankIconPath != null
        ? Image.asset(
            rankIconPath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 숫자로 표시
              return Text(
                '$rank',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              );
            },
          )
        : Text(
            '$rank',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          );
  }

  Widget _buildBadgeChip(LeagueBadge badge) {
    // 뱃지별 색상 매핑
    final badgeColors = {
      LeagueBadge.streak: AppColors.mathOrange,
      LeagueBadge.perfect: AppColors.mathYellow,
      LeagueBadge.topScorer: AppColors.mathPurple,
      LeagueBadge.rising: AppColors.mathTeal,
      LeagueBadge.veteran: AppColors.mathGold,
    };

    final badgeColor = badgeColors[badge] ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withOpacity(0.2),
            badgeColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badgeColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.icon,
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 3),
          Text(
            badge.displayName.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 듀오링고 스타일 티어 선택 바
  Widget _buildTierSelector(LeagueTier? currentTier) {
    // 현재 티어로 초기 선택값 설정
    if (currentTier != null && selectedTier != currentTier) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedTier = currentTier;
        });
      });
    }

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: LeagueTier.values.length,
        itemBuilder: (context, index) {
          final tier = LeagueTier.values[index];
          final isSelected = tier == selectedTier;
          final isCurrentUserTier = tier == currentTier;

          // 도달하지 못한 리그인지 확인 (현재 티어보다 높은 티어)
          final isLocked = currentTier != null && tier.index > currentTier.index;

          return GestureDetector(
            onTap: isLocked ? null : () {
              setState(() {
                selectedTier = tier;
              });
            },
            child: Opacity(
              opacity: isLocked ? 0.3 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSelected ? 100 : 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLocked
                        ? [
                            Colors.grey.withOpacity(0.3),
                            Colors.grey.withOpacity(0.2),
                          ]
                        : isSelected
                            ? [
                                Color(tier.color),
                                Color(tier.color).withOpacity(0.8),
                              ]
                            : [
                                Color(tier.color).withOpacity(0.3),
                                Color(tier.color).withOpacity(0.2),
                              ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white,
                          width: 3,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(tier.color).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    // 티어 아이콘
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLocked) ...[
                            // 잠긴 리그는 실루엣만 표시
                            Container(
                              width: isSelected ? 50 : 40,
                              height: isSelected ? 50 : 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ] else ...[
                            // 랭크 아이콘 이미지
                            Image.asset(
                              tier.iconPath,
                              width: isSelected ? 50 : 40,
                              height: isSelected ? 50 : 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // 이미지 로드 실패 시 이모티콘 표시
                                return Text(
                                  tier.iconEmoji,
                                  style: TextStyle(
                                    fontSize: isSelected ? 40 : 32,
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            tier.displayName.replaceAll(' 리그', ''),
                            style: TextStyle(
                              fontSize: isSelected ? 13 : 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isLocked ? Colors.white38 : (isSelected ? Colors.white : Colors.white70),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // 현재 사용자 티어 표시
                    if (isCurrentUserTier && !isLocked)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.mathYellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mathYellow.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
