import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/services/mock_data_service.dart';

/// 오답 노트 화면
/// 실제 스크린샷과 동일한 레이아웃으로 구현
class ErrorsScreen extends StatefulWidget {
  const ErrorsScreen({Key? key}) : super(key: key);

  @override
  State<ErrorsScreen> createState() => _ErrorsScreenState();
}

class _ErrorsScreenState extends State<ErrorsScreen>
    with TickerProviderStateMixin {
  final MockDataService _dataService = MockDataService();
  late TabController _tabController;

  List<ErrorNote> _allErrorNotes = [];
  Map<String, int> _errorStats = {};

  final List<String> _filterTabs = ['전체', '미복습', '1회', '2회+'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _allErrorNotes = _dataService.getSampleErrorNotes();
    _errorStats = _dataService.getErrorNoteStats(_allErrorNotes);
  }

  List<ErrorNote> get _filteredErrorNotes {
    final selectedTab = _filterTabs[_tabController.index];

    switch (selectedTab) {
      case '미복습':
        return _allErrorNotes.where((note) => note.reviewCount == 0).toList();
      case '1회':
        return _allErrorNotes.where((note) => note.reviewCount == 1).toList();
      case '2회+':
        return _allErrorNotes.where((note) => note.reviewCount >= 2).toList();
      default:
        return _allErrorNotes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('오답 노트'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildStatsGrid(),
          _buildActionButtons(),
          _buildFilterTabs(),
          Expanded(child: _buildErrorNotesList()),
          _buildTips(),
        ],
      ),
    );
  }

  /// 헤더 텍스트
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '틀린 문제를 복습하고 완벽하게 이해하세요',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            '반복 학습을 통해 약점을 보완하고 실력을 향상시킬 수 있습니다.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 통계 카드 그리드 (4열)
  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 500;

          if (isSmallScreen) {
            // 작은 화면에서는 2x2 그리드
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '총 오답',
                        _errorStats['total']?.toString() ?? '0',
                        AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildStatCard(
                        '미복습',
                        _errorStats['unreviewed']?.toString() ?? '0',
                        AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '1회 복습',
                        _errorStats['reviewedOnce']?.toString() ?? '0',
                        AppColors.warningOrange,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildStatCard(
                        '2회 이상',
                        _errorStats['reviewedTwice']?.toString() ?? '0',
                        AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // 일반 화면에서는 4열 가로 배치
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '총 오답',
                  _errorStats['total']?.toString() ?? '0',
                  AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  '미복습',
                  _errorStats['unreviewed']?.toString() ?? '0',
                  AppColors.errorRed,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  '1회 복습',
                  _errorStats['reviewedOnce']?.toString() ?? '0',
                  AppColors.warningOrange,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  '2회 이상',
                  _errorStats['reviewedTwice']?.toString() ?? '0',
                  AppColors.successGreen,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardElevation,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(color: valueColor),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.statLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 액션 버튼들 (2열)
  Widget _buildActionButtons() {
    final selectedErrorCount = _filteredErrorNotes.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: selectedErrorCount > 0 ? _reviewSelectedProblems : null,
              icon: const Icon(Icons.refresh, size: AppDimensions.iconS),
              label: Text('선택 문제 복습 ($selectedErrorCount)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _allErrorNotes.isNotEmpty ? _createCustomReviewSet : null,
              icon: const Icon(Icons.library_books, size: AppDimensions.iconS),
              label: const Text('맞춤 복습 세트 만들기'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 탭바
  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _filterTabs.map((tab) => Tab(text: tab)).toList(),
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppDimensions.cardElevation,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        onTap: (_) => setState(() {}),
      ),
    );
  }

  /// 오답 노트 목록
  Widget _buildErrorNotesList() {
    final filteredNotes = _filteredErrorNotes;

    if (filteredNotes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final errorNote = filteredNotes[index];
        return _buildErrorNoteCard(errorNote);
      },
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    final selectedTab = _filterTabs[_tabController.index];

    if (_allErrorNotes.isEmpty) {
      return EmptyState(
        icon: '📈',
        title: '오답이 없습니다!',
        message: '완벽한 학습을 이어가고 계시네요 🎉\n\n앞으로도 꾸준히 학습해보세요.',
        actionText: '학습하러 가기',
        onActionPressed: () {
          // TODO: 학습 화면으로 이동
        },
      );
    }

    return EmptyState(
      icon: '✅',
      title: '$selectedTab 문제가 없습니다',
      message: '다른 탭을 확인해보세요.',
    );
  }

  /// 오답 노트 카드
  Widget _buildErrorNoteCard(ErrorNote errorNote) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Card(
        child: InkWell(
          onTap: () => _showErrorNoteDetails(errorNote),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        errorNote.question.length > 50
                            ? '${errorNote.question.substring(0, 50)}...'
                            : errorNote.question,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    _buildStatusBadge(errorNote.status),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  errorNote.category,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '복습 ${errorNote.reviewCount}회',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '${errorNote.daysSinceCreated}일 전',
                      style: AppTextStyles.bodySmall,
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
                      color: AppColors.warningOrange.withOpacity(0.1),
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
      ),
    );
  }

  /// 상태 뱃지
  Widget _buildStatusBadge(ErrorStatus status) {
    Color color;
    String text;

    switch (status) {
      case ErrorStatus.new_error:
        color = AppColors.errorRed;
        text = '신규';
        break;
      case ErrorStatus.reviewing:
        color = AppColors.warningOrange;
        text = '복습중';
        break;
      case ErrorStatus.improving:
        color = AppColors.primaryBlue;
        text = '향상중';
        break;
      case ErrorStatus.mastered:
        color = AppColors.successGreen;
        text = '완료';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
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
        color: AppColors.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.warningOrange.withOpacity(0.3),
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

  void _reviewSelectedProblems() {
    final selectedCount = _filteredErrorNotes.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선택 문제 복습'),
        content: Text('$selectedCount개의 문제를 복습하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 복습 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$selectedCount개 문제 복습을 시작합니다!')),
              );
            },
            child: const Text('복습 시작'),
          ),
        ],
      ),
    );
  }

  void _createCustomReviewSet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('맞춤 복습 세트'),
        content: const Text('어떤 기준으로 복습 세트를 만드시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createReviewSetByCategory();
            },
            child: const Text('카테고리별'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createReviewSetByDifficulty();
            },
            child: const Text('난이도별'),
          ),
        ],
      ),
    );
  }

  void _createReviewSetByCategory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카테고리별 복습 세트를 생성합니다')),
    );
  }

  void _createReviewSetByDifficulty() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('난이도별 복습 세트를 생성합니다')),
    );
  }

  void _showErrorNoteDetails(ErrorNote errorNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오답 노트 상세'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('문제: ${errorNote.question}'),
              const SizedBox(height: AppDimensions.spacingS),
              Text('내 답: ${errorNote.userAnswer}',
                  style: const TextStyle(color: AppColors.errorRed)),
              Text('정답: ${errorNote.correctAnswer}',
                  style: const TextStyle(color: AppColors.successGreen)),
              const SizedBox(height: AppDimensions.spacingS),
              Text('해설: ${errorNote.explanation}'),
              const SizedBox(height: AppDimensions.spacingS),
              Text('복습 횟수: ${errorNote.reviewCount}회'),
              Text('상태: ${errorNote.statusText}'),
              Text('난이도: ${errorNote.difficultyText}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 이 문제만 복습하기
            },
            child: const Text('복습하기'),
          ),
        ],
      ),
    );
  }
}