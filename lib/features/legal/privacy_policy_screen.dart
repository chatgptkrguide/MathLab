import 'package:flutter/material.dart';

import '../../shared/constants/constants.dart';

/// 개인정보 처리방침 화면
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MathLab 개인정보 처리방침',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '최종 수정일: 2025년 2월 1일',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            _buildSection(
              '1. 수집하는 개인정보 항목',
              '앱은 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다.\n\n'
                  '- 필수 항목: 이메일 주소, 닉네임\n'
                  '- 선택 항목: 프로필 사진, 학습 선호 설정\n'
                  '- 자동 수집 항목: 학습 기록, 앱 이용 기록, 접속 로그',
            ),

            _buildSection(
              '2. 개인정보의 수집 및 이용 목적',
              '- 회원 가입 및 관리\n'
                  '- 서비스 제공 및 학습 기록 관리\n'
                  '- 개인화된 학습 경험 제공\n'
                  '- 서비스 개선 및 통계 분석\n'
                  '- 고객 지원 및 공지사항 전달',
            ),

            _buildSection(
              '3. 개인정보의 보유 및 이용 기간',
              '이용자의 개인정보는 서비스 이용 기간 동안 보유하며, '
                  '회원 탈퇴 시 지체 없이 파기합니다.\n\n'
                  '단, 관계 법령에 의해 보존할 필요가 있는 경우 '
                  '해당 법령에서 정한 기간 동안 보관합니다.',
            ),

            _buildSection(
              '4. 개인정보의 제3자 제공',
              '앱은 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다.\n\n'
                  '다만, 다음의 경우에는 예외로 합니다.\n'
                  '- 이용자가 사전에 동의한 경우\n'
                  '- 법령에 의해 요구되는 경우',
            ),

            _buildSection(
              '5. 개인정보의 파기 절차 및 방법',
              '이용자의 개인정보는 목적 달성 후 별도의 DB로 옮겨져 '
                  '내부 방침 및 관련 법령에 의한 일정 기간 저장 후 파기됩니다.\n\n'
                  '- 전자적 파일: 기록을 재생할 수 없는 기술적 방법으로 삭제\n'
                  '- 종이 문서: 분쇄기로 분쇄 또는 소각',
            ),

            _buildSection(
              '6. 이용자의 권리',
              '이용자는 언제든지 다음의 권리를 행사할 수 있습니다.\n\n'
                  '- 개인정보 열람 요구\n'
                  '- 오류가 있을 경우 정정 요구\n'
                  '- 삭제 요구\n'
                  '- 처리정지 요구',
            ),

            _buildSection(
              '7. 개인정보 보호 책임자',
              '앱은 개인정보 처리에 관한 업무를 총괄해서 책임지고, '
                  '이용자의 불만 처리 및 피해구제 등을 위해 아래와 같이 '
                  '개인정보 보호 책임자를 지정하고 있습니다.\n\n'
                  '문의: gomath.support@gmail.com',
            ),

            _buildSection(
              '8. 제3자 서비스 및 SDK',
              '앱은 서비스 제공을 위해 다음의 제3자 SDK를 사용합니다.\n\n'
                  '- Google Firebase: 인증, 데이터 저장, 푸시 알림, 분석, 오류 보고\n'
                  '- Google Sign-In: Google 계정을 통한 소셜 로그인\n'
                  '- Apple Sign-In: Apple 계정을 통한 소셜 로그인 (iOS)\n\n'
                  '각 서비스는 해당 제공자의 개인정보처리방침에 따라 데이터를 처리합니다.',
            ),

            _buildSection(
              '9. 개인정보 처리방침 변경',
              '이 개인정보 처리방침은 법령 및 정책의 변경에 따라 수정될 수 있으며, '
                  '변경 시 앱 내 공지사항을 통해 안내합니다.',
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
