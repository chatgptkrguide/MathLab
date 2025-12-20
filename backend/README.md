# MathLab Backend API Server

## 기술 스택

- **Runtime**: Node.js 20.x
- **Framework**: Express.js 4.x
- **Language**: TypeScript 5.x
- **Database**: PostgreSQL 16.x
- **Cache**: Redis 7.x
- **Authentication**: Firebase Admin SDK + JWT
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **API Documentation**: Swagger/OpenAPI 3.0

## 프로젝트 구조

```
backend/
├── src/
│   ├── config/              # 설정 파일
│   │   ├── database.ts      # PostgreSQL 설정
│   │   ├── redis.ts         # Redis 설정
│   │   ├── firebase.ts      # Firebase Admin SDK 설정
│   │   └── env.ts           # 환경 변수 관리
│   ├── controllers/         # 요청 핸들러
│   │   ├── auth.controller.ts
│   │   ├── fcm.controller.ts
│   │   └── payment.controller.ts
│   ├── middlewares/         # 미들웨어
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   └── error.middleware.ts
│   ├── models/              # 데이터 모델
│   │   ├── user.model.ts
│   │   ├── fcm-token.model.ts
│   │   └── payment.model.ts
│   ├── routes/              # API 라우트
│   │   ├── auth.routes.ts
│   │   ├── fcm.routes.ts
│   │   └── payment.routes.ts
│   ├── services/            # 비즈니스 로직
│   │   ├── auth.service.ts
│   │   ├── fcm.service.ts
│   │   └── payment.service.ts
│   ├── utils/               # 유틸리티
│   │   ├── logger.ts
│   │   ├── validator.ts
│   │   └── response.ts
│   ├── types/               # TypeScript 타입 정의
│   │   └── index.ts
│   ├── app.ts               # Express 앱 설정
│   └── server.ts            # 서버 진입점
├── tests/                   # 테스트 파일
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── scripts/                 # 스크립트
│   ├── migrate.ts
│   └── seed.ts
├── .env.example            # 환경 변수 예시
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

## 주요 API 엔드포인트

### Authentication API
```
POST   /api/v1/auth/register          # 회원가입
POST   /api/v1/auth/login             # 로그인
POST   /api/v1/auth/refresh           # 토큰 갱신
POST   /api/v1/auth/logout            # 로그아웃
POST   /api/v1/auth/custom-token      # Firebase Custom Token 발급
GET    /api/v1/auth/verify            # 토큰 검증
```

### FCM Token Management API
```
POST   /api/v1/fcm/token              # FCM 토큰 등록/갱신
DELETE /api/v1/fcm/token/:userId      # FCM 토큰 삭제
POST   /api/v1/fcm/subscribe          # 토픽 구독
POST   /api/v1/fcm/unsubscribe        # 토픽 구독 해제
POST   /api/v1/fcm/send               # 푸시 알림 전송 (관리자)
```

### Payment Verification API
```
POST   /api/v1/payment/verify/ios     # iOS 영수증 검증
POST   /api/v1/payment/verify/android # Android 영수증 검증
GET    /api/v1/payment/status/:userId # 결제 상태 조회
POST   /api/v1/payment/webhook        # 결제 웹훅
```
