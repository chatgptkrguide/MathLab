import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/common_app_bar.dart';
import '../../data/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 메시지 상세 화면
class MessageDetailScreen extends StatelessWidget {
  final Message message;

  const MessageDetailScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
            CommonAppBar(
              title: '메시지',
              actions: [
                // 이메일 답장 버튼
                IconButton(
                  icon: const Icon(Icons.reply, color: AppColors.surface),
                  tooltip: '이메일로 답장',
                  onPressed: () => _sendReplyEmail(context),
                ),
              ],
            ),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 발신자 정보
                        _buildSenderInfo(),
                        const SizedBox(height: AppDimensions.paddingXL),
                        // 제목
                        Text(
                          message.title,
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        // 본문
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusL),
                            border: Border.all(
                              color: AppColors.borderLight.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            message.body,
                            style: AppTextStyles.bodyLarge.copyWith(
                              height: 1.6,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        // 액션 버튼
                        if (message.actionText != null &&
                            message.actionRoute != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: 라우트로 이동
                                Navigator.pop(context);
                                // Navigator.pushNamed(context, message.actionRoute!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mathBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusL),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                message.actionText!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // 읽은 시간
                        if (message.readAt != null) ...[
                          const SizedBox(height: AppDimensions.paddingL),
                          Container(
                            padding:
                                const EdgeInsets.all(AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusM),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 20,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${timeago.format(message.readAt!, locale: 'ko')}에 읽음',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getIconColor().withValues(alpha: 0.1),
            _getIconColor().withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: _getIconColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getIconColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              _getIconData(),
              color: _getIconColor(),
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(message.createdAt, locale: 'ko'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 중요 표시
          if (message.isImportant)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '중요',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 이메일로 답장
  Future<void> _sendReplyEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@gomath.com',
      query:
          'subject=Re: ${message.title}&body=\n\n---\n원본 메시지: ${message.body}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
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
      if (context.mounted) {
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

  IconData _getIconData() {
    switch (message.type) {
      case MessageType.system:
        return Icons.notifications;
      case MessageType.friend:
        return Icons.person;
      case MessageType.league:
        return Icons.emoji_events;
      case MessageType.achievement:
        return Icons.emoji_events;
      case MessageType.streak:
        return Icons.local_fire_department;
      case MessageType.promotion:
        return Icons.star;
    }
  }

  Color _getIconColor() {
    switch (message.type) {
      case MessageType.system:
        return AppColors.mathBlue;
      case MessageType.friend:
        return AppColors.success;
      case MessageType.league:
        return AppColors.warning;
      case MessageType.achievement:
        return AppColors.error;
      case MessageType.streak:
        return Colors.orange;
      case MessageType.promotion:
        return Colors.purple;
    }
  }
}
