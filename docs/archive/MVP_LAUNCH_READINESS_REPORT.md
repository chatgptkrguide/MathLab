# MVP 출시 준비 상태 보고서

**작성일**: 2025-12-26
**프로젝트**: MathLab (수학 학습 게이미피케이션 앱)
**목표**: MVP 실제 출시 가능 여부 검증

---

## 📊 프로젝트 현황

### 코드베이스 통계
- **총 Dart 파일 수**: 255개
- **모델**: 40개
- **프로바이더**: 40개
- **서비스**: 28개
- **리포지토리**: 8개
- **공유 위젯**: 42개
- **화면/기능**: 35개
- **Analyze 이슈**: 320개 (대부분 info-level warnings, 0 compile errors)
- **테스트 파일**: 2개 (widget_test.dart, deep_link_service_test.dart)

### 기술 스택
- **Frontend**: Flutter 3.5.0 + Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **인앱 구매**: iOS StoreKit + Android Billing
- **로컬 저장**: Hive + SharedPreferences + SecureStorage

---

## ✅ 완료된 핵심 기능

### 1. 사용자 인증 시스템 ✅
- 소셜 로그인: Google, Kakao, Apple 통합 완료
- 게스트 모드: 임시 계정 생성 및 정식 계정 전환 지원
- 계정 마이그레이션: 게스트 → 정식 회원 데이터 이전 로직 구현

### 2. 온보딩 시스템 ✅
- 6페이지 완성된 온보딩 플로우
- 게임 메커니즘 설명: XP/레벨, 스트릭/하트, 주간 리그, 힌트/오답 노트, 데일리 챌린지
- SharedPreferences로 완료 상태 저장

### 3. 코어 게이미피케이션 ✅
- **XP 시스템**: 문제당 XP 획득, 레벨업 애니메이션, 일일 XP 리셋
- **레벨 시스템**: 50개 레벨, Bronze → Silver → Gold → Diamond 티어
- **스트릭 시스템**: 연속 학습 추적, 스트릭 보너스 XP (3일/5일/10일 연속)
- **리그 시스템**: 주간 경쟁, 실시간 순위, 승급/강등

### 4. 문제 풀이 시스템 ✅
- 문제 유형: 객관식, 주관식, 계산 문제
- 힌트 시스템: 단계별 힌트 제공 (XP 감소)
- 오답 노트: 틀린 문제 자동 저장 및 복습
- 풀이 타이머: 문제 풀이 시간 측정
- 애니메이션: 정답/오답 피드백, XP 획득 애니메이션

### 5. UI/UX ✅
- Figma 기반 디자인 시스템 구현
- 모던하고 깔끔한 인터페이스
- 햅틱 피드백 및 사운드 효과
- 다크모드 지원 (부분적)

### 6. 데이터 관리 ✅
- Repository 패턴: 로컬 + Firebase 자동 동기화
- 실시간 동기화: Firestore 스트림 활용
- 오프라인 지원: 로컬 우선 로드, 백그라운드 동기화

### 7. 프리미엄 시스템 기반 ✅
- 인앱 구매 서비스 구현 (iOS/Android)
- 구독 등급: Free, Monthly, Yearly, Lifetime
- 영수증 검증 프레임워크 (서버 검증 필요)

---

## 🚨 치명적 차단 요소 (Critical Blockers)

### 1. 문제 데이터 부족 🔥
**심각도**: **CRITICAL** (출시 불가)

**현상**:
- 현재 문제 데이터: **2개만 존재** (polynomial_001.json, polynomial_002.json)
- MVP 최소 요구사항: **200-300개 문제** (CLAUDE.md 기준)
- 20개 유닛 × 5개 레슨 = 100개 레슨
- 레슨당 평균 10-20개 문제 필요

**영향**:
- 사용자가 2문제 풀고 나면 더 이상 학습할 콘텐츠가 없음
- 게이미피케이션 시스템 (레벨업, 리그, 스트릭)이 무의미해짐
- 앱 출시 즉시 1성 리뷰 폭탄 예상

