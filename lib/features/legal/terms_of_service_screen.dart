import 'package:flutter/material.dart';

import '../../shared/constants/constants.dart';

/// 이용약관 화면
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('이용약관'),
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
              'MathLab 이용약관',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '최종 수정일: 2026년 4월 3일',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            _buildSection(
              '제1조 (목적)',
              '이 약관은 MathLab(이하 "앱")이 제공하는 수학 학습 서비스(이하 "서비스")의 '
                  '이용조건 및 절차, 이용자와 앱의 권리, 의무, 책임사항을 규정함을 목적으로 합니다.',
            ),

            _buildSection(
              '제2조 (용어의 정의)',
              '1. "서비스"라 함은 MathLab이 제공하는 모든 수학 학습 관련 기능을 말합니다.\n'
                  '2. "이용자"라 함은 이 약관에 따라 서비스를 이용하는 자를 말합니다.\n'
                  '3. "콘텐츠"라 함은 서비스 내에서 제공되는 문제, 해설, 학습 자료 등을 말합니다.',
            ),

            _buildSection(
              '제3조 (약관의 효력)',
              '본 약관은 서비스를 이용하고자 하는 모든 이용자에게 적용됩니다. '
                  '약관의 내용은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지합니다.',
            ),

            _buildSection(
              '제4조 (서비스 이용)',
              '1. 서비스는 무료로 제공되며, 일부 프리미엄 기능은 유료로 제공될 수 있습니다.\n'
                  '2. 이용자는 서비스를 학습 목적으로만 사용해야 합니다.\n'
                  '3. 서비스의 이용 시간은 연중무휴 24시간을 원칙으로 합니다.',
            ),

            _buildSection(
              '제5조 (개인정보 보호)',
              '앱은 이용자의 개인정보를 보호하기 위해 최선을 다하며, '
                  '개인정보 처리방침에 따라 이용자의 개인정보를 수집, 이용, 관리합니다.',
            ),

            _buildSection(
              '제6조 (이용자의 의무)',
              '1. 이용자는 타인의 학습을 방해하는 행위를 해서는 안 됩니다.\n'
                  '2. 이용자는 서비스를 이용하여 얻은 정보를 상업적으로 이용해서는 안 됩니다.\n'
                  '3. 이용자는 관계 법령, 이 약관의 규정, 이용안내 및 주의사항을 준수해야 합니다.',
            ),

            _buildSection(
              '제7조 (면책사항)',
              '1. 앱은 천재지변 등 불가항력적 사유로 인해 서비스를 제공할 수 없는 경우 책임이 면제됩니다.\n'
                  '2. 앱은 이용자의 귀책사유로 인한 서비스 이용 장애에 대해 책임을 지지 않습니다.',
            ),

            _buildSection(
              '제8조 (회원 탈퇴 및 데이터 삭제)',
              '1. 이용자는 언제든지 앱 설정에서 회원 탈퇴를 요청할 수 있습니다.\n'
                  '2. 탈퇴 시 이용자의 개인정보 및 학습 기록은 즉시 삭제됩니다.\n'
                  '3. 삭제된 데이터는 복구할 수 없으며, 동일 계정으로 재가입 시 새로운 계정으로 시작됩니다.',
            ),

            _buildSection(
              '제9조 (제3자 서비스)',
              '본 앱은 다음의 제3자 서비스를 활용합니다.\n\n'
                  '- Google Firebase: 인증, 데이터 저장, 분석\n'
                  '- Google Sign-In: 소셜 로그인\n'
                  '- Apple Sign-In: 소셜 로그인 (iOS)\n\n'
                  '각 서비스의 이용약관 및 개인정보처리방침은 해당 서비스 제공자의 정책을 따릅니다.',
            ),

            _buildSection(
              '제10조 (문의)',
              '서비스 이용에 관한 문의는 아래 이메일로 연락해주세요.\n\n'
                  '이메일: gomath.support@gmail.com',
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
