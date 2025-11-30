# Phase 4 구현 계획: Cloud Functions - 영수증 검증 및 Webhook 처리

## 📋 개요

Phase 4에서는 프리미엄 구독 시스템의 **서버 측 영수증 검증 및 자동 갱신 처리**를 위한 Firebase Cloud Functions를 구현합니다.

### 🎯 목표
- iOS/Android 영수증 서버 측 검증으로 보안 강화
- App Store/Google Play Webhook을 통한 구독 상태 자동 동기화
- 사기 방지 및 구독 무결성 보장

## 🏗️ 아키텍처

```
┌─────────────────┐
│  Flutter App    │
│  (Client)       │
└────────┬────────┘
         │ 1. Purchase Complete
         ↓
┌─────────────────────────────────┐
│  Cloud Functions                │
│                                 │
│  ┌──────────────────────────┐  │
│  │ verifyIOSReceipt         │←─┼── App Store Server API
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │ verifyAndroidReceipt     │←─┼── Google Play API
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │ iosWebhook               │←─┼── App Store S2S Notifications
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │ androidWebhook           │←─┼── Google RTDN
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │ syncSubscriptionStatus   │  │
│  └──────────────────────────┘  │
└────────┬────────────────────────┘
         │ 2. Update Firestore
         ↓
┌─────────────────┐
│  Firestore      │
│  subscriptions/ │
└─────────────────┘
```

## 📦 구현할 Functions

### 1. **verifyIOSReceipt** (HTTP Function)
**목적**: iOS App Store 영수증 검증

**입력**:
```typescript
{
  userId: string;
  receiptData: string; // Base64 encoded receipt
  transactionId: string;
  productId: string;
}
```

**처리 흐름**:
1. App Store Server API 호출 (`verifyReceipt` endpoint)
2. 영수증 진위 확인
3. 구독 정보 추출 (tier, expiryDate, autoRenew 등)
4. Firestore `subscriptions/{subscriptionId}` 생성/업데이트
5. 사용자 `premiumStatus` 업데이트

**출력**:
```typescript
{
  success: boolean;
  subscriptionId?: string;
  expiryDate?: Date;
  error?: string;
}
```

### 2. **verifyAndroidReceipt** (HTTP Function)
**목적**: Android Google Play 영수증 검증

**입력**:
```typescript
{
  userId: string;
  purchaseToken: string;
  productId: string;
  packageName: string;
}
```

**처리 흐름**:
1. Google Play Developer API 호출 (`purchases.subscriptions.get`)
2. 구매 토큰 검증
3. 구독 정보 추출
4. Firestore 업데이트
5. 사용자 프리미엄 상태 활성화

**출력**:
```typescript
{
  success: boolean;
  subscriptionId?: string;
  expiryDate?: Date;
  error?: string;
}
```

### 3. **iosWebhook** (HTTP Function)
**목적**: iOS Server-to-Server Notifications 처리

**Webhook 이벤트 타입**:
- `DID_RENEW`: 구독 갱신
- `DID_FAIL_TO_RENEW`: 갱신 실패
- `DID_CHANGE_RENEWAL_STATUS`: 자동 갱신 상태 변경
- `EXPIRED`: 구독 만료
- `CANCEL`: 구독 취소
- `REFUND`: 환불

**처리 흐름**:
1. Webhook 서명 검증 (JWT)
2. 이벤트 타입별 처리
3. Firestore `subscriptions` 업데이트
4. 사용자 프리미엄 상태 동기화
5. 로깅 및 모니터링

### 4. **androidWebhook** (HTTP Function)
**목적**: Android Real-time Developer Notifications 처리

**Webhook 이벤트 타입**:
- `SUBSCRIPTION_RENEWED`: 구독 갱신
- `SUBSCRIPTION_CANCELED`: 구독 취소
- `SUBSCRIPTION_EXPIRED`: 구독 만료
- `SUBSCRIPTION_RECOVERED`: 구독 복원
- `SUBSCRIPTION_PAUSED`: 구독 일시정지
- `SUBSCRIPTION_REVOKED`: 구독 취소 (환불)

**처리 흐름**:
1. Pub/Sub 메시지 디코딩
2. Google Play API로 구독 상태 조회
3. Firestore 업데이트
4. 사용자 상태 동기화
5. 로깅

### 5. **syncSubscriptionStatus** (Scheduled Function)
**목적**: 주기적 구독 상태 동기화 (백업/안전장치)

**실행 주기**: 매일 00:00 (한국 시간)

**처리 흐름**:
1. 만료 예정 구독 조회 (7일 이내)
2. App Store/Google Play API로 최신 상태 확인
3. 불일치 시 Firestore 업데이트
4. 만료된 구독 처리
5. 리포트 생성 및 알림

## 🔧 기술 스택

### Firebase Functions
- **런타임**: Node.js 18
- **언어**: TypeScript
- **패키지 관리**: npm

### 필수 npm 패키지
```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0",
    "axios": "^1.6.0",
    "jsonwebtoken": "^9.0.0",
    "google-auth-library": "^9.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "firebase-functions-test": "^3.0.0"
  }
}
```

### API 키 및 인증

**iOS (App Store)**:
- App Store Connect API Key (`.p8` 파일)
- Issuer ID
- Key ID
- Bundle ID

**Android (Google Play)**:
- Service Account JSON 키
- Package Name
- Google Play Developer API 활성화

## 📁 프로젝트 구조

