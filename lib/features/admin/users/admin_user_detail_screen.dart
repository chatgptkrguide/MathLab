import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/providers/admin/admin_user_provider.dart';

class AdminUserDetailScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  ConsumerState<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState
    extends ConsumerState<AdminUserDetailScreen> {
  late String _currentRole;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.user.role;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanges) {
          // Changes were already saved, result will be handled by Navigator.pop
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              AdaptiveAppHeader(
                title: user.displayName ?? '사용자 상세',
                gradientColors: AppColors.adminGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                titleAlignment: MainAxisAlignment.spaceBetween,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.headerText, size: 28),
                  onPressed: () =>
                      Navigator.of(context).pop(_hasChanges ? true : null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile header
                      _buildProfileHeader(user),
                      const SizedBox(height: 20),
                      // Info sections
                      _buildInfoSection('기본 정보', [
                        _buildInfoRow(
                            Icons.email_outlined, '이메일', user.email ?? '-'),
                        _buildInfoRow(Icons.badge_outlined, '역할',
                            _currentRole == 'admin' ? '관리자' : '일반 사용자'),
                        _buildInfoRow(Icons.calendar_today_outlined, '가입일',
                            _formatDate(user.createdAt)),
                        _buildInfoRow(Icons.update_outlined, '최종 수정',
                            _formatDate(user.updatedAt)),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('학습 정보', [
                        _buildInfoRow(Icons.trending_up_outlined, '레벨',
                            'Lv.${user.level}'),
                        _buildInfoRow(
                            Icons.star_outlined, 'XP', '${user.xp}'),
                        _buildInfoRow(Icons.star_border_outlined, '총 XP',
                            '${user.totalXp}'),
                        _buildInfoRow(Icons.local_fire_department_outlined,
                            '스트릭', '${user.streak}일'),
                      ]),
                      const SizedBox(height: 16),
                      _buildInfoSection('게이미피케이션', [
                        _buildInfoRow(Icons.favorite_outlined, '하트',
                            '${user.hearts} / ${user.maxHearts}'),
                        _buildInfoRow(Icons.diamond_outlined, '보석',
                            '${user.gems}'),
                        _buildInfoRow(
                            Icons.emoji_events_outlined, '리그', user.league),
                      ]),
                      const SizedBox(height: 24),
                      // Role toggle section
                      _buildRoleToggleSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final initial = (user.displayName?.isNotEmpty == true)
        ? user.displayName![0].toUpperCase()
        : '?';
    final isAdmin = _currentRole == 'admin';

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor:
              isAdmin ? AppColors.adminPurple : AppColors.mathBlue,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName ?? '이름 없음',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '이메일 없음',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: (isAdmin ? AppColors.adminPurple : AppColors.mathBlue)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isAdmin ? 'ADMIN' : 'USER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  isAdmin ? AppColors.adminPurple : AppColors.mathBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...rows,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleToggleSection() {
    final isAdmin = _currentRole == 'admin';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '역할 변경',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '사용자의 역할을 변경합니다. 관리자 권한을 부여하면 관리자 패널에 접근할 수 있습니다.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRoleButton(
                  label: '일반 사용자',
                  icon: Icons.person_outline,
                  isSelected: !isAdmin,
                  color: AppColors.mathBlue,
                  onTap: () {
                    if (isAdmin) {
                      _confirmRoleChange('user');
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRoleButton(
                  label: '관리자',
                  icon: Icons.admin_panel_settings_outlined,
                  isSelected: isAdmin,
                  color: AppColors.adminPurple,
                  onTap: () {
                    if (!isAdmin) {
                      _confirmRoleChange('admin');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? color : AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRoleChange(String newRole) async {
    final roleName = newRole == 'admin' ? '관리자' : '일반 사용자';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('역할 변경'),
        content: Text(
          '${widget.user.displayName ?? '이 사용자'}의 역할을 "$roleName"(으)로 변경하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.adminPurple,
            ),
            child: const Text('변경'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(adminUserNotifierProvider.notifier)
            .updateUserRole(widget.user.uid, newRole);
        ref.read(adminUserListProvider.notifier).refresh();
        setState(() {
          _currentRole = newRole;
          _hasChanges = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('역할이 "$roleName"(으)로 변경되었습니다'),
              backgroundColor: AppColors.mathGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('역할 변경 실패: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
