import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/learning/error_note_provider.dart';
import '../../data/providers/learning/problem_provider.dart';
import '../problem/problem_screen.dart';
import 'widgets/widgets.dart';
import 'dialogs/dialogs.dart';

/// 오답 노트 화면
/// 실제 ErrorNoteProvider 데이터 기반으로 구현
class ErrorsScreen extends ConsumerStatefulWidget {
  const ErrorsScreen({super.key});

  @override
  ConsumerState<ErrorsScreen> createState() => _ErrorsScreenState();
}

class _ErrorsScreenState extends ConsumerState<ErrorsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _filterTabs = ['전체', '미복습', '1회', '2회+'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ErrorNote> _getFilteredErrorNotes(List<ErrorNote> allNotes) {
    final selectedTab = _filterTabs[_tabController.index];

    switch (selectedTab) {
      case '미복습':
        return allNotes.where((note) => note.reviewCount == 0).toList();
      case '1회':
        return allNotes.where((note) => note.reviewCount == 1).toList();
      case '2회+':
        return allNotes.where((note) => note.reviewCount >= 2).toList();
      default:
        return allNotes;
    }
  }

  Map<String, int> _getErrorStats(List<ErrorNote> allNotes) {
    return {
      'total': allNotes.length,
      'unreviewed': allNotes.where((note) => note.reviewCount == 0).length,
      'reviewedOnce': allNotes.where((note) => note.reviewCount == 1).length,
      'reviewedTwice': allNotes.where((note) => note.reviewCount >= 2).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final userId = user?.id ?? 'user001';

    // ErrorNoteProvider에서 사용자의 오답 노트 가져오기
    final allErrorNotes = ref.watch(errorNoteProvider);
    final userErrorNotes = allErrorNotes.where((note) => note.userId == userId).toList();
    final filteredNotes = _getFilteredErrorNotes(userErrorNotes);
    final errorStats = _getErrorStats(userErrorNotes);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6DA5D8),
              Color(0xFFE8F4FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 공통 헤더 위젯 사용
              const CommonAppHeader(
                title: '오답 노트',
              ),
              Expanded(
                child: ResponsiveWrapper(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        ErrorStatsGrid(errorStats: errorStats),
                        FadeInWidget(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 100),
                          child: ErrorActionButtons(
                            filteredNotes: filteredNotes,
                            onReviewSelected: () => _reviewSelectedProblems(filteredNotes),
                            onCreateCustomSet: () => _createCustomReviewSet(userId),
                          ),
                        ),
                        ErrorFilterTabs(
                          controller: _tabController,
                          filterTabs: _filterTabs,
                          onTabChanged: () => setState(() {}),
                        ),
                        _buildErrorNotesList(userErrorNotes, filteredNotes),
                        if (filteredNotes.isEmpty)
                          const LearningTipsCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 텍스트 - Duolingo style
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '틀린 문제를 복습하고 완벽하게 이해하세요',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          const Text(
            '반복 학습을 통해 약점을 보완하고 실력을 향상시킬 수 있습니다.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }



  /// 오답 노트 목록
  Widget _buildErrorNotesList(List<ErrorNote> allNotes, List<ErrorNote> filteredNotes) {
    if (filteredNotes.isEmpty) {
      return _buildEmptyState(allNotes);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final errorNote = filteredNotes[index];
        return FadeInWidget(
          delay: Duration(milliseconds: 50 * index),
          child: ErrorNoteCard(
            errorNote: errorNote,
            onTap: () => _navigateToProblemReview(errorNote),
          ),
        );
      },
    );
  }

  /// 빈 상태
  Widget _buildEmptyState(List<ErrorNote> allNotes) {
    final selectedTab = _filterTabs[_tabController.index];

    if (allNotes.isEmpty) {
      return EmptyState(
        icon: Icons.trending_up,
        title: '오답이 없습니다!',
        message: '완벽한 학습을 이어가고 계시네요.\n\n앞으로도 꾸준히 학습해보세요.',
        actionText: '학습하러 가기',
        onAction: () {
          // 학습 화면으로 이동 (Lessons 탭으로 변경)
          DefaultTabController.of(context).animateTo(1);
        },
      );
    }

    return EmptyState(
      icon: Icons.check_circle,
      title: '$selectedTab 문제가 없습니다',
      message: '다른 탭을 확인해보세요.',
    );
  }


  // 이벤트 핸들러들

  void _reviewSelectedProblems(List<ErrorNote> selectedNotes) {
    showDialog(
      context: context,
      builder: (context) => ReviewConfirmationDialog(
        selectedCount: selectedNotes.length,
        onConfirm: () => _startReviewSession(selectedNotes),
      ),
    );
  }

  void _startReviewSession(List<ErrorNote> errorNotes) {
    // 오답 노트에서 문제 ID 추출
    final problemIds = errorNotes.map((note) => note.problemId).toList();

    // ProblemProvider에서 해당 문제들 가져오기
    final allProblems = ref.read(problemProvider);
    final reviewProblems = allProblems
        .where((problem) => problemIds.contains(problem.id))
        .toList();

    if (reviewProblems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복습할 문제를 찾을 수 없습니다.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // 문제 풀이 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemScreen(
          lessonId: 'review_session',
          problems: reviewProblems,
        ),
      ),
    );

    // 복습 카운트 증가 (각 오답 노트)
    for (final errorNote in errorNotes) {
      ref.read(errorNoteProvider.notifier).reviewErrorNote(errorNote.id);
    }
  }

  void _createCustomReviewSet(String userId) {
    showDialog(
      context: context,
      builder: (context) => CustomReviewSetDialog(
        onCreateByCategory: () => _createReviewSetByCategory(userId),
        onCreateByDifficulty: () => _createReviewSetByDifficulty(userId),
      ),
    );
  }

  void _createReviewSetByCategory(String userId) {
    // 카테고리별 맞춤 복습 세트 생성
    final customSet = ref.read(errorNoteProvider.notifier).createCustomReviewSet(
      userId: userId,
      maxCount: 10,
    );

    if (customSet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복습할 문제가 없습니다.'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    _startReviewSession(customSet);
  }

  void _createReviewSetByDifficulty(String userId) {
    // 난이도별 맞춤 복습 세트 생성 (난이도 3 이하)
    final customSet = ref.read(errorNoteProvider.notifier).createCustomReviewSet(
      userId: userId,
      maxDifficulty: 3,
      maxCount: 10,
    );

    if (customSet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복습할 문제가 없습니다.'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    _startReviewSession(customSet);
  }

  void _navigateToProblemReview(ErrorNote errorNote) {
    showDialog(
      context: context,
      builder: (context) => ErrorNoteDetailDialog(
        errorNote: errorNote,
        onReview: () => _startReviewSession([errorNote]),
      ),
    );
  }
}