**해결 방안**:
1. **즉시**: 초등 3-6학년 기초 산술 100개 문제 생성
2. **1주차**: 중1 대수 (방정식, 부등식) 100개 문제 추가
3. **2주차**: 중2-중3 기하 100개 문제 추가
4. **외주 검토**: 수학 교사/학원 강사에게 문제 제작 의뢰

**예상 소요 시간**: 2-3주 (내부 제작 기준)

---

### 2. 하트 시스템 미작동 🔥
**심각도**: **CRITICAL** (핵심 게임 메커니즘 누락)

**현상**:
- 온보딩에서 하트 시스템을 설명함: "하트 5개, 문제 틀리면 1개 감소, 30분마다 1개 재생"
- 실제 구현 상태:
  - ✅ User 모델에 `hearts` 필드 존재
  - ✅ 하트 재생 로직 존재: `_updateHeartsBasedOnTime()` (30분마다 1개)
  - ❌ **하트 감소 로직 미연결**: `decreaseHeart()` 메서드가 정의되어 있지만 **어디에서도 호출되지 않음**

**코드 위치**:
```dart
// lib/features/problem/problem_screen.dart:470
Future<void> _handleWrongAnswer(...) async {
  _currentStreak = 0;
  await AppHapticFeedback.error();
  await SoundEffects.playWrong();
  // ❌ 여기서 ref.read(userProvider.notifier).decreaseHeart() 호출 필요!
  await ref.read(errorNoteProvider.notifier).addErrorNote(...);
  ...
}
```

**영향**:
- 사용자가 무한정 문제를 틀려도 하트가 감소하지 않음
- 듀오링고 스타일의 핵심 텐션/리스크 요소가 작동하지 않음
- 온보딩에서 거짓 정보 제공 → 사용자 신뢰도 하락

**해결 방안**:
```dart
// problem_screen.dart:470 라인 수정
Future<void> _handleWrongAnswer(...) async {
  _currentStreak = 0;

  // ✅ 하트 감소 로직 추가
  await ref.read(userProvider.notifier).decreaseHeart();

  // 하트가 0이 되면 게임 오버 처리
  final user = ref.read(userProvider);
  if (user != null && user.hearts <= 0) {
    if (mounted) {
      _showHeartDepletedDialog(); // 하트 소진 다이얼로그 표시
    }
    return; // 더 이상 문제 풀이 불가
  }

  await AppHapticFeedback.error();
  await SoundEffects.playWrong();
  await ref.read(errorNoteProvider.notifier).addErrorNote(...);
  ...
}
```

**예상 소요 시간**: 2-3시간 (하트 소진 UI 포함)

---

### 3. 영수증 검증 서버 미구현 🔥
**심각도**: **HIGH** (보안 취약점)

**현상**:
```dart
// lib/data/services/in_app_purchase_service.dart:364
Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
  // TODO: 서버 사이드 검증 구현
  // 현재는 간단한 로컬 검증만 수행

  if (Platform.isIOS) {
    final iosPurchase = purchaseDetails as AppStorePurchaseDetails;
    if (iosPurchase.skPaymentTransaction.transactionIdentifier == null) {
      return false;
    }
    // TODO: 서버로 영수증 전송 및 검증
    return true; // ⚠️ 항상 true 반환 (보안 취약점!)
  }

  if (Platform.isAndroid) {
    // TODO: 서버로 영수증 전송 및 검증
    return true; // ⚠️ 항상 true 반환 (보안 취약점!)
  }

  return false;
}
```

**영향**:
- 클라이언트 검증만으로는 쉽게 우회 가능
- 해커가 결제하지 않고도 프리미엄 기능 사용 가능
- Apple/Google 정책 위반 → 앱 리젝트 가능

