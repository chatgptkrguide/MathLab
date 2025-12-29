import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../data/providers/subscription/premium_providers.dart';
import '../../data/providers/infrastructure/firebase_providers.dart';
import '../../data/models/subscription/premium_tier.dart';
import '../../data/services/premium_feature_service.dart';

/// 프리미엄 업그레이드 화면
///
/// 무료 vs 프리미엄 기능 비교, 가격 플랜, 구매 버튼을 제공합니다.
class PremiumUpgradeScreen extends ConsumerStatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  ConsumerState<PremiumUpgradeScreen> createState() =>
      _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends ConsumerState<PremiumUpgradeScreen> {
  PremiumTier _selectedTier = PremiumTier.yearly; // 기본 선택: 연간 (최고 할인율)
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final canStartTrial = ref.watch(canStartTrialProvider);
    final isPremiumActive = ref.watch(isPremiumActiveProvider);

    // 이미 프리미엄 사용자면 구독 관리 화면으로 리다이렉트
    if (isPremiumActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.premiumGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(context),

              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // 히어로 섹션
                      _buildHeroSection(),

                      const SizedBox(height: 32),

                      // 기능 비교표
                      _buildFeatureComparison(),

                      const SizedBox(height: 32),

                      // 가격 플랜
                      _buildPricingPlans(),

                      const SizedBox(height: 24),

                      // 무료 체험 버튼 (조건부)
                      if (canStartTrial) ...[
                        _buildTrialButton(user?.uid ?? ''),
                        const SizedBox(height: 16),
                      ],

                      // 구매 버튼
                      _buildPurchaseButton(user?.uid ?? ''),

                      const SizedBox(height: 16),

                      // 이용약관 & 개인정보처리방침
                      _buildLegalText(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 (닫기 버튼)
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 48), // 대칭을 위한 빈 공간
        ],
      ),
    );
  }

  /// 히어로 섹션
  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // 프리미엄 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // 타이틀
          Text(
            '프리미엄으로 업그레이드',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 서브타이틀
          Text(
            '무제한 학습과 모든 프리미엄 기능을\n지금 바로 사용해보세요!',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 기능 비교표
  Widget _buildFeatureComparison() {
    final featureService = PremiumFeatureService();
    final features = featureService.getFeatureComparisons();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '무료 vs 프리미엄',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 헤더 행
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(''),
                ),
                Expanded(
                  child: Text(
                    '무료',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '프리미엄',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.premiumGold,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // 기능 행들
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // 아이콘 & 이름
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              feature.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 무료 값
                      Expanded(
                        child: Text(
                          feature.freeValue,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // 프리미엄 값
                      Expanded(
                        child: Text(
                          feature.premiumValue,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.premiumGold,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 가격 플랜
  Widget _buildPricingPlans() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '플랜 선택',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 월간 플랜
          _buildPricingCard(
            tier: PremiumTier.monthly,
            title: '월간',
            price: PremiumTier.monthly.formattedPrice,
            period: '/월',
            description: '언제든지 취소 가능',
          ),

          const SizedBox(height: 12),

          // 연간 플랜 (추천)
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildPricingCard(
                tier: PremiumTier.yearly,
                title: '연간',
                price: PremiumTier.yearly.formattedPrice,
                period: '/년',
                description: '${PremiumTier.yearly.formattedMonthlyEquivalent}/월 (${PremiumTier.yearly.discountPercentage.toStringAsFixed(0)}% 절약)',
                isRecommended: true,
              ),

              // 추천 뱃지
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mathOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '최고 절약',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 평생 플랜
          _buildPricingCard(
            tier: PremiumTier.lifetime,
            title: '평생',
            price: PremiumTier.lifetime.formattedPrice,
            period: '',
            description: '단 한 번만 결제하고 영구 사용',
          ),
        ],
      ),
    );
  }

  /// 가격 카드
  Widget _buildPricingCard({
    required PremiumTier tier,
    required String title,
    required String price,
    required String period,
    required String description,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTier = tier;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.premiumGold : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.premiumGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 선택 라디오
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.premiumGold : AppColors.borderLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.premiumGold : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // 플랜 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 가격
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.premiumGold : AppColors.textPrimary,
                      ),
                    ),
                    if (period.isNotEmpty)
                      Text(
                        period,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 무료 체험 버튼
  Widget _buildTrialButton(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isPurchasing ? null : () => _handleStartTrial(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.premiumPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: _isPurchasing
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '7일 무료 체험 시작',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// 구매 버튼
  Widget _buildPurchaseButton(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isPurchasing ? null : () => _handlePurchase(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.premiumGold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: _isPurchasing
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '지금 구매하기',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// 법적 텍스트
  Widget _buildLegalText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            '• 구독은 현재 기간이 끝나기 최소 24시간 전에 자동 갱신을 끄지 않으면 자동으로 갱신됩니다.\n'
            '• 계정은 현재 기간이 끝나기 24시간 이내에 갱신 비용이 청구됩니다.\n'
            '• 구독은 사용자가 관리하며, 구매 후 사용자의 계정 설정으로 이동하여 자동 갱신을 끌 수 있습니다.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: 이용약관 페이지 열기
                },
                child: Text(
                  '이용약관',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' • ',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 개인정보처리방침 페이지 열기
                },
                child: Text(
                  '개인정보처리방침',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================
  // 이벤트 핸들러
  // ========================================

  /// 무료 체험 시작
  Future<void> _handleStartTrial(String userId) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);

      // 무료 체험 시작
      await subscriptionService.startFreeTrial(userId, 'mobile');

      if (!mounted) return;

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 7일 무료 체험이 시작되었습니다!'),
          backgroundColor: AppColors.mathGreen,
        ),
      );

      // 화면 닫기
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // 오류 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('체험 시작 실패: $e'),
          backgroundColor: AppColors.mathRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  /// 구매 처리
  Future<void> _handlePurchase(String userId) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final iapService = ref.read(inAppPurchaseServiceProvider);

      // IAP 구매 시작
      await iapService.purchaseSubscription(
        userId: userId,
        tier: _selectedTier,
        onComplete: (success, error) {
          if (!mounted) return;

          if (success) {
            // 성공 메시지
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 프리미엄 구독이 완료되었습니다!'),
                backgroundColor: AppColors.mathGreen,
              ),
            );

            // 화면 닫기
            Navigator.of(context).pop();
          } else {
            // 오류 메시지
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? '구매 실패'),
                backgroundColor: AppColors.mathRed,
              ),
            );
          }

          setState(() {
            _isPurchasing = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      // 오류 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구매 처리 오류: $e'),
          backgroundColor: AppColors.mathRed,
        ),
      );

      setState(() {
        _isPurchasing = false;
      });
    }
  }
}
