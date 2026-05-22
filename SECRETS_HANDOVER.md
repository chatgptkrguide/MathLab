# MathLab 시크릿 파일 인수인계 체크리스트

> ⚠️ 모든 파일은 **1Password Family/Team 공유 폴더**로만 전달.
> ❌ Slack DM, 이메일, GitHub, 메신저 파일 첨부 절대 금지.

## 받아야 할 파일

### Android (4개)
- [ ] `android/key.properties` — 서명 keystore 비밀번호
- [ ] `android/local.properties` — Kakao 앱 키, Flutter SDK 경로
- [ ] `android/app/google-services.json` — Firebase Android 설정
- [ ] `.secrets/upload-keystore.jks` (또는 동일 키스토어 파일) — 앱 서명 인증서

### iOS (4개)
- [ ] `ios/Runner/GoogleService-Info.plist` — Firebase iOS 설정
- [ ] `ios/Flutter/KakaoSecrets.xcconfig` — iOS Kakao 키
- [ ] iOS 배포 인증서 `.p12` + 비밀번호 (위치는 별도 채널로 전달)
- [ ] iOS 프로비저닝 프로파일 `.mobileprovision`

### 배포 자동화 (2개)
- [ ] `.secrets/play-store-deploy.json` — Play Store 서비스 계정
- [ ] `.secrets/ios-credentials.md` — 인증서 비밀번호 / API Key 정리본

### 환경변수 (2개)
- [ ] `.env` — 로컬 개발용 (API URL, Google Client ID, FCM 키)
- [ ] `.env.production` — 프로덕션 빌드용

## 검증 순서

각 파일을 받은 직후 아래 명령으로 검증하세요.

```bash
# 1. Android 서명 키 정상 동작 확인
cd android && ./gradlew signingReport
# → SHA-1, SHA-256 출력되면 OK

# 2. iOS 빌드 준비
cd ios && pod install && open Runner.xcworkspace
# → Xcode가 열리면 Signing & Capabilities 탭에서 Team UHL26F5Y87 선택

# 3. Firebase 연동 확인
flutter run -d <기기>
# → 앱 실행 후 Firebase 초기화 에러 없으면 OK

# 4. 환경변수 로드 확인 (앱 내 로그 확인)
flutter run --dart-define-from-file=.env
```

## .gitignore 확인 (이미 처리됨)

다음 패턴이 모두 `.gitignore`에 포함되어 commit되지 않습니다:

```
.env
.env.local
.env.production
.env.*.local
.secrets
*.jks
*.p12
*.mobileprovision
key.properties
android/key.properties
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
ios/Flutter/KakaoSecrets.xcconfig
```

⚠️ **commit 전 항상 `git status`로 시크릿 파일이 staged 되어 있지 않은지 확인하세요.**

## 인수인계 절차 (인수자 → 인계자)

1. 인계자(메인테이너)가 1Password "MathLab Secrets" 공유 폴더 생성
2. 위 11개 파일 + 비밀번호를 폴더에 업로드
3. 인수자(공동 개발자) 이메일로 폴더 공유 권한 부여
4. 인수자가 1Password에서 다운로드 후 정확한 경로에 배치
5. 인수자가 위 "검증 순서" 4단계 모두 통과 보고
6. 인계자가 인수 완료 확인 후 공유 폴더 권한 유지 (필요 시 회수)

## 사고 시 대응

| 사고 | 대응 |
|---|---|
| keystore 유출 | Play Console에서 새 키 발급 + 앱 키 교체 (앱 업데이트로 전파 불가, 신규 앱 출시 필요) |
| iOS 인증서 유출 | Apple Developer Portal → Certificates → Revoke → 새 인증서 생성 |
| Firebase 키 유출 | Firebase Console → 프로젝트 설정 → 새 API 키 발급 |
| GitHub에 실수로 push | 즉시 `git reset --hard HEAD~1` + `git push --force` (커밋 1개일 때) + 해당 키 전부 재발급 |
