import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/models/lesson/lesson_progress_model.dart';
import '../../../shared/constants/figma_colors.dart';
import 'curved_path_painter.dart';

/// 듀오링고 스타일 학습 경로 위젯
///
/// S자 곡선 경로 위에 레슨 노드를 배치하는 스크롤 가능한 위젯.
/// 스태거드 입장, 탭 스프링, 경로 진행 애니메이션 포함.
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
  // 기존 pulse 애니메이션
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // 스태거드 입장 애니메이션
  late AnimationController _entranceController;

  // 경로 진행 애니메이션
  late AnimationController _pathProgressController;
  late Animation<double> _pathProgressAnimation;

  // 탭 스프링 상태 (인덱스별)
  final Map<int, AnimationController> _tapControllers = {};

  static const double _nodeSize = 80.0;
  static const double _verticalSpacing = 140.0;
  static const double _startY = 60.0;


  @override
  void initState() {
    super.initState();

    // Pulse (현재 노드 숨쉬기)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 스태거드 입장
    _entranceController = AnimationController(
      duration: Duration(
        milliseconds: 500 + (widget.lessons.length * 80),
      ),
      vsync: this,
    )..forward();

    // 경로 진행 애니메이션
    _pathProgressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pathProgressAnimation = CurvedAnimation(
      parent: _pathProgressController,
      curve: Curves.easeInOut,
    );
    // 약간 딜레이 후 경로 그리기 시작
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _pathProgressController.forward();
    });
  }

  AnimationController _getTapController(int index) {
    if (!_tapControllers.containsKey(index)) {
      _tapControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
        lowerBound: 0.0,
        upperBound: 1.0,
      );
    }
    return _tapControllers[index]!;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _pathProgressController.dispose();
    for (final c in _tapControllers.values) {
      c.dispose();
    }
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
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _pathProgressAnimation]),
        builder: (context, _) {
          return Stack(
            children: [
              // 배경 곡선 경로 (애니메이션 진행)
              CustomPaint(
                size: Size(screenWidth, totalHeight),
                painter: CurvedPathPainter(
                  nodePositions: nodePositions,
                  completedCount: _completedCount,
                  pathProgress: _pathProgressAnimation.value,
                ),
              ),

              // 레슨 노드들 (스태거드 입장)
              ...List.generate(widget.lessons.length, (index) {
                final lesson = widget.lessons[index];
                final progress = widget.progressMap[lesson.id];
                final position = nodePositions[index];
                final isCurrent = index == _currentLessonIndex;
                // 첫 번째 레슨은 항상 잠금 해제, 또는 이전 레슨이 완료된 경우
                final isFirstOrPreviousCompleted = index == 0 ||
                    (index > 0 && widget.progressMap[widget.lessons[index - 1].id]?.status == LessonStatus.completed);
                final status = progress?.status ??
                    (isFirstOrPreviousCompleted ? LessonStatus.unlocked : LessonStatus.locked);
                final isUnlocked = status != LessonStatus.locked;

                // 스태거드 입장 progress (0~1)
                final staggerStart = (index * 80) /
                    (500 + widget.lessons.length * 80).toDouble();
                final staggerEnd = ((index * 80) + 500) /
                    (500 + widget.lessons.length * 80).toDouble();
                final entranceProgress = Curves.elasticOut.transform(
                  ((_entranceController.value - staggerStart) /
                          (staggerEnd - staggerStart))
                      .clamp(0.0, 1.0),
                );

                return Positioned(
                  left: position.dx - (_nodeSize / 2),
                  top: position.dy - (_nodeSize / 2),
                  child: Transform.scale(
                    scale: entranceProgress,
                    child: Opacity(
                      opacity: entranceProgress.clamp(0.0, 1.0),
                      child: _buildNodeColumn(
                        index: index,
                        lesson: lesson,
                        status: status,
                        stars: progress?.stars ?? 0,
                        isCurrent: isCurrent,
                        isUnlocked: isUnlocked,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNodeColumn({
    required int index,
    required LessonModel lesson,
    required LessonStatus status,
    required int stars,
    required bool isCurrent,
    required bool isUnlocked,
  }) {
    final tapCtrl = _getTapController(index);

    return Column(
      children: [
        // START 배지 (현재 레슨에만)
        if (isCurrent && isUnlocked && status != LessonStatus.completed)
          _buildStartBadge(),

        // 레슨 노드 + 탭 스프링
        GestureDetector(
          onTapDown: isUnlocked
              ? (_) {
                  HapticFeedback.lightImpact();
                  tapCtrl.forward();
                }
              : null,
          onTapUp: isUnlocked
              ? (_) {
                  tapCtrl.reverse();
                  widget.onLessonTap(lesson.id);
                }
              : null,
          onTapCancel: isUnlocked ? () => tapCtrl.reverse() : null,
          child: AnimatedBuilder(
            animation: tapCtrl,
            builder: (context, child) {
              final scale = 1.0 - (tapCtrl.value * 0.1); // 1.0 → 0.9
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: isCurrent && isUnlocked && status != LessonStatus.completed
                ? ScaleTransition(
                    scale: _pulseAnimation,
                    child: _buildNode(lesson, status, stars, isCurrent: true),
                  )
                : _buildNode(lesson, status, stars, isCurrent: false),
          ),
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
    );
  }

  Widget _buildStartBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        gradient: FigmaColors.deepBlueCTA,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FigmaColors.deepBlue.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        'START!',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNode(
    LessonModel lesson,
    LessonStatus status,
    int stars, {
    required bool isCurrent,
  }) {
    final isCompleted = status == LessonStatus.completed;
    final isLocked = status == LessonStatus.locked;
    final nodeColor = _getNodeColor(status, lesson.type);
    final nodeImagePath = _getNodeImagePath(lesson.type, status);

    Widget nodeWidget = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 외곽 글로우 (활성 노드)
        if (!isLocked)
          Container(
            width: _nodeSize + 12,
            height: _nodeSize + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: nodeColor.withValues(alpha: isCurrent ? 0.6 : 0.35),
                  blurRadius: isCurrent ? 22 : 14,
                  spreadRadius: isCurrent ? 4 : 2,
                ),
              ],
            ),
          ),

        // 3D 바닥 그림자
        Positioned(
          top: 4,
          child: Container(
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
        ),

        // 메인 원 + RadialGradient 오버레이
        Container(
          width: _nodeSize,
          height: _nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isLocked
                ? null
                : RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    radius: 1.0,
                    colors: [
                      Color.lerp(nodeColor, Colors.white, 0.2)!,
                      nodeColor,
                      Color.lerp(nodeColor, Colors.black, 0.15)!,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
            color: isLocked ? FigmaColors.nodeLockedBg : null,
            border: Border.all(
              color: isCompleted
                  ? Colors.white.withValues(alpha: 0.6)
                  : isLocked
                      ? const Color(0xFFD0D0D0)
                      : Colors.white.withValues(alpha: 0.4),
              width: 4,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: nodeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                // 아이콘/이미지 콘텐츠
                Center(
                  child: _buildNodeContent(nodeImagePath, status, lesson.type),
                ),
                // 글로시 하이라이트
                if (!isLocked)
                  Positioned(
                    top: 2,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: _nodeSize * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_nodeSize),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            FigmaColors.glossyHighlight,
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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

    // 현재 노드에 shimmer 글로우 효과
    if (isCurrent && !isLocked && !isCompleted) {
      nodeWidget = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // shimmer 글로우 배경 링
          Shimmer.fromColors(
            baseColor: nodeColor.withValues(alpha: 0.3),
            highlightColor: nodeColor.withValues(alpha: 0.7),
            period: const Duration(milliseconds: 2000),
            child: Container(
              width: _nodeSize + 20,
              height: _nodeSize + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          nodeWidget,
        ],
      );
    }

    return nodeWidget;
  }

  String? _getNodeImagePath(LessonType type, LessonStatus status) {
    if (status == LessonStatus.locked) return null;
    return null; // 아직 이미지 에셋 없음 → 아이콘 폴백
  }

  Widget _buildNodeContent(String? imagePath, LessonStatus status, LessonType type) {
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildNodeIcon(status, type),
      );
    }
    return _buildNodeIcon(status, type);
  }

  Widget _buildNodeIcon(LessonStatus status, LessonType type) {
    if (status == LessonStatus.locked) {
      return const Icon(Icons.lock_rounded, color: Colors.white60, size: 32);
    }
    if (status == LessonStatus.completed) {
      return const Icon(Icons.check_rounded, color: Colors.white, size: 40);
    }
    return Icon(_getTypeIcon(type), color: Colors.white, size: 34);
  }

  Widget _buildStars(int stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FigmaColors.gold,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
