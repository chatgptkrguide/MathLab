// Wrong Answer Screen
//
// Displays wrong answers with filtering and retry functionality
// Redesigned with gradient background, pill tabs, and staggered animations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/wrong_answer/wrong_answer_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/models/wrong_answer_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
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
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
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
        appBar: AppBar(title: const Text('오답 노트')),
        body: const Center(
          child: Text('사용자 정보를 불러올 수 없습니다'),
        ),
      );
    }

    final state = ref.watch(wrongAnswerProvider(user.uid));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.skyBlue.withValues(alpha: 0.15),
              Colors.white,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? _buildErrorState(state)
                  : _buildMainContent(user.uid, state),
        ),
      ),
    );
  }

  Widget _buildErrorState(WrongAnswerState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.mathRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.mathRed,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            '오답을 불러올 수 없습니다',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            state.error!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(String userId, WrongAnswerState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Stats cards
          SliverToBoxAdapter(
            child: WrongAnswerStats(statistics: state.statistics),
          ),

          // Pill tab bar
          SliverToBoxAdapter(child: _buildPillTabBar()),

          // Filter chips
          SliverToBoxAdapter(
            child: WrongAnswerFilterChips(
              currentFilter: state.currentFilter,
              onFilterChanged: (filter) {
                ref
                    .read(wrongAnswerProvider(userId).notifier)
                    .setFilter(filter);
              },
            ),
          ),

          // Content
          if (state.filteredAnswers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            _buildCardList(userId, state),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing20, AppDimensions.spacing16,
        AppDimensions.spacing20, AppDimensions.spacing8,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Text(
            '오답 노트',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing20,
        vertical: AppDimensions.spacing8,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing4),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
        ),
        child: Row(
          children: [
            _buildPillTab(0, '레슨별'),
            _buildPillTab(1, '단원별'),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(int index, String label) {
    final isActive = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Math-themed icon composition
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.mathGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.mathGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 40,
                      color: AppColors.mathGreen,
                    ),
                  ),
                  // Small decorative math icons
                  Positioned(
                    top: 5,
                    right: 10,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 5,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.mathPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'x',
                          style: TextStyle(
                            color: AppColors.mathPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            Text(
              '아직 오답이 없어요!',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              '완벽한 학습을 이어가세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(String userId, WrongAnswerState state) {
    final Map<String, List<WrongAnswerModel>> grouped;
    if (_selectedTabIndex == 0) {
      grouped = ref.read(wrongAnswerProvider(userId).notifier).groupByLesson();
    } else {
      grouped = ref.read(wrongAnswerProvider(userId).notifier).groupByUnit();
    }

    if (grouped.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    // Flatten grouped entries into a list of widgets for the sliver
    final items = <Widget>[];
    int cardIndex = 0;

    for (final entry in grouped.entries) {
      items.add(_buildGroupHeader(entry.key, entry.value.length));
      for (final answer in entry.value) {
        items.add(_StaggeredCard(
          index: cardIndex,
          child: WrongAnswerCard(
            wrongAnswer: answer,
            onRetry: () async {
              await ref
                  .read(wrongAnswerProvider(userId).notifier)
                  .retryWrongAnswer(answer.id);
              if (mounted) {
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('해결 완료로 표시되었습니다'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.mathGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
          ),
        ));
        cardIndex++;
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => items[index],
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacing16,
        bottom: AppDimensions.spacing8,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.spacing2),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing8),
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
              horizontal: AppDimensions.spacing8,
              vertical: AppDimensions.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Text(
              '$count개',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered entrance animation for cards
class _StaggeredCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredCard({
    required this.index,
    required this.child,
  });

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Stagger by index, capped at 5 to avoid long delays
    final delay = Duration(milliseconds: (widget.index.clamp(0, 5)) * 60);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: widget.child,
        ),
      ),
    );
  }
}
