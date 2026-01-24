# MathLab TODO 목록

프로젝트의 모든 TODO 항목을 카테고리별로 정리한 문서입니다.

## 🔐 Firebase & 보안 (4개)

### Firebase Security Rules 설정
- `lib/app/auth_wrapper.dart:54` - Firebase Security Rules 설정 후 활성화
- `lib/app/auth_wrapper.dart:69` - Firebase Security Rules 설정 후 활성화
- `lib/data/providers/user/user_provider.dart:138` - Firebase Security Rules 설정 후 활성화
- `lib/data/repositories/user_repository.dart:90` - Firebase Security Rules 설정 후 활성화

### 프로덕션 보안
- `lib/data/services/encryption_service.dart:28` - 프로덕션 환경에서는 flutter_secure_storage 사용 고려
- `lib/data/services/encryption_service.dart:32` - device_info_plus 패키지로 실제 디바이스 ID 가져오기

## 🌐 서버 통합 (9개)

### API 구현
- `lib/features/messages/send_message_screen.dart:376` - 실제 서버로 전송하는 로직 추가
- `lib/data/models/gamification/daily_reward.dart:80` - 실제 구현에서는 서버 API 호출
- `lib/data/services/firebase_auth_service.dart:147` - 백엔드에서 커스텀 토큰 생성 후 Firebase 로그인

### 영수증 검증
- `lib/data/services/in_app_purchase_service.dart:365` - 서버 사이드 검증 구현
- `lib/data/services/in_app_purchase_service.dart:376` - 서버로 영수증 전송 및 검증
- `lib/data/services/in_app_purchase_service.dart:385` - 서버로 영수증 전송 및 검증

### 토큰 관리
- `lib/data/providers/communication/fcm_provider.dart:85` - 서버에 새 토큰 전송
- `lib/data/services/notification_service.dart:76` - 서버에 새 토큰 저장

### Firebase 업데이트
- `lib/data/services/heart_regeneration_service.dart:209` - Firebase에 업데이트

## 🔔 푸시 알림 (3개)

- `lib/data/providers/communication/message_provider.dart:181` - Firebase Cloud Messaging을 통한 실제 푸시 알림 구현
- `lib/data/services/heart_regeneration_service.dart:107` - 알림 클릭 시 앱 열기 및 하트 화면으로 이동
- `lib/data/services/notification_service.dart:205` - 적절한 화면으로 네비게이션
- `lib/data/services/notification_service.dart:210` - 알림 타입별 처리

## 🎯 Navigation & Routing (6개)

- `lib/features/messages/message_detail_screen.dart:102` - 라우트로 이동
- `lib/features/problem_management/problem_management_screen.dart:272` - 문제 상세 화면으로 이동
- `lib/data/services/deep_link_service.dart:129` - NavigationProvider를 사용하여 탭 인덱스 변경 필요
- `lib/data/services/deep_link_service.dart:144` - NavigationProvider를 사용하여 탭 인덱스 변경 필요
- `lib/data/services/deep_link_service.dart:240` - 특정 채팅방 상세 화면으로 이동

## 💎 프리미엄 기능 (4개)

- `lib/features/problem/widgets/heart_depleted_dialog.dart:58` - 프리미엄 구독 화면으로 이동
- `lib/features/premium/subscription_management_screen.dart:94` - 프리미엄 업그레이드 화면으로 이동
- `lib/shared/widgets/heart_widget.dart:185` - 하트 구매 화면으로 이동
- `lib/features/premium/premium_upgrade_screen.dart:582` - 이용약관 페이지 열기
- `lib/features/premium/premium_upgrade_screen.dart:600` - 개인정보처리방침 페이지 열기

## 🎨 UI 구현 (6개)

- `lib/features/settings/dialogs/delete_account_dialog.dart:22` - 계정 탈퇴 로직 구현
- `lib/features/auth/views/login_view.dart:65` - 소셜 로그인 구현 (Phase 2)
- `lib/features/academic_records/academic_records_screen.dart:409` - 성적 추가 다이얼로그 구현
- `lib/features/problem/problem_screen.dart:603` - 뱃지 언락 체크 및 알림
- `lib/features/course_enrollment/course_enrollment_screen.dart:408` - 실제 과정 목록에서 선택하도록 구현
- `lib/features/wrong_answer/wrong_answer_screen.dart:57` - 학년 선택 드로어 (필요시 추가)

## 📊 Analytics & Monitoring (2개)

- `lib/shared/utils/logger.dart:64` - Sentry, Firebase Crashlytics 등 통합
- `lib/shared/utils/logger.dart:122` - Google Analytics, Mixpanel 등 통합
- `lib/data/services/conflict_resolution_service.dart:351` - 충돌 통계를 Analytics에 전송하여 모니터링

## 🔄 데이터 변환 (4개)

- `lib/data/repositories/wrong_answer_repository.dart:100` - Firestore에서 받은 데이터를 WrongAnswer로 변환
- `lib/data/repositories/wrong_answer_repository.dart:179` - Firebase UID 사용
- `lib/data/repositories/wrong_answer_repository.dart:186` - 오프라인 큐에 추가
- `lib/data/repositories/problem_repository.dart:22` - 실제 구현 시 카테고리별 문제 목록 파일 경로 관리

## 🖼️ 이미지 처리 (1개)

- `lib/data/services/file_upload_service.dart:285` - 이미지 압축 라이브러리 사용 (image_picker, flutter_image_compress 등)

---

**총 TODO 개수**: 약 50개  
**최종 업데이트**: 2026-01-12  
**작성자**: Claude Code

## 우선순위

### 높음 (즉시 처리 필요)
1. Firebase Security Rules 설정 (4개)
2. 프로덕션 보안 강화 (2개)

### 중간 (Phase 2 구현)
1. 소셜 로그인 (1개)
2. 서버 API 통합 (9개)
3. 푸시 알림 (3개)
4. 프리미엄 기능 완성 (4개)

### 낮음 (향후 개선)
1. Analytics 통합 (2개)
2. UI 개선 (6개)
3. 이미지 최적화 (1개)

## 완료된 TODO 추적

이 섹션은 완료된 TODO를 추적하기 위해 사용됩니다. 완료 시 날짜와 함께 기록합니다.

- (예정) 2026-01-XX: Firebase Security Rules 설정 완료
