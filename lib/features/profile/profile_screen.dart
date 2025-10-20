import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../shared/widgets/fade_in_widget.dart';
import '../../data/providers/user_provider.dart';

/// 프로필/계정 화면 (Figma 디자인 05)
/// 사용자 정보와 학습 통계를 표시
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
                _buildHeader(context),
                Expanded(
                  child: _buildContent(user),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 제목 + 설정)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Account',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // 설정 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  /// 메인 컨텐츠
  Widget _buildContent(user) {
    return Column(
      children: [
        // 프로필 섹션 (파란 배경)
        _buildProfileSection(user),
        // 통계 섹션 (흰색 배경)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: _buildStatisticsSection(user),
            ),
          ),
        ),
      ],
    );
  }

  /// 프로필 섹션 (파란 배경 영역)
  Widget _buildProfileSection(user) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
        child: Column(
          children: [
          // 프로필 사진
          Stack(
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.name?.isNotEmpty == true ? user!.name[0] : '학',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: AppColors.mathButtonBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // 이름
          Text(
            user?.name ?? '소인수분해',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          // 가입일
          Text(
            'Joined since 17 April 2021',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          // 통계 (Followers, Lifetime XP, Following)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTopStat('1,820', 'Followers'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildTopStat('12,695', 'Lifetime XP'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildTopStat('284', 'Following'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          // 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // 프로필 편집
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    ),
                  ),
                  child: Text(
                    'EDIT PROFILE',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 메시지
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mathButtonBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    ),
                  ),
                  child: Text(
                    'MESSAGE',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXL),
        ],
      ),
    ),
    );
  }

  /// 상단 통계 (Followers, Lifetime XP, Following)
  Widget _buildTopStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 섹션 (흰색 배경 영역)
  Widget _buildStatisticsSection(user) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Your Statistics',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        // 통계 카드들 (2x3 그리드)
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.spacingM,
          crossAxisSpacing: AppDimensions.spacingM,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
            _buildStatCard('Challenges', '235'),
            _buildStatCard('Lessons Passed', '138'),
            _buildStatCard('Total Diamonds', '1,239'),
            _buildStatCard('Total Lifetime', '18,539'),
            _buildStatCard('Correct Practices', '1,239'),
            _buildStatCard('Top 3 Position', '43'),
          ],
        ),
      ],
    ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
