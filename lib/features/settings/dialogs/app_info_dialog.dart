// App info dialog — small modal showing the app version, tagline, and links
// to terms of service and privacy policy.
import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';
import '../../legal/privacy_policy_screen.dart';
import '../../legal/terms_of_service_screen.dart';

/// Shows the app info modal dialog.
void showAppInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Image.asset(
            'assets/icons/gomath_logo_small.png',
            width: 32,
            height: 32,
            errorBuilder: (_, __, ___) => const Text('M',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathBlue)),
          ),
          const SizedBox(width: 12),
          const Text('MathLab'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('v1.0.0',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('매일 5분, 수학이 쉬워진다', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TermsOfServiceScreen()),
                  );
                },
                child: const Text('이용약관'),
              ),
              const Text(' · '),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
                child: const Text('개인정보 처리방침'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
