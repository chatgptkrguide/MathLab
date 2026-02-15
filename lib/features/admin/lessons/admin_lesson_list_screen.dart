import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/providers/admin/admin_lesson_provider.dart';
import 'admin_lesson_form_screen.dart';

class AdminLessonListScreen extends ConsumerStatefulWidget {
  final String unitId;
  final String unitTitle;

  const AdminLessonListScreen({
    super.key,
    required this.unitId,
    required this.unitTitle,
  });

  @override
  ConsumerState<AdminLessonListScreen> createState() =>
      _AdminLessonListScreenState();
}

class _AdminLessonListScreenState
    extends ConsumerState<AdminLessonListScreen> {
  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(adminLessonsProvider(widget.unitId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '${widget.unitTitle} - 레슨',
              gradientColors: AppColors.adminGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.headerText, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: lessonsAsync.when(
                data: (lessons) => lessons.isEmpty
                    ? _buildEmptyState()
                    : _buildLessonList(lessons),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('오류: $e',
                      style: const TextStyle(color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(null),
        backgroundColor: AppColors.mathGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(adminLessonsProvider(widget.unitId)),
      child: ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.menu_book_outlined,
                    size: 64, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text(
                  '레슨이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '+ 버튼을 눌러 새 레슨을 추가하세요',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonList(List<LessonModel> lessons) {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(adminLessonsProvider(widget.unitId)),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        onReorder: (oldIndex, newIndex) =>
            _onReorder(lessons, oldIndex, newIndex),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _AdminLessonCard(
            key: ValueKey(lesson.id),
            lesson: lesson,
            onEdit: () => _navigateToForm(lesson),
            onDelete: () => _confirmDelete(lesson),
          );
        },
      ),
    );
  }

  Future<void> _onReorder(
      List<LessonModel> lessons, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final reordered = List<LessonModel>.from(lessons);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    try {
      await ref
          .read(adminLessonNotifierProvider.notifier)
          .reorderLessons(widget.unitId, reordered);
      ref.invalidate(adminLessonsProvider(widget.unitId));
    } catch (e) {
      // Rollback: re-fetch original order from server
      ref.invalidate(adminLessonsProvider(widget.unitId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('순서 변경에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _navigateToForm(LessonModel? lesson) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminLessonFormScreen(
          unitId: widget.unitId,
          lesson: lesson,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(adminLessonsProvider(widget.unitId));
    }
  }

  Future<void> _confirmDelete(LessonModel lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('레슨 삭제'),
        content: Text(
            '이 레슨과 포함된 모든 문제를 삭제하시겠습니까?\n\n"${lesson.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.mathRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(adminLessonNotifierProvider.notifier)
            .deleteLesson(widget.unitId, lesson.id);
        ref.invalidate(adminLessonsProvider(widget.unitId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('레슨이 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }
}

class _AdminLessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminLessonCard({
    super.key,
    required this.lesson,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.drag_handle, color: AppColors.textTertiary),
                ],
              ),
              if (lesson.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  lesson.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip(_typeLabel(lesson.type), AppColors.mathBlue),
                  const SizedBox(width: 6),
                  _buildChip(
                    _difficultyLabel(lesson.difficulty),
                    _difficultyColor(lesson.difficulty),
                  ),
                  const SizedBox(width: 6),
                  _buildChip('${lesson.xpReward} XP', AppColors.mathOrange),
                  const SizedBox(width: 6),
                  _buildChip('${lesson.estimatedMinutes}분', AppColors.textSecondary),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.mathBlue,
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.mathRed,
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _typeLabel(LessonType type) {
    switch (type) {
      case LessonType.standard:
        return '표준';
      case LessonType.story:
        return '스토리';
      case LessonType.practice:
        return '연습';
      case LessonType.review:
        return '복습';
      case LessonType.challenge:
        return '챌린지';
      case LessonType.boss:
        return '보스';
    }
  }

  String _difficultyLabel(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return '초급';
      case LessonDifficulty.intermediate:
        return '중급';
      case LessonDifficulty.advanced:
        return '고급';
      case LessonDifficulty.expert:
        return '전문가';
    }
  }

  Color _difficultyColor(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return AppColors.mathGreen;
      case LessonDifficulty.intermediate:
        return AppColors.mathBlue;
      case LessonDifficulty.advanced:
        return AppColors.mathOrange;
      case LessonDifficulty.expert:
        return AppColors.mathRed;
    }
  }
}
