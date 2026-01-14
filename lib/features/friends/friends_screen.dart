import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/user/friend_provider.dart';
import '../../data/providers/communication/chat_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/utils/level_badge_mapper.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../chat/chat_detail_screen.dart';
import 'friend_profile_screen.dart';
import 'user_search_screen.dart';

/// 친구 목록 화면
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);
    final notifier = ref.read(friendsProvider.notifier);

    final acceptedFriends = notifier.acceptedFriends;
    final pendingRequests = notifier.pendingRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            const AdaptiveAppHeader(
              title: '친구',
            ),

            // 친구 목록
            Expanded(
              child: friends.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => notifier.refresh(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // 대기 중인 친구 요청
                          if (pendingRequests.isNotEmpty) ...[
                            _buildSectionHeader(
                                '친구 요청', pendingRequests.length),
                            ...pendingRequests.map((friend) {
                              return _buildPendingRequestItem(
                                  context, ref, friend);
                            }),
                            const SizedBox(height: 16),
                          ],

                          // 친구 목록
                          if (acceptedFriends.isNotEmpty) ...[
                            _buildSectionHeader('내 친구', acceptedFriends.length),
                            ...acceptedFriends.map((friend) {
                              return _buildFriendItem(context, ref, friend);
                            }),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFriendDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          '친구 추가',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 친구 아이템
  Widget _buildFriendItem(BuildContext context, WidgetRef ref, Friend friend) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () => _showFriendActions(context, ref, friend),
        leading: CircleAvatar(
          backgroundColor: AppColors.accentCyan.withValues(alpha: 0.1),
          child: Text(
            friend.name[0].toUpperCase(),
            style: TextStyle(
              color: AppColors.accentCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            // 레벨 배지
            Image.asset(
              LevelBadgeMapper.getBadgeImagePath(friend.level),
              width: 18,
              height: 18,
              errorBuilder: (context, error, stackTrace) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium,
                        size: 14, color: AppColors.mathGold),
                    const SizedBox(width: 4),
                    Text(
                      'Lv.${friend.level}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 12),
            Icon(Icons.star, size: 14, color: AppColors.mathYellow),
            const SizedBox(width: 4),
            Text(
              '${friend.xp} XP',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 대기 중인 친구 요청 아이템
  Widget _buildPendingRequestItem(
    BuildContext context,
    WidgetRef ref,
    Friend friend,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            friend.name[0].toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '친구 요청을 보냈습니다',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle, color: AppColors.success),
              onPressed: () async {
                await ref
                    .read(friendsProvider.notifier)
                    .acceptFriendRequest(friend.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${friend.name}님과 친구가 되었습니다!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: AppColors.error),
              onPressed: () async {
                await ref
                    .read(friendsProvider.notifier)
                    .rejectFriendRequest(friend.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('친구 요청을 거절했습니다')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '친구가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '친구를 추가해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 친구 추가 - 사용자 검색 화면으로 이동
  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    );
  }

  /// 친구 액션 보텀시트
  void _showFriendActions(BuildContext context, WidgetRef ref, Friend friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.chat, color: AppColors.primary),
              title: const Text('1:1 대화 시작'),
              onTap: () async {
                Navigator.pop(context);

                // 1:1 채팅방 생성
                final now = DateTime.now();
                final newRoom = ChatRoom(
                  id: 'room_${now.millisecondsSinceEpoch}',
                  name: friend.name,
                  type: ChatRoomType.direct,
                  participantIds: ['user', friend.userId],
                  createdAt: now,
                  updatedAt: now,
                );

                await ref
                    .read(chatRoomsProvider.notifier)
                    .createChatRoom(newRoom);

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(chatRoom: newRoom),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: AppColors.accentCyan),
              title: const Text('프로필 보기'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendProfileScreen(friend: friend),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_remove, color: AppColors.error),
              title: const Text('친구 삭제'),
              onTap: () async {
                Navigator.pop(context);

                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('친구 삭제'),
                    content: Text('${friend.name}님을 친구 목록에서 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  await ref
                      .read(friendsProvider.notifier)
                      .removeFriend(friend.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${friend.name}님을 친구 목록에서 삭제했습니다')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
