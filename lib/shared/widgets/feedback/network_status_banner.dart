import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../../data/services/network_service.dart';

/// 네트워크 상태를 표시하는 배너 위젯
///
/// 오프라인일 때만 화면 상단에 배너를 표시합니다.
class NetworkStatusBanner extends ConsumerWidget {
  final Widget child;

  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Column(
      children: [
        // 네트워크 배너 (오프라인 시에만 표시)
        networkStatus.when(
          data: (status) {
            if (status == NetworkStatus.offline) {
              return _buildOfflineBanner();
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // 메인 컨텐츠
        Expanded(child: child),
      ],
    );
  }

  /// 오프라인 배너
  Widget _buildOfflineBanner() {
    return Material(
      color: AppColors.warningOrange,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off,
                color: AppColors.surface,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Text(
                  '인터넷에 연결되어 있지 않습니다',
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.info_outline,
                color: AppColors.surface,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 네트워크 상태 인디케이터 (간단한 버전)
class NetworkStatusIndicator extends ConsumerWidget {
  const NetworkStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return networkStatus.when(
      data: (status) {
        if (status == NetworkStatus.offline) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warningOrange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off,
                  color: AppColors.warningOrange,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '오프라인',
                  style: TextStyle(
                    color: AppColors.warningOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
