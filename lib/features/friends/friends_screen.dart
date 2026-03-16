// 👥 Friends Screen
//
// Main friends screen with tabs for friends list, requests, and activity feed

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/friend/friend_provider.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../shared/widgets/loading_overlay.dart';
import 'friend_list_tab.dart';
import 'friend_requests_tab.dart';
import 'friend_activity_tab.dart';
import 'friend_search_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final firebaseUser = authState.firebaseUser;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    final friendState = ref.watch(friendProvider(firebaseUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendSearchScreen(),
                ),
              );
            },
            tooltip: '친구 찾기',
          ),
          // Pending requests badge
          if (friendState.pendingRequestCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${friendState.pendingRequestCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: '친구 (${friendState.friendCount})',
              icon: const Icon(Icons.people),
            ),
            Tab(
              text: '요청',
              icon: friendState.pendingRequestCount > 0
                  ? Badge(
                      label: Text('${friendState.pendingRequestCount}'),
                      child: const Icon(Icons.person_add),
                    )
                  : const Icon(Icons.person_add),
            ),
            const Tab(
              text: '활동',
              icon: Icon(Icons.timeline),
            ),
          ],
        ),
      ),
      body: friendState.isLoading
          ? const LoadingOverlay(message: '친구 목록을 불러오는 중...')
          : TabBarView(
              controller: _tabController,
              children: [
                FriendListTab(userId: firebaseUser.uid),
                FriendRequestsTab(userId: firebaseUser.uid),
                FriendActivityTab(userId: firebaseUser.uid),
              ],
            ),
    );
  }
}
