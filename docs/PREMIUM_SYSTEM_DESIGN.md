# Premium Subscription System - Design Document

## 1. Overview

프리미엄 구독 시스템은 MathLab 앱의 수익 모델이자 사용자에게 향상된 학습 경험을 제공하는 핵심 기능입니다.

### 1.1 목표
- 사용자에게 프리미엄 기능을 명확하게 제공
- iOS/Android 인앱 결제 통합
- Firebase를 통한 구독 상태 관리
- 무료 사용자와 프리미엄 사용자 기능 구분

### 1.2 비즈니스 모델
- **Free Tier**: 기본 학습 기능, 광고 포함, 하트 시스템 제한
- **Premium Tier**: 광고 제거, 무제한 하트, 고급 분석, 개인화 학습

---

## 2. Data Models

### 2.1 PremiumTier Enum

```dart
/// 프리미엄 등급
enum PremiumTier {
  free,        // 무료 사용자
  monthly,     // 월간 구독
  yearly,      // 연간 구독
  lifetime,    // 평생 구독
}
```

### 2.2 SubscriptionStatus Enum

```dart
/// 구독 상태
enum SubscriptionStatus {
  active,      // 활성 구독
  expired,     // 만료됨
  cancelled,   // 취소됨 (기간 종료까지 사용 가능)
  trial,       // 무료 체험 중
  paused,      // 일시 정지
}
```

### 2.3 Subscription Model

```dart
/// 구독 정보 모델
class Subscription {
  final String id;                          // 구독 ID
  final String userId;                      // 사용자 ID
  final PremiumTier tier;                   // 구독 등급
  final SubscriptionStatus status;          // 구독 상태
  final DateTime startDate;                 // 구독 시작일
  final DateTime? expiryDate;               // 구독 만료일 (평생 구독은 null)
  final String? transactionId;              // 거래 ID (영수증)
  final String platform;                    // 플랫폼 (ios/android/web)
  final bool autoRenew;                     // 자동 갱신 여부
  final DateTime? cancelledAt;              // 취소 시각
  final DateTime createdAt;                 // 생성 시각
  final DateTime updatedAt;                 // 수정 시각

  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.expiryDate,
    this.transactionId,
    required this.platform,
    this.autoRenew = true,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON serialization
  factory Subscription.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }

  // Firestore serialization
  factory Subscription.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }

  // Helper methods
  bool get isActive => status == SubscriptionStatus.active && !isExpired;
  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isTrial => status == SubscriptionStatus.trial;
  int get daysRemaining => expiryDate != null
    ? expiryDate!.difference(DateTime.now()).inDays
    : -1;

  Subscription copyWith({ ... });
}
```

### 2.4 User Model Updates

기존 User 모델에 프리미엄 관련 필드 추가:

```dart
class User {
  // ... 기존 필드들

  // ====== 프리미엄 관련 필드 추가 ======
  final bool isPremium;                     // 프리미엄 사용자 여부
  final PremiumTier premiumTier;            // 프리미엄 등급
  final DateTime? premiumExpiryDate;        // 프리미엄 만료일
  final bool hasHadTrial;                   // 무료 체험 사용 이력

  const User({
    // ... 기존 파라미터들
    this.isPremium = false,
    this.premiumTier = PremiumTier.free,
    this.premiumExpiryDate,
    this.hasHadTrial = false,
  });

  // Helper methods
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumTier == PremiumTier.lifetime) return true;
    if (premiumExpiryDate == null) return false;
    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  bool get canStartTrial => !hasHadTrial && !isPremium;
}
```

---

## 3. Architecture Design

### 3.1 Layered Architecture

```
┌─────────────────────────────────────────┐
│          UI Layer (Screens)             │
│  - PremiumUpgradeScreen                 │
│  - PaymentScreen                        │
│  - SubscriptionManagementScreen         │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Presentation Layer (Providers)     │
│  - premiumStatusProvider                │
│  - subscriptionProvider                 │
│  - inAppPurchaseProvider                │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│       Business Logic (Services)         │
│  - SubscriptionService                  │
│  - InAppPurchaseService                 │
│  - PremiumFeatureService                │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Data Layer (Repository)         │
│  - SubscriptionRepository               │
│  - Firebase Firestore                   │
└─────────────────────────────────────────┘
```

### 3.2 Component Responsibilities

#### UI Layer
- 프리미엄 업그레이드 화면 표시
- 결제 플로우 UI
- 구독 관리 화면

#### Presentation Layer (Riverpod Providers)
- 프리미엄 상태 관리 및 노출
- 구독 정보 제공
- 인앱 구매 상태 관리

#### Business Logic (Services)
- **SubscriptionService**: 구독 로직, 만료 체크, 갱신 처리
- **InAppPurchaseService**: 플랫폼별 결제 처리 (iOS/Android)
- **PremiumFeatureService**: 프리미엄 기능 접근 제어

#### Data Layer
- Firestore에 구독 데이터 저장/조회
- 캐싱 및 오프라인 지원

---

## 4. Premium Features

### 4.1 Free Tier (무료)
- ✅ 기본 학습 콘텐츠 접근
- ✅ 하루 5개의 하트 (오답 시 차감)
- ✅ 기본 통계 및 진행률
- ✅ 리그 참여
- ❌ 광고 표시 (레슨 사이, 하트 충전 시)

### 4.2 Premium Tier (프리미엄)
- ✅ **무제한 하트**: 실수해도 제한 없음
- ✅ **광고 제거**: 모든 광고 비활성화
- ✅ **고급 분석**: 학습 패턴, 취약점 분석
- ✅ **개인화 학습**: AI 기반 맞춤형 문제 추천
- ✅ **오프라인 모드**: 인터넷 없이 학습 가능
- ✅ **우선 지원**: 고객 지원 우선 처리
- ✅ **프리미엄 뱃지**: 프로필에 특별 뱃지 표시
- ✅ **친구 초대 보너스**: 추가 XP 및 리워드

