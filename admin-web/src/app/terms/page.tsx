export const metadata = {
  title: "서비스 이용약관 - MathLab",
};

export default function TermsOfServicePage() {
  return (
    <div className="min-h-screen bg-white">
      <div className="max-w-3xl mx-auto px-6 py-12">
        <h1 className="text-3xl font-bold mb-2">서비스 이용약관</h1>
        <p className="text-gray-500 mb-8">시행일자: 2025년 1월 1일</p>

        <div className="prose prose-gray max-w-none space-y-6 text-[15px] leading-relaxed">
          <h2 className="text-xl font-semibold mt-8">제1조 (목적)</h2>
          <p>
            본 약관은 MathLab(이하 &quot;회사&quot;)이 제공하는 MathLab
            서비스(이하 &quot;서비스&quot;)의 이용과 관련하여 회사와 회원
            간의 권리, 의무 및 책임 사항, 기타 필요한 사항을 규정함을
            목적으로 합니다.
          </p>

          <h2 className="text-xl font-semibold mt-8">
            제2조 (용어의 정의)
          </h2>
          <ol className="list-decimal pl-6 space-y-1">
            <li>
              &quot;서비스&quot;란 회사가 제공하는 MathLab 모바일
              애플리케이션 및 관련 제반 서비스를 의미합니다.
            </li>
            <li>
              &quot;회원&quot;이란 본 약관에 동의하고 회사와 이용계약을
              체결하여 서비스를 이용하는 자를 의미합니다.
            </li>
            <li>
              &quot;콘텐츠&quot;란 서비스 내에서 제공되는 학습 문제, 설명,
              이미지, 동영상 등 정보의 총칭을 의미합니다.
            </li>
            <li>
              &quot;유료 서비스&quot;란 회사가 유료로 제공하는 프리미엄 구독
              등의 서비스를 의미합니다.
            </li>
          </ol>

          <h2 className="text-xl font-semibold mt-8">
            제3조 (약관의 명시 및 변경)
          </h2>
          <ol className="list-decimal pl-6 space-y-1">
            <li>
              회사는 본 약관의 내용을 회원이 쉽게 알 수 있도록 서비스 초기
              화면 또는 설정 메뉴에 게시합니다.
            </li>
            <li>
              회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본
              약관을 변경할 수 있습니다.
            </li>
            <li>
              약관 변경 시 적용일자 및 변경사유를 명시하여 7일 이전부터
              공지합니다.
            </li>
          </ol>

          <h2 className="text-xl font-semibold mt-8">제4조 (회원가입)</h2>
          <ol className="list-decimal pl-6 space-y-1">
            <li>
              회원가입은 이용자가 약관에 동의하고 회원가입신청을 한 후
              회사가 승낙함으로써 체결됩니다.
            </li>
            <li>
              회원가입 시 이메일 주소, 비밀번호, 닉네임을 제공해야 합니다.
            </li>
            <li>
              타인의 명의 이용, 허위 정보 기재, 만 14세 미만 아동의
              법정대리인 미동의 시 승낙이 거부될 수 있습니다.
            </li>
          </ol>

          <h2 className="text-xl font-semibold mt-8">
            제5조 (회원의 의무)
          </h2>
          <p>회원은 다음 행위를 하여서는 안 됩니다:</p>
          <ul className="list-disc pl-6 space-y-1">
            <li>허위내용의 등록 및 타인의 정보 도용</li>
            <li>회사 및 제3자의 저작권 등 지적재산권 침해</li>
            <li>회사 및 제3자의 명예 손상 또는 업무 방해</li>
            <li>
              외설 또는 폭력적인 정보를 서비스에 공개 또는 게시하는 행위
            </li>
            <li>타 회원을 괴롭히거나 협박하는 행위</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            제6조 (서비스의 제공)
          </h2>
          <p>회사는 다음과 같은 서비스를 제공합니다:</p>
          <ul className="list-disc pl-6 space-y-1">
            <li>수학 학습 콘텐츠 제공</li>
            <li>학습 진도 관리 및 기록 서비스</li>
            <li>학습 통계 및 리포트 서비스</li>
            <li>친구 기능 및 리더보드 서비스</li>
            <li>프리미엄 구독 서비스</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            제7조 (유료 서비스)
          </h2>
          <h3 className="text-lg font-medium">구독 기간</h3>
          <ul className="list-disc pl-6 space-y-1">
            <li>월간 구독: 1개월 / 연간 구독: 12개월</li>
            <li>
              구독 기간 만료 24시간 전까지 취소하지 않으면 자동 갱신됩니다.
            </li>
          </ul>

          <h3 className="text-lg font-medium">환불 정책</h3>
          <ul className="list-disc pl-6 space-y-1">
            <li>구매 후 7일 이내, 서비스 미사용 시 전액 환불 가능</li>
            <li>서비스 사용 후에는 이용 기간에 비례하여 환불</li>
            <li>Apple 및 Google의 환불 정책을 따릅니다.</li>
          </ul>

          <h2 className="text-xl font-semibold mt-8">
            제8조 (저작권의 귀속)
          </h2>
          <p>
            회사가 작성한 저작물에 대한 저작권 기타 지적재산권은 회사에
            귀속합니다. 회원은 서비스를 통해 얻은 정보를 회사의 사전 승낙
            없이 상업적으로 이용할 수 없습니다.
          </p>

          <h2 className="text-xl font-semibold mt-8">
            제9조 (계약 해지 및 이용 제한)
          </h2>
          <ol className="list-decimal pl-6 space-y-1">
            <li>
              회원은 언제든지 서비스 이용을 중단하고 이용계약을 해지할 수
              있습니다.
            </li>
            <li>
              회원 탈퇴 시 관련 법령에 따라 보유하는 경우를 제외하고 즉시
              모든 데이터가 삭제됩니다.
            </li>
          </ol>

          <h2 className="text-xl font-semibold mt-8">
            제10조 (면책조항)
          </h2>
          <ol className="list-decimal pl-6 space-y-1">
            <li>
              천재지변 또는 불가항력으로 인한 서비스 제공 불가 시 책임이
              면제됩니다.
            </li>
            <li>
              회원의 귀책사유로 인한 서비스 이용 장애에 대해 책임지지
              않습니다.
            </li>
          </ol>

          <h2 className="text-xl font-semibold mt-8">
            제11조 (분쟁의 해결)
          </h2>
          <p>
            서비스와 관련한 분쟁은 회사의 본사 소재지를 관할하는 법원을
            관할 법원으로 합니다. 본 약관은 대한민국 법령에 의하여
            규정되고 이행됩니다.
          </p>

          <h2 className="text-xl font-semibold mt-8">부칙</h2>
          <p>본 약관은 2025년 1월 1일부터 시행됩니다.</p>

          <hr className="my-8" />
          <div className="text-sm text-gray-500 space-y-1">
            <p>회사명: MathLab | 대표자: 여준수</p>
            <p>이메일: support@mathlab.com</p>
            <p>최종 수정일: 2025년 1월 1일 | 버전: 1.0</p>
          </div>
        </div>
      </div>
    </div>
  );
}
