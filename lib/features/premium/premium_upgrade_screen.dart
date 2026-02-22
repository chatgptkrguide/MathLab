import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../data/providers/subscription/premium_providers.dart';
import '../../data/providers/infrastructure/firebase_providers.dart';
import '../../data/models/subscription/premium_tier.dart';
import 'widgets/widgets.dart';

/// 프리미엄 업그레이드 화면
///
/// 무료 vs 프리미엄 기능 비교, 가격 플랜, 구매 버튼을 제공합니다.
/// Hero section: gradient blue to purple background
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.mathBlue, // Brand blue
              Color(0xFF7E57C2), // Purple
              Color(0xFF5E35B1), // Deep purple
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              const PremiumHeader(),

              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.spacing16),

                      // 히어로 섹션
                      const PremiumHeroSection(),

                      const SizedBox(height: AppDimensions.spacing32),

                      // 기능 비교표
                      const PremiumFeatureComparison(),

                      const SizedBox(height: AppDimensions.spacing32),

                      // 가격 플랜
                      PremiumPricingPlans(
                        selectedTier: _selectedTier,
                        onTierSelected: (tier) {
                          setState(() {
                            _selectedTier = tier;
                          });
                        },
                      ),

                      const SizedBox(height: AppDimensions.spacing24),

                      // 무료 체험 버튼 (조건부)
                      if (canStartTrial) ...[
                        PremiumTrialButton(
                          isPurchasing: _isPurchasing,
                          onPressed: () => _handleStartTrial(user?.uid ?? ''),
                        ),
                        const SizedBox(height: AppDimensions.spacing16),
                      ],

                      // 구매 버튼
                      PremiumPurchaseButton(
                        isPurchasing: _isPurchasing,
                        onPressed: () => _handlePurchase(user?.uid ?? ''),
                      ),

                      const SizedBox(height: AppDimensions.spacing16),

                      // 이용약관 & 개인정보처리방침
                      const PremiumLegalText(),

                      const SizedBox(height: AppDimensions.spacing32),
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
          content: Text('7일 무료 체험이 시작되었습니다!'),
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
                content: Text('프리미엄 구독이 완료되었습니다!'),
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