```
functions/
├── src/
│   ├── index.ts                 # Main entry point
│   ├── config/
│   │   ├── ios-config.ts        # iOS API 설정
│   │   └── android-config.ts    # Android API 설정
│   ├── services/
│   │   ├── ios-verification.ts  # iOS 영수증 검증 로직
│   │   ├── android-verification.ts # Android 검증 로직
│   │   └── subscription-sync.ts # 구독 동기화 로직
│   ├── webhooks/
│   │   ├── ios-webhook.ts       # iOS Webhook 핸들러
│   │   └── android-webhook.ts   # Android Webhook 핸들러
│   ├── utils/
│   │   ├── logger.ts            # 로깅 유틸리티
│   │   ├── error-handler.ts     # 에러 처리
│   │   └── validators.ts        # 입력 검증
│   └── types/
│       ├── subscription.ts      # 타입 정의
│       └── webhook.ts           # Webhook 타입
├── package.json
├── tsconfig.json
└── .env.example
```

## 🔐 보안 고려사항

### 1. API 키 관리
- Firebase Functions 환경 변수 사용
- `.env` 파일은 `.gitignore`에 추가
- 프로덕션 키는 Firebase Console에서 직접 설정

### 2. Webhook 검증
- **iOS**: JWT 서명 검증 (Apple 공개키)
- **Android**: Pub/Sub 서명 검증

### 3. 입력 검증
- 모든 HTTP 요청에 대한 파라미터 검증
- SQL Injection, XSS 방지
- Rate limiting 적용

### 4. 에러 처리
- 민감한 정보 로그 제외
- 구조화된 에러 응답
- 재시도 로직 (exponential backoff)

## 📊 모니터링 및 로깅

### Cloud Logging
```typescript
{
  level: 'INFO' | 'WARN' | 'ERROR',
  function: 'verifyIOSReceipt',
  userId: 'user123',
  action: 'verification_success',
  metadata: {
    subscriptionId: 'sub_xxx',
    tier: 'yearly'
  }
}
```

### 모니터링 지표
- 영수증 검증 성공률 (iOS/Android 별도)
- Webhook 처리 시간
- 에러율 및 에러 타입별 분류
- 구독 갱신/취소 트렌드

## ⚡ 성능 최적화

### 1. 캐싱
- App Store/Google Play API 응답 캐싱 (5분)
- Firestore 쿼리 결과 캐싱

### 2. 병렬 처리
- 여러 구독 검증 시 Promise.all() 사용
- Firestore 배치 쓰기

### 3. Cold Start 최적화
- Min instances 설정 (프로덕션)
- 함수 크기 최소화

## 🧪 테스트 전략

### 1. 단위 테스트
- 각 함수별 독립적 테스트
- Mock API 응답 사용
- Firebase Functions Test SDK 활용

### 2. 통합 테스트
- Sandbox 환경에서 실제 API 호출
- Firestore Emulator 사용
- E2E 시나리오 테스트

### 3. 테스트 케이스
- ✅ 유효한 영수증 검증 성공
- ❌ 무효한 영수증 검증 실패
- ✅ Webhook 정상 처리
- ❌ 잘못된 Webhook 서명 거부
- ✅ 구독 갱신 자동 처리
- ❌ 네트워크 에러 재시도

## 🚀 배포 계획

### 1. 개발 환경
```bash
# Firebase Functions 로컬 에뮬레이터
firebase emulators:start --only functions
```

### 2. 스테이징 환경
```bash
# 스테이징 프로젝트 배포
firebase deploy --only functions --project mathlab-staging
```

### 3. 프로덕션 환경
```bash
# 프로덕션 배포 (승인 후)
firebase deploy --only functions --project mathlab-prod
```

## 📝 구현 체크리스트

### Phase 4-1: 프로젝트 초기화
- [ ] Firebase Functions 프로젝트 생성
- [ ] TypeScript 설정
- [ ] package.json 의존성 설치
- [ ] 프로젝트 구조 생성
- [ ] 환경 변수 템플릿 작성

### Phase 4-2: iOS 영수증 검증
- [ ] App Store Server API 연동
- [ ] verifyIOSReceipt 함수 구현
- [ ] 에러 처리 및 로깅
- [ ] 단위 테스트 작성

### Phase 4-3: Android 영수증 검증
- [ ] Google Play API 연동
- [ ] verifyAndroidReceipt 함수 구현
- [ ] 에러 처리 및 로깅
- [ ] 단위 테스트 작성

### Phase 4-4: Webhook 핸들러
- [ ] iosWebhook 함수 구현
- [ ] androidWebhook 함수 구현
- [ ] Webhook 서명 검증
- [ ] 이벤트 타입별 처리 로직

### Phase 4-5: 구독 동기화
- [ ] syncSubscriptionStatus 함수 구현
- [ ] Cron 스케줄 설정
- [ ] 배치 처리 로직

### Phase 4-6: 테스트 및 배포
- [ ] 로컬 에뮬레이터 테스트
- [ ] Sandbox 환경 테스트
- [ ] 스테이징 배포
- [ ] 프로덕션 배포

## 🔗 참고 문서

- [Firebase Cloud Functions 문서](https://firebase.google.com/docs/functions)
- [App Store Server API](https://developer.apple.com/documentation/appstoreserverapi)
- [Google Play Billing API](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions)
- [iOS Server Notifications](https://developer.apple.com/documentation/appstoreservernotifications)
- [Android Real-time Developer Notifications](https://developer.android.com/google/play/billing/rtdn-reference)

## ⚠️ 주의사항

1. **API 할당량**: App Store/Google Play API 호출 제한 확인
2. **비용**: Cloud Functions 호출 수에 따른 과금 모니터링
3. **보안**: API 키 절대 하드코딩 금지
4. **Webhook URL**: HTTPS 필수, Firebase 도메인 사용
5. **에러 복구**: 재시도 로직 구현 필수
