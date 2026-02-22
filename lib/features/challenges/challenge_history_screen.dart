// Challenge History Screen (Figma "03" Frame)
//
// Displays challenge progress, calendar view, and level info.
// Teal-green header with learning path nodes + white card body.
// All data is fetched from Firestore via providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/lesson/lesson_progress_model.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';

class ChallengeHistoryScreen extends ConsumerStatefulWidget {
  const ChallengeHistoryScreen({super.key});

  @override
  ConsumerState<ChallengeHistoryScreen> createState() =>
      _ChallengeHistoryScreenState();
}

class _ChallengeHistoryScreenState
    extends ConsumerState<ChallengeHistoryScreen> {
  Set<int> _studiedDays = {};
  DateTime _displayMonth = DateTime.now();
  bool _isLoadingCalendar = true;

  @override
  void initState() {
    super.initState();
    _loadStudyDates();
  }

  Future<void> _loadStudyDates() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;

    final userNotifier = ref.read(userProvider.notifier);
    final now = _displayMonth;
    final dates = await userNotifier.getStudyDatesForMonth(now.year, now.month);

    if (mounted) {
      setState(() {
        _studiedDays = dates;
        _isLoadingCalendar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);
    final uid = authState.firebaseUser?.uid;

    if (uid == null || user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progressState = ref.watch(lessonProgressProvider(uid));
    final curriculumAsync = ref.watch(curriculumProvider);

    return curriculumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('커리큘럼을 불러오는데 실패했습니다'),
      ),
      data: (allUnits) {
        final totalLessons =
            allUnits.fold<int>(0, (sum, u) => sum + u.lessonCount);
        final completedLessons = progressState.completedCount;

        // 현재 활성 유닛 찾기
        String activeUnitTitle = allUnits.first.title;
        int activeUnitOrder = 1;
        for (final unit in allUnits) {
          for (final lesson in unit.lessons) {
            final lp = progressState.progressMap[lesson.id];
            if (lp != null && lp.status == LessonStatus.inProgress) {
              activeUnitTitle = unit.title;
              activeUnitOrder = unit.order;
              break;
            }
          }
        }

        // 현재 유닛의 레슨 노드 상태 계산
        final activeUnit = allUnits.firstWhere(
          (u) => u.order == activeUnitOrder,
          orElse: () => allUnits.first,
        );

        return Container(
          color: const Color(0xFFFAFAFA),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildHeader(
                    unitOrder: activeUnitOrder,
                    unitTitle: activeUnitTitle,
                    lessons: activeUnit.lessons,
                    progressMap: progressState.progressMap,
                  ),
                  _buildWhiteCardSection(
                    user: user,
                    completedLessons: completedLessons,
                    totalLessons: totalLessons,
                    activeUnitTitle: activeUnitTitle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Header: teal-green background with learning path nodes
  // ---------------------------------------------------------------------------
  Widget _buildHeader({
    required int unitOrder,
    required String unitTitle,
    required List lessons,
    required Map<String, LessonProgressModel> progressMap,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.tealGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20, vertical: AppDimensions.spacing24),
      child: Column(
        children: [
          Text(
            'UNIT $unitOrder',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            unitTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing20),
          _buildPathNodes(lessons, progressMap),
        ],
      ),
    );
  }

  Widget _buildPathNodes(
    List lessons,
    Map<String, LessonProgressModel> progressMap,
  ) {
    final nodes = <_NodeState>[];
    bool foundActive = false;

    for (final lesson in lessons) {
      final progress = progressMap[lesson.id];
      if (progress == null || progress.status == LessonStatus.locked) {
        nodes.add(_NodeState.locked);
      } else if (progress.status == LessonStatus.completed) {
        nodes.add(_NodeState.completed);
      } else {
        // inProgress or unlocked → active
        if (!foundActive) {
          nodes.add(_NodeState.active);
          foundActive = true;
        } else {
          nodes.add(_NodeState.locked);
        }
      }
    }

    // 노드가 없으면 기본값
    if (nodes.isEmpty) {
      nodes.addAll([_NodeState.active, _NodeState.locked, _NodeState.locked]);
    }

    // 활성 노드가 없으면 첫 번째 미완료 노드를 활성으로
    if (!foundActive && nodes.isNotEmpty) {
      final firstNonCompleted =
          nodes.indexWhere((n) => n != _NodeState.completed);
      if (firstNonCompleted >= 0) {
        nodes[firstNonCompleted] = _NodeState.active;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(nodes.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftState = nodes[i ~/ 2];
          final isCompleted = leftState == _NodeState.completed;
          return Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.white : AppColors.nodeLockedBg,
              borderRadius: BorderRadius.circular(AppDimensions.spacing2),
            ),
          );
        }
        return _buildSingleNode(nodes[i ~/ 2]);
      }),
    );
  }

  Widget _buildSingleNode(_NodeState state) {
    const double size = 28;

    switch (state) {
      case _NodeState.completed:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.check, size: 16, color: AppColors.tealGreen),
        );
      case _NodeState.active:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              const Icon(Icons.star, size: 16, color: AppColors.tealGreen),
        );
      case _NodeState.locked:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.nodeLockedBg,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock, size: 14, color: Colors.grey.shade500),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // White card body
  // ---------------------------------------------------------------------------
  Widget _buildWhiteCardSection({
    required dynamic user,
    required int completedLessons,
    required int totalLessons,
    required String activeUnitTitle,
  }) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius24)),
        ),
        padding: const EdgeInsets.fromLTRB(AppDimensions.spacing20, 28, AppDimensions.spacing20, AppDimensions.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '챌린지',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            _buildStatCardsRow(
              completedLessons: completedLessons,
              totalLessons: totalLessons,
              streak: user.streak,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            _buildCalendarSection(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildLevelProgress(user),
            const SizedBox(height: AppDimensions.spacing24),
            _buildSubjectInfo(
              unitTitle: activeUnitTitle,
              streak: user.streak,
              xp: user.totalXp,
              league: user.league,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stat cards
  // ---------------------------------------------------------------------------
  Widget _buildStatCardsRow({
    required int completedLessons,
    required int totalLessons,
    required int streak,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildChallengeDoneCard(completedLessons, totalLessons),
        ),
        const SizedBox(width: AppDimensions.spacing12),
        Expanded(
          child: _buildRemainingCard(completedLessons, totalLessons, streak),
        ),
      ],
    );
  }

  Widget _buildChallengeDoneCard(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 18,
                  color: AppColors.gold,
                ),
              ),
              const Spacer(),
              Text(
                'Challenge Done',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            '$completed/$total',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$percent% completed',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingCard(int completed, int total, int streak) {
    final remaining = total - completed;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.tealGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.tealGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: AppColors.tealGreen,
                ),
              ),
              const Spacer(),
              Text(
                'Remaining',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$streak ',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                TextSpan(
                  text: 'Days',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            '/ $total Lessons',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$remaining lessons left',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.tealGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Calendar section
  // ---------------------------------------------------------------------------
  Widget _buildCalendarSection() {
    final now = _displayMonth;
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _displayMonth = DateTime(now.year, now.month - 1);
                      _isLoadingCalendar = true;
                    });
                    _loadStudyDates();
                  },
                  icon: const Icon(Icons.chevron_left, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppDimensions.spacing4),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _displayMonth = DateTime(now.year, now.month + 1);
                      _isLoadingCalendar = true;
                    });
                    _loadStudyDates();
                  },
                  icon: const Icon(Icons.chevron_right, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppDimensions.spacing4),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing12),
        _buildDayHeaders(),
        const SizedBox(height: AppDimensions.spacing8),
        _isLoadingCalendar
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing20),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _buildDateGrid(),
      ],
    );
  }

  Widget _buildDayHeaders() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateGrid() {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final firstDay = DateTime(year, month, 1);
    final totalDays = DateTime(year, month + 1, 0).day;

    // Monday = 1, Sunday = 7 → offset = (weekday - 1)
    final startOffset = firstDay.weekday - 1;
    final today = DateTime.now();
    final isCurrentMonth = today.year == year && today.month == month;

    final totalCells = startOffset + totalDays;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > totalDays) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final isStudied = _studiedDays.contains(dayNum);
              final isToday = isCurrentMonth && dayNum == today.day;

              return Expanded(
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: isStudied
                        ? BoxDecoration(
                            color: _studiedDayColor(dayNum),
                            borderRadius: BorderRadius.circular(10),
                          )
                        : isToday
                            ? BoxDecoration(
                                border: Border.all(
                                  color: AppColors.tealGreen,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: isStudied || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isStudied
                            ? Colors.white
                            : isToday
                                ? AppColors.tealGreen
                                : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Color _studiedDayColor(int day) {
    // 주별로 다른 색상
    if (day <= 7) return AppColors.tealGreen;
    if (day <= 14) return AppColors.skyBlue;
    if (day <= 21) return AppColors.gold;
    return AppColors.tealGreen;
  }

  // ---------------------------------------------------------------------------
  // Level progress
  // ---------------------------------------------------------------------------
  Widget _buildLevelProgress(dynamic user) {
    final league = (user.league as String).toLowerCase();
    final totalXp = user.totalXp as int;

    // 리그별 XP 임계값
    final leagueThresholds = {
      'bronze': {'xp': 0, 'next': 'Silver', 'nextXp': 500},
      'silver': {'xp': 500, 'next': 'Gold', 'nextXp': 1100},
      'gold': {'xp': 1100, 'next': 'Diamond', 'nextXp': 2500},
      'diamond': {'xp': 2500, 'next': 'Master', 'nextXp': 5000},
      'master': {'xp': 5000, 'next': 'Master', 'nextXp': 10000},
    };

    final current = leagueThresholds[league] ?? leagueThresholds['bronze']!;
    final currentXpBase = current['xp'] as int;
    final nextXp = current['nextXp'] as int;
    final nextLeague = current['next'] as String;

    final xpInTier = totalXp - currentXpBase;
    final xpNeeded = nextXp - currentXpBase;
    final progress = xpNeeded > 0 ? (xpInTier / xpNeeded).clamp(0.0, 1.0) : 1.0;
    final percent = (progress * 100).toInt();

    final leagueDisplay = league[0].toUpperCase() + league.substring(1);
    final badgeLetter = league[0].toUpperCase();

    // 리그별 그라디언트
    LinearGradient badgeGradient;
    Color progressColor;
    switch (league) {
      case 'gold':
        badgeGradient = AppColors.goldGradient;
        progressColor = AppColors.gold;
        break;
      case 'silver':
        badgeGradient = const LinearGradient(
          colors: [Color(0xFF90A4AE), Color(0xFFB0BEC5)],
        );
        progressColor = const Color(0xFF90A4AE);
        break;
      case 'diamond':
        badgeGradient = const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
        );
        progressColor = const Color(0xFF42A5F5);
        break;
      case 'master':
        badgeGradient = const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
        );
        progressColor = const Color(0xFF7E57C2);
        break;
      default: // bronze
        badgeGradient = const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFDDA15E)],
        );
        progressColor = const Color(0xFFCD7F32);
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: badgeGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            alignment: Alignment.center,
            child: Text(
              badgeLetter,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$leagueDisplay Rank',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.nodeLockedBg,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  '$totalXp / $nextXp XP to $nextLeague',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Subject info row
  // ---------------------------------------------------------------------------
  Widget _buildSubjectInfo({
    required String unitTitle,
    required int streak,
    required int xp,
    required String league,
  }) {
    // RankModel shortName 대신 간단하게 리그 약어 표시
    final leagueLower = league.toLowerCase();
    String rankShort;
    switch (leagueLower) {
      case 'bronze':
        rankShort = 'ALv1';
        break;
      case 'silver':
        rankShort = 'ALv2';
        break;
      case 'gold':
        rankShort = 'HLv1';
        break;
      case 'diamond':
        rankShort = 'HLv2';
        break;
      case 'master':
        rankShort = 'GTLv1';
        break;
      default:
        rankShort = 'ALv1';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tealGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
            child: Text(
              unitTitle,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.tealGreen,
              ),
            ),
          ),
          const Spacer(),
          _buildInfoPill(
              Icons.local_fire_department, '$streak', AppColors.streakGold),
          const SizedBox(width: 10),
          _buildInfoPill(Icons.bolt, '$xp', AppColors.skyBlue),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
            child: Text(
              rankShort,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal node-state enum for the header path visualisation
// ---------------------------------------------------------------------------
enum _NodeState { completed, active, locked }