**해결 방안**:
1. Firebase Functions로 영수증 검증 API 구현
2. Apple: `verifyReceipt` API 호출 ([Apple Docs](https://developer.apple.com/documentation/appstorereceipts))
3. Google: Play Developer API로 구매 검증 ([Google Docs](https://developers.google.com/android-publisher))

**예상 소요 시간**: 1주일 (백엔드 개발 + 테스트)

---

## ⚠️ 높은 우선순위 문제 (High Priority)

### 4. 테스트 커버리지 부족
**현상**: 테스트 파일 2개만 존재 (widget_test.dart, deep_link_service_test.dart)
- 유닛 테스트 없음
- 통합 테스트 없음
- E2E 테스트 없음

**권장 사항**:
- 핵심 로직 유닛 테스트: UserProvider, LessonProvider, ProblemScreen
- 통합 테스트: 온보딩 → 문제 풀이 → 결과 플로우
- **최소 목표**: 핵심 기능 60% 커버리지

**예상 소요 시간**: 1주일

---

### 5. BuildContext Async Gap (28개 파일)
**현상**: async 작업 후 BuildContext 사용 전 mounted 체크 누락

**이미 수정 완료**:
- ✅ SplashScreen
- ✅ SignUpView

**남은 작업**: ~26개 파일 더 수정 필요

**예상 소요 시간**: 4-6시간

---

### 6. Firebase Analytics 미완성
**현상**:
- Analytics 코드 50% 구현
- Crashlytics 40% 구현
- 실제 이벤트 추적 누락

**권장 최소 이벤트**:
- 사용자 가입/로그인
- 문제 풀이 시작/완료
- 레벨업
- 구매 완료
- 앱 크래시

**예상 소요 시간**: 2-3일

---

## 📌 중간 우선순위 (Medium Priority)

### 7. Warning 정리 (320개)
**카테고리**:
- `withOpacity` deprecated: ~150개 → `withValues(alpha:)`로 변경
- BuildContext async gaps: ~28개
- `avoid_print`: ~18개 → Logger로 마이그레이션
- 스타일/린트 이슈: ~124개

**권장 사항**:
- 출시 전 최소 deprecated 관련 150개 수정
- 나머지는 출시 후 점진적 개선

**예상 소요 시간**: 2-3일

---

### 8. 레슨 데이터 부족
**현상**: `assets/data/lessons.json` 로드 실패 시 MockDataService의 샘플 레슨 5개만 제공

**권장 사항**:
- `assets/data/lessons.json` 파일 생성
- 최소 20개 유닛, 각 5개 레슨 정의
- 각 레슨당 문제 ID 매핑

**예상 소요 시간**: 1-2일

---

### 9. 이미지 리소스 누락
**현상**:
```json
"imageUrl": "assets/problems/images/polynomial_001_question.png",
"answerImageUrl": "assets/problems/images/polynomial_001_answer.png"
```
문제 JSON에 이미지 경로 정의되어 있지만 실제 파일 없음

**권장 사항**:
- 이미지 없이도 작동하도록 fallback 처리 (현재는 에러 발생 가능)
- 향후 수식 이미지 생성 시스템 구축

**예상 소요 시간**: 1일 (에러 처리만)

---

## 📋 MVP 출시 체크리스트

### 필수 (MUST)
- [ ] **문제 데이터 최소 200개 생성** (현재: 2개)
- [ ] **하트 시스템 연결** (decreaseHeart 호출)
- [ ] **하트 소진 UI 구현** (게임 오버 다이얼로그)
- [ ] **영수증 검증 서버 구현**
- [ ] **핵심 기능 테스트 작성** (최소 60% 커버리지)
- [ ] **Firebase Analytics 이벤트 추가**
- [ ] **BuildContext async gaps 수정** (28개 파일)

### 권장 (SHOULD)
- [ ] **레슨 데이터 JSON 파일 생성** (100개 레슨)
- [ ] **Warning 150개 수정** (deprecated 관련)
- [ ] **이미지 리소스 fallback 처리**
- [ ] **에러 처리 강화** (네트워크 오류, 타임아웃 등)

### 선택 (NICE TO HAVE)
- [ ] **E2E 테스트 작성**
- [ ] **오프라인 모드 완성도 향상**
- [ ] **성능 최적화** (앱 크기, 로딩 속도)
- [ ] **다크모드 완성**

---

## 📅 출시 일정 제안

### 현재 상태: 60% 완성
- 코어 시스템: 90% ✅
- 게이미피케이션: 85% ✅ (하트 시스템 제외)
- 컨텐츠: **1%** 🚨 (문제 데이터)
- 테스트: 5% ⚠️
- 보안: 40% ⚠️ (서버 검증 누락)

### 빠른 출시 (2-3주)
**목표**: 최소 기능 MVP (Minimum Viable Product)

**Week 1**:
- [ ] 하트 시스템 연결 (0.5일)
- [ ] 문제 데이터 100개 생성 (5일, 외주 시 병렬 진행 가능)
- [ ] BuildContext 수정 (0.5일)

**Week 2**:
- [ ] 문제 데이터 추가 100개 (5일)
- [ ] 영수증 검증 서버 구현 (3일)
- [ ] 핵심 테스트 작성 (2일)

**Week 3**:
- [ ] Firebase Analytics 완성 (2일)
- [ ] 레슨 JSON 생성 (1일)
- [ ] 최종 QA 및 버그 수정 (2일)

**출시 예정일**: 2025년 1월 20일

---

### 안정적 출시 (4-6주)
**목표**: 완성도 높은 MVP

**Week 1-2**: (동일)

**Week 3-4**:
- [ ] 문제 데이터 추가 100개 (총 300개)
- [ ] Warning 150개 수정
- [ ] 이미지 fallback 처리
- [ ] E2E 테스트 작성

**Week 5-6**:
- [ ] 베타 테스트 (50-100명)
- [ ] 피드백 반영
- [ ] 성능 최적화
- [ ] 최종 QA

**출시 예정일**: 2025년 2월 중순

---

## 💡 권장 사항

### 즉시 조치 필요
1. **문제 데이터 생성 시작** - 가장 시간이 오래 걸리는 작업
2. **하트 시스템 연결** - 2-3시간이면 완료 가능
3. **영수증 검증 서버 개발 착수** - 백엔드 리소스 할당 필요

### 우선순위 조정
1. **컨텐츠 > 기술적 완성도**: 문제 데이터가 없으면 앱이 무용지물
2. **보안 > UI/UX**: 결제 시스템 보안 취약점은 앱 리젝트 사유
3. **핵심 기능 안정성 > 추가 기능**: MVP는 작지만 완전해야 함

### 리소스 배분 제안
- **개발자 1명**: 하트 시스템, BuildContext 수정, Analytics
- **백엔드 개발자 1명**: 영수증 검증 서버
- **컨텐츠 제작자 2-3명**: 문제 데이터 생성 (외주 가능)
- **QA 1명**: 테스트 작성 및 버그 리포트

---

## 🎯 최종 결론

**현재 상태**: **출시 불가 (Not Ready for Launch)**

**주요 이유**:
1. 🔥 문제 데이터 부족 (2개/300개 필요)
2. 🔥 하트 시스템 미작동 (핵심 게임 메커니즘)
3. 🔥 영수증 검증 보안 취약점

**예상 출시 가능 시점**:
- **빠른 출시**: 2-3주 후 (최소 기능 MVP)
- **안정적 출시**: 4-6주 후 (권장)

**성공 가능성**:
- **현재 상태 출시 시**: 1-2성 평점 예상 (컨텐츠 부족)
- **3주 후 빠른 MVP**: 3-4성 평점 예상 (기본 기능 작동)
- **6주 후 완성 MVP**: 4-5성 평점 가능 (완성도 높음)

---

**작성자**: Claude Code AI
**검토 일시**: 2025-12-26
**다음 체크포인트**: 2025-01-02 (1주 후)
