// 🔍 Friend Search Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/friend/friend_provider.dart';
import '../../../data/providers/auth/auth_handler.dart';

class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() =>
      _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final user = ref.read(authHandlerProvider).user;
    if (user != null) {
      final results = await ref
          .read(friendProvider(user.id).notifier)
          .searchUsers(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authHandlerProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다')));
    }

    final friendState = ref.watch(friendProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('친구 찾기')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '이름으로 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text('검색 결과가 없습니다', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      final resultId = result['id'] as String;
                      final isFriend = friendState.isFriend(resultId);
                      final hasRequestSent =
                          friendState.hasRequestSent(resultId);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: result['photoUrl'] != null
                              ? NetworkImage(result['photoUrl'] as String)
                              : null,
                          child: result['photoUrl'] == null
                              ? Text((result['name'] as String)[0])
                              : null,
                        ),
                        title: Text(result['name'] as String),
                        subtitle: Text(result['email'] as String? ?? ''),
                        trailing: isFriend
                            ? const Chip(label: Text('친구'))
                            : hasRequestSent
                                ? const Chip(label: Text('요청 전송됨'))
                                : ElevatedButton.icon(
                                    icon: const Icon(Icons.person_add,
                                        size: 18),
                                    label: const Text('친구 추가'),
                                    onPressed: () async {
                                      await ref
                                          .read(friendProvider(user.id).notifier)
                                          .sendFriendRequest(resultId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('${result['name']}님에게 친구 요청을 보냈습니다')),
                                        );
                                      }
                                    },
                                  ),
                      );
                    },
                  ),
          ),
          // Friend suggestions
          ref.watch(friendSuggestionsProvider(user.id)).when(
                data: (suggestions) {
                  if (suggestions.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('추천 친구',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = suggestions[index];
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          suggestion['photoUrl'] != null
                                              ? NetworkImage(
                                                  suggestion['photoUrl']
                                                      as String)
                                              : null,
                                      child: suggestion['photoUrl'] == null
                                          ? Text(
                                              (suggestion['name'] as String)[0])
                                          : null,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      suggestion['name'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
        ],
      ),
    );
  }
}
