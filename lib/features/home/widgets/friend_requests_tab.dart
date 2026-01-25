/// 📨 Friend Requests Tab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/providers/friend/friend_provider.dart';

class FriendRequestsTab extends ConsumerWidget {
  final String userId;

  const FriendRequestsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendState = ref.watch(friendProvider(userId));

    if (friendState.pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('받은 친구 요청이 없습니다', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friendState.pendingRequests.length,
      itemBuilder: (context, index) {
        final request = friendState.pendingRequests[index];
        return _RequestCard(request: request, userId: userId);
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final FriendRequestModel request;
  final String userId;

  const _RequestCard({required this.request, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: request.fromUserAvatar != null
                  ? NetworkImage(request.fromUserAvatar!)
                  : null,
              child: request.fromUserAvatar == null
                  ? Text(request.fromUserName[0])
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.fromUserName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(request.getTimeAgo(),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    await ref
                        .read(friendProvider(userId).notifier)
                        .acceptFriendRequest(request.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${request.fromUserName}님과 친구가 되었습니다')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    await ref
                        .read(friendProvider(userId).notifier)
                        .rejectFriendRequest(request.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
