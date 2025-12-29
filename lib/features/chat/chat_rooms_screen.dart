import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/communication/chat_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import 'chat_detail_screen.dart';

/// 채팅방 목록 화면
class ChatRoomsScreen extends ConsumerWidget {
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            const AdaptiveAppHeader(
              title: '메시지',
            ),

            // 채팅방 목록
            Expanded(
              child: chatRooms.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final room = chatRooms[index];
                        return _buildChatRoomItem(context, ref, room);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewChatDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '새 대화',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 채팅방 아이템
  Widget _buildChatRoomItem(
    BuildContext context,
    WidgetRef ref,
    ChatRoom room,
  ) {
    return ListTile(
      onTap: () {
        // 읽음 처리
        ref.read(chatRoomsProvider.notifier).markAsRead(room.id);

        // 채팅 상세 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chatRoom: room),
          ),
        );
      },
      leading: _buildAvatar(room),
      title: Text(
        room.name,
        style: TextStyle(
          fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: room.lastMessage != null
          ? Text(
              room.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: room.unreadCount > 0
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight:
                    room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageTime != null)
            Text(
              _formatTime(room.lastMessageTime!),
              style: TextStyle(
                fontSize: 12,
                color: room.unreadCount > 0
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          if (room.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 아바타
  Widget _buildAvatar(ChatRoom room) {
    IconData icon;
    Color color;

    switch (room.type) {
      case ChatRoomType.assistant:
        icon = Icons.smart_toy;
        color = AppColors.primary;
        break;
      case ChatRoomType.group:
        icon = Icons.group;
        color = AppColors.mathPurple;
        break;
      case ChatRoomType.direct:
        icon = Icons.person;
        color = AppColors.accentCyan;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '채팅방이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새 대화를 시작해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금';
    }
  }

  /// 새 채팅 다이얼로그
  void _showNewChatDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    ChatRoomType selectedType = ChatRoomType.direct;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('새 대화 시작'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '대화 이름',
                  hintText: '예: 친구와의 대화',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '대화 유형',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ChatRoomType>(
                value: selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ChatRoomType.direct,
                    child: Text('1:1 대화'),
                  ),
                  DropdownMenuItem(
                    value: ChatRoomType.group,
                    child: Text('그룹 채팅'),
                  ),
                  DropdownMenuItem(
                    value: ChatRoomType.assistant,
                    child: Text('학습 도우미'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('대화 이름을 입력해주세요')),
                  );
                  return;
                }

                final now = DateTime.now();
                final newRoom = ChatRoom(
                  id: 'room_${now.millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  type: selectedType,
                  participantIds: ['user'],
                  createdAt: now,
                  updatedAt: now,
                );

                await ref.read(chatRoomsProvider.notifier).createChatRoom(newRoom);

                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(chatRoom: newRoom),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                '시작',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
