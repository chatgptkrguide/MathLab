import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/communication/chat_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 채팅 상세 화면
class ChatDetailScreen extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 메시지 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatMessagesProvider(widget.chatRoom.id).notifier)
          .markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.chatRoom.id));
    final user = ref.watch(userProvider);

    // 메시지가 로드되면 스크롤을 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: widget.chatRoom.name,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showChatOptions(context),
                ),
              ],
            ),

            // 메시지 목록
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == (user?.id ?? 'user');
                        return _buildMessageBubble(message, isMe);
                      },
                    ),
            ),

            // 메시지 입력
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /// 메시지 버블
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 발신자 이름 (상대방 메시지만)
            if (!isMe) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // 메시지 내용
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

            // 시간
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                _formatMessageTime(message.sentAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메시지 입력 영역
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 텍스트 입력 필드
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 전송 버튼
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (widget.chatRoom.type) {
      case ChatRoomType.assistant:
        message = '학습 도우미와 대화를 시작해보세요!\n수학 문제나 개념에 대해 질문할 수 있습니다.';
        icon = Icons.smart_toy;
        break;
      case ChatRoomType.group:
        message = '그룹 채팅을 시작해보세요!\n함께 공부하고 질문을 나눌 수 있습니다.';
        icon = Icons.group;
        break;
      case ChatRoomType.direct:
        message = '대화를 시작해보세요!\n궁금한 점을 자유롭게 물어보세요.';
        icon = Icons.chat_bubble_outline;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메시지 전송
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(userProvider);
    final notifier =
        ref.read(chatMessagesProvider(widget.chatRoom.id).notifier);

    // 메시지 전송
    await notifier.sendMessage(
      senderId: user?.id ?? 'user',
      senderName: user?.name ?? '사용자',
      content: content,
    );

    // 채팅방 정보 업데이트
    await ref.read(chatRoomsProvider.notifier).updateChatRoom(
          widget.chatRoom.id,
          lastMessage: content,
          lastMessageTime: DateTime.now(),
        );

    // 입력 필드 초기화
    _messageController.clear();

    // AI 학습 도우미 자동 응답
    if (widget.chatRoom.type == ChatRoomType.assistant) {
      await Future.delayed(const Duration(seconds: 1));
      await _sendAssistantResponse(content);
    }
  }

  /// AI 학습 도우미 자동 응답
  Future<void> _sendAssistantResponse(String userMessage) async {
    final notifier =
        ref.read(chatMessagesProvider(widget.chatRoom.id).notifier);

    // 간단한 응답 로직 (실제로는 AI API 연동 필요)
    String response;
    if (userMessage.contains('문제') || userMessage.contains('풀이')) {
      response = '문제를 풀어드리겠습니다! 문제의 내용을 자세히 알려주시면, 단계별로 설명해드릴게요. 📝';
    } else if (userMessage.contains('개념') || userMessage.contains('설명')) {
      response =
          '개념 설명을 도와드리겠습니다! 어떤 개념에 대해 궁금하신가요? 예를 들어, 함수, 방정식, 도형 등을 말씀해주세요. 📚';
    } else if (userMessage.contains('도와') || userMessage.contains('질문')) {
      response = '네, 무엇을 도와드릴까요? 수학 문제나 개념에 대해 자유롭게 질문해주세요! 😊';
    } else {
      response =
          '흥미로운 질문이네요! 더 자세히 설명해주시면 도움을 드릴 수 있을 것 같습니다. 어떤 부분이 궁금하신가요? 🤔';
    }

    await notifier.sendMessage(
      senderId: 'assistant',
      senderName: '학습 도우미',
      content: response,
    );

    // 채팅방 정보 업데이트
    await ref.read(chatRoomsProvider.notifier).updateChatRoom(
          widget.chatRoom.id,
          lastMessage: response,
          lastMessageTime: DateTime.now(),
        );
  }

  /// 시간 포맷팅
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    final minute = time.minute.toString().padLeft(2, '0');

    if (messageDay == today) {
      return '$period $hour:$minute';
    } else {
      final diff = today.difference(messageDay).inDays;
      if (diff == 1) {
        return '어제 $period $hour:$minute';
      } else if (diff < 7) {
        return '$diff일 전';
      } else {
        return '${time.month}/${time.day}';
      }
    }
  }

  /// 채팅 옵션
  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('새로고침'),
              onTap: () {
                ref
                    .read(chatMessagesProvider(widget.chatRoom.id).notifier)
                    .refresh();
                Navigator.pop(context);
              },
            ),
            if (widget.chatRoom.type != ChatRoomType.assistant)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('대화 삭제',
                    style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  await ref
                      .read(chatRoomsProvider.notifier)
                      .deleteChatRoom(widget.chatRoom.id);
                  if (context.mounted) {
                    Navigator.pop(context); // 옵션 닫기
                    Navigator.pop(context); // 채팅 화면 닫기
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
