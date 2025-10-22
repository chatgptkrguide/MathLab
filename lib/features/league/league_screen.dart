import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/league_provider.dart';
import '../../data/models/league.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';

/// 리그 화면
class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // 카운트다운 타이머 시작
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _updateRemainingTime();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateRemainingTime();
      }
    });
  }

  void _updateRemainingTime() {
    final state = ref.read(leagueProvider);
    setState(() {
      _remainingTime = state.remainingTimeString;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leagueProvider);
    final myLeagueInfo = state.myLeagueInfo;

    // 순위로 정렬
    final sortedParticipants = [...state.participants]
      ..sort((a, b) => b.weeklyXP.compareTo(a.weeklyXP));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: myLeagueInfo.tier.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                await AppHapticFeedback.lightImpact();
                if (mounted) Navigator.of(context).pop();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: myLeagueInfo.tier.gradientColors,
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // 티어 아이콘
                        Text(
                          myLeagueInfo.tier.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        // 티어명
                        Text(
                          '${myLeagueInfo.tier.displayName} 리그',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXS),
                        // 순위
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          ),
                          child: Text(
                            '${state.myRank}위 / ${myLeagueInfo.totalPlayers}명',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        // 주간 XP
                        Text(
                          '주간 XP: ${state.myWeeklyXP}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXS),
                        // 남은 시간
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '남은 시간: $_remainingTime',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 승급/강등 안내
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.paddingL),
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: myLeagueInfo.canPromote
                    ? AppColors.success.withOpacity(0.1)
                    : myLeagueInfo.relegationRisk
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: myLeagueInfo.canPromote
                      ? AppColors.success
                      : myLeagueInfo.relegationRisk
                          ? AppColors.error
                          : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    myLeagueInfo.canPromote
                        ? Icons.arrow_upward
                        : myLeagueInfo.relegationRisk
                            ? Icons.arrow_downward
                            : Icons.info_outline,
                    color: myLeagueInfo.canPromote
                        ? AppColors.success
                        : myLeagueInfo.relegationRisk
                            ? AppColors.error
                            : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      myLeagueInfo.canPromote
                          ? '🎉 상위 20% 안에 들었어요! 이대로 유지하면 승급할 수 있어요.'
                          : myLeagueInfo.relegationRisk
                              ? '⚠️ 하위 20%입니다. 조금만 더 열심히 하면 강등을 피할 수 있어요!'
                              : '💪 열심히 학습해서 상위권에 진입하세요!',
                      style: TextStyle(
                        color: myLeagueInfo.canPromote
                            ? AppColors.success
                            : myLeagueInfo.relegationRisk
                                ? AppColors.error
                                : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 참가자 리스트
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final participant = sortedParticipants[index];
                final rank = index + 1;
                final isMe = participant.id == 'current_user';

                return _ParticipantCard(
                  participant: participant,
                  rank: rank,
                  isMe: isMe,
                  isPromotionZone: rank <= (sortedParticipants.length * 0.2).round(),
                  isRelegationZone: rank > (sortedParticipants.length * 0.8).round(),
                );
              },
              childCount: sortedParticipants.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacingXL),
          ),
        ],
      ),
    );
  }
}

/// 참가자 카드
class _ParticipantCard extends StatelessWidget {
  final LeagueParticipant participant;
  final int rank;
  final bool isMe;
  final bool isPromotionZone;
  final bool isRelegationZone;

  const _ParticipantCard({
    required this.participant,
    required this.rank,
    required this.isMe,
    required this.isPromotionZone,
    required this.isRelegationZone,
  });

  Color _getRankColor() {
    if (rank == 1) return const Color(0xFFFFD700); // 금
    if (rank == 2) return const Color(0xFFC0C0C0); // 은
    if (rank == 3) return const Color(0xFFCD7F32); // 동
    return AppColors.textSecondary;
  }

  IconData _getRankIcon() {
    if (rank == 1) return Icons.emoji_events;
    if (rank == 2) return Icons.emoji_events;
    if (rank == 3) return Icons.emoji_events;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: isMe ? AppDimensions.paddingS : 4,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isMe
              ? AppColors.primary
              : isPromotionZone
                  ? AppColors.success.withOpacity(0.3)
                  : isRelegationZone
                      ? AppColors.error.withOpacity(0.3)
                      : AppColors.borderLight,
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 순위
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? _getRankColor().withOpacity(0.2)
                  : AppColors.disabled.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      _getRankIcon(),
                      color: _getRankColor(),
                      size: 28,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppDimensions.spacingM),

          // 이름 및 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      participant.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isMe ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: const Text(
                          '나',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      participant.tier.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      participant.tier.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 주간 XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${participant.weeklyXP}',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isMe ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              Text(
                'XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // 승급/강등 표시
          if (isPromotionZone && !isMe) ...[
            const SizedBox(width: AppDimensions.spacingS),
            const Icon(
              Icons.arrow_upward,
              color: AppColors.success,
              size: 20,
            ),
          ] else if (isRelegationZone && !isMe) ...[
            const SizedBox(width: AppDimensions.spacingS),
            const Icon(
              Icons.arrow_downward,
              color: AppColors.error,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
