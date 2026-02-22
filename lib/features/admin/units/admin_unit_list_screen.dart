import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/providers/admin/admin_unit_provider.dart';
import '../lessons/admin_lesson_list_screen.dart';
import 'admin_unit_form_screen.dart';

class AdminUnitListScreen extends ConsumerStatefulWidget {
  const AdminUnitListScreen({super.key});

  @override
  ConsumerState<AdminUnitListScreen> createState() =>
      _AdminUnitListScreenState();
}

class _AdminUnitListScreenState extends ConsumerState<AdminUnitListScreen> {
  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(adminUnitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '유닛 관리',
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
              child: unitsAsync.when(
                data: (units) => units.isEmpty
                    ? _buildEmptyState()
                    : _buildUnitList(units),
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
      onRefresh: () async => ref.invalidate(adminUnitsProvider),
      child: ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 64, color: AppColors.textTertiary),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  '유닛이 없습니다',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                const Text(
                  '+ 버튼을 눌러 새 유닛을 추가하세요',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitList(List<UnitModel> units) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminUnitsProvider),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        itemCount: units.length,
        onReorder: (oldIndex, newIndex) => _onReorder(units, oldIndex, newIndex),
        itemBuilder: (context, index) {
          final unit = units[index];
          return _AdminUnitCard(
            key: ValueKey(unit.id),
            unit: unit,
            onEdit: () => _navigateToForm(unit),
            onDelete: () => _confirmDelete(unit),
            onManageLessons: () => _navigateToLessons(unit),
          );
        },
      ),
    );
  }

  Future<void> _onReorder(
      List<UnitModel> units, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final reordered = List<UnitModel>.from(units);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    try {
      await ref.read(adminUnitNotifierProvider.notifier).reorderUnits(reordered);
      ref.invalidate(adminUnitsProvider);
    } catch (e) {
      // Rollback: re-fetch original order from server
      ref.invalidate(adminUnitsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('순서 변경에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _navigateToForm(UnitModel? unit) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUnitFormScreen(unit: unit),
      ),
    );
    if (result == true) {
      ref.invalidate(adminUnitsProvider);
    }
  }

  void _navigateToLessons(UnitModel unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminLessonListScreen(unitId: unit.id, unitTitle: unit.title),
      ),
    );
  }

  Future<void> _confirmDelete(UnitModel unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('유닛 삭제'),
        content: Text(
          '이 유닛과 포함된 모든 레슨/문제를 삭제하시겠습니까?\n\n'
          '"${unit.emoji} ${unit.title}" (레슨 ${unit.lessonCount}개)',
        ),
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
        await ref.read(adminUnitNotifierProvider.notifier).deleteUnit(unit.id);
        ref.invalidate(adminUnitsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('유닛이 삭제되었습니다')),
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

class _AdminUnitCard extends StatelessWidget {
  final UnitModel unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageLessons;

  const _AdminUnitCard({
    super.key,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
    required this.onManageLessons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius12)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(unit.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.title,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.spacing2),
                      Text(
                        unit.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.drag_handle, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              children: [
                _buildChip('레슨 ${unit.lessonCount}개', AppColors.mathBlue),
                const SizedBox(width: 6),
                _buildChip('${unit.totalXP} XP', AppColors.mathOrange),
                const SizedBox(width: 6),
                _buildChip(unit.theme.name, _themeColor(unit.theme)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.list_alt_outlined, size: AppDimensions.spacing20),
                  color: AppColors.mathGreen,
                  onPressed: onManageLessons,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppDimensions.spacing4),
                  tooltip: '레슨 관리',
                ),
                const SizedBox(width: AppDimensions.spacing4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: AppDimensions.spacing20),
                  color: AppColors.mathBlue,
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppDimensions.spacing4),
                ),
                const SizedBox(width: AppDimensions.spacing4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: AppDimensions.spacing20),
                  color: AppColors.mathRed,
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppDimensions.spacing4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _themeColor(UnitTheme theme) {
    switch (theme) {
      case UnitTheme.blue:
        return AppColors.mathBlue;
      case UnitTheme.green:
        return AppColors.mathGreen;
      case UnitTheme.orange:
        return AppColors.mathOrange;
      case UnitTheme.purple:
        return AppColors.mathPurple;
      case UnitTheme.red:
        return AppColors.mathRed;
      case UnitTheme.yellow:
        return AppColors.mathYellow;
    }
  }
}
