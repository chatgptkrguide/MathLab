import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 이용약관 화면
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            const AdaptiveAppHeader(
              title: '이용약관',
            ),

            // 이용약관 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: '제 1 조 (목적)',
                      content:
                          '''본 약관은 MathLab(이하 "서비스")의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.''',
                    ),

                    _buildSection(
                      title: '제 2 조 (정의)',
                      content: '''1. "서비스"란 MathLab이 제공하는 모든 교육 서비스를 의미합니다.
2. "이용자"란 본 약관에 따라 서비스를 이용하는 모든 회원 및 비회원을 말합니다.
3. "회원"이란 서비스에 회원등록을 한 자로서, 계속적으로 서비스를 이용할 수 있는 자를 말합니다.
4. "콘텐츠"란 서비스 내에서 제공되는 학습 자료, 문제, 강의 등을 의미합니다.''',
                    ),

                    _buildSection(
                      title: '제 3 조 (약관의 효력 및 변경)',
                      content:
                          '''1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 공지함으로써 효력이 발생합니다.
2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있습니다.
3. 회사가 약관을 변경할 경우에는 적용일자 및 변경사유를 명시하여 현행약관과 함께 서비스 초기화면에 그 적용일자 7일 이전부터 적용일자 전일까지 공지합니다.''',
                    ),

                    _buildSection(
                      title: '제 4 조 (회원가입)',
                      content:
                          '''1. 회원가입은 이용자가 약관의 내용에 대하여 동의를 한 다음 회원가입 신청을 하고 회사가 이러한 신청에 대하여 승낙함으로써 체결됩니다.
2. 회사는 다음 각 호에 해당하는 신청에 대하여는 승낙을 하지 않거나 사후에 이용계약을 해지할 수 있습니다:
   - 실명이 아니거나 타인의 명의를 이용한 경우
   - 허위의 정보를 기재하거나, 회사가 제시하는 내용을 기재하지 않은 경우
   - 만 14세 미만 아동이 법정대리인의 동의를 얻지 아니한 경우''',
                    ),

                    _buildSection(
                      title: '제 5 조 (서비스의 제공 및 변경)',
                      content: '''1. 회사는 다음과 같은 서비스를 제공합니다:
   - 수학 학습 콘텐츠 제공
   - 학습 진도 관리 및 통계
   - 레벨 시스템 및 게이미피케이션
   - 기타 회사가 정하는 서비스
2. 회사는 상당한 이유가 있는 경우에 운영상, 기술상의 필요에 따라 제공하고 있는 서비스를 변경할 수 있습니다.''',
                    ),

                    _buildSection(
                      title: '제 6 조 (서비스 이용시간)',
                      content:
                          '''1. 서비스 이용은 회사의 업무상 또는 기술상 특별한 지장이 없는 한 연중무휴, 1일 24시간 운영을 원칙으로 합니다.
2. 회사는 시스템 정기점검, 증설 및 교체를 위해 회사가 정한 날이나 시간에 서비스를 일시 중단할 수 있으며, 예정되어 있는 작업으로 인한 서비스 일시중단은 서비스 제공화면에 공지합니다.''',
                    ),

                    _buildSection(
                      title: '제 7 조 (회원의 의무)',
                      content: '''1. 회원은 다음 행위를 하여서는 안 됩니다:
   - 신청 또는 변경 시 허위 내용의 등록
   - 타인의 정보 도용
   - 회사가 게시한 정보의 변경
   - 회사가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시
   - 회사와 기타 제3자의 저작권 등 지적재산권에 대한 침해
   - 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위''',
                    ),

                    _buildSection(
                      title: '제 8 조 (저작권)',
                      content: '''1. 회사가 작성한 저작물에 대한 저작권 기타 지적재산권은 회사에 귀속합니다.
2. 이용자는 서비스를 이용함으로써 얻은 정보 중 회사에게 지적재산권이 귀속된 정보를 회사의 사전 승낙 없이 복제, 송신, 출판, 배포, 방송 기타 방법에 의하여 영리목적으로 이용하거나 제3자에게 이용하게 하여서는 안됩니다.''',
                    ),

                    _buildSection(
                      title: '제 9 조 (면책조항)',
                      content:
                          '''1. 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.
2. 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.
3. 회사는 이용자가 서비스를 이용하여 기대하는 학습효과나 결과를 얻지 못한 것에 대하여 책임을 지지 않습니다.''',
                    ),

                    _buildSection(
                      title: '제 10 조 (분쟁해결)',
                      content:
                          '''1. 회사는 이용자가 제기하는 정당한 의견이나 불만을 반영하고 그 피해를 보상처리하기 위하여 피해보상처리기구를 설치·운영합니다.
2. 서비스 이용으로 발생한 분쟁에 대해 소송이 제기되는 경우 회사의 본사 소재지를 관할하는 법원을 관할 법원으로 합니다.''',
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // 최종 업데이트 날짜
                    Center(
                      child: Text(
                        '최종 업데이트: 2024년 11월 27일',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
