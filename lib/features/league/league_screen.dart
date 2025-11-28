import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/league_provider.dart';
import '../../data/providers/friend_provider.dart';
import '../../data/providers/all_users_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/models.dart';
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
              icon: const Icon(Icons.arrow_back, color: AppColors.surface),
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
                            color: AppColors.surface,
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
                            color: AppColors.surface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          ),
                          child: Text(
                            '${state.myRank}위 / ${myLeagueInfo.totalPlayers}명',
                            style: const TextStyle(
                              color: AppColors.surface,
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
                            color: AppColors.surface,
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
                              color: AppColors.surface,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '남은 시간: $_remainingTime',
                              style: const TextStyle(
                                color: AppColors.surface,
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
                    ? AppColors.success.withValues(alpha: 0.1)
                    : myLeagueInfo.relegationRisk
                        ? AppColors.error.withValues(alpha: 0.1)
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
                boxShadow: [
                  BoxShadow(
                    color: (myLeagueInfo.canPromote
                            ? AppColors.success
                            : myLeagueInfo.relegationRisk
                                ? AppColors.error
                                : AppColors.borderLight)
                        .withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                          ? '상위 20% 안에 들었어요! 이대로 유지하면 승급할 수 있어요.'
                          : myLeagueInfo.relegationRisk
                              ? '하위 20%입니다. 조금만 더 열심히 하면 강등을 피할 수 있어요!'
                              : '열심히 학습해서 상위권에 진입하세요!',
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
class _ParticipantCard extends ConsumerWidget {
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
    if (rank == 1) return AppColors.mathYellow; // 금 (GoMath)
    if (rank == 2) return AppColors.levelSilver; // 은 (표준 메달 색상)
    if (rank == 3) return AppColors.levelBronze; // 동 (표준 메달 색상)
    return AppColors.textSecondary;
  }

  IconData _getRankIcon() {
    if (rank == 1) return Icons.emoji_events;
    if (rank == 2) return Icons.emoji_events;
    if (rank == 3) return Icons.emoji_events;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: isMe ? AppDimensions.paddingS : 4,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isMe
              ? AppColors.primary
              : isPromotionZone
                  ? AppColors.success.withValues(alpha: 0.3)
                  : isRelegationZone
                      ? AppColors.error.withValues(alpha: 0.3)
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
                  ? _getRankColor().withValues(alpha: 0.2)
                  : AppColors.disabled.withValues(alpha: 0.2),
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
                            color: AppColors.surface,
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

          // 친구 추가 버튼 (자기 자신이 아닌 경우만)
          if (!isMe) ...[
            const SizedBox(width: 8),
            _buildFriendButton(context, ref),
          ],

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

  /// 친구 추가 버튼
  Widget _buildFriendButton(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);

    // 이미 친구인지 확인
    final isFriend = friends.any(
      (f) => f.userId == participant.id && f.status == FriendRequestStatus.accepted,
    );

    // 대기 중인 요청이 있는지 확인
    final hasPendingRequest = friends.any(
      (f) => f.userId == participant.id && f.status == FriendRequestStatus.pending,
    );

    if (isFriend) {
      return const SizedBox.shrink();
    }

    if (hasPendingRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '대기중',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // 친구 추가 버튼
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () => _sendFriendRequest(context, ref),
        icon: Icon(Icons.person_add, color: AppColors.primary, size: 20),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        tooltip: '친구 추가',
      ),
    );
  }

  /// 친구 요청 보내기
  Future<void> _sendFriendRequest(BuildContext context, WidgetRef ref) async {
    try {
      // AllUsersProvider에서 실제 사용자 정보 가져오기
      final allUsers = ref.read(allUsersProvider);
      final targetUser = allUsers.firstWhere(
        (u) => u.id == participant.id,
        orElse: () => User(
          id: participant.id,
          name: participant.name,
          email: '${participant.id}@example.com',
          joinDate: DateTime.now(),
          level: 1,
          xp: participant.weeklyXP,
          streakDays: 0,
          currentGrade: '중1',
          avatarUrl: '👤',
          hearts: 5,
          dailyXP: 0,
          lastXPResetDate: DateTime.now(),
        ),
      );

      await ref.read(friendsProvider.notifier).sendFriendRequest(
        userId: targetUser.id,
        name: targetUser.name,
        level: targetUser.level,
        xp: targetUser.xp,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${targetUser.name}님에게 친구 요청을 보냈습니다'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('친구 요청을 보내는데 실패했습니다'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
