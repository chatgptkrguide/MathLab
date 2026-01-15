#!/bin/bash

# MathLab 코드 품질 검사 스크립트
# 코드 품질, 테스트, 포맷팅을 한 번에 검사합니다.

set -e

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 카운터
PASSED=0
FAILED=0
WARNINGS=0

# 함수: 통과 메시지
pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED++))
}

# 함수: 실패 메시지
fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED++))
}

# 함수: 경고 메시지
warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

# 함수: 정보 메시지
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo "=========================================="
echo "  MathLab 코드 품질 검사"
echo "=========================================="
echo ""

# 1. Flutter 버전 확인
info "Flutter 버전 확인 중..."
if flutter --version > /dev/null 2>&1; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    pass "Flutter 설치됨: $FLUTTER_VERSION"
else
    fail "Flutter가 설치되어 있지 않습니다."
    exit 1
fi
echo ""

# 2. 의존성 확인
info "의존성 확인 중..."
if flutter pub get > /dev/null 2>&1; then
    pass "의존성 최신 상태"
else
    warn "의존성 업데이트 필요"
fi
echo ""

# 3. 코드 포맷팅 검사
info "코드 포맷팅 검사 중..."
UNFORMATTED=$(dart format --set-exit-if-changed lib test 2>&1 || true)
if [ -z "$UNFORMATTED" ]; then
    pass "코드 포맷팅 통과"
else
    warn "일부 파일이 포맷팅되지 않았습니다."
    echo "$UNFORMATTED"
    info "자동 포맷팅: dart format ."
fi
echo ""

# 4. 코드 분석
info "코드 분석 중..."
ANALYZE_OUTPUT=$(flutter analyze --no-pub 2>&1)
if echo "$ANALYZE_OUTPUT" | grep -q "No issues found"; then
    pass "코드 분석 통과: 이슈 없음"
else
    if echo "$ANALYZE_OUTPUT" | grep -q "error"; then
        fail "코드 분석 실패"
        echo "$ANALYZE_OUTPUT"
    elif echo "$ANALYZE_OUTPUT" | grep -q "warning"; then
        warn "경고가 발견되었습니다"
        echo "$ANALYZE_OUTPUT"
    else
        info "$ANALYZE_OUTPUT"
    fi
fi
echo ""

# 5. 테스트 실행
info "단위 테스트 실행 중..."
if flutter test --no-pub > /dev/null 2>&1; then
    pass "모든 테스트 통과"
else
    fail "일부 테스트 실패"
    flutter test --no-pub
fi
echo ""

# 6. TODO 주석 확인
info "TODO 주석 확인 중..."
TODO_COUNT=$(grep -r "TODO\|FIXME\|HACK\|XXX" lib --include="*.dart" 2>/dev/null | wc -l | xargs)
if [ "$TODO_COUNT" -eq 0 ]; then
    pass "TODO 주석 없음"
else
    warn "TODO 주석 $TODO_COUNT개 발견"
    info "TODO 주석 목록:"
    grep -r "TODO\|FIXME\|HACK\|XXX" lib --include="*.dart" -n | head -10
fi
echo ""

# 7. 하드코딩된 문자열 확인 (간단 체크)
info "하드코딩 문자열 확인 중..."
HARDCODED_COUNT=$(grep -r "Text('.*')" lib --include="*.dart" 2>/dev/null | grep -v "// ignore:" | wc -l | xargs)
if [ "$HARDCODED_COUNT" -lt 10 ]; then
    pass "하드코딩 문자열 최소화됨"
else
    warn "하드코딩된 문자열 $HARDCODED_COUNT개 발견 (국제화 고려 권장)"
fi
echo ""

# 8. 큰 파일 확인
info "큰 파일 확인 중..."
LARGE_FILES=$(find lib -name "*.dart" -type f -exec wc -l {} + | awk '$1 > 500 {print $2": "$1" lines"}' | head -5)
if [ -z "$LARGE_FILES" ]; then
    pass "큰 파일 없음 (500줄 이하)"
else
    warn "큰 파일 발견 (리팩토링 고려):"
    echo "$LARGE_FILES"
fi
echo ""

# 9. Git 상태 확인
info "Git 상태 확인 중..."
if git diff --quiet && git diff --cached --quiet; then
    pass "작업 디렉토리 깨끗함"
else
    warn "커밋되지 않은 변경사항이 있습니다"
fi
echo ""

# 10. 빌드 가능 여부 확인 (선택사항)
if [ "$1" == "--build" ]; then
    info "빌드 테스트 중... (시간이 걸릴 수 있습니다)"
    if flutter build apk --debug > /dev/null 2>&1; then
        pass "빌드 성공"
    else
        fail "빌드 실패"
    fi
    echo ""
fi

# 결과 요약
echo "=========================================="
echo "  검사 결과 요약"
echo "=========================================="
echo -e "${GREEN}✅ 통과: $PASSED${NC}"
echo -e "${YELLOW}⚠️  경고: $WARNINGS${NC}"
echo -e "${RED}❌ 실패: $FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}코드 품질 검사 실패${NC}"
    echo "실패한 항목을 수정한 후 다시 시도하세요."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}경고가 있지만 진행 가능합니다${NC}"
    echo "경고 사항을 검토해주세요."
    exit 0
else
    echo -e "${GREEN}모든 검사 통과! 🎉${NC}"
    echo "코드 품질이 우수합니다."
    exit 0
fi
