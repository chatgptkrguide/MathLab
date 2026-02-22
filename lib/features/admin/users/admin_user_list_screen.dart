import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/providers/admin/admin_user_provider.dart';
import 'admin_user_detail_screen.dart';

class AdminUserListScreen extends ConsumerStatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  ConsumerState<AdminUserListScreen> createState() =>
      _AdminUserListScreenState();
}

class _AdminUserListScreenState extends ConsumerState<AdminUserListScreen> {
  String _searchQuery = '';
  String _roleFilter = '전체'; // '전체', 'admin', 'user'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Role filter
      if (_roleFilter != '전체' && user.role != _roleFilter) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch =
            user.displayName?.toLowerCase().contains(query) ?? false;
        final emailMatch = user.email?.toLowerCase().contains(query) ?? false;
        return nameMatch || emailMatch;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUserListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '사용자 관리',
              gradientColors: AppColors.adminGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.headerText, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimensions.spacing16, AppDimensions.spacing12, AppDimensions.spacing16, AppDimensions.spacing4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '이름 또는 이메일로 검색',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16, vertical: AppDimensions.spacing12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            // Role filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimensions.spacing16, AppDimensions.spacing4, AppDimensions.spacing16, AppDimensions.spacing8),
              child: Row(
                children: [
                  _buildFilterChip('전체'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildFilterChip('admin'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildFilterChip('user'),
                ],
              ),
            ),
            // User list
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  final filtered = _filterUsers(users);
                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildUserList(filtered);
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('사용자 목록을 불러올 수 없습니다',
                          style: TextStyle(color: AppColors.error)),
                      const SizedBox(height: AppDimensions.spacing16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(adminUserListProvider.notifier).refresh(),
                        child: const Text('다시 시도'),
                      ),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _roleFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _roleFilter = label;
        });
      },
      selectedColor: AppColors.adminPurple.withValues(alpha: 0.15),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.adminPurple : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.adminPurple : AppColors.borderLight,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius20)),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminUserListProvider.notifier).refresh();
      },
      child: ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(Icons.people_outline, size: 64,
                    color: AppColors.textTertiary),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  '사용자가 없습니다',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                const Text(
                  '검색 조건을 변경해 보세요',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    final hasMore = ref.read(adminUserListProvider.notifier).hasMore;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminUserListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        itemCount: users.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            // Load more button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
              child: Center(
                child: OutlinedButton(
                  onPressed: () =>
                      ref.read(adminUserListProvider.notifier).loadMore(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.adminPurple,
                    side: const BorderSide(color: AppColors.adminPurple),
                  ),
                  child: const Text('더 보기'),
                ),
              ),
            );
          }
          final user = users[index];
          return _AdminUserCard(
            user: user,
            onTap: () => _navigateToDetail(user),
          );
        },
      ),
    );
  }

  Future<void> _navigateToDetail(UserModel user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUserDetailScreen(user: user),
      ),
    );
    if (result == true) {
      ref.read(adminUserListProvider.notifier).refresh();
    }
  }
}

class _AdminUserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _AdminUserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (user.displayName?.isNotEmpty == true)
        ? user.displayName![0].toUpperCase()
        : '?';
    final isAdmin = user.role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    isAdmin ? AppColors.adminPurple : AppColors.mathBlue,
                child: Text(
                  initial,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? '이름 없음',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacing2),
                    Text(
                      user.email ?? '이메일 없음',
                      style: AppTextStyles.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              // Level badge
              _buildChip('Lv.${user.level}', AppColors.mathOrange),
              const SizedBox(width: 6),
              // Role badge
              _buildChip(
                isAdmin ? 'admin' : 'user',
                isAdmin ? AppColors.adminPurple : AppColors.mathBlue,
              ),
              const SizedBox(width: AppDimensions.spacing4),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
            color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
