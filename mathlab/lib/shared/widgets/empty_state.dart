import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 빈 상태 위젯
/// 데이터가 없을 때 표시하는 일러스트레이션과 메시지
/// 완전한 반응형 처리로 오버플로우 방지
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double? height;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600 || screenSize.width < 400;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = height ?? constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        return Container(
          height: availableHeight > 0 ? availableHeight : null,
          width: availableWidth,
          padding: EdgeInsets.all(isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingL),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight > 0
                    ? (availableHeight - (isSmallScreen ? 32 : 48)).clamp(100, double.infinity)
                    : 200,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 이모지 아이콘
                    Text(
                      icon,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 48,
                        height: 1.0,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingL),

                    // 제목
                    Text(
                      title,
                      style: isSmallScreen
                          ? AppTextStyles.titleLarge
                          : AppTextStyles.headlineSmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),

                    SizedBox(height: isSmallScreen ? AppDimensions.spacingS : AppDimensions.spacingM),

                    // 메시지
                    Flexible(
                      child: Text(
                        message,
                        style: isSmallScreen
                            ? AppTextStyles.bodySmall
                            : AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),

                    // 액션 버튼 (있는 경우에만)
                    if (actionText != null && onActionPressed != null) ...[
                      SizedBox(height: isSmallScreen ? AppDimensions.spacingM : AppDimensions.spacingXL),
                      SizedBox(
                        width: isSmallScreen ? availableWidth * 0.8 : 200,
                        child: OutlinedButton(
                          onPressed: onActionPressed,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? AppDimensions.paddingM : AppDimensions.paddingXL,
                              vertical: AppDimensions.paddingM,
                            ),
                          ),
                          child: Text(
                            actionText!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
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
      },
    );
  }
}