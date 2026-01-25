/// 📊 Friend Activity Tab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/providers/friend/friend_provider.dart';

class FriendActivityTab extends ConsumerWidget {
  final String userId;

  const FriendActivityTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendState = ref.watch(friendProvider(userId));

    if (friendState.friendActivities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('친구 활동 내역이 없습니다', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(friendProvider(userId).notifier)
            .loadFriendActivities();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friendState.friendActivities.length,
        itemBuilder: (context, index) {
          final activity = friendState.friendActivities[index];
          return _ActivityCard(activity: activity);
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final FriendActivityModel activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: activity.userAvatar != null
              ? NetworkImage(activity.userAvatar!)
              : null,
          child:
              activity.userAvatar == null ? Text(activity.userName[0]) : null,
        ),
        title: Row(
          children: [
            Text(activity.activityIcon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: activity.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: activity.description),
                  ],
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(activity.getTimeAgo(),
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ),
    );
  }
}
