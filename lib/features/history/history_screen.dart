import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/services/mock_data_service.dart';

/// 학습 이력 화면
/// 실제 스크린샷과 동일한 레이아웃으로 구현
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  final MockDataService _dataService = MockDataService();
  late TabController _tabController;

  LearningStats? _stats;

  final List<String> _periodTabs = ['오늘', '이번 주', '전체'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _periodTabs.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _stats = _dataService.getSampleLearningStats();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('학습 이력'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildStatsGrid(),
          _buildPeriodTabs(),
          Expanded(child: _buildHistoryContent()),
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
            '자세한 학습 기록을 확인하세요',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            '학습 패턴을 분석하여 더 나은 학습 계획을 세워보세요.',
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
                        icon: '🕐',
                        label: '총 학습 시간',
                        value: _stats!.formattedTotalStudyTime,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildStatCard(
                        icon: '🎯',
                        label: '푼 문제',
                        value: '${_stats!.totalProblems}개',
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: '📊',
                        label: '정답률',
                        value: '${_stats!.accuracyPercentage}%',
                        color: AppColors.warningOrange,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildStatCard(
                        icon: '🏆',
                        label: '학습 세션',
                        value: '${_stats!.totalSessions}회',
                        color: AppColors.purpleAccent,
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
                  icon: '🕐',
                  label: '총 학습 시간',
                  value: _stats!.formattedTotalStudyTime,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  icon: '🎯',
                  label: '푼 문제',
                  value: '${_stats!.totalProblems}개',
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  icon: '📊',
                  label: '정답률',
                  value: '${_stats!.accuracyPercentage}%',
                  color: AppColors.warningOrange,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  icon: '🏆',
                  label: '학습 세션',
                  value: '${_stats!.totalSessions}회',
                  color: AppColors.purpleAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
            icon,
            style: AppTextStyles.emojiLarge,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 기간 선택 탭바
  Widget _buildPeriodTabs() {
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
        tabs: _periodTabs.map((tab) => Tab(text: tab)).toList(),
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

  /// 학습 이력 콘텐츠
  Widget _buildHistoryContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPeriodContent('오늘'),
        _buildPeriodContent('이번 주'),
        _buildPeriodContent('전체'),
      ],
    );
  }

  /// 기간별 콘텐츠
  Widget _buildPeriodContent(String period) {
    // 모든 기간에서 빈 상태로 표시 (샘플 데이터가 없으므로)
    return EmptyState(
      icon: '📅',
      title: '학습 기록이 없습니다',
      message: '아직 $period 학습 기록이 없어요.\n학습을 시작해서 기록을 만들어보세요!',
      actionText: '학습 시작하기',
      onActionPressed: () {
        _navigateToLearning();
      },
    );
  }

  /// 학습 기록 카드 (실제 데이터가 있을 때 사용)
  Widget _buildHistoryCard({
    required String date,
    required int studyTime,
    required int problemsSolved,
    required int xpEarned,
    required double accuracy,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingXS,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      '+$xpEarned XP',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniStat('⏱️', '${studyTime}분'),
                  _buildMiniStat('📝', '$problemsSolved문제'),
                  _buildMiniStat('🎯', '${(accuracy * 100).round()}%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 미니 통계 위젯
  Widget _buildMiniStat(String icon, String value) {
    return Column(
      children: [
        Text(icon, style: AppTextStyles.emoji),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(value, style: AppTextStyles.bodySmall),
      ],
    );
  }

  // 이벤트 핸들러들

  void _navigateToLearning() {
    // TODO: 학습 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('학습 화면으로 이동합니다!'),
        action: SnackBarAction(
          label: '시작',
          onPressed: () {
            // 학습 화면으로 이동 로직
          },
        ),
      ),
    );
  }
}