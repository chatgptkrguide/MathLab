import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 개인정보처리방침 화면
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            const AdaptiveAppHeader(
              title: '개인정보처리방침',
            ),

            // 개인정보처리방침 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: '1. 개인정보의 처리 목적',
                      content: '''MathLab은 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

가. 회원 가입 및 관리
회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지 목적으로 개인정보를 처리합니다.

나. 서비스 제공
학습 콘텐츠 제공, 학습 진도 관리, 맞춤형 학습 서비스 제공, 본인인증 등의 목적으로 개인정보를 처리합니다.''',
                    ),

                    _buildSection(
                      title: '2. 개인정보의 처리 및 보유 기간',
                      content: '''① MathLab은 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다:
   - 회원가입 및 관리: 회원 탈퇴 시까지
   - 학습 기록 및 통계: 회원 탈퇴 후 3개월
   - 결제 정보: 관련 법령에 따라 5년''',
                    ),

                    _buildSection(
                      title: '3. 처리하는 개인정보의 항목',
                      content: '''① MathLab은 다음의 개인정보 항목을 처리하고 있습니다:

가. 필수항목
   - 이름, 이메일 주소, 비밀번호
   - 생년월일 (만 14세 미만 확인용)
   - 학습 진도 및 성적 정보

나. 선택항목
   - 프로필 이미지
   - 학년, 학교 정보
   - 기기 정보 (앱 사용 기록)''',
                    ),

                    _buildSection(
                      title: '4. 개인정보의 제3자 제공',
                      content: '''① MathLab은 원칙적으로 정보주체의 개인정보를 수집·이용 목적으로 명시한 범위 내에서 처리하며, 다음의 경우를 제외하고는 정보주체의 사전 동의 없이는 본래의 목적 범위를 초과하여 처리하거나 제3자에게 제공하지 않습니다:

   - 정보주체로부터 별도의 동의를 받은 경우
   - 법률에 특별한 규정이 있는 경우
   - 정보주체 또는 법정대리인이 의사표시를 할 수 없는 상태에 있거나 주소불명 등으로 사전 동의를 받을 수 없는 경우로서 명백히 정보주체 또는 제3자의 급박한 생명, 신체, 재산의 이익을 위하여 필요하다고 인정되는 경우''',
                    ),

                    _buildSection(
                      title: '5. 개인정보처리의 위탁',
                      content: '''① MathLab은 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다:

수탁업체: (향후 추가 예정)
위탁업무 내용: 학습 데이터 분석, 서버 관리
위탁기간: 회원 탈퇴 시 또는 위탁계약 종료 시까지

② MathLab은 위탁계약 체결 시 개인정보 보호법 제26조에 따라 위탁업무 수행목적 외 개인정보 처리금지, 기술적·관리적 보호조치, 재위탁 제한, 수탁자에 대한 관리·감독, 손해배상 등 책임에 관한 사항을 계약서 등 문서에 명시하고, 수탁자가 개인정보를 안전하게 처리하는지를 감독하고 있습니다.''',
                    ),

                    _buildSection(
                      title: '6. 정보주체의 권리·의무 및 그 행사방법',
                      content: '''① 정보주체는 MathLab에 대해 언제든지 개인정보 열람·정정·삭제·처리정지 요구 등의 권리를 행사할 수 있습니다.

② 제1항에 따른 권리 행사는 MathLab에 대해 개인정보 보호법 시행령 제41조제1항에 따라 서면, 전자우편 등을 통하여 하실 수 있으며 MathLab은 이에 대해 지체 없이 조치하겠습니다.

③ 개인정보 열람 및 처리정지 요구는 개인정보보호법 제35조 제4항, 제37조 제2항에 의하여 정보주체의 권리가 제한될 수 있습니다.''',
                    ),

                    _buildSection(
                      title: '7. 개인정보의 파기',
                      content: '''① MathLab은 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.

② 개인정보 파기의 절차 및 방법은 다음과 같습니다:

가. 파기절차
이용자가 입력한 정보는 목적 달성 후 별도의 DB에 옮겨져(종이의 경우 별도의 서류) 내부 방침 및 기타 관련 법령에 따라 일정기간 저장된 후 혹은 즉시 파기됩니다.

나. 파기방법
   - 전자적 파일 형태: 복구 및 재생되지 않도록 안전하게 삭제
   - 종이에 출력된 개인정보: 분쇄기로 분쇄하거나 소각''',
                    ),

                    _buildSection(
                      title: '8. 개인정보 보호책임자',
                      content: '''① MathLab은 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다:

개인정보 보호책임자
성명: (담당자 지정 예정)
이메일: privacy@mathlab.com
전화번호: (향후 추가 예정)

② 정보주체께서는 MathLab의 서비스를 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자로 문의하실 수 있습니다.''',
                    ),

                    _buildSection(
                      title: '9. 개인정보의 안전성 확보조치',
                      content: '''MathLab은 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다:

1. 관리적 조치: 내부관리계획 수립·시행, 정기적 직원 교육 등
2. 기술적 조치: 개인정보처리시스템 등의 접근권한 관리, 접근통제시스템 설치, 고유식별정보 등의 암호화, 보안프로그램 설치
3. 물리적 조치: 전산실, 자료보관실 등의 접근통제''',
                    ),

                    _buildSection(
                      title: '10. 개인정보 자동 수집 장치의 설치·운영 및 거부',
                      content: '''① MathLab은 이용자에게 개별적인 맞춤서비스를 제공하기 위해 이용정보를 저장하고 수시로 불러오는 '쿠키(cookie)'를 사용합니다.

② 쿠키는 웹사이트를 운영하는데 이용되는 서버가 이용자의 컴퓨터 브라우저에게 보내는 소량의 정보이며 이용자들의 PC 컴퓨터내의 하드디스크에 저장되기도 합니다.

③ 이용자는 쿠키 설치에 대한 선택권을 가지고 있습니다. 따라서, 이용자는 웹브라우저에서 옵션을 설정함으로써 모든 쿠키를 허용하거나, 쿠키가 저장될 때마다 확인을 거치거나, 아니면 모든 쿠키의 저장을 거부할 수도 있습니다.''',
                    ),

                    _buildSection(
                      title: '11. 개인정보 처리방침 변경',
                      content: '''① 이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.

② 다만, 개인정보의 제3자 제공, 개인정보의 처리 위탁과 같이 이용자 권리의 중요한 변경이 있을 경우에는 최소 30일 전에 고지합니다.''',
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
