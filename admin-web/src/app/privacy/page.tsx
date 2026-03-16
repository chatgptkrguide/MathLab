export const metadata = {
  title: "개인정보 처리방침 - MathLab",
};

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-white">
      <div className="max-w-3xl mx-auto px-6 py-12">
        <h1 className="text-3xl font-bold mb-2">개인정보 처리방침</h1>
        <p className="text-gray-500 mb-8">시행일자: 2025년 1월 1일</p>

        <div className="prose prose-gray max-w-none space-y-6 text-[15px] leading-relaxed">
          <p>
            MathLab(이하 &quot;회사&quot;)은 정보통신망 이용촉진 및 정보보호 등에
            관한 법률, 개인정보보호법 등 관련 법령상의 개인정보보호 규정을
            준수하며, 이용자의 개인정보 보호에 최선을 다하고 있습니다.
          </p>

          <h2 className="text-xl font-semibold mt-8">
            1. 수집하는 개인정보 항목
          </h2>

          <h3 className="text-lg font-medium">1.1 필수 수집 항목</h3>
          <ul className="list-disc pl-6 space-y-1">
            <li>회원가입 시: 이메일 주소, 비밀번호, 닉네임</li>
            <li>
              소셜 로그인 시: 소셜 계정 정보 (Google, Apple 계정 이메일)
            </li>
            <li>
              서비스 이용 기록: 학습 기록, 문제 풀이 기록, XP, 레벨, 스트릭
              데이터
            </li>
          </ul>

          <h3 className="text-lg font-medium">1.2 선택 수집 항목</h3>
          <ul className="list-disc pl-6 space-y-1">
            <li>프로필 정보: 프로필 사진, 학년</li>
            <li>친구 관계: 친구 목록, 친구 요청 내역</li>
          </ul>

          <h3 className="text-lg font-medium">1.3 자동 수집 항목</h3>
          <ul className="list-disc pl-6 space-y-1">
            <li>기기 정보: 기기 모델, OS 버전, 앱 버전</li>
            <li>로그 정보: 접속 시간, IP 주소, 서비스 이용 기록</li>
            <li>광고 식별자: 맞춤 서비스 제공 목적 (선택)</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            2. 개인정보의 수집 및 이용 목적
          </h2>
          <ul className="list-disc pl-6 space-y-1">
            <li>회원 가입 및 관리</li>
            <li>학습 진도 관리 및 기록 저장</li>
            <li>맞춤형 학습 콘텐츠 제공</li>
            <li>학습 통계 및 리포트 제공</li>
            <li>신규 서비스 개발 및 기존 서비스 개선</li>
            <li>고객 문의 응대 및 불만 처리</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            3. 개인정보의 보유 및 이용 기간
          </h2>
          <ul className="list-disc pl-6 space-y-1">
            <li>회원 정보: 회원 탈퇴 시까지 (탈퇴 후 즉시 파기)</li>
            <li>학습 기록: 회원 탈퇴 후 1년 (재가입 시 복구 지원)</li>
            <li>
              계약 또는 청약철회 등에 관한 기록: 5년 (전자상거래법)
            </li>
            <li>소비자 불만 또는 분쟁처리에 관한 기록: 3년</li>
            <li>로그인 기록: 3개월 (통신비밀보호법)</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            4. 개인정보의 제3자 제공
          </h2>
          <p>
            회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지
            않습니다. 다만, 이용자의 동의가 있거나 법령의 규정에 의한 경우는
            예외로 합니다.
          </p>

          <h2 className="text-xl font-semibold mt-8">
            5. 개인정보 처리 위탁
          </h2>
          <table className="w-full border-collapse border border-gray-300 text-sm">
            <thead>
              <tr className="bg-gray-50">
                <th className="border border-gray-300 px-4 py-2 text-left">
                  수탁업체
                </th>
                <th className="border border-gray-300 px-4 py-2 text-left">
                  위탁 업무 내용
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td className="border border-gray-300 px-4 py-2">
                  Google Cloud Platform
                </td>
                <td className="border border-gray-300 px-4 py-2">
                  서버 인프라 제공
                </td>
              </tr>
              <tr>
                <td className="border border-gray-300 px-4 py-2">
                  Firebase
                </td>
                <td className="border border-gray-300 px-4 py-2">
                  데이터베이스, 인증, 푸시 알림
                </td>
              </tr>
              <tr>
                <td className="border border-gray-300 px-4 py-2">
                  Google Analytics
                </td>
                <td className="border border-gray-300 px-4 py-2">
                  서비스 이용 통계 분석
                </td>
              </tr>
            </tbody>
          </table>

          <h2 className="text-xl font-semibold mt-8">6. 이용자의 권리</h2>
          <ul className="list-disc pl-6 space-y-1">
            <li>
              개인정보 열람: 앱 내 설정 &gt; 프로필에서 조회
            </li>
            <li>
              개인정보 수정: 앱 내 설정 &gt; 프로필 편집에서 수정
            </li>
            <li>
              개인정보 삭제: 앱 내 설정 &gt; 계정 관리 &gt; 회원 탈퇴
            </li>
            <li>
              마케팅 수신 철회: 앱 내 설정 &gt; 알림 설정
            </li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            7. 개인정보 보호를 위한 기술적/관리적 대책
          </h2>
          <ul className="list-disc pl-6 space-y-1">
            <li>비밀번호 암호화 저장 및 관리</li>
            <li>Firebase Authentication 및 Firestore 보안 규칙 적용</li>
            <li>개인정보 접근 권한 최소 인원 제한</li>
            <li>개인정보 접근 기록 보관 및 위조/변조 방지</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            8. 아동의 개인정보 보호
          </h2>
          <p>
            회사는 만 14세 미만 아동의 개인정보 보호를 위해 만 14세 미만
            아동의 경우 법정대리인의 동의를 받도록 하고 있습니다.
          </p>

          <h2 className="text-xl font-semibold mt-8">
            9. 개인정보 보호책임자
          </h2>
          <ul className="list-none space-y-1">
            <li>이름: 여준수</li>
            <li>직책: 대표</li>
            <li>이메일: privacy@mathlab.com</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            10. 개인정보 침해 관련 상담 및 신고
          </h2>
          <ul className="list-disc pl-6 space-y-1">
            <li>개인정보 침해 신고센터: 118 (privacy.kisa.or.kr)</li>
            <li>
              개인정보 분쟁조정위원회: 1833-6972 (www.kopico.go.kr)
            </li>
            <li>대검찰청 사이버범죄수사단: 02-3480-3573</li>
            <li>경찰청 사이버안전국: 182</li>
          </ul>

          <hr className="my-8" />
          <div className="text-sm text-gray-500 space-y-1">
            <p>회사명: MathLab | 대표자: 여준수</p>
            <p>이메일: privacy@mathlab.com</p>
            <p>최종 수정일: 2025년 1월 1일 | 버전: 1.0</p>
          </div>
        </div>
      </div>
    </div>
  );
}
