import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../data/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 메시지 리스트 아이템
class MessageListItem extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MessageListItem({
    super.key,
    required this.message,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: message.isRead
                  ? AppColors.surface
                  : AppColors.mathBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                color: message.isImportant
                    ? AppColors.error
                    : message.isRead
                        ? AppColors.borderLight.withValues(alpha: 0.3)
                        : AppColors.mathBlue.withValues(alpha: 0.3),
                width: message.isImportant ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: message.isRead
                      ? Colors.black.withValues(alpha: 0.03)
                      : AppColors.mathBlue.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getIconColor(),
                        _getIconColor().withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _getIconColor().withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconData(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                // 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목과 안 읽음 표시
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: message.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!message.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          if (message.isImportant) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '중요',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 본문
                      Text(
                        message.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // 시간과 메시지 타입
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(
                              message.createdAt,
                              locale: 'ko',
                            ),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getIconColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getIconColor().withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _getTypeLabel(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getIconColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        return Icons.military_tech;
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

  String _getTypeLabel() {
    switch (message.type) {
      case MessageType.system:
        return '시스템';
      case MessageType.friend:
        return '친구';
      case MessageType.league:
        return '리그';
      case MessageType.achievement:
        return '업적';
      case MessageType.streak:
        return '스트릭';
      case MessageType.promotion:
        return '프로모션';
    }
  }
}
