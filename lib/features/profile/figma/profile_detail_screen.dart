// Profile Detail Screen — Figma "03" 디자인
// 챌린지 진행률 + 레벨 + 캘린더를 한 화면에 표시
// 스크롤 없이 한 화면에 모든 정보 표시

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/effects/noise_texture.dart';
import '../edit_profile_screen.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
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
    final dates =
        await userNotifier.getStudyDatesForMonth(now.year, now.month);

    if (mounted) {
      setState(() {
        _studiedDays = dates;
        _isLoadingCalendar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Background gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.skyBlueGradient),
        ),
        const NoiseTexture(opacity: 0.025, color: Colors.white),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── 헤더: 프로필 + 레벨 ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: user.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.person_rounded,
                              size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? '사용자',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Lv.${user.level}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Settings / Edit button
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          '수정',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── 상태 뱃지 Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildStatusBadge(
                        Icons.local_fire_department_rounded,
                        '${user.streak}',
                        const Color(0xFFFF9600)),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                        Icons.bolt_rounded, '${user.xp}', Colors.white),
                    const SizedBox(width: 8),
                    _buildStatusBadge(Icons.diamond_rounded,
                        '${user.gems}', const Color(0xFF64B5F6)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 메인 콘텐츠 (흰색 카드) ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 챌린지 헤더
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '챌린지',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Text(
                              '${user.streak}/30',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 레벨 진행률
                        _buildLevelProgress(user),

                        const SizedBox(height: 12),

                        // 챌린지 Done / Remaining
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.local_fire_department_rounded,
                                iconColor: const Color(0xFFFF9600),
                                label: '완료',
                                value: '${user.streak}일',
                                bgColor:
                                    const Color(0xFFFF9600).withValues(alpha: 0.08),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.calendar_today_rounded,
                                iconColor: AppColors.skyBlue,
                                label: '남은 목표',
                                value: '${(30 - user.streak).clamp(0, 30)}일',
                                bgColor:
                                    AppColors.skyBlue.withValues(alpha: 0.08),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 캘린더
                        Expanded(child: _buildCalendar()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(IconData icon, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(UserModel user) {
    final league = user.league.toLowerCase();
    final leagueDisplay = league[0].toUpperCase() + league.substring(1);

    final thresholds = {
      'bronze': [0, 500],
      'silver': [500, 1100],
      'gold': [1100, 2500],
      'diamond': [2500, 5000],
      'master': [5000, 10000],
    };

    final t = thresholds[league] ?? [0, 500];
    final xpInTier = user.totalXp - t[0];
    final xpNeeded = t[1] - t[0];
    final progress = xpNeeded > 0 ? (xpInTier / xpNeeded).clamp(0.0, 1.0) : 1.0;
    final percent = (progress * 100).toInt();

    Color barColor;
    switch (league) {
      case 'gold':
        barColor = AppColors.gold;
        break;
      case 'silver':
        barColor = const Color(0xFF90A4AE);
        break;
      case 'diamond':
        barColor = const Color(0xFF42A5F5);
        break;
      case 'master':
        barColor = const Color(0xFF7E57C2);
        break;
      default:
        barColor = const Color(0xFFCD7F32);
    }

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              league[0].toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: barColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$leagueDisplay Lv${user.level}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: barColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = _displayMonth;
    final monthName = DateFormat('yyyy년 M월').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _displayMonth = DateTime(now.year, now.month - 1);
                      _isLoadingCalendar = true;
                    });
                    _loadStudyDates();
                  },
                  child: const Icon(Icons.chevron_left, size: 20),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _displayMonth = DateTime(now.year, now.month + 1);
                      _isLoadingCalendar = true;
                    });
                    _loadStudyDates();
                  },
                  child: const Icon(Icons.chevron_right, size: 20),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Day headers
        Row(
          children: ['월', '화', '수', '목', '금', '토', '일']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),

        // Date grid
        if (_isLoadingCalendar)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          Expanded(child: _buildDateGrid()),
      ],
    );
  }

  Widget _buildDateGrid() {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final firstDay = DateTime(year, month, 1);
    final totalDays = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;
    final today = DateTime.now();
    final isCurrentMonth = today.year == year && today.month == month;

    final totalCells = startOffset + totalDays;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return Expanded(
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > totalDays) {
                return const Expanded(child: SizedBox());
              }

              final isStudied = _studiedDays.contains(dayNum);
              final isToday = isCurrentMonth && dayNum == today.day;

              return Expanded(
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: isStudied
                        ? BoxDecoration(
                            color: AppColors.skyBlue,
                            borderRadius: BorderRadius.circular(10),
                          )
                        : isToday
                            ? BoxDecoration(
                                border: Border.all(
                                  color: AppColors.skyBlue,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isStudied || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isStudied
                            ? Colors.white
                            : isToday
                                ? AppColors.skyBlue
                                : const Color(0xFF333333),
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

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}
