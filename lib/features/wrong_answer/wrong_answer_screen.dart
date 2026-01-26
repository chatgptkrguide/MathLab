/// 📝 Wrong Answer Screen
///
/// Displays wrong answers with filtering and retry functionality

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/models/wrong_answer_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import 'widgets/wrong_answer_card.dart';
import 'widgets/wrong_answer_stats.dart';
import 'widgets/wrong_answer_filter_chips.dart';

class WrongAnswerScreen extends ConsumerStatefulWidget {
  const WrongAnswerScreen({super.key});

  @override
  ConsumerState<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends ConsumerState<WrongAnswerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final userState = ref.read(userProvider);
    if (userState != null) {
      await ref
          .read(wrongAnswerProvider(userState.uid).notifier)
          .loadWrongAnswers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('오답 노트'),
        ),
        body: const Center(
          child: Text('사용자 정보를 불러올 수 없습니다'),
        ),
      );
    }

    final state = ref.watch(wrongAnswerProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '오답 노트',
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '레슨별'),
                Tab(text: '단원별'),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '오답을 불러올 수 없습니다',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Column(
                    children: [
                      // Statistics Card
                      WrongAnswerStats(statistics: state.statistics),

                      // Filter Chips
                      WrongAnswerFilterChips(
                        currentFilter: state.currentFilter,
                        onFilterChanged: (filter) {
                          ref
                              .read(wrongAnswerProvider(user.uid)
                                  .notifier)
                              .setFilter(filter);
                        },
                      ),

                      // Content
                      Expanded(
                        child: state.filteredAnswers.isEmpty
                            ? _buildEmptyState()
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLessonGroupView(
                                      user.uid, state),
                                  _buildUnitGroupView(
                                      user.uid, state),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '오답이 없습니다',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '완벽해요! 계속 열심히 공부하세요.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonGroupView(String userId, WrongAnswerState state) {
    final groupedByLesson =
        ref.read(wrongAnswerProvider(userId).notifier).groupByLesson();

    if (groupedByLesson.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedByLesson.length,
      itemBuilder: (context, index) {
        final lessonName = groupedByLesson.keys.elementAt(index);
        final answers = groupedByLesson[lessonName]!;

        return _buildGroupSection(
          title: lessonName,
          answers: answers,
          userId: userId,
        );
      },
    );
  }

  Widget _buildUnitGroupView(String userId, WrongAnswerState state) {
    final groupedByUnit =
        ref.read(wrongAnswerProvider(userId).notifier).groupByUnit();

    if (groupedByUnit.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedByUnit.length,
      itemBuilder: (context, index) {
        final unitName = groupedByUnit.keys.elementAt(index);
        final answers = groupedByUnit[unitName]!;

        return _buildGroupSection(
          title: unitName,
          answers: answers,
          userId: userId,
        );
      },
    );
  }

  Widget _buildGroupSection({
    required String title,
    required List<WrongAnswerModel> answers,
    required String userId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${answers.length}개',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Wrong Answer Cards
        ...answers.map((answer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WrongAnswerCard(
                wrongAnswer: answer,
                onRetry: () async {
                  await ref
                      .read(wrongAnswerProvider(userId).notifier)
                      .retryWrongAnswer(answer.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('문제를 다시 풀어보세요'),
                      ),
                    );
                  }
                },
                onMarkResolved: () async {
                  await ref
                      .read(wrongAnswerProvider(userId).notifier)
                      .markAsResolved(answer.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('해결 완료로 표시되었습니다'),
                      ),
                    );
                  }
                },
              ),
            )),

        const SizedBox(height: 16),
      ],
    );
  }
}
