// 👥 Friend List Tab
//
// Shows the list of friends

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/friend_model.dart';
import '../../data/providers/friend/friend_provider.dart';
import '../../shared/widgets/common/empty_state_view.dart';
import 'friend_search_screen.dart';

class FriendListTab extends ConsumerWidget {
  final String userId;

  const FriendListTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendState = ref.watch(friendProvider(userId));

    if (friendState.friends.isEmpty) {
      return EmptyStateView(
        icon: Icons.people_outline_rounded,
        title: '아직 친구가 없어요',
        subtitle: '친구를 추가하면 함께 진도를 비교하고\n서로 응원할 수 있어요.',
        actionLabel: '친구 찾아보기',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const FriendSearchScreen(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(friendProvider(userId).notifier).loadFriends();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friendState.friends.length,
        itemBuilder: (context, index) {
          final friend = friendState.friends[index];
          return _FriendCard(friend: friend, userId: userId);
        },
      ),
    );
  }
}

class _FriendCard extends ConsumerWidget {
  final FriendModel friend;
  final String userId;

  const _FriendCard({required this.friend, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: friend.friendAvatar != null
              ? NetworkImage(friend.friendAvatar!)
              : null,
          child: friend.friendAvatar == null
              ? Text(friend.friendName[0])
              : null,
        ),
        title: Text(friend.friendName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(friend.statusLabel),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'remove') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('친구 삭제'),
                  content: Text('${friend.friendName}님을 친구 목록에서 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(friendProvider(userId).notifier)
                    .removeFriend(friend.friendId);
              }
            } else if (value == 'block') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('친구 차단'),
                  content: Text('${friend.friendName}님을 차단하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('차단'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(friendProvider(userId).notifier)
                    .blockFriend(friend.friendId);
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'remove', child: Text('친구 삭제')),
            const PopupMenuItem(
                value: 'block',
                child: Text('차단', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
