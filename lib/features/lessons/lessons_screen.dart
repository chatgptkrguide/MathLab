import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../data/providers/user_provider.dart';

/// 학습 카드 그리드 화면 (Figma 디자인 01)
/// 학습 주제별 카드를 그리드로 표시
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: Column(
              children: [
                _buildHeader(),
                _buildUserStats(
                  streakDays: user?.streakDays ?? 0,
                  xp: user?.xp ?? 0,
                  level: user?.level ?? 1,
                ),
                Expanded(
                  child: _buildLearningGrid(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (GoMath 스타일)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 햄버거 메뉴 아이콘
          Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
          // Home 텍스트
          Text(
            'Home',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // GoMath 로고 (임시로 텍스트)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'GoMATH',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.mathButtonBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자 통계 (상단)
  Widget _buildUserStats({
    required int streakDays,
    required int xp,
    required int level,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 사용자 이름
          Expanded(
            child: Text(
              '소인수분해',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 스트릭
          _buildStatItem('🔥', streakDays.toString()),
          const SizedBox(width: AppDimensions.spacingM),
          // XP
          _buildStatItem('🔶', xp.toString()),
          const SizedBox(width: AppDimensions.spacingM),
          // 레벨
          _buildStatItem('⭐', level.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 학습 카드 그리드
  Widget _buildLearningGrid(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          children: [
            // 큰 학습 카드들
            Row(
              children: [
                Expanded(
                  child: _buildLargeCard(
                    icon: '📚',
                    label: 'START!',
                    onTap: () => _showComingSoon(context, '학습 시작'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    children: [
                      _buildMediumCard(
                        icon: '📐',
                        onTap: () => _showComingSoon(context, '기하'),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      _buildMediumCard(
                        icon: '✏️',
                        onTap: () => _showComingSoon(context, '대수'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // 작은 아이콘 카드 그리드
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: AppDimensions.spacingM,
              crossAxisSpacing: AppDimensions.spacingM,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSmallCard('🎒', '가방'),
                _buildSmallCard('⏰', '시간'),
                _buildSmallCard('🏆', '트로피'),
                _buildSmallCard('💻', '컴퓨터'),
                _buildSmallCard('🌍', '지구본'),
                _buildSmallCard('📋', '칠판'),
                _buildSmallCard('⚛️', '원자'),
                _buildSmallCard('🔬', '현미경'),
                _buildSmallCard('📖', '책'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 큰 학습 카드
  Widget _buildLargeCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.mathButtonGradient,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.mathButtonBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 중간 크기 카드
  Widget _buildMediumCard({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.mathButtonGradient,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.mathButtonBlue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }

  /// 작은 아이콘 카드
  Widget _buildSmallCard(String icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mathBlueLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 기능이 곧 추가됩니다!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),
    );
  }
}
