import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/all_users_provider.dart';
import '../../data/providers/friend_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 사용자 검색 및 친구 추가 화면
///
/// 모든 앱 사용자를 검색하고 친구로 추가할 수 있습니다.
/// - 이름 검색
/// - 레벨별 필터
/// - 학년별 필터
/// - 추천 사용자 (같은 레벨/학년)
class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGrade;
  int? _minLevel;
  int? _maxLevel;
  bool _showActiveOnly = false;

  // 학년 옵션
  final List<String> _gradeOptions = ['초6', '중1', '중2', '중3', '고1', '고2', '고3'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final allUsers = ref.watch(allUsersProvider);
    final friends = ref.watch(friendsProvider);

    // 현재 사용자와 이미 친구인 사용자 제외
    final friendUserIds = friends
        .where((f) => f.status == FriendRequestStatus.accepted)
        .map((f) => f.userId)
        .toSet();

    // 검색 결과
    final searchResults = ref.read(allUsersProvider.notifier).search(
          nameQuery: _searchQuery.isEmpty ? null : _searchQuery,
          grade: _selectedGrade,
          minLevel: _minLevel,
          maxLevel: _maxLevel,
          activeOnly: _showActiveOnly,
        );

    // 현재 사용자와 친구 제외
    final filteredResults = searchResults.where((user) {
      return user.id != currentUser?.id && !friendUserIds.contains(user.id);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '친구 찾기',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 검색창
            _buildSearchBar(),

            // 필터 칩
            _buildFilterChips(),

            // 추천 사용자 섹션 (검색 전)
            if (_searchQuery.isEmpty &&
                _selectedGrade == null &&
                _minLevel == null &&
                _maxLevel == null &&
                !_showActiveOnly &&
                currentUser != null)
              _buildRecommendedSection(currentUser),

            // 검색 결과
            Expanded(
              child: _buildSearchResults(filteredResults),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색창
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: '이름으로 검색',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 활성 사용자만 보기
          FilterChip(
            label: Text('활성 사용자', style: TextStyle(fontSize: 13)),
            selected: _showActiveOnly,
            onSelected: (selected) {
              setState(() {
                _showActiveOnly = selected;
              });
            },
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),

          // 학년 필터
          PopupMenuButton<String>(
            child: Chip(
              label: Text(
                _selectedGrade ?? '학년',
                style: TextStyle(fontSize: 13),
              ),
              deleteIcon: _selectedGrade != null
                  ? Icon(Icons.close, size: 18)
                  : null,
              onDeleted: _selectedGrade != null
                  ? () {
                      setState(() {
                        _selectedGrade = null;
                      });
                    }
                  : null,
              backgroundColor: _selectedGrade != null
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surface,
            ),
            itemBuilder: (context) {
              return _gradeOptions.map((grade) {
                return PopupMenuItem(
                  value: grade,
                  child: Text(grade),
                );
              }).toList();
            },
            onSelected: (grade) {
              setState(() {
                _selectedGrade = grade;
              });
            },
          ),
          const SizedBox(width: 8),

          // 레벨 범위 필터
          InkWell(
            onTap: () => _showLevelRangeDialog(),
            child: Chip(
              label: Text(
                _minLevel != null || _maxLevel != null
                    ? '레벨 ${_minLevel ?? '?'}-${_maxLevel ?? '?'}'
                    : '레벨 범위',
                style: TextStyle(fontSize: 13),
              ),
              deleteIcon: _minLevel != null || _maxLevel != null
                  ? Icon(Icons.close, size: 18)
                  : null,
              onDeleted: _minLevel != null || _maxLevel != null
                  ? () {
                      setState(() {
                        _minLevel = null;
                        _maxLevel = null;
                      });
                    }
                  : null,
              backgroundColor: _minLevel != null || _maxLevel != null
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surface,
            ),
          ),
          const SizedBox(width: 8),

          // 필터 초기화
          if (_searchQuery.isNotEmpty ||
              _selectedGrade != null ||
              _minLevel != null ||
              _maxLevel != null ||
              _showActiveOnly)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedGrade = null;
                  _minLevel = null;
                  _maxLevel = null;
                  _showActiveOnly = false;
                });
              },
              icon: Icon(Icons.refresh, size: 18),
              label: Text('초기화', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }

  /// 추천 사용자 섹션
  Widget _buildRecommendedSection(User currentUser) {
    final recommendedByLevel = ref
        .read(allUsersProvider.notifier)
        .getRecommendedUsersByLevel(currentUser.level);

    final recommendedByGrade = ref
        .read(allUsersProvider.notifier)
        .getRecommendedUsersByGrade(currentUser.currentGrade);

    final friends = ref.watch(friendsProvider);
    final friendUserIds = friends
        .where((f) => f.status == FriendRequestStatus.accepted)
        .map((f) => f.userId)
        .toSet();

    // 현재 사용자와 친구 제외
    final levelRecommendations = recommendedByLevel.where((user) {
      return user.id != currentUser.id && !friendUserIds.contains(user.id);
    }).take(5).toList();

    final gradeRecommendations = recommendedByGrade.where((user) {
      return user.id != currentUser.id && !friendUserIds.contains(user.id);
    }).take(5).toList();

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (levelRecommendations.isNotEmpty) ...[
            Text(
              '비슷한 레벨의 친구 (레벨 ${currentUser.level})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...levelRecommendations.map((user) => _buildUserCard(user)),
            const SizedBox(height: 24),
          ],
          if (gradeRecommendations.isNotEmpty) ...[
            Text(
              '같은 학년 친구 (${currentUser.currentGrade})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...gradeRecommendations.map((user) => _buildUserCard(user)),
          ],
        ],
      ),
    );
  }

  /// 검색 결과
  Widget _buildSearchResults(List<User> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 검색어나 필터를 시도해보세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildUserCard(results[index]);
      },
    );
  }

  /// 사용자 카드
  Widget _buildUserCard(User user) {
    final friends = ref.watch(friendsProvider);
    final pendingRequest = friends.firstWhere(
      (f) => f.userId == user.id && f.status == FriendRequestStatus.pending,
      orElse: () => Friend(
        id: '',
        userId: '',
        name: '',
        level: 0,
        xp: 0,
        status: FriendRequestStatus.rejected,
        createdAt: DateTime.now(),
      ),
    );

    final hasPendingRequest = pendingRequest.id.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showUserProfile(user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아바타
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.avatarUrl,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 사용자 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '레벨 ${user.level}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.currentGrade,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (user.streakDays > 0) ...[
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${user.streakDays}일',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // 친구 추가 버튼
                if (hasPendingRequest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '대기중',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => _sendFriendRequest(user),
                    icon: Icon(
                      Icons.person_add,
                      color: AppColors.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 레벨 범위 선택 다이얼로그
  void _showLevelRangeDialog() {
    int tempMinLevel = _minLevel ?? 1;
    int tempMaxLevel = _maxLevel ?? 50;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('레벨 범위 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '최소 레벨',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: tempMinLevel.toString()),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 1) {
                          tempMinLevel = parsed;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '최대 레벨',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: tempMaxLevel.toString()),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= tempMinLevel) {
                          tempMaxLevel = parsed;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _minLevel = tempMinLevel;
                  _maxLevel = tempMaxLevel;
                });
                Navigator.pop(context);
              },
              child: const Text('적용'),
            ),
          ],
        ),
      ),
    );
  }

  /// 친구 요청 보내기
  Future<void> _sendFriendRequest(User user) async {
    await ref.read(friendsProvider.notifier).sendFriendRequest(
          userId: user.id,
          name: user.name,
          level: user.level,
          xp: user.xp,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name}님에게 친구 요청을 보냈습니다'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// 사용자 프로필 보기
  void _showUserProfile(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 프로필 정보
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.avatarUrl,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 통계
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow('레벨', '${user.level}', Icons.trending_up, AppColors.primary),
                  const SizedBox(height: 16),
                  _buildStatRow('XP', '${user.xp}', Icons.star, AppColors.warning),
                  const SizedBox(height: 16),
                  _buildStatRow('스트릭', '${user.streakDays}일', Icons.local_fire_department, AppColors.error),
                  const SizedBox(height: 16),
                  _buildStatRow('학년', user.currentGrade, Icons.school, AppColors.success),
                  const SizedBox(height: 16),
                  _buildStatRow('등급', user.userGrade, Icons.emoji_events, AppColors.accentCyan),
                ],
              ),
            ),
            const Spacer(),

            // 친구 추가 버튼
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendFriendRequest(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '친구 추가',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 행
  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
