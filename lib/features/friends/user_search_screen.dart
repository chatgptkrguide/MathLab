import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/user/all_users_provider.dart';
import '../../data/providers/user/friend_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import 'widgets/user_search_card.dart';
import 'widgets/user_profile_bottom_sheet.dart';

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
            ...levelRecommendations.map(
              (user) => UserSearchCard(
                user: user,
                onTap: () => _showUserProfile(user),
                onAddFriend: () => _sendFriendRequest(user),
              ),
            ),
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
            ...gradeRecommendations.map(
              (user) => UserSearchCard(
                user: user,
                onTap: () => _showUserProfile(user),
                onAddFriend: () => _sendFriendRequest(user),
              ),
            ),
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
        final user = results[index];
        return UserSearchCard(
          user: user,
          onTap: () => _showUserProfile(user),
          onAddFriend: () => _sendFriendRequest(user),
        );
      },
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
      builder: (context) => UserProfileBottomSheet(
        user: user,
        onAddFriend: () => _sendFriendRequest(user),
      ),
    );
  }

}
