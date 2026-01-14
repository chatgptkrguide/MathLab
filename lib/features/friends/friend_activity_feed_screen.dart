import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../shared/widgets/headers/common_app_header.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../data/providers/social/friend_provider.dart';

/// 친구 활동 피드 화면
///
/// 친구들의 최근 활동을 실시간으로 표시
/// - 레벨업, 업적 달성, 레슨 완료 등
/// - 시간순 정렬
/// - 무한 스크롤
class FriendActivityFeedScreen extends ConsumerWidget {
  const FriendActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 한국어 timeago 설정
    timeago.setLocaleMessages('ko', timeago.KoMessages());

    final activitiesAsync = ref.watch(friendActivitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: const CommonAppHeaderWithBack(
        title: '친구 활동',
        icon: Icons.notifications_active,
        iconColor: AppColors.mathYellow,
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return _buildEmptyState();
          }
          return _buildActivityList(activities);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  /// 활동 목록
  Widget _buildActivityList(List<FriendActivity> activities) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 새로고침 로직
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(activities[index]);
        },
      ),
    );
  }

  /// 활동 카드
  Widget _buildActivityCard(FriendActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            _buildProfileImage(activity.userPhotoUrl),
            const SizedBox(width: 12),

            // 활동 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.userName,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildActivityIcon(activity.activityType),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(activity.timestamp, locale: 'ko'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // 메타데이터 표시
                  if (activity.metadata != null)
                    _buildMetadata(activity.metadata!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지
  Widget _buildProfileImage(String photoUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.person,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  /// 활동 타입 아이콘
  Widget _buildActivityIcon(String activityType) {
    IconData icon;
    Color color;

    switch (activityType) {
      case 'level_up':
        icon = Icons.arrow_upward;
        color = AppColors.mathYellow;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        color = AppColors.mathYellow;
        break;
      case 'lesson_complete':
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case 'streak':
        icon = Icons.local_fire_department;
        color = AppColors.mathOrange;
        break;
      case 'problem_solve':
        icon = Icons.psychology;
        color = AppColors.mathPurple;
        break;
      default:
        icon = Icons.star;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  /// 메타데이터 표시
  Widget _buildMetadata(Map<String, dynamic> metadata) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...metadata.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${_formatMetadataKey(entry.key)}: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatMetadataKey(String key) {
    switch (key) {
      case 'level':
        return '레벨';
      case 'xp':
        return 'XP';
      case 'achievement':
        return '업적';
      case 'lesson':
        return '레슨';
      case 'score':
        return '점수';
      case 'streak':
        return '스트릭';
      default:
        return key;
    }
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '아직 친구 활동이 없습니다',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '친구를 추가하고\n함께 학습해보세요!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            '활동을 불러올 수 없습니다',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
