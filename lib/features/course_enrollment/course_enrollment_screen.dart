import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/learning/course_enrollment_provider.dart';
import '../../data/services/course_enrollment_service.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 과정 수강 관리 화면
class CourseEnrollmentScreen extends ConsumerWidget {
  const CourseEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEnrollmentsAsync = ref.watch(activeEnrollmentsProvider);
    final availableSlotsAsync = ref.watch(availableSlotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '수강 과정',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 수강 가능 슬롯 정보
            _buildSlotsInfo(availableSlotsAsync),

            // 활성 과정 목록
            Expanded(
              child:
                  _buildEnrollmentsList(context, ref, activeEnrollmentsAsync),
            ),
          ],
        ),
      ),
      floatingActionButton: availableSlotsAsync.when(
        data: (slots) => slots > 0
            ? FloatingActionButton.extended(
                onPressed: () => _showAddCourseDialog(context, ref),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '과정 추가',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  /// 수강 가능 슬롯 정보
  Widget _buildSlotsInfo(AsyncValue<int> slotsAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: slotsAsync.when(
        data: (slots) {
          final enrolled = CourseEnrollmentService.maxEnrollments - slots;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$enrolled/${CourseEnrollmentService.maxEnrollments} 과정 수강 중',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slots > 0 ? '$slots개 과정 더 추가 가능' : '최대 수강 과정 수에 도달했습니다',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (_, __) => const Text(
          '데이터를 불러올 수 없습니다',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  /// 수강 과정 목록
  Widget _buildEnrollmentsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CourseEnrollment>> enrollmentsAsync,
  ) {
    return enrollmentsAsync.when(
      data: (enrollments) {
        if (enrollments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '수강 중인 과정이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새 과정을 추가해보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: enrollments.length,
          itemBuilder: (context, index) {
            final enrollment = enrollments[index];
            return _buildEnrollmentCard(context, ref, enrollment);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('데이터를 불러올 수 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(activeEnrollmentsProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 수강 과정 카드
  Widget _buildEnrollmentCard(
    BuildContext context,
    WidgetRef ref,
    CourseEnrollment enrollment,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEnrollmentOptions(context, ref, enrollment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.book,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            enrollment.courseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(enrollment.status),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 진행률
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '진행률',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${enrollment.completedLessons}/${enrollment.totalLessons} 레슨',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: enrollment.totalLessons > 0
                            ? enrollment.completedLessons /
                                enrollment.totalLessons
                            : 0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${enrollment.progressPercentage.toStringAsFixed(0)}% 완료',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),

                // 마지막 접근 시간
                if (enrollment.lastAccessDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '마지막 접근: ${_formatDate(enrollment.lastAccessDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(EnrollmentStatus status) {
    Color color;
    switch (status) {
      case EnrollmentStatus.active:
        color = AppColors.success;
        break;
      case EnrollmentStatus.paused:
        color = AppColors.warning;
        break;
      case EnrollmentStatus.completed:
        color = AppColors.primary;
        break;
      case EnrollmentStatus.dropped:
        color = AppColors.error;
        break;
      case EnrollmentStatus.cancelled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// 과정 추가 다이얼로그
  void _showAddCourseDialog(BuildContext context, WidgetRef ref) {
    // TODO: 실제 과정 목록에서 선택하도록 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('과정 추가'),
        content: const Text('과정 추가 기능은 곧 구현됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 수강 과정 옵션
  void _showEnrollmentOptions(
    BuildContext context,
    WidgetRef ref,
    CourseEnrollment enrollment,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              enrollment.courseName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (enrollment.status == EnrollmentStatus.active) ...[
              ListTile(
                leading: Icon(Icons.pause, color: AppColors.warning),
                title: const Text('일시 중지'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(courseEnrollmentActionsProvider)
                      .pauseCourse(enrollment.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.stop, color: AppColors.error),
                title: const Text('중단'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(courseEnrollmentActionsProvider)
                      .dropCourse(enrollment.id);
                },
              ),
            ],
            if (enrollment.status == EnrollmentStatus.paused) ...[
              ListTile(
                leading: Icon(Icons.play_arrow, color: AppColors.success),
                title: const Text('재개'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(courseEnrollmentActionsProvider)
                      .resumeCourse(enrollment.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.stop, color: AppColors.error),
                title: const Text('중단'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(courseEnrollmentActionsProvider)
                      .dropCourse(enrollment.id);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
