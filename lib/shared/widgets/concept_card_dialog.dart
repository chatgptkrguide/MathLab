// 📚 Concept Card Dialog
//
// Shows detailed concept explanation with examples

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/concept_card_model.dart';
import '../../data/providers/concept_card/concept_card_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class ConceptCardDialog extends ConsumerStatefulWidget {
  final ConceptCardModel conceptCard;

  const ConceptCardDialog({
    super.key,
    required this.conceptCard,
  });

  @override
  ConsumerState<ConceptCardDialog> createState() => _ConceptCardDialogState();
}

class _ConceptCardDialogState extends ConsumerState<ConceptCardDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Mark as viewed when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null) {
        ref
            .read(conceptCardProvider(user.id).notifier)
            .markAsViewed(widget.conceptCard.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final conceptState = user != null
        ? ref.watch(conceptCardProvider(user.id))
        : null;

    final isBookmarked = conceptState?.isBookmarked(widget.conceptCard.id) ?? false;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radius20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.conceptCard.category,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacing4),
                            Text(
                              widget.conceptCard.title,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: user != null
                            ? () {
                                ref
                                    .read(conceptCardProvider(user.id)
                                        .notifier)
                                    .toggleBookmark(widget.conceptCard.id);
                              }
                            : null,
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  Row(
                    children: [
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radius12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.conceptCard.difficultyIcon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: AppDimensions.spacing4),
                            Text(
                              widget.conceptCard.difficultyLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      // Tags
                      ...widget.conceptCard.tags.take(2).map((tag) => Padding(
                            padding: const EdgeInsets.only(right: AppDimensions.spacing8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacing8,
                                vertical: AppDimensions.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radius12),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '설명'),
                  Tab(text: '예제'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDescriptionTab(),
                  _buildExamplesTab(),
                ],
              ),
            ),

            // Related concepts footer
            if (widget.conceptCard.relatedConcepts.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '관련 개념',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Wrap(
                      spacing: AppDimensions.spacing8,
                      runSpacing: AppDimensions.spacing8,
                      children: widget.conceptCard.relatedConcepts
                          .map((concept) => Chip(
                                label: Text(
                                  concept,
                                  style: AppTextStyles.bodySmall,
                                ),
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            widget.conceptCard.description,
            style: AppTextStyles.bodyLarge,
          ),

          const SizedBox(height: AppDimensions.spacing24),
          const Divider(),
          const SizedBox(height: AppDimensions.spacing24),

          // Key points
          Text(
            '핵심 포인트',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          ...widget.conceptCard.keyPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: Text(
                        point,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),

          // Visualization (if available)
          if (widget.conceptCard.visualizationUrl != null) ...[
            const SizedBox(height: AppDimensions.spacing24),
            const Divider(),
            const SizedBox(height: AppDimensions.spacing24),
            Text(
              '시각화',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              child: Image.network(
                widget.conceptCard.visualizationUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExamplesTab() {
    if (widget.conceptCard.examples.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              '예제가 없습니다',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      itemCount: widget.conceptCard.examples.length,
      itemBuilder: (context, index) {
        final example = widget.conceptCard.examples[index];

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
          elevation: AppDimensions.elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Example number
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing8,
                        vertical: AppDimensions.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppDimensions.radius12),
                      ),
                      child: Text(
                        '예제 ${index + 1}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing12),

                // Question
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                  child: Text(
                    example.question,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing12),

                // Solution
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            '풀이',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        example.solution,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),

                // Explanation (if available)
                if (example.explanation != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: AppDimensions.spacing8),
                            Text(
                              '설명',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        Text(
                          example.explanation!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
