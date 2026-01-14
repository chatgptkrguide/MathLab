#!/bin/bash

# MathLab 프로젝트 상태 점검 스크립트
# 배포 전 모든 항목을 자동으로 확인합니다.

set -e

echo "=========================================="
echo "  MathLab 프로젝트 상태 점검"
echo "=========================================="
echo ""

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAIL_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARN_COUNT++))
}

echo "1️⃣  Flutter 환경 확인..."
if command -v flutter &> /dev/null; then
    check_pass "Flutter 설치됨: $(flutter --version | head -1)"
else
    check_fail "Flutter가 설치되어 있지 않습니다"
fi
echo ""

echo "2️⃣  의존성 확인..."
if [ -f "pubspec.yaml" ]; then
    check_pass "pubspec.yaml 존재"
    flutter pub get > /dev/null 2>&1
    check_pass "의존성 설치 완료"
else
    check_fail "pubspec.yaml을 찾을 수 없습니다"
fi
echo ""

echo "3️⃣  코드 분석..."
if flutter analyze --no-pub 2>&1 | grep -q "No issues found"; then
    check_pass "코드 분석 통과: 이슈 없음"
else
    check_warn "코드 분석에서 경고 또는 오류 발견"
fi
echo ""

echo "4️⃣  필수 파일 확인..."
files_to_check=(
    "README_DEPLOYMENT.md"
    "DEPLOYMENT_READY.md"
    "docs/STORE_DEPLOYMENT_GUIDE.md"
    "docs/PRIVACY_POLICY.md"
    "docs/TERMS_OF_SERVICE.md"
    "scripts/create_keystore.sh"
    "scripts/build_release.sh"
    ".env.example"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        check_pass "$file 존재"
    else
        check_fail "$file 없음"
    fi
done
echo ""

echo "5️⃣  앱 아이콘 확인..."
if [ -f "assets/images/app_icon.png" ]; then
    check_pass "앱 아이콘 존재"
else
    check_warn "앱 아이콘 없음 (생성 필요)"
fi
echo ""

echo "6️⃣  iOS 설정 확인..."
if [ -f "ios/Runner/Info.plist" ]; then
    check_pass "iOS Info.plist 존재"
else
    check_fail "iOS Info.plist 없음"
fi
echo ""

echo "7️⃣  Android 설정 확인..."
if [ -f "android/app/build.gradle.kts" ]; then
    check_pass "Android build.gradle.kts 존재"
else
    check_fail "Android build.gradle.kts 없음"
fi

if [ -f "android/key.properties" ]; then
    check_pass "Android 키스토어 설정됨"
else
    check_warn "Android 키스토어 미설정 (./scripts/create_keystore.sh 실행)"
fi
echo ""

echo "8️⃣  Git 상태 확인..."
if command -v git &> /dev/null; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        check_pass "Git 저장소 초기화됨"
        
        # 커밋되지 않은 변경사항 확인
        if [ -z "$(git status --porcelain)" ]; then
            check_pass "모든 변경사항 커밋됨"
        else
            check_warn "커밋되지 않은 변경사항 있음"
        fi
    else
        check_warn "Git 저장소 아님"
    fi
else
    check_warn "Git이 설치되어 있지 않습니다"
fi
echo ""

echo "=========================================="
echo "  점검 결과"
echo "=========================================="
echo -e "${GREEN}통과: $PASS_COUNT${NC}"
echo -e "${YELLOW}경고: $WARN_COUNT${NC}"
echo -e "${RED}실패: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ 모든 필수 항목이 준비되었습니다!${NC}"
    echo ""
    echo "다음 단계:"
    echo "1. ./scripts/build_release.sh 실행"
    echo "2. 스토어에 업로드"
    exit 0
else
    echo -e "${RED}❌ $FAIL_COUNT개의 필수 항목이 누락되었습니다.${NC}"
    echo "문제를 해결한 후 다시 시도하세요."
    exit 1
fi