### 4.3 Price Tiers (가격 정책)

| Tier | Price | Discount | Features |
|------|-------|----------|----------|
| Monthly | ₩9,900/월 | - | 모든 프리미엄 기능 |
| Yearly | ₩89,000/년 | ~25% | 월간 대비 절감 |
| Lifetime | ₩199,000 | - | 평생 사용 |

---

## 5. Implementation Sequence

### Phase 1: Foundation (기초 구축)
1. ✅ Data models 생성
   - `Subscription` model
   - `PremiumTier` enum
   - `SubscriptionStatus` enum
   - `User` model 업데이트

2. ✅ Firebase 구조 설계
   - Firestore collections: `subscriptions/{userId}`
   - Security rules 작성

### Phase 2: Service Layer (서비스 계층)
3. ✅ SubscriptionService 구현
   - 구독 상태 확인
   - 만료 체크
   - 갱신 로직

4. ✅ InAppPurchaseService 구현
   - `in_app_purchase` 패키지 통합
   - iOS/Android 설정
   - 결제 플로우

### Phase 3: State Management (상태 관리)
5. ✅ Riverpod providers 구현
   - `premiumStatusProvider`
   - `subscriptionProvider`
   - `inAppPurchaseProvider`

### Phase 4: Feature Gating (기능 제어)
6. ✅ PremiumFeatureService 구현
   - 기능별 접근 권한 체크
   - 프리미엄 전용 기능 잠금/해제

### Phase 5: UI Implementation (UI 구현)
7. ✅ 프리미엄 업그레이드 화면
   - 프리미엄 혜택 설명
   - 가격 옵션 선택
   - CTA (Call-to-Action) 버튼

8. ✅ 결제 화면
   - 플랫폼별 결제 UI
   - 로딩 및 에러 처리

9. ✅ 구독 관리 화면
   - 현재 구독 상태 표시
   - 취소/변경 옵션
   - 영수증 확인

### Phase 6: Testing (테스트)
10. ✅ Unit tests
    - Model tests
    - Service logic tests
    - Provider tests

11. ✅ Integration tests
    - 결제 플로우 E2E
    - 구독 상태 동기화

12. ✅ Platform tests
    - iOS sandbox testing
    - Android test purchases

---

## 6. Security Considerations

### 6.1 Server-Side Validation
- ⚠️ **중요**: 클라이언트만 믿지 말고 서버에서 영수증 검증
- Firebase Functions를 통한 영수증 검증
- Apple/Google API로 구독 상태 실시간 확인

### 6.2 Fraud Prevention
- 구독 ID와 User ID 매핑 검증
- 중복 거래 방지
- 비정상적인 구독 패턴 감지

### 6.3 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 구독 정보는 본인만 읽을 수 있음
    match /subscriptions/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // 서버 측에서만 수정 가능
    }
  }
}
```

---

## 7. Error Handling

### 7.1 Common Error Scenarios
- 결제 실패 (카드 거절, 잔액 부족)
- 네트워크 오류
- 서버 검증 실패
- 플랫폼별 오류 (iOS/Android)

### 7.2 Error Recovery
- 자동 재시도 로직
- 사용자 친화적인 오류 메시지
- 고객 지원 연락 옵션

---

## 8. Analytics & Monitoring

### 8.1 Key Metrics
- 프리미엄 전환율 (Free → Premium)
- ARPU (Average Revenue Per User)
- 구독 유지율 (Retention Rate)
- 취소율 (Churn Rate)
- 평균 구독 기간

### 8.2 Events to Track
- `premium_upgrade_viewed` - 업그레이드 화면 조회
- `premium_tier_selected` - 가격 옵션 선택
- `payment_initiated` - 결제 시작
- `payment_completed` - 결제 완료
- `payment_failed` - 결제 실패
- `subscription_renewed` - 구독 갱신
- `subscription_cancelled` - 구독 취소

---

## 9. Testing Strategy

### 9.1 Development Testing
- iOS: Sandbox environment
- Android: Test purchase items
- Firebase: Test Firestore with emulator

### 9.2 QA Checklist
- [ ] 각 price tier 구매 테스트
- [ ] 구독 만료 시나리오
- [ ] 자동 갱신 확인
- [ ] 구독 취소 플로우
- [ ] 영수증 검증
- [ ] 오프라인 동작
- [ ] 플랫폼 간 동기화

---

## 10. Future Enhancements

### 10.1 Phase 2 Features
- 가족 공유 구독
- 학생/교사 할인
- 그룹 라이센스
- 프로모션 코드

### 10.2 Advanced Analytics
- 학습 패턴 AI 분석
- 개인화 추천 엔진
- 성적 예측 모델

---

## 11. Dependencies

### 11.1 Flutter Packages

```yaml
dependencies:
  # 인앱 구매
  in_app_purchase: ^3.1.13
  in_app_purchase_storekit: ^0.3.6+7  # iOS
  in_app_purchase_android: ^0.3.0+18  # Android

  # 상태 관리 (이미 설치됨)
  flutter_riverpod: ^2.4.9

  # Firebase (이미 설치됨)
  cloud_firestore: ^5.6.0
  firebase_auth: ^5.3.4
```

### 11.2 Platform Setup

#### iOS (Info.plist)
```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

---

## 12. References

- [Flutter In-App Purchase](https://pub.dev/packages/in_app_purchase)
- [Apple StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
