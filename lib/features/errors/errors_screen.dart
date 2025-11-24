import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/error_note_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../problem/problem_screen.dart';

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
              // 통합 헤더 (홈 화면과 동일한 디자인)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.headerBlueGradient,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // 대칭을 위한 빈 공간
                    Expanded(
                      child: Text(
                        '오답 노트',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.headerText,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // 대칭을 위한 빈 공간
                  ],
                ),
              ),
              Expanded(
                child: ResponsiveWrapper(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildStatsGrid(errorStats),
                        _buildActionButtons(filteredNotes),
                        _buildFilterTabs(),
                        _buildErrorNotesList(userErrorNotes, filteredNotes),
                        if (filteredNotes.isEmpty)
                          _buildTips(),
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

  /// 통계 카드 그리드 (2x2 그리드로 변경 - 가독성 향상)
  Widget _buildStatsGrid(Map<String, int> errorStats) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingL,
          AppDimensions.paddingM,
          AppDimensions.paddingL,
          AppDimensions.paddingL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '총 오답',
                    errorStats['total']?.toString() ?? '0',
                    AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _buildStatCard(
                    '미복습',
                    errorStats['unreviewed']?.toString() ?? '0',
                    AppColors.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '1회 복습',
                    errorStats['reviewedOnce']?.toString() ?? '0',
                    AppColors.warningOrange,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _buildStatCard(
                    '2회 이상',
                    errorStats['reviewedTwice']?.toString() ?? '0',
                    AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 카드 - GoMath flat style (더 넉넉한 여백)
  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingL + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 액션 버튼들 (반응형 2열)
  Widget _buildActionButtons(List<ErrorNote> filteredNotes) {
    final user = ref.watch(userProvider);
    final userId = user?.id ?? 'user001';
    final selectedErrorCount = filteredNotes.length;

    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 500;

            if (isSmallScreen) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: selectedErrorCount > 0
                          ? () => _reviewSelectedProblems(filteredNotes)
                          : null,
                      icon: const Icon(Icons.refresh, size: AppDimensions.iconS),
                      label: Text('선택 문제 복습 ($selectedErrorCount)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: filteredNotes.isNotEmpty
                          ? () => _createCustomReviewSet(userId)
                          : null,
                      icon: const Icon(Icons.library_books,
                          size: AppDimensions.iconS),
                      label: const Text('맞춤 복습 세트'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: selectedErrorCount > 0
                        ? () => _reviewSelectedProblems(filteredNotes)
                        : null,
                    icon: const Icon(Icons.refresh, size: AppDimensions.iconS),
                    label: Text('선택 문제 복습 ($selectedErrorCount)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: filteredNotes.isNotEmpty
                        ? () => _createCustomReviewSet(userId)
                        : null,
                    icon: const Icon(Icons.library_books,
                        size: AppDimensions.iconS),
                    label: const Text('맞춤 복습 세트'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 필터 탭바 - GoMath flat style
  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingM,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXS),
      decoration: BoxDecoration(
        color: AppColors.background, // GoMath 배경색
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _filterTabs.map((tab) => Tab(height: 40, text: tab)).toList(),
        labelColor: AppColors.mathBlue, // GoMath 파란색 (선택됨)
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        indicator: BoxDecoration(
          color: AppColors.surface, // Duolingo flat white
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        indicatorPadding: const EdgeInsets.all(0),
        onTap: (_) => setState(() {}),
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
          child: _buildErrorNoteCard(errorNote),
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
        onActionPressed: () {
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

  /// 오답 노트 카드 - Duolingo flat style (개선: 그림자 추가)
  Widget _buildErrorNoteCard(ErrorNote errorNote) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: InkWell(
        onTap: () => _showErrorNoteDetails(errorNote),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderLight.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        errorNote.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    _buildStatusBadge(errorNote.status),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  errorNote.category,
                  style: const TextStyle(
                    color: AppColors.mathBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '복습 ${errorNote.reviewCount}회',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${errorNote.daysSinceCreated}일 전',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (errorNote.needsReview) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      '복습이 필요한 문제입니다',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warningOrange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }

  /// 상태 뱃지 - GoMath style
  Widget _buildStatusBadge(ErrorStatus status) {
    Color color;
    String text;

    switch (status) {
      case ErrorStatus.newError:
        color = AppColors.errorRed; // GoMath 빨간색
        text = '신규';
        break;
      case ErrorStatus.reviewing:
        color = AppColors.mathOrange; // GoMath 주황색
        text = '복습중';
        break;
      case ErrorStatus.improving:
        color = AppColors.mathBlue; // GoMath 파란색
        text = '향상중';
        break;
      case ErrorStatus.mastered:
        color = AppColors.successGreen; // GoMath 초록색
        text = '완료';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.surface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 학습 팁
  Widget _buildTips() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.warningOrange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warningOrange,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Flexible(
                child: Text(
                  '오답 노트 활용 팁',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.warningOrange,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            '• 틀린 문제는 자동으로 오답 노트에 저장됩니다',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• 같은 유형의 문제를 선택해서 집중 복습하세요',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '• 맞춤 복습 세트를 만들어 체계적으로 학습하세요',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  // 이벤트 핸들러들

  void _reviewSelectedProblems(List<ErrorNote> selectedNotes) {
    final selectedCount = selectedNotes.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Row(
          children: [
            Text('🔄', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              '선택 문제 복습',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '$selectedCount개의 문제를 복습하시겠습니까?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startReviewSession(selectedNotes);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mathButtonBlue,
            ),
            child: const Text('복습 시작'),
          ),
        ],
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: AppColors.primary, size: 24),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              '맞춤 복습 세트',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '어떤 기준으로 복습 세트를 만드시겠습니까?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createReviewSetByCategory(userId);
            },
            child: Text(
              '카테고리별',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mathButtonBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createReviewSetByDifficulty(userId);
            },
            child: Text(
              '난이도별',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mathButtonBlue,
              ),
            ),
          ),
        ],
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

  void _showErrorNoteDetails(ErrorNote errorNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Row(
          children: [
            Text('📝', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                '오답 노트 상세',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('문제', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(errorNote.question, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppDimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('내 답', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppDimensions.spacingXS),
                        Text(
                          errorNote.userAnswer,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('정답', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppDimensions.spacingXS),
                        Text(
                          errorNote.correctAnswer,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.successGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),

              Text('해설', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(errorNote.explanation, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppDimensions.spacingM),

              Wrap(
                spacing: AppDimensions.spacingM,
                runSpacing: AppDimensions.spacingS,
                children: [
                  _buildInfoChip('카테고리', errorNote.category, AppColors.mathBlue),
                  _buildInfoChip('난이도', errorNote.difficultyText, AppColors.mathOrange),
                  _buildInfoChip('복습', '${errorNote.reviewCount}회', AppColors.mathTeal),
                  _buildInfoChip('상태', errorNote.statusText, _getStatusColor(errorNote.status)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '닫기',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startReviewSession([errorNote]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mathButtonBlue,
            ),
            child: const Text('이 문제 복습하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ErrorStatus status) {
    switch (status) {
      case ErrorStatus.newError:
        return AppColors.errorRed;
      case ErrorStatus.reviewing:
        return AppColors.warningOrange;
      case ErrorStatus.improving:
        return AppColors.mathBlue;
      case ErrorStatus.mastered:
        return AppColors.successGreen;
    }
  }
}