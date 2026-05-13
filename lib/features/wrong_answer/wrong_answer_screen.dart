// Wrong Answer Screen — Figma "02" 디자인
// 파란 헤더 + 카테고리 카드 형태
// 한 화면에 모든 정보 표시 (스크롤 최소화)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import 'widgets/wrong_answer_card.dart';

class WrongAnswerScreen extends ConsumerStatefulWidget {
  /// 코치마크용 GlobalKey
  static final wrongAnswerHeaderKey = GlobalKey(debugLabel: 'wrongAnswerHeader');

  const WrongAnswerScreen({super.key});

  @override
  ConsumerState<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends ConsumerState<WrongAnswerScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('사용자 정보를 불러올 수 없습니다')),
      );
    }

    final state = ref.watch(wrongAnswerProvider(user.uid));

    return Stack(
      children: [
        // Background gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.skyBlueGradient),
        ),
        const NoiseTexture(opacity: 0.025, color: Colors.white),
        SafeArea(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── 헤더 ──
                    Padding(
                      key: WrongAnswerScreen.wrongAnswerHeaderKey,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '오답 노트',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // 총 오답 수 (카테고리 필터 반영)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${_selectedCategory == null ? state.filteredAnswers.length : state.filteredAnswers.where((a) => a.unitName == _selectedCategory).length}개',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── 카테고리 필터 (칩) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCategoryChips(user.uid),
                    ),

                    const SizedBox(height: 14),

                    // ── 오답 목록 (흰색 카드) ──
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: (_selectedCategory == null
                                ? state.filteredAnswers
                                : state.filteredAnswers
                                    .where((a) => a.unitName == _selectedCategory)
                                    .toList())
                            .isEmpty
                            ? _buildEmptyState()
                            : _buildAnswerList(user.uid, state),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(String userId) {
    final grouped =
        ref.read(wrongAnswerProvider(userId).notifier).groupByUnit();
    final categories = grouped.keys.toList();

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('전체', _selectedCategory == null),
          for (final cat in categories) ...[
            const SizedBox(width: 8),
            _buildChip(cat, _selectedCategory == cat),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() =>
          _selectedCategory = (label == '전체') ? null : label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(17),
          border: isActive
              ? Border.all(
                  color: AppColors.xpGold.withValues(alpha: 0.6),
                  width: 1.5,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            // 활성: xpGold 계열 accent, 비활성: alpha 0.5 절제
            color: isActive
                ? AppColors.xpGold
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 40,
              color: AppColors.skyBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 오답이 없어요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '완벽한 학습을 이어가세요',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerList(String userId, WrongAnswerState state) {
    // 카테고리 필터 적용
    final answers = _selectedCategory == null
        ? state.filteredAnswers
        : state.filteredAnswers
            .where((a) => a.unitName == _selectedCategory)
            .toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: answers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return WrongAnswerCard(
          wrongAnswer: answer,
          onRetry: () async {
            await ref
                .read(wrongAnswerProvider(userId).notifier)
                .retryWrongAnswer(answer.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('문제를 다시 풀어보세요'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          onMarkResolved: () async {
            await ref
                .read(wrongAnswerProvider(userId).notifier)
                .markAsResolved(answer.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('해결 완료!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
