#!/bin/bash

# ========================================
# MathLab - Unified Deploy Script
# ========================================
#
# 하나의 스크립트로 모든 배포 경로를 관리
#
# Usage:
#   ./scripts/deploy.sh patch android        # OTA 패치 (재설치 X, 90% 사용)
#   ./scripts/deploy.sh patch ios
#   ./scripts/deploy.sh patch both
#
#   ./scripts/deploy.sh test android         # Firebase App Distribution (테스터)
#   ./scripts/deploy.sh test ios
#
#   ./scripts/deploy.sh store android        # Google Play (internal 트랙)
#   ./scripts/deploy.sh store ios            # App Store (빌드 업로드)
#
#   ./scripts/deploy.sh store android beta   # 특정 트랙 지정

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

export PATH="$HOME/.shorebird/bin:$PATH"

MODE="${1:-patch}"
PLATFORM="${2:-android}"
TRACK="${3:-internal}"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║   MathLab Deploy                         ║"
echo "║   Mode: $MODE | Platform: $PLATFORM      "
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

case "$MODE" in
  patch)
    echo -e "${GREEN}🚀 OTA Patch (재설치 불필요)${NC}"
    case "$PLATFORM" in
      android) cd android && fastlane patch ;;
      ios)     cd ios && fastlane patch ;;
      both)    cd android && fastlane patch && cd ../ios && fastlane patch ;;
      *)       echo -e "${RED}Invalid platform: $PLATFORM${NC}"; exit 1 ;;
    esac
    ;;
  test)
    echo -e "${GREEN}📱 Firebase App Distribution (테스터 배포)${NC}"
    case "$PLATFORM" in
      android) cd android && fastlane distribute ;;
      ios)     cd ios && fastlane distribute ;;
      both)    cd android && fastlane distribute && cd ../ios && fastlane distribute ;;
      *)       echo -e "${RED}Invalid platform: $PLATFORM${NC}"; exit 1 ;;
    esac
    ;;
  store)
    echo -e "${GREEN}🏪 스토어 배포${NC}"
    case "$PLATFORM" in
      android)
        echo -e "${YELLOW}Google Play ($TRACK 트랙)${NC}"
        cd android && fastlane deploy_play_store track:"$TRACK"
        ;;
      ios)
        echo -e "${YELLOW}App Store 빌드 업로드${NC}"
        cd ios && fastlane deploy_app_store
        ;;
      *)
        echo -e "${RED}Invalid platform: $PLATFORM${NC}"; exit 1
        ;;
    esac
    ;;
  *)
    echo -e "${RED}Invalid mode: $MODE${NC}"
    echo ""
    echo "Usage:"
    echo "  ./scripts/deploy.sh patch android    # OTA (90% 사용)"
    echo "  ./scripts/deploy.sh test android     # 테스터 배포"
    echo "  ./scripts/deploy.sh store android    # Play Store"
    echo "  ./scripts/deploy.sh store ios        # App Store"
    exit 1
    ;;
esac

echo -e "\n${GREEN}✅ 배포 완료!${NC}"
