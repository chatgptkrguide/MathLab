import 'package:flutter/material.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../data/models/models.dart';

/// 오답 노트 액션 버튼들 (반응형 2열 레이아웃)
class ErrorActionButtons extends StatelessWidget {
  final List<ErrorNote> filteredNotes;
  final VoidCallback onReviewSelected;
  final VoidCallback onCreateCustomSet;

  const ErrorActionButtons({
    super.key,
    required this.filteredNotes,
    required this.onReviewSelected,
    required this.onCreateCustomSet,
  });

  @override
  Widget build(BuildContext context) {
    final selectedErrorCount = filteredNotes.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 500;

          if (isSmallScreen) {
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: selectedErrorCount > 0 ? onReviewSelected : null,
                    icon: const Icon(Icons.refresh, size: AppDimensions.iconS),
                    label: Text('선택 문제 복습 ($selectedErrorCount)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        filteredNotes.isNotEmpty ? onCreateCustomSet : null,
                    icon: const Icon(Icons.library_books,
                        size: AppDimensions.iconS),
                    label: const Text('맞춤 복습 세트'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: selectedErrorCount > 0 ? onReviewSelected : null,
                  icon: const Icon(Icons.refresh, size: AppDimensions.iconS),
                  label: Text('선택 문제 복습 ($selectedErrorCount)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingM,
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      filteredNotes.isNotEmpty ? onCreateCustomSet : null,
                  icon: const Icon(Icons.library_books,
                      size: AppDimensions.iconS),
                  label: const Text('맞춤 복습 세트'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingM,
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
