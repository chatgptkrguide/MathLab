
## 데이터베이스 스키마

### users 테이블
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  firebase_uid VARCHAR(128) UNIQUE,
  name VARCHAR(100) NOT NULL,
  avatar_url TEXT,
  current_grade VARCHAR(20),
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  hearts INTEGER DEFAULT 5,
  daily_xp INTEGER DEFAULT 0,
  is_premium BOOLEAN DEFAULT FALSE,
  premium_tier VARCHAR(20),
  role VARCHAR(20) DEFAULT 'user',
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### fcm_tokens 테이블
```sql
CREATE TABLE fcm_tokens (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  token VARCHAR(255) NOT NULL,
  device_type VARCHAR(20) CHECK (device_type IN ('ios', 'android', 'web')),
  device_id VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(user_id, device_id)
);
```

### payments 테이블
```sql
CREATE TABLE payments (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  platform VARCHAR(20) CHECK (platform IN ('ios', 'android')),
  transaction_id VARCHAR(255) UNIQUE NOT NULL,
  product_id VARCHAR(100) NOT NULL,
  receipt_data TEXT NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,
  amount DECIMAL(10, 2),
  currency VARCHAR(3) DEFAULT 'KRW',
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Supabase 설정

### 1. Supabase 프로젝트 생성

1. [Supabase Dashboard](https://app.supabase.com)에 접속
2. "New Project" 클릭
3. 프로젝트 정보 입력:
   - Name: `mathlab-production`
   - Database Password: 강력한 비밀번호 생성
   - Region: `Northeast Asia (Seoul)` 선택
4. "Create new project" 클릭

### 2. 데이터베이스 스키마 생성

1. Supabase Dashboard → SQL Editor
2. `scripts/supabase-setup.sql` 파일 내용 복사
3. SQL Editor에 붙여넣기
4. "Run" 클릭하여 실행

### 3. API 키 확인

1. Supabase Dashboard → Settings → API
2. 다음 값 복사:
   - Project URL → `SUPABASE_URL`
   - `anon` public key → `SUPABASE_ANON_KEY`
   - `service_role` secret key → `SUPABASE_SERVICE_ROLE_KEY`

### 4. 환경 변수 설정

`.env` 파일 생성 및 설정:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## 개발 환경 설정

### 1. 의존성 설치

```bash
cd backend
npm install
```

### 2. 환경 변수 설정

```bash
cp .env.example .env
# .env 파일 편집하여 실제 값 입력
```

### 3. 개발 서버 실행

```bash
npm run dev
```

서버가 http://localhost:3000 에서 실행됩니다.

### 4. API 테스트

```bash
# Health check
curl http://localhost:3000/health

# FCM 토큰 등록 (인증 필요)
curl -X POST http://localhost:3000/api/v1/fcm/token \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "token": "fcm-token-here",
    "deviceType": "ios",
    "deviceId": "device-id-here"
  }'
```

## GCP Cloud Run 배포

### 1. GCP 프로젝트 설정

```bash
# GCP CLI 설치 확인
gcloud --version

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# Container Registry API 활성화
gcloud services enable containerregistry.googleapis.com

# Cloud Run API 활성화
gcloud services enable run.googleapis.com
```

### 2. 환경 변수 설정

Cloud Run에서 사용할 환경 변수를 Secret Manager에 저장:

```bash
# Supabase URL
echo -n "https://your-project.supabase.co" | \
  gcloud secrets create SUPABASE_URL --data-file=-

# Supabase Service Role Key
echo -n "your-service-role-key" | \
  gcloud secrets create SUPABASE_SERVICE_ROLE_KEY --data-file=-

# JWT Secret
echo -n "your-super-secret-jwt-key" | \
  gcloud secrets create JWT_SECRET --data-file=-
```

### 3. 배포 실행

```bash
# 배포 스크립트 실행 권한 부여
chmod +x scripts/deploy-cloud-run.sh

# 스크립트 내 PROJECT_ID 수정 후 실행
./scripts/deploy-cloud-run.sh
```

### 4. 배포 확인

```bash
# 서비스 URL 확인
gcloud run services describe mathlab-api \
  --platform managed \
  --region asia-northeast3 \
  --format 'value(status.url)'

# Health check
curl https://your-service-url.run.app/health
```

## 보안 설정

### 1. Secret Manager 사용

민감한 정보는 Secret Manager에 저장:

```bash
# Firebase Private Key
gcloud secrets create FIREBASE_PRIVATE_KEY \
  --data-file=path/to/firebase-private-key.txt

# Apple IAP Shared Secret
echo -n "your-apple-shared-secret" | \
  gcloud secrets create APPLE_SHARED_SECRET --data-file=-
```

### 2. Cloud Run IAM 설정

Service Account에 필요한 권한 부여:

```bash
# Secret Manager 접근 권한
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:YOUR_SERVICE_ACCOUNT" \
  --role="roles/secretmanager.secretAccessor"
```

### 3. CORS 설정

프로덕션 환경에서는 특정 도메인만 허용:

```env
ALLOWED_ORIGINS=https://mathlab.app,https://www.mathlab.app
```

## 모니터링 및 로깅

### 1. Cloud Logging

```bash
# 최근 로그 확인
gcloud logging read "resource.type=cloud_run_revision AND \
  resource.labels.service_name=mathlab-api" \
  --limit 50 \
  --format json

# 실시간 로그 스트리밍
gcloud alpha logging tail "resource.type=cloud_run_revision AND \
  resource.labels.service_name=mathlab-api"
```

### 2. Error Reporting

Google Cloud Console → Error Reporting에서 에러 확인

### 3. Cloud Monitoring

대시보드에서 다음 메트릭 모니터링:
- Request count
- Request latency
- Error rate
- CPU utilization
- Memory utilization

## 성능 최적화

### 1. Cold Start 최소화

```yaml
# cloud-run.yaml
min-instances: 1  # Warm instance 유지
```

### 2. 메모리 최적화

```yaml
memory: 512Mi  # 필요에 따라 조정
cpu: 1
```

### 3. Timeout 설정

```yaml
timeout: 60s  # 긴 요청에 대비
```

## 문제 해결

### 배포 실패

```bash
# 로그 확인
gcloud run services logs read mathlab-api \
  --platform managed \
  --region asia-northeast3

# 이미지 빌드 로그 확인
gcloud builds list --limit 5
```

### 데이터베이스 연결 실패

1. Supabase 프로젝트 상태 확인
2. 환경 변수 확인
3. Row Level Security 정책 확인

### FCM 전송 실패

1. Firebase Admin SDK 초기화 확인
2. FCM 토큰 유효성 확인
3. Firebase Console에서 프로젝트 설정 확인

## 라이센스

MIT License
