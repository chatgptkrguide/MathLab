// 💡 Duolingo-style Hint Popup
//
// Modal dialog showing step-by-step hints with unlock functionality

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/math/math_renderer.dart';

class HintPopup extends StatefulWidget {
  final List<String> hints;
  final Set<int> unlockedHints;
  final Function(int) onUnlockHint;
  final VoidCallback onClose;

  const HintPopup({
    super.key,
    required this.hints,
    required this.unlockedHints,
    required this.onUnlockHint,
    required this.onClose,
  });

  @override
  State<HintPopup> createState() => _HintPopupState();

  static Future<void> show({
    required BuildContext context,
    required List<String> hints,
    required Set<int> unlockedHints,
    required Function(int) onUnlockHint,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Hint Popup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return HintPopup(
          hints: hints,
          unlockedHints: unlockedHints,
          onUnlockHint: onUnlockHint,
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
      transitionBuilder: (_, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

class _HintPopupState extends State<HintPopup> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.mathOrange.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            // Hints list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: List.generate(widget.hints.length, (index) {
                    return _buildHintItem(index);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mathOrange,
            AppColors.mathOrange.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Lightbulb icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Title and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '힌트',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.unlockedHints.length}/${widget.hints.length} 해제됨',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintItem(int index) {
    final isUnlocked = widget.unlockedHints.contains(index);
    final isFirstLocked = !isUnlocked &&
        (index == 0 || widget.unlockedHints.contains(index - 1));

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.mathGreen.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? AppColors.mathGreen.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: isUnlocked
            ? _buildUnlockedHint(index)
            : _buildLockedHint(index, isFirstLocked),
      ),
    );
  }

  Widget _buildUnlockedHint(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Check icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.mathGreen, Color(0xFF06A03C)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mathGreen.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        // Hint content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mathGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '힌트 ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              MathRichText(
                text: widget.hints[index],
                textStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
                mathFontSize: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedHint(int index, bool canUnlockThis) {
    return GestureDetector(
      onTap: canUnlockThis ? () => widget.onUnlockHint(index) : null,
      child: Row(
        children: [
          // Number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: canUnlockThis
                  ? AppColors.mathOrange.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: canUnlockThis
                      ? AppColors.mathOrange
                      : Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Hint label
          Expanded(
            child: Text(
              canUnlockThis ? '탭하여 힌트 열기' : '이전 힌트를 먼저 확인하세요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: canUnlockThis ? FontWeight.w500 : FontWeight.w400,
                color: canUnlockThis ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
          ),
          // Unlock button or lock icon
          if (canUnlockThis)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mathOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '열기',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          else
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: Colors.grey[350],
            ),
        ],
      ),
    );
  }

}
