// Challenge History Screen — Figma 스타일
// 틸 그린 헤더 + 학습 경로 노드 + 챌린지 정보
// 한 화면에 모든 정보 표시 (스크롤 없음)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson/lesson_progress_model.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/effects/noise_texture.dart';

class ChallengeHistoryScreen extends ConsumerWidget {
  const ChallengeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);
    final uid = authState.firebaseUser?.uid;

    if (uid == null || user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progressState = ref.watch(lessonProgressProvider(uid));
    final curriculumAsync = ref.watch(curriculumProvider);

    return curriculumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('커리큘럼을 불러오는데 실패했습니다'),
      ),
      data: (allUnits) {
        final totalLessons =
            allUnits.fold<int>(0, (sum, u) => sum + u.lessonCount);
        final completedLessons = progressState.completedCount;

        // 현재 활성 유닛 찾기
        String activeUnitTitle = allUnits.first.title;
        int activeUnitOrder = 1;
        for (final unit in allUnits) {
          for (final lesson in unit.lessons) {
            final lp = progressState.progressMap[lesson.id];
            if (lp != null && lp.status == LessonStatus.inProgress) {
              activeUnitTitle = unit.title;
              activeUnitOrder = unit.order;
              break;
            }
          }
        }

        final activeUnit = allUnits.firstWhere(
          (u) => u.order == activeUnitOrder,
          orElse: () => allUnits.first,
        );

        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(gradient: AppColors.tealGradient),
            ),
            const NoiseTexture(opacity: 0.025, color: Colors.white),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── 헤더: UNIT + 제목 ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'UNIT $activeUnitOrder',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeUnitTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 학습 경로 노드 ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildPathNodes(
                      activeUnit.lessons,
                      progressState.progressMap,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 메인 콘텐츠 (흰색 카드) ──
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 챌린지 제목 + 진행률
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '학습 이력',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                Text(
                                  '$completedLessons/$totalLessons',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // 진행률 바
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: totalLessons > 0
                                    ? completedLessons / totalLessons
                                    : 0,
                                minHeight: 8,
                                backgroundColor:
                                    AppColors.tealGreen.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<
                                    Color>(AppColors.tealGreen),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 통계 카드 Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.check_circle_rounded,
                                    iconColor: AppColors.tealGreen,
                                    label: '완료 레슨',
                                    value: '$completedLessons',
                                    bgColor: AppColors.tealGreen
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.local_fire_department_rounded,
                                    iconColor: const Color(0xFFFF9600),
                                    label: '연속 학습',
                                    value: '${user.streak}일',
                                    bgColor: const Color(0xFFFF9600)
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.bolt_rounded,
                                    iconColor: AppColors.skyBlue,
                                    label: '총 XP',
                                    value: '${user.totalXp}',
                                    bgColor: AppColors.skyBlue
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 최근 학습 과목 정보
                            Expanded(
                              child: _buildRecentUnits(
                                  allUnits, progressState.progressMap),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPathNodes(
    List lessons,
    Map<String, LessonProgressModel> progressMap,
  ) {
    final nodes = <_NodeState>[];
    bool foundActive = false;

    for (final lesson in lessons) {
      final progress = progressMap[lesson.id];
      if (progress == null || progress.status == LessonStatus.locked) {
        nodes.add(_NodeState.locked);
      } else if (progress.status == LessonStatus.completed) {
        nodes.add(_NodeState.completed);
      } else {
        if (!foundActive) {
          nodes.add(_NodeState.active);
          foundActive = true;
        } else {
          nodes.add(_NodeState.locked);
        }
      }
    }

    if (nodes.isEmpty) {
      nodes.addAll(
          [_NodeState.active, _NodeState.locked, _NodeState.locked]);
    }

    if (!foundActive && nodes.isNotEmpty) {
      final firstNonCompleted =
          nodes.indexWhere((n) => n != _NodeState.completed);
      if (firstNonCompleted >= 0) {
        nodes[firstNonCompleted] = _NodeState.active;
      }
    }

    // 최대 7개만 표시
    final displayNodes = nodes.take(7).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(displayNodes.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftState = displayNodes[i ~/ 2];
          final isCompleted = leftState == _NodeState.completed;
          return Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
        return _buildSingleNode(displayNodes[i ~/ 2]);
      }),
    );
  }

  Widget _buildSingleNode(_NodeState state) {
    const double size = 28;

    switch (state) {
      case _NodeState.completed:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 16, color: AppColors.tealGreen),
        );
      case _NodeState.active:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.star, size: 16, color: AppColors.tealGreen),
        );
      case _NodeState.locked:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock, size: 14, color: Colors.grey.shade400),
        );
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUnits(
    List allUnits,
    Map<String, LessonProgressModel> progressMap,
  ) {
    // 진행 중이거나 완료된 유닛 찾기
    final unitProgress = <Map<String, dynamic>>[];

    for (final unit in allUnits) {
      int completed = 0;
      bool hasProgress = false;

      for (final lesson in unit.lessons) {
        final lp = progressMap[lesson.id];
        if (lp != null && lp.status == LessonStatus.completed) {
          completed++;
          hasProgress = true;
        } else if (lp != null &&
            (lp.status == LessonStatus.inProgress ||
                lp.status == LessonStatus.unlocked)) {
          hasProgress = true;
        }
      }

      if (hasProgress) {
        unitProgress.add({
          'title': unit.title,
          'emoji': unit.emoji,
          'completed': completed,
          'total': unit.lessonCount,
        });
      }
    }

    if (unitProgress.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded,
                size: 40, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              '학습을 시작해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: unitProgress.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final unit = unitProgress[index];
        final progress = (unit['total'] as int) > 0
            ? (unit['completed'] as int) / (unit['total'] as int)
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(unit['emoji'] as String,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor:
                            AppColors.tealGreen.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.tealGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${unit['completed']}/${unit['total']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _NodeState { completed, active, locked }
