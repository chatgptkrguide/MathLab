#!/bin/bash

# ========================================
# MathLab - GitHub Secrets Setup Script
# ========================================
#
# distribute.yml 워크플로우에 필요한 13개 Secret 일괄 등록
#
# Usage:
#   ./scripts/setup_github_secrets.sh
#
# Prerequisites:
#   - gh CLI 로그인: gh auth status
#   - keystore 백업: ~/backups/MathLab-keystore/

set -euo pipefail

REPO="chatgptkrguide/MathLab"
BACKUP_DIR="$HOME/backups/MathLab-keystore"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() { echo -e "\n${CYAN}[$1]${NC} $2"; }
print_ok()   { echo -e "  ${GREEN}OK${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}SKIP${NC} $1"; }
print_err()  { echo -e "  ${RED}FAIL${NC} $1"; }

# ========================================
# 사전 체크
# ========================================
if ! command -v gh &>/dev/null; then
    echo -e "${RED}gh CLI가 필요합니다${NC}"; exit 1
fi

if ! gh auth status &>/dev/null; then
    echo -e "${RED}gh 로그인 필요: gh auth login${NC}"; exit 1
fi

echo -e "${GREEN}"
echo "┌──────────────────────────────────────────┐"
echo "│  MathLab GitHub Secrets Setup             │"
echo "│  Repo: $REPO                 │"
echo "└──────────────────────────────────────────┘"
echo -e "${NC}"

# ========================================
# 값이 확정된 Secret (자동 등록)
# ========================================
print_step "1/4" "Firebase App IDs (고정값)"

printf "1:421762663548:android:8819363bb6b0f241ff35f9" | \
    gh secret set FIREBASE_ANDROID_APP_ID --repo "$REPO" && \
    print_ok "FIREBASE_ANDROID_APP_ID"

printf "1:421762663548:ios:20d3e33da071d49bff35f9" | \
    gh secret set FIREBASE_IOS_APP_ID --repo "$REPO" && \
    print_ok "FIREBASE_IOS_APP_ID"

# ========================================
# Android Keystore (이미 백업돼 있으면 자동 등록)
# ========================================
print_step "2/4" "Android Keystore / key.properties"

KEYSTORE_B64="$BACKUP_DIR/mathlab-release.jks.base64"
KEY_PROPS="$BACKUP_DIR/key.properties"

if [ -f "$KEYSTORE_B64" ]; then
    gh secret set ANDROID_KEYSTORE_BASE64 --repo "$REPO" < "$KEYSTORE_B64" && \
        print_ok "ANDROID_KEYSTORE_BASE64"
else
    print_err "백업 파일 없음: $KEYSTORE_B64"
fi

if [ -f "$KEY_PROPS" ]; then
    STORE_PW=$(grep storePassword= "$KEY_PROPS" | cut -d= -f2)
    KEY_PW=$(grep keyPassword= "$KEY_PROPS" | cut -d= -f2)
    KEY_ALIAS=$(grep keyAlias= "$KEY_PROPS" | cut -d= -f2)

    printf "%s" "$STORE_PW" | gh secret set ANDROID_STORE_PASSWORD --repo "$REPO" && \
        print_ok "ANDROID_STORE_PASSWORD"
    printf "%s" "$KEY_PW" | gh secret set ANDROID_KEY_PASSWORD --repo "$REPO" && \
        print_ok "ANDROID_KEY_PASSWORD"
    printf "%s" "$KEY_ALIAS" | gh secret set ANDROID_KEY_ALIAS --repo "$REPO" && \
        print_ok "ANDROID_KEY_ALIAS"
else
    print_err "$KEY_PROPS 없음"
fi

# ========================================
# Keychain 랜덤 패스워드 (CI 임시)
# ========================================
print_step "3/4" "KEYCHAIN_PASSWORD (랜덤 생성)"

KEYCHAIN_PW=$(openssl rand -base64 16)
printf "%s" "$KEYCHAIN_PW" | gh secret set KEYCHAIN_PASSWORD --repo "$REPO" && \
    print_ok "KEYCHAIN_PASSWORD"

# ========================================
# 아직 발급 필요한 Secret (사용자 입력 대기)
# ========================================
print_step "4/4" "수동 입력이 필요한 Secret 7개"

echo ""
echo "아래 파일 경로가 준비되면 실행하세요:"
echo ""
cat <<'MANUAL'
# Firebase Service Account (Firebase Console → 프로젝트 설정 → 서비스 계정 → 새 키)
gh secret set FIREBASE_SERVICE_ACCOUNT --repo chatgptkrguide/MathLab < path/to/service-account.json

# Google Services JSON / plist
base64 -i path/to/google-services.json | gh secret set GOOGLE_SERVICES_JSON --repo chatgptkrguide/MathLab
base64 -i path/to/GoogleService-Info.plist | gh secret set GOOGLE_SERVICE_INFO_PLIST --repo chatgptkrguide/MathLab

# iOS (Apple Developer 멤버십 승인 후)
base64 -i path/to/Certificate.p12 | gh secret set IOS_CERTIFICATE_BASE64 --repo chatgptkrguide/MathLab
printf 'your_p12_password' | gh secret set IOS_CERTIFICATE_PASSWORD --repo chatgptkrguide/MathLab
base64 -i path/to/profile.mobileprovision | gh secret set IOS_PROVISION_PROFILE_BASE64 --repo chatgptkrguide/MathLab
MANUAL

echo ""
# ========================================
# 최종 검증: distribute.yml이 요구하는 13개 Secret 확인
# ========================================
REQUIRED_SECRETS=(
    FIREBASE_ANDROID_APP_ID
    FIREBASE_IOS_APP_ID
    FIREBASE_SERVICE_ACCOUNT
    GOOGLE_SERVICES_JSON
    GOOGLE_SERVICE_INFO_PLIST
    ANDROID_KEYSTORE_BASE64
    ANDROID_STORE_PASSWORD
    ANDROID_KEY_PASSWORD
    ANDROID_KEY_ALIAS
    IOS_CERTIFICATE_BASE64
    IOS_CERTIFICATE_PASSWORD
    IOS_PROVISION_PROFILE_BASE64
    KEYCHAIN_PASSWORD
)

echo -e "\n${CYAN}[검증] distribute.yml 필수 Secrets${NC}"
REGISTERED=$(gh secret list --repo "$REPO" --json name --jq '.[].name' 2>/dev/null || true)
MISSING=()
for secret in "${REQUIRED_SECRETS[@]}"; do
    if echo "$REGISTERED" | grep -qx "$secret"; then
        print_ok "$secret"
    else
        print_err "$secret (누락)"
        MISSING+=("$secret")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    echo -e "\n${GREEN}✅ 모든 Secret 등록 완료. distribute.yml 실행 준비됨.${NC}"
else
    echo -e "\n${YELLOW}⚠️  누락 ${#MISSING[@]}개: ${MISSING[*]}${NC}"
    exit 1
fi
