/// 🎯 Drag and Drop Widget
///
/// Interactive drag-and-drop interface for math problems.
/// Supports equation assembly, matching, and ordering tasks.

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../math/math_renderer.dart';

/// Draggable item model
class DraggableItem {
  final String id;
  final String content;
  final bool isMath;

  const DraggableItem({
    required this.id,
    required this.content,
    this.isMath = true,
  });
}

/// Drop zone model
class DropZone {
  final String id;
  final String? acceptedItemId;
  final String? hint;

  const DropZone({
    required this.id,
    this.acceptedItemId,
    this.hint,
  });
}

/// Drag and drop math problem widget
class DragAndDropMathWidget extends StatefulWidget {
  final List<DraggableItem> items;
  final List<DropZone> dropZones;
  final ValueChanged<Map<String, String>>? onChanged;
  final bool isEnabled;
  final Map<String, String>? initialPlacements;

  const DragAndDropMathWidget({
    super.key,
    required this.items,
    required this.dropZones,
    this.onChanged,
    this.isEnabled = true,
    this.initialPlacements,
  });

  @override
  State<DragAndDropMathWidget> createState() => _DragAndDropMathWidgetState();
}

class _DragAndDropMathWidgetState extends State<DragAndDropMathWidget> {
  // Map: dropZoneId -> itemId
  late Map<String, String> placements;

  @override
  void initState() {
    super.initState();
    placements = Map.from(widget.initialPlacements ?? {});
  }

  void _handleDrop(String dropZoneId, String itemId) {
    if (!widget.isEnabled) return;

    setState(() {
      // Remove item from any previous zone
      placements.removeWhere((key, value) => value == itemId);

      // Place item in new zone
      placements[dropZoneId] = itemId;
    });

    widget.onChanged?.call(placements);
  }

  void _handleRemove(String dropZoneId) {
    if (!widget.isEnabled) return;

    setState(() {
      placements.remove(dropZoneId);
    });

    widget.onChanged?.call(placements);
  }

  bool _isItemPlaced(String itemId) {
    return placements.containsValue(itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drop zones
        ...widget.dropZones.map((zone) => _buildDropZone(zone)),

        const SizedBox(height: 24),

        // Available items
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '선택 가능한 항목',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.items
                    .where((item) => !_isItemPlaced(item.id))
                    .map((item) => _buildDraggableItem(item))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone(DropZone zone) {
    final placedItemId = placements[zone.id];
    final placedItem = placedItemId != null
        ? widget.items.firstWhere((item) => item.id == placedItemId)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DragTarget<String>(
        onWillAccept: (data) => widget.isEnabled,
        onAccept: (itemId) => _handleDrop(zone.id, itemId),
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: placedItem != null
                  ? AppColors.mathBlue.withOpacity(0.1)
                  : isHovering
                      ? AppColors.mathGreen.withOpacity(0.1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: placedItem != null
                    ? AppColors.mathBlue
                    : isHovering
                        ? AppColors.mathGreen
                        : AppColors.borderLight,
                width: 2,
                style: placedItem == null && !isHovering
                    ? BorderStyle.solid
                    : BorderStyle.solid,
              ),
            ),
            child: placedItem != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildItemContent(placedItem),
                      ),
                      if (widget.isEnabled)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _handleRemove(zone.id),
                          color: AppColors.mathRed,
                        ),
                    ],
                  )
                : Center(
                    child: Text(
                      zone.hint ?? '여기에 드래그하세요',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableItem(DraggableItem item) {
    if (!widget.isEnabled) {
      return _buildItemChip(item);
    }

    return Draggable<String>(
      data: item.id,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: _buildItemChip(item, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildItemChip(item),
      ),
      child: _buildItemChip(item),
    );
  }

  Widget _buildItemChip(DraggableItem item, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDragging
            ? AppColors.mathYellow
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1.5,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: _buildItemContent(item),
    );
  }

  Widget _buildItemContent(DraggableItem item) {
    if (item.isMath) {
      return MathRichText(
        text: item.content,
        textStyle: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        mathFontSize: 20.0,
      );
    } else {
      return Text(
        item.content,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }
}

/// Matching pairs widget
class MatchingPairsWidget extends StatefulWidget {
  final List<DraggableItem> leftItems;
  final List<DraggableItem> rightItems;
  final Map<String, String> correctMatches; // leftId -> rightId
  final ValueChanged<Map<String, String>>? onChanged;
  final bool isEnabled;

  const MatchingPairsWidget({
    super.key,
    required this.leftItems,
    required this.rightItems,
    required this.correctMatches,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<MatchingPairsWidget> createState() => _MatchingPairsWidgetState();
}

class _MatchingPairsWidgetState extends State<MatchingPairsWidget> {
  // Map: leftId -> rightId
  late Map<String, String> userMatches;

  @override
  void initState() {
    super.initState();
    userMatches = {};
  }

  void _handleMatch(String leftId, String rightId) {
    if (!widget.isEnabled) return;

    setState(() {
      // Remove any existing match for this left item
      userMatches.remove(leftId);

      // Remove any existing match for this right item
      userMatches.removeWhere((key, value) => value == rightId);

      // Create new match
      userMatches[leftId] = rightId;
    });

    widget.onChanged?.call(userMatches);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            children: widget.leftItems
                .map((item) => _buildLeftItem(item))
                .toList(),
          ),
        ),

        const SizedBox(width: 24),

        // Right column
        Expanded(
          child: Column(
            children: widget.rightItems
                .map((item) => _buildRightItem(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftItem(DraggableItem item) {
    final isMatched = userMatches.containsKey(item.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMatched
              ? AppColors.mathBlue.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMatched ? AppColors.mathBlue : AppColors.borderLight,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: item.isMath
                  ? MathRichText(
                      text: item.content,
                      textStyle: AppTextStyles.bodyLarge,
                      mathFontSize: 18.0,
                    )
                  : Text(
                      item.content,
                      style: AppTextStyles.bodyLarge,
                    ),
            ),
            if (isMatched)
              Icon(
                Icons.arrow_forward,
                color: AppColors.mathBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightItem(DraggableItem item) {
    final isMatched = userMatches.containsValue(item.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DragTarget<String>(
        onWillAccept: (leftId) => widget.isEnabled && leftId != null,
        onAccept: (leftId) => _handleMatch(leftId, item.id),
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isMatched
                  ? AppColors.mathBlue.withOpacity(0.1)
                  : isHovering
                      ? AppColors.mathGreen.withOpacity(0.1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMatched
                    ? AppColors.mathBlue
                    : isHovering
                        ? AppColors.mathGreen
                        : AppColors.borderLight,
                width: 2,
              ),
            ),
            child: item.isMath
                ? MathRichText(
                    text: item.content,
                    textStyle: AppTextStyles.bodyLarge,
                    mathFontSize: 18.0,
                  )
                : Text(
                    item.content,
                    style: AppTextStyles.bodyLarge,
                  ),
          );
        },
      ),
    );
  }
}
