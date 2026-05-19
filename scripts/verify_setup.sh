#!/bin/bash

# ========================================
# MathLab - Setup Verification
# ========================================
#
# 새 개발자 셋업 후 환경 검증.
# 시크릿 파일 / 도구 / 의존성 / 빌드 가능 여부 확인.
#
# Usage:
#   ./scripts/verify_setup.sh

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; WARN=$((WARN+1)); }

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "$1 설치됨 ($(command -v "$1"))"
  else
    fail "$1 미설치"
  fi
}

check_file() {
  if [ -f "$1" ]; then
    pass "$1"
  else
    fail "$1 없음"
  fi
}

check_file_optional() {
  if [ -f "$1" ]; then
    pass "$1"
  else
    warn "$1 없음 (필요 시 시크릿 인수)"
  fi
}

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║   MathLab Setup Verification             ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}[1/5] 필수 도구${NC}"
check_cmd flutter
check_cmd dart
check_cmd git

echo -e "\n${CYAN}[2/5] 선택 도구${NC}"
if command -v shorebird >/dev/null 2>&1 || [ -x "$HOME/.shorebird/bin/shorebird" ]; then
  pass "shorebird 설치됨"
else
  warn "shorebird 미설치 (OTA 패치 시 필요)"
fi

if command -v pod >/dev/null 2>&1; then
  pass "cocoapods 설치됨"
else
  warn "cocoapods 미설치 (iOS 빌드 시 필요: sudo gem install cocoapods)"
fi

if command -v fastlane >/dev/null 2>&1; then
  pass "fastlane 설치됨"
else
  warn "fastlane 미설치 (스토어 배포 시 필요: brew install fastlane)"
fi

echo -e "\n${CYAN}[3/5] 시크릿 파일 (1Password에서 받아 배치)${NC}"
check_file_optional ".env"
check_file_optional "android/key.properties"
check_file_optional "android/local.properties"
check_file_optional "android/app/google-services.json"
check_file_optional "ios/Runner/GoogleService-Info.plist"
check_file_optional "ios/Flutter/KakaoSecrets.xcconfig"
check_file_optional ".secrets/play-store-deploy.json"

echo -e "\n${CYAN}[4/5] Flutter 환경${NC}"
if flutter pub get --offline >/dev/null 2>&1; then
  pass "Flutter 의존성 설치됨 (.dart_tool 존재)"
else
  warn "flutter pub get 실행 필요"
fi

DOCTOR_OUTPUT=$(flutter doctor 2>&1)
if echo "$DOCTOR_OUTPUT" | grep -q "No issues found"; then
  pass "flutter doctor 통과"
else
  warn "flutter doctor 항목 확인 필요 (flutter doctor 실행)"
fi

echo -e "\n${CYAN}[5/5] 시크릿 .gitignore 보호${NC}"
GITIGNORE_OK=true
for pattern in ".env" ".secrets" "key.properties" "google-services.json" "GoogleService-Info.plist" "KakaoSecrets.xcconfig" "*.p12" "*.jks"; do
  if grep -q "$pattern" .gitignore 2>/dev/null; then
    : # OK
  else
    warn ".gitignore 에 '$pattern' 미포함"
    GITIGNORE_OK=false
  fi
done
if $GITIGNORE_OK; then
  pass ".gitignore 시크릿 패턴 8개 모두 포함"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "결과: ${GREEN}통과 $PASS${NC} / ${YELLOW}경고 $WARN${NC} / ${RED}실패 $FAIL${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$FAIL" -gt 0 ]; then
  echo -e "\n${RED}✗ 실패 항목이 있습니다. 위 메시지를 확인하세요.${NC}"
  exit 1
fi

if [ "$WARN" -gt 0 ]; then
  echo -e "\n${YELLOW}! 경고 항목이 있습니다. SECRETS_HANDOVER.md 와 ONBOARDING.md 를 확인하세요.${NC}"
  echo -e "  (전체 셋업이 끝나지 않았어도 코드 작업은 가능합니다)"
fi

if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
  echo -e "\n${GREEN}✅ 모든 항목 통과! 'flutter run' 으로 앱을 실행해보세요.${NC}"
fi

exit 0
