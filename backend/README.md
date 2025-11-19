# MathLab Backend API

MathLab 게이미피케이션 수학 학습 앱의 백엔드 API 서버입니다.

## 🚀 기술 스택

- **Runtime**: Node.js 18+
- **Framework**: Express + TypeScript
- **Database**: PostgreSQL 14+
- **Cache**: Redis 7+
- **Authentication**: JWT
- **Deployment**: Google Cloud Run
- **Container**: Docker

## 📁 프로젝트 구조

```
backend/
├── src/
│   ├── config/           # 설정 (Database, Redis)
│   ├── controllers/      # API 컨트롤러
│   ├── services/         # 비즈니스 로직
│   ├── models/           # 데이터 모델/타입
│   ├── middlewares/      # 미들웨어 (인증 등)
│   ├── routes/           # API 라우트
│   ├── utils/            # 유틸리티 (JWT, Logger)
│   └── index.ts          # 서버 진입점
├── database/
│   ├── schema.sql        # PostgreSQL DDL
│   └── seed.sql          # 초기 데이터
├── Dockerfile            # Docker 이미지 빌드
├── docker-compose.yml    # 로컬 개발 환경
└── cloudbuild.yaml       # GCP Cloud Build 설정
```

## 🛠️ 로컬 개발 환경 설정

### 1. 환경 변수 설정

```bash
cp .env.example .env
# .env 파일 편집
```

### 2. Docker Compose로 실행

```bash
docker-compose up -d
```

이 명령은 다음을 자동으로 시작합니다:
- PostgreSQL (포트 5432)
- Redis (포트 6379)
- API 서버 (포트 8080)

### 3. 헬스 체크

```bash
curl http://localhost:8080/health
```

## 📡 API 엔드포인트

### 인증 API (`/api/v1/auth`)

- `POST /auth/signup/email` - 이메일 회원가입
- `POST /auth/login/email` - 이메일 로그인
- `POST /auth/login/google` - Google 로그인
- `POST /auth/login/kakao` - Kakao 로그인
- `POST /auth/refresh` - 토큰 갱신
- `POST /auth/logout` - 로그아웃

### 사용자 API (`/api/v1/users`)

- `GET /users/me` - 현재 사용자 정보
- `PUT /users/me` - 프로필 업데이트
- `GET /users/me/stats` - 학습 통계
- `POST /users/me/xp` - XP 추가 (서버 검증)
- `POST /users/me/hearts` - 하트 차감/회복

### 레슨 API (`/api/v1/lessons`)

- `GET /lessons` - 전체 레슨 목록
- `GET /lessons/me/progress` - 내 레슨 진행도
- `POST /lessons/:lessonId/complete` - 레슨 완료

### 문제 API (`/api/v1/problems`)

- `GET /problems?lessonId=` - 레슨별 문제 목록
- `POST /problems/:problemId/submit` - 답안 제출 (서버 검증)
- `GET /problems/me/results` - 내 풀이 기록

### 리더보드 API (`/api/v1/leaderboard`)

- `GET /leaderboard/weekly?league=bronze` - 주간 리더보드
- `GET /leaderboard/me` - 내 순위

## 🔐 인증

모든 보호된 엔드포인트는 Authorization 헤더에 JWT 토큰이 필요합니다:

```
Authorization: Bearer <access_token>
```

## 🚢 GCP Cloud Run 배포

### 1. GCP 프로젝트 설정

```bash
# GCP 프로젝트 ID 설정
export PROJECT_ID=your-gcp-project-id

# gcloud 인증
gcloud auth login
gcloud config set project $PROJECT_ID
```

### 2. Cloud SQL 및 Memorystore 생성

```bash
# Cloud SQL (PostgreSQL) 생성
gcloud sql instances create mathlab-db \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=asia-northeast3

# 데이터베이스 생성
gcloud sql databases create mathlab --instance=mathlab-db

# Redis (Memorystore) 생성
gcloud redis instances create mathlab-redis \
  --size=1 \
  --region=asia-northeast3 \
  --redis-version=redis_7_0
```

### 3. Secret Manager 설정

```bash
# JWT Secret 저장
echo -n "your_super_secret_jwt_key" | \
  gcloud secrets create jwt-secret --data-file=-

# DB Password 저장
echo -n "your_db_password" | \
  gcloud secrets create db-password --data-file=-
```

### 4. Cloud Build를 통한 배포

```bash
gcloud builds submit --config cloudbuild.yaml
```

### 5. 환경 변수 설정

Cloud Run 콘솔에서 다음 환경 변수 설정:

- `NODE_ENV=production`
- `DB_HOST=<Cloud SQL 연결 문자열>`
- `REDIS_HOST=<Memorystore IP>`
- `JWT_SECRET=<Secret Manager에서 참조>`

## 📊 모니터링

### 로그 확인

```bash
# Cloud Run 로그
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# 로컬 로그
docker-compose logs -f api
```

### 메트릭

Cloud Run 콘솔에서 다음 메트릭 확인:
- Request count
- Request latency
- Error rate
- Container instances

## 🧪 테스트

```bash
# 개발 서버 실행
npm run dev

# 빌드
npm run build

# 프로덕션 실행
npm start
```

## 📝 데이터베이스 마이그레이션

```bash
# Docker 컨테이너 내부에서 SQL 실행
docker-compose exec postgres psql -U postgres -d mathlab -f /docker-entrypoint-initdb.d/01-schema.sql
```

## 🔒 보안

- JWT 토큰은 15분 유효 (Access Token)
- Refresh Token은 7일 유효
- 비밀번호는 bcrypt로 해싱 (12 rounds)
- Rate Limiting: 1분당 100 요청
- CORS 설정 필수
- HTTPS 필수 (프로덕션)

## 💰 예상 비용 (월별)

**개발 환경 (최소 구성)**:
- Cloud SQL (db-f1-micro): $10
- Memorystore (M1, 1GB): $50
- Cloud Run (트래픽 적음): ~$0
- **Total**: ~$60/월

**프로덕션 (10,000 사용자)**:
- Cloud SQL (db-g1-small): $50
- Memorystore (M2, 4GB): $200
- Cloud Run: $20
- **Total**: ~$270/월

## 📞 문의

- **Team**: MathLab Development Team
- **Email**: dev@mathlab.app

## 📄 라이센스

MIT License
