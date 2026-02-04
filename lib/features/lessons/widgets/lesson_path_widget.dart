import 'package:flutter/material.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../shared/constants/figma_colors.dart';
import 'curved_path_painter.dart';

/// 듀오링고 스타일 학습 경로 위젯
///
/// S자 곡선 경로 위에 레슨 노드를 배치하는 스크롤 가능한 위젯.
class LessonPathWidget extends StatefulWidget {
  final List<LessonModel> lessons;
  final Map<String, LessonProgressModel> progressMap;
  final void Function(String lessonId) onLessonTap;

  const LessonPathWidget({
    super.key,
    required this.lessons,
    required this.progressMap,
    required this.onLessonTap,
  });

  @override
  State<LessonPathWidget> createState() => _LessonPathWidgetState();
}

class _LessonPathWidgetState extends State<LessonPathWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double _nodeSize = 80.0;
  static const double _verticalSpacing = 140.0;
  static const double _startY = 60.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _completedCount {
    int count = 0;
    for (final lesson in widget.lessons) {
      final progress = widget.progressMap[lesson.id];
      if (progress?.status == LessonStatus.completed) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// 현재 활성 레슨의 인덱스 (START 배지 표시할 곳)
  int get _currentLessonIndex {
    for (int i = 0; i < widget.lessons.length; i++) {
      final progress = widget.progressMap[widget.lessons[i].id];
      if (progress == null || progress.status == LessonStatus.locked) {
        return i > 0 ? i : 0;
      }
      if (progress.status == LessonStatus.unlocked ||
          progress.status == LessonStatus.inProgress) {
        return i;
      }
    }
    return widget.lessons.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalHeight = _startY + (widget.lessons.length * _verticalSpacing) + 80;

    final nodePositions = PathLayoutCalculator.calculateNodePositions(
      nodeCount: widget.lessons.length,
      width: screenWidth,
      startY: _startY,
      verticalSpacing: _verticalSpacing,
    );

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // 배경 곡선 경로
          CustomPaint(
            size: Size(screenWidth, totalHeight),
            painter: CurvedPathPainter(
              nodePositions: nodePositions,
              completedCount: _completedCount,
            ),
          ),

          // 레슨 노드들
          ...List.generate(widget.lessons.length, (index) {
            final lesson = widget.lessons[index];
            final progress = widget.progressMap[lesson.id];
            final position = nodePositions[index];
            final isCurrent = index == _currentLessonIndex;
            final status = progress?.status ?? LessonStatus.locked;
            final isUnlocked = status != LessonStatus.locked;

            return Positioned(
              left: position.dx - (_nodeSize / 2),
              top: position.dy - (_nodeSize / 2),
              child: Column(
                children: [
                  // START 배지 (현재 레슨에만)
                  if (isCurrent && isUnlocked && status != LessonStatus.completed)
                    _buildStartBadge(),

                  // 레슨 노드
                  GestureDetector(
                    onTap: isUnlocked
                        ? () => widget.onLessonTap(lesson.id)
                        : null,
                    child: isCurrent && isUnlocked && status != LessonStatus.completed
                        ? ScaleTransition(
                            scale: _pulseAnimation,
                            child: _buildNode(lesson, status, progress?.stars ?? 0),
                          )
                        : _buildNode(lesson, status, progress?.stars ?? 0),
                  ),

                  const SizedBox(height: 8),

                  // 레슨 제목
                  SizedBox(
                    width: 100,
                    child: Text(
                      lesson.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                        color: isUnlocked ? Colors.white : Colors.white54,
                      ),
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

  Widget _buildStartBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'START',
        style: TextStyle(
          color: Color(0xFF58CC02),
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNode(LessonModel lesson, LessonStatus status, int stars) {
    final isCompleted = status == LessonStatus.completed;
    final isLocked = status == LessonStatus.locked;
    final nodeColor = _getNodeColor(status, lesson.type);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 외곽 글로우 (활성 노드만)
        if (!isLocked)
          Container(
            width: _nodeSize + 12,
            height: _nodeSize + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: nodeColor.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

        // 3D 효과 바닥 원
        Container(
          width: _nodeSize,
          height: _nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLocked
                ? const Color(0xFF8A8A8A)
                : HSLColor.fromColor(nodeColor)
                    .withLightness(
                        (HSLColor.fromColor(nodeColor).lightness - 0.15)
                            .clamp(0.0, 1.0))
                    .toColor(),
          ),
        ),

        // 메인 원
        Container(
          width: _nodeSize - 4,
          height: _nodeSize - 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nodeColor,
            border: Border.all(
              color: isCompleted
                  ? Colors.white.withOpacity(0.5)
                  : isLocked
                      ? const Color(0xFF9A9A9A)
                      : Colors.white.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Center(
            child: _buildNodeIcon(status, lesson.type),
          ),
        ),

        // 별 표시 (완료 시)
        if (isCompleted && stars > 0)
          Positioned(
            bottom: -6,
            child: _buildStars(stars),
          ),
      ],
    );
  }

  Widget _buildNodeIcon(LessonStatus status, LessonType type) {
    if (status == LessonStatus.locked) {
      return const Icon(
        Icons.lock_rounded,
        color: Colors.white60,
        size: 32,
      );
    }
    if (status == LessonStatus.completed) {
      return const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 40,
      );
    }
    return Icon(
      _getTypeIcon(type),
      color: Colors.white,
      size: 34,
    );
  }

  Widget _buildStars(int stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FigmaColors.gold,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          stars.clamp(0, 3),
          (_) => const Icon(Icons.star_rounded, color: Colors.white, size: 14),
        ),
      ),
    );
  }

  Color _getNodeColor(LessonStatus status, LessonType type) {
    if (status == LessonStatus.locked) return FigmaColors.nodeLocked;
    if (status == LessonStatus.completed) return FigmaColors.nodeGreen;

    switch (type) {
      case LessonType.story:
        return FigmaColors.nodePurple;
      case LessonType.practice:
        return FigmaColors.nodeOrange;
      case LessonType.review:
        return FigmaColors.skyBlue;
      case LessonType.challenge:
        return FigmaColors.nodeRed;
      case LessonType.boss:
        return FigmaColors.nodeBoss;
      default:
        return FigmaColors.royalBlue;
    }
  }

  IconData _getTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.story:
        return Icons.menu_book_rounded;
      case LessonType.practice:
        return Icons.fitness_center_rounded;
      case LessonType.review:
        return Icons.replay_rounded;
      case LessonType.challenge:
        return Icons.flash_on_rounded;
      case LessonType.boss:
        return Icons.emoji_events_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
