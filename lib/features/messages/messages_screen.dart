import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/common_app_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/message_provider.dart';
import 'widgets/message_list_item.dart';
import 'message_detail_screen.dart';
import 'send_message_screen.dart';

/// 메시지 목록 화면
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MessageType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageProvider);
    final unreadCount = ref.watch(unreadMessageCountProvider);

    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: Column(
          children: [
            // 앱바
            CommonAppBar(
              title: '메시지',
              actions: [
                // 이메일 문의 버튼
                IconButton(
                  icon: const Icon(Icons.email_outlined, color: AppColors.surface),
                  tooltip: '이메일 문의',
                  onPressed: _sendEmail,
                ),
                // 모두 읽음 표시 버튼
                if (unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.done_all, color: AppColors.surface),
                    tooltip: '모두 읽음',
                    onPressed: () {
                      ref.read(messageProvider.notifier).markAllAsRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('모든 메시지를 읽음으로 표시했습니다'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.mathBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            // 탭바
            Container(
              color: Colors.transparent,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.surface,
                unselectedLabelColor: AppColors.surface.withOpacity(0.6),
                indicatorColor: AppColors.mathYellow,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('전체'),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: '시스템'),
                  const Tab(text: '업적'),
                  const Tab(text: '스트릭'),
                ],
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        _selectedType = null;
                        break;
                      case 1:
                        _selectedType = MessageType.system;
                        break;
                      case 2:
                        _selectedType = MessageType.achievement;
                        break;
                      case 3:
                        _selectedType = MessageType.streak;
                        break;
                    }
                  });
                },
              ),
            ),
            // 메시지 리스트
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: _buildMessageList(messages),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SendMessageScreen(),
            ),
          );
        },
        backgroundColor: AppColors.mathYellow,
        icon: const Icon(Icons.edit, color: AppColors.textPrimary),
        label: Text(
          '문의하기',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 이메일 보내기
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@gomath.com',  // 실제 지원 이메일로 변경
      query: 'subject=GoMath 문의&body=문의 내용을 작성해주세요.',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('이메일 앱을 열 수 없습니다'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이메일 전송 실패: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    }
  }

  Widget _buildMessageList(List<Message> allMessages) {
    // 필터링
    final filteredMessages = _selectedType == null
        ? allMessages
        : allMessages.where((m) => m.type == _selectedType).toList();

    if (filteredMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              '메시지가 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 서버에서 새 메시지 가져오기
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.mathBlue,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: filteredMessages.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.spacingM),
        itemBuilder: (context, index) {
          final message = filteredMessages[index];
          return MessageListItem(
            message: message,
            onTap: () => _openMessageDetail(message),
            onDelete: () => _deleteMessage(message.id),
          );
        },
      ),
    );
  }

  void _openMessageDetail(Message message) {
    // 읽지 않은 메시지면 읽음 표시
    if (!message.isRead) {
      ref.read(messageProvider.notifier).markAsRead(message.id);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageDetailScreen(message: message),
      ),
    );
  }

  void _deleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: const Text('이 메시지를 삭제하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(messageProvider.notifier).deleteMessage(messageId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('메시지가 삭제되었습니다'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.mathBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
              );
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
