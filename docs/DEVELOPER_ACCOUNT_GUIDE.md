# 👨‍💻 개발자 계정 등록 완전 가이드

## 📋 목차
1. [개요](#개요)
2. [Apple Developer Program](#apple-developer-program)
3. [Google Play Console](#google-play-console)
4. [비용 요약](#비용-요약)
5. [등록 후 설정](#등록-후-설정)

---

## 🎯 개요

### 왜 필요한가?
MathLab 앱을 App Store와 Google Play Store에 배포하려면 각 플랫폼의 개발자 계정이 필요합니다.

### 준비물
- ✅ 신용카드 (Visa, MasterCard, American Express)
- ✅ 애플 계정 (Apple ID)
- ✅ 구글 계정 (Gmail)
- ✅ 정부 발행 신분증 (개인 계정의 경우)
- ✅ 사업자등록증 (기업 계정의 경우)

### 예상 소요 시간
- **Apple Developer**: 30분 ~ 1시간
- **Google Play**: 15분 ~ 30분

---

## 🍎 Apple Developer Program

### 💰 비용
- **개인/조직**: $99/년 (약 132,000원)
- **교육기관**: 무료
- **결제**: 신용카드 (자동 갱신)

### 📝 등록 절차

#### 1단계: Apple ID 준비
```
1. Apple ID가 없다면 생성:
   https://appleid.apple.com

2. 2단계 인증 활성화 (필수)
   - Apple ID > 보안 > 2단계 인증 켜기
```

#### 2단계: Apple Developer 웹사이트 접속
```
https://developer.apple.com/programs/enroll/
```

#### 3단계: 등록 시작
```
1. "Start Your Enrollment" 클릭
2. Apple ID로 로그인
3. 계정 유형 선택:
   - 개인 (Individual): 개인 이름으로 앱 배포
   - 조직 (Organization): 회사 이름으로 앱 배포
```

#### 4단계: 개인 정보 입력 (Individual)
```
필수 정보:
- 법적 이름 (Legal Name): 여준수
- 전화번호: +82 10-0000-0000
- 주소: 서울특별시 강남구 테헤란로 123

주의:
- 이름은 정부 발행 신분증과 동일해야 함
- 앱 스토어에 표시되는 개발자 이름
```

#### 5단계: 조직 정보 입력 (Organization) - 선택사항
```
추가 필요 서류:
- 사업자등록증
- D-U-N-S Number (Dun & Bradstreet에서 무료 발급)

D-U-N-S Number 신청:
1. https://developer.apple.com/enroll/duns-lookup/
2. 회사 정보 입력
3. 5-10 영업일 소요
```

#### 6단계: 결제
```
1. 결제 정보 입력
   - 신용카드 번호
   - 유효기간
   - CVV
   - 청구지 주소

2. $99 결제 완료
3. 자동 갱신 설정 확인
```

#### 7단계: 약관 동의
```
1. Apple Developer Program License Agreement 읽기
2. 동의 체크박스 선택
3. "Continue" 클릭
```

#### 8단계: 심사 대기
```
심사 기간:
- 개인: 1-2일
- 조직: 5-10일 (D-U-N-S 검증 포함)

상태 확인:
https://developer.apple.com/account/
```

#### 9단계: 활성화 확인
```
1. 이메일로 활성화 알림 수신
2. Apple Developer > Membership
3. Status: Active 확인
```

### ✅ 등록 후 설정

#### App Store Connect 접속
```
https://appstoreconnect.apple.com

1. Apple ID로 로그인
2. 대시보드 확인
3. My Apps 메뉴 확인
```

#### 계약 동의 (중요!)
```
1. App Store Connect > Agreements, Tax, and Banking
2. Paid Apps Agreement 동의 (인앱 구매 사용 시)
3. 세금 정보 입력
4. 은행 정보 입력 (수익 정산용)
```

#### 팀 설정 (선택)
```
1. App Store Connect > Users and Access
2. 팀원 초대 (Admin, Developer, Marketing 등)
3. 권한 설정
```

---

## 🤖 Google Play Console

### 💰 비용
- **일회성 등록비**: $25 (약 33,000원)
- **추가 비용 없음**: 평생 사용 가능
- **결제**: 신용카드

### 📝 등록 절차

#### 1단계: Google 계정 준비
```
1. Gmail 계정이 없다면 생성:
   https://accounts.google.com

2. 2단계 인증 활성화 (권장)
```

#### 2단계: Google Play Console 접속
```
https://play.google.com/console/signup
```

#### 3단계: 개발자 계정 생성
```
1. Google 계정으로 로그인
2. "Create Developer Account" 클릭
3. 거주 국가/지역 선택: 대한민국
4. 계정 유형 선택:
   - 개인 (Personal): 개인 이름으로 앱 배포
   - 조직 (Organization): 회사 이름으로 앱 배포
```

#### 4단계: 개발자 정보 입력

##### 개인 계정 (Personal)
```
필수 정보:
- 개발자 이름: 여준수
- 이메일 주소: your@email.com
- 전화번호: +82-10-0000-0000
- 주소: 서울특별시 강남구 테헤란로 123
- 웹사이트: (선택사항)

주의:
- Play Store에 표시되는 개발자 이름
- 나중에 변경 가능 (최대 1회)
```

##### 조직 계정 (Organization)
```
추가 필요 정보:
- 조직 이름: MathLab Inc.
- 조직 유형: 회사, 비영리단체 등
- 사업자등록번호 (선택사항)
```

#### 5단계: 신원 확인
```
Google은 다음 중 하나를 요구할 수 있음:
- 정부 발행 신분증 업로드
- 전화번호 인증
- 추가 정보 제공

시간:
- 즉시 ~ 최대 3일
```

#### 6단계: 개발자 계정 설정 약관 동의
```
1. 개발자 배포 계약 읽기
2. 미국 수출 관련 법률 준수 동의
3. 모든 체크박스 선택
4. "Create Account and Pay" 클릭
```

#### 7단계: 결제
```
1. 결제 정보 입력
   - 신용카드 번호
   - 유효기간
   - CVV
   - 청구지 주소

2. $25 결제 완료
3. 영수증 이메일 수신
```

#### 8단계: 계정 활성화 확인
```
1. 결제 완료 즉시 계정 활성화
2. Google Play Console 대시보드 접속 가능
3. "Create App" 버튼 활성화 확인
```

### ✅ 등록 후 설정

#### 결제 프로필 설정 (수익 정산용)
```
1. Play Console > Payments profile
2. 판매자 정보 입력
3. 세금 정보 입력
4. 은행 계좌 정보 입력
```

#### 콘텐츠 등급 설정
```
1. 앱 생성 후 "Store presence" > "App content"
2. Content ratings 설정
3. IARC 등급 설문 작성
```

#### 개인정보 처리방침 URL 준비
```
MathLab 프로젝트에 이미 준비됨:
docs/PRIVACY_POLICY.md

호스팅 방법:
1. GitHub Pages
2. Vercel
3. Firebase Hosting

예시 URL:
https://mathlab.com/privacy-policy
```

---

## 💳 비용 요약

### 총 초기 비용
```
Apple Developer:  $99/년 (132,000원)
Google Play:      $25     ( 33,000원)
─────────────────────────────────────
합계:             $124    (165,000원)
```

### 연간 유지 비용
```
Apple Developer:  $99/년 (자동 갱신)
Google Play:      $0     (추가 비용 없음)
```

### 추가 비용 (선택)
```
- 앱 아이콘 디자인: $25-$100
- 스크린샷 제작: $50-$200
- 마케팅 자료: $100-$500
```

---

## 🛠️ 등록 후 설정

### Apple Developer

#### 인증서 및 프로비저닝 프로필
```
1. Xcode 자동 관리 사용 (권장)
   - Xcode > Signing & Capabilities
   - "Automatically manage signing" 체크

2. 수동 관리 (고급)
   - Certificates, Identifiers & Profiles 메뉴
   - Distribution Certificate 생성
   - Provisioning Profile 생성
```

#### App ID 등록
```
1. Certificates, Identifiers & Profiles
2. Identifiers > App IDs
3. "+" 버튼 클릭
4. 정보 입력:
   - Description: MathLab
   - Bundle ID: com.mathlab.app
   - Capabilities: Push Notifications, In-App Purchase 등
5. "Continue" 및 "Register" 클릭
```

#### 푸시 알림 인증서 (선택)
```
1. Keys > "+" 버튼
2. Key Name: MathLab Push Key
3. Apple Push Notifications service (APNs) 체크
4. "Continue" 및 "Register"
5. .p8 파일 다운로드
6. Key ID 메모
7. Firebase Console에 업로드
```

### Google Play Console

#### 앱 서명 키 설정
```
1. Play Console > Setup > App integrity
2. App signing by Google Play 선택 (권장)
3. 자동으로 키 생성됨
4. 키 정보 다운로드 및 안전하게 보관
```

#### 테스터 트랙 설정
```
1. Release > Testing > Internal testing
2. "Create new release" 클릭
3. 테스터 이메일 추가
4. 앱 배포 (빌드 업로드)
```

---

## ⏰ 타임라인

### Apple Developer Program
```
Day 1:  신청 및 결제
Day 2-3: 심사 (개인)
Day 5-10: 심사 (조직)
Day 11+: 활성화 후 앱 업로드 가능
```

### Google Play Console
```
Day 1: 신청, 결제, 즉시 활성화
Day 1: 앱 업로드 가능
```

### 첫 앱 심사 (참고)
```
Apple:
- 초기 심사: 1-3일
- 업데이트 심사: 24시간 이내

Google:
- 초기 심사: 1-3일
- 업데이트 심사: 수 시간 ~ 1일
```

---

## 🆘 문제 해결

### Apple Developer

#### 문제: 결제 실패
```
원인: 신용카드 거부, 주소 불일치
해결: 카드사에 해외 결제 활성화 요청
```

#### 문제: D-U-N-S Number 지연
```
원인: 회사 정보 검증 시간 필요
해결: 5-10 영업일 대기, 상태 확인 이메일 확인
```

#### 문제: 심사 지연
```
원인: 추가 정보 요청, 공휴일
해결: Apple 지원팀 이메일 확인, 요청 정보 제공
```

### Google Play Console

#### 문제: 신원 확인 실패
```
원인: 신분증 불일치, 불명확한 사진
해결: 고해상도 신분증 사진 재업로드
```

#### 문제: 결제 실패
```
원인: 신용카드 거부
해결: 다른 카드 사용, PayPal 사용 (가능 시)
```

#### 문제: 계정 정지
```
원인: 정책 위반, 중복 계정
해결: Google 지원팀 문의, 이의 제기
```

---

## ✅ 최종 체크리스트

### Apple Developer Program
- [ ] Apple ID 생성 및 2단계 인증 활성화
- [ ] 개인/조직 유형 결정
- [ ] D-U-N-S Number 발급 (조직의 경우)
- [ ] $99 결제 완료
- [ ] 심사 통과 및 활성화 확인
- [ ] App Store Connect 접속 가능
- [ ] 계약 동의 (Agreements, Tax, and Banking)

### Google Play Console
- [ ] Google 계정 준비
- [ ] 개인/조직 유형 결정
- [ ] 개발자 정보 입력
- [ ] 신원 확인 완료
- [ ] $25 결제 완료
- [ ] 계정 활성화 확인
- [ ] Play Console 대시보드 접속 가능
- [ ] 결제 프로필 설정 (수익 정산용)

### 공통
- [ ] 개인정보 처리방침 URL 준비
- [ ] 서비스 이용약관 URL 준비
- [ ] 앱 아이콘 1024x1024 준비
- [ ] 스크린샷 준비 (iOS: 최소 1장, Android: 최소 2장)
- [ ] 앱 설명 작성 (한국어/영어)

---

## 📞 고객 지원

### Apple Developer Support
```
웹사이트: https://developer.apple.com/support/
전화: 1-800-633-2152 (미국)
이메일: developer.apple.com/contact/ 통해 문의
```

### Google Play Support
```
웹사이트: https://support.google.com/googleplay/android-developer
이메일: play-dev-support@google.com
커뮤니티: https://www.reddit.com/r/androiddev/
```

---

## 📚 추가 리소스

### 공식 가이드
- Apple Developer Guide: https://developer.apple.com/help/account/
- Google Play Guide: https://support.google.com/googleplay/android-developer/

### 커뮤니티
- r/iOSProgramming: https://reddit.com/r/iOSProgramming
- r/androiddev: https://reddit.com/r/androiddev
- Flutter Community: https://flutter.dev/community

---

**최종 업데이트**: 2025년 1월 18일
**문서 버전**: 1.0
