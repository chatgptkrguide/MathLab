import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/constants.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/lesson/unit_model.dart';
import '../../data/models/lesson/lesson_model.dart';
import '../../data/providers/admin/admin_problem_provider.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import 'admin_problem_form_screen.dart';

class AdminProblemListScreen extends ConsumerStatefulWidget {
  const AdminProblemListScreen({super.key});

  @override
  ConsumerState<AdminProblemListScreen> createState() =>
      _AdminProblemListScreenState();
}

class _AdminProblemListScreenState
    extends ConsumerState<AdminProblemListScreen> {
  String? _selectedUnitId;
  String? _selectedLessonId;

  @override
  Widget build(BuildContext context) {
    final curriculumAsync = ref.watch(curriculumProvider);
    final problemsAsync = ref.watch(adminProblemsProvider(_selectedLessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '문제 관리',
              gradientColors: AppColors.headerBlueGradient,
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
            // Filters
            curriculumAsync.when(
              data: (units) => _buildFilters(units),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Problem list
            Expanded(
              child: problemsAsync.when(
                data: (problems) => problems.isEmpty
                    ? _buildEmptyState()
                    : _buildProblemList(problems),
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

  Widget _buildFilters(List<UnitModel> units) {
    final selectedUnit = units
        .where((u) => u.id == _selectedUnitId)
        .firstOrNull;
    final lessons = selectedUnit?.lessons ?? <LessonModel>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Unit dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedUnitId,
              decoration: const InputDecoration(
                labelText: '유닛',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('전체')),
                ...units.map((u) => DropdownMenuItem(
                      value: u.id,
                      child: Text(
                        '${u.emoji} ${u.title}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUnitId = value;
                  _selectedLessonId = null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Lesson dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedLessonId,
              decoration: const InputDecoration(
                labelText: '레슨',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('전체')),
                ...lessons.map((l) => DropdownMenuItem(
                      value: l.id,
                      child: Text(l.title, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: _selectedUnitId == null
                  ? null
                  : (value) {
                      setState(() {
                        _selectedLessonId = value;
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminProblemsProvider(_selectedLessonId));
      },
      child: ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text(
                  '문제가 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '+ 버튼을 눌러 새 문제를 추가하세요',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemList(List<ProblemModel> problems) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminProblemsProvider(_selectedLessonId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: problems.length,
        itemBuilder: (context, index) {
          final problem = problems[index];
          return _AdminProblemCard(
            problem: problem,
            onEdit: () => _navigateToForm(problem),
            onDelete: () => _confirmDelete(problem),
          );
        },
      ),
    );
  }

  Future<void> _navigateToForm(ProblemModel? problem) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProblemFormScreen(problem: problem),
      ),
    );
    if (result == true) {
      ref.invalidate(adminProblemsProvider(_selectedLessonId));
    }
  }

  Future<void> _confirmDelete(ProblemModel problem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('문제 삭제'),
        content: Text('이 문제를 삭제하시겠습니까?\n\n"${problem.question}"'),
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
        await ref.read(adminProblemNotifierProvider.notifier).deleteProblem(
              problem.id,
              problem.allImages,
            );
        ref.invalidate(adminProblemsProvider(_selectedLessonId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문제가 삭제되었습니다')),
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

class _AdminProblemCard extends StatelessWidget {
  final ProblemModel problem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminProblemCard({
    required this.problem,
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
              // Question text
              Text(
                problem.question,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Chips row
              Row(
                children: [
                  _buildChip(_typeLabel(problem.type), AppColors.mathBlue),
                  const SizedBox(width: 6),
                  _buildChip(
                    _difficultyLabel(problem.difficulty),
                    _difficultyColor(problem.difficulty),
                  ),
                  const SizedBox(width: 6),
                  _buildChip('${problem.points}pt', AppColors.mathOrange),
                  if (problem.allImages.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.image, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      '${problem.allImages.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _typeLabel(ProblemType type) {
    switch (type) {
      case ProblemType.multipleChoice:
        return '객관식';
      case ProblemType.trueFalse:
        return 'O/X';
      case ProblemType.fillInBlank:
        return '빈칸';
      case ProblemType.matching:
        return '매칭';
      case ProblemType.dragAndDrop:
        return '드래그';
    }
  }

  String _difficultyLabel(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return '쉬움';
      case ProblemDifficulty.medium:
        return '보통';
      case ProblemDifficulty.hard:
        return '어려움';
    }
  }

  Color _difficultyColor(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return AppColors.mathGreen;
      case ProblemDifficulty.medium:
        return AppColors.mathOrange;
      case ProblemDifficulty.hard:
        return AppColors.mathRed;
    }
  }
}
