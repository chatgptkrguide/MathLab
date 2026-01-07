import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../data/providers/subscription/premium_providers.dart';
import '../../data/providers/infrastructure/firebase_providers.dart';
import '../../data/models/subscription/premium_tier.dart';
import '../../data/models/subscription/subscription.dart';

/// 구독 관리 화면
///
/// 프리미엄 사용자가 현재 구독 상태를 확인하고 관리할 수 있는 화면입니다.
/// - 구독 정보 확인
/// - 구독 취소
/// - 구매 복원
/// - 결제 수단 변경
class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends ConsumerState<SubscriptionManagementScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('구독 관리'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: subscriptionAsync.when(
        data: (subscription) {
          if (subscription == null || !subscription.isActive) {
            // 프리미엄이 아닌 경우
            return _buildNoSubscriptionView();
          }

          // 프리미엄 사용자 UI
          return _buildSubscriptionView(subscription);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('구독 정보를 불러올 수 없습니다: $error'),
        ),
      ),
    );
  }

  /// 구독 없음 뷰
  Widget _buildNoSubscriptionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.workspace_premium_outlined,
              size: 100,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              '활성 구독이 없습니다',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '프리미엄을 구독하고 모든 기능을 사용해보세요!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: 프리미엄 업그레이드 화면으로 이동
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumGold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '프리미엄 구독하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 구독 정보 뷰
  Widget _buildSubscriptionView(Subscription subscription) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 구독 상태 카드
          _buildStatusCard(subscription),

          const SizedBox(height: 16),

          // 구독 정보 섹션
          _buildSubscriptionDetails(subscription),

          const SizedBox(height: 16),

          // 구독 관리 액션들
          _buildManagementActions(subscription),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 구독 상태 카드
  Widget _buildStatusCard(Subscription subscription) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: subscription.isTrial
              ? [AppColors.mathYellow, AppColors.mathOrange]
              : AppColors.premiumGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              subscription.isTrial ? Icons.star : Icons.workspace_premium,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // 상태 텍스트
          Text(
            subscription.isTrial ? '무료 체험 중' : '프리미엄 활성',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 등급 & 남은 기간
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subscription.tier.displayName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              if (subscription.tier != PremiumTier.lifetime) ...[
                Text(
                  ' • ',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  subscription.remainingTimeText,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),

          // 취소 경고
          if (subscription.isCancelled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '구독이 취소되었습니다. ${DateFormat('yyyy.MM.dd').format(subscription.expiryDate!)}까지 사용 가능합니다.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 구독 정보 상세
  Widget _buildSubscriptionDetails(Subscription subscription) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '구독 정보',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 플랜
          _buildInfoRow(
            icon: Icons.workspace_premium,
            label: '플랜',
            value: subscription.tier.displayName,
          ),

          const Divider(height: 24),

          // 가격
          _buildInfoRow(
            icon: Icons.payment,
            label: '가격',
            value: subscription.tier.formattedPrice,
          ),

          const Divider(height: 24),

          // 시작일
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: '시작일',
            value: dateFormat.format(subscription.startDate),
          ),

          const Divider(height: 24),

          // 만료일 (lifetime이 아닌 경우)
          if (subscription.expiryDate != null)
            _buildInfoRow(
              icon: Icons.event,
              label: subscription.tier == PremiumTier.lifetime ? '유효기간' : '만료일',
              value: subscription.tier == PremiumTier.lifetime
                  ? '평생'
                  : dateFormat.format(subscription.expiryDate!),
            ),

          if (subscription.expiryDate != null) const Divider(height: 24),

          // 자동 갱신
          if (subscription.tier != PremiumTier.lifetime)
            _buildInfoRow(
              icon: Icons.autorenew,
              label: '자동 갱신',
              value: subscription.autoRenew ? '활성화' : '비활성화',
              valueColor: subscription.autoRenew
                  ? AppColors.mathGreen
                  : AppColors.textSecondary,
            ),

          if (subscription.tier != PremiumTier.lifetime)
            const Divider(height: 24),

          // 플랫폼
          _buildInfoRow(
            icon: Icons.phone_android,
            label: '결제 플랫폼',
            value: subscription.platform == 'ios' ? 'App Store' : 'Google Play',
          ),

          const Divider(height: 24),

          // 상태
          _buildInfoRow(
            icon: Icons.info_outline,
            label: '상태',
            value: subscription.status.displayName,
            valueColor: Color(
              int.parse(subscription.status.colorHex.substring(1), radix: 16) +
                  0xFF000000,
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.premiumGold,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 관리 액션들
  Widget _buildManagementActions(Subscription subscription) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '구독 관리',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 구매 복원 버튼
          _buildActionButton(
            icon: Icons.refresh,
            title: '구매 복원',
            subtitle: '이전 구매 내역을 복원합니다',
            onTap: _handleRestorePurchases,
            color: AppColors.mathBlue,
          ),

          const SizedBox(height: 12),

          // 구독 취소 버튼 (취소되지 않은 경우만)
          if (!subscription.isCancelled &&
              subscription.tier != PremiumTier.lifetime)
            _buildActionButton(
              icon: Icons.cancel_outlined,
              title: '구독 취소',
              subtitle: '다음 결제일부터 갱신되지 않습니다',
              onTap: () => _handleCancelSubscription(subscription.id),
              color: AppColors.mathRed,
            ),

          // 구독 재활성화 버튼 (취소된 경우만)
          if (subscription.isCancelled && subscription.isActive)
            _buildActionButton(
              icon: Icons.restart_alt,
              title: '구독 재활성화',
              subtitle: '자동 갱신을 다시 활성화합니다',
              onTap: () => _handleRestoreSubscription(subscription.id),
              color: AppColors.mathGreen,
            ),
        ],
      ),
    );
  }

  /// 액션 버튼
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // 이벤트 핸들러
  // ========================================

  /// 구매 복원
  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final iapService = ref.read(inAppPurchaseServiceProvider);
      final success = await iapService.restorePurchases(user.uid);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매 복원이 완료되었습니다'),
            backgroundColor: AppColors.mathGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복원할 구매 내역이 없습니다'),
            backgroundColor: AppColors.mathOrange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구매 복원 실패: $e'),
          backgroundColor: AppColors.mathRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// 구독 취소
  Future<void> _handleCancelSubscription(String subscriptionId) async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 취소'),
        content: const Text(
          '정말 구독을 취소하시겠습니까?\n\n'
          '기간이 끝날 때까지는 프리미엄 기능을 계속 사용할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mathRed,
            ),
            child: const Text('구독 취소'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      await subscriptionService.cancelSubscription(subscriptionId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구독이 취소되었습니다'),
          backgroundColor: AppColors.mathGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구독 취소 실패: $e'),
          backgroundColor: AppColors.mathRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// 구독 재활성화
  Future<void> _handleRestoreSubscription(String subscriptionId) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      await subscriptionService.restoreSubscription(subscriptionId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구독이 재활성화되었습니다'),
          backgroundColor: AppColors.mathGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구독 재활성화 실패: $e'),
          backgroundColor: AppColors.mathRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
