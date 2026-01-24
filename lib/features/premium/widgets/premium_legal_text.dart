import 'package:flutter/material.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 프리미엄 법적 텍스트 위젯 (이용약관, 개인정보처리방침)
class PremiumLegalText extends StatelessWidget {
  const PremiumLegalText({super.key});

  @override
  Widget build(BuildContext context) {
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
}
