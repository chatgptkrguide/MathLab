#!/bin/bash

# ========================================
# MathLab - Shorebird OTA Patch Script
# ========================================
#
# Dart 코드 변경 후 OTA 패치 배포 (앱 재설치 불필요)
# 테스터가 앱을 열면 자동으로 최신 버전 적용
#
# Usage:
#   ./scripts/patch.sh android        # Android 패치
#   ./scripts/patch.sh ios            # iOS 패치
#   ./scripts/patch.sh both           # 둘 다 패치
#
# Prerequisites:
#   - Shorebird CLI: curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
#   - Shorebird Login: shorebird login
#   - Initial release already created: shorebird release android / shorebird release ios

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Add Shorebird to PATH
export PATH="$HOME/.shorebird/bin:$PATH"

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# ========================================
# Patch Functions
# ========================================
patch_android() {
    print_header "Android OTA Patch"

    echo -e "${YELLOW}Creating Android patch...${NC}"
    yes | shorebird patch android

    echo -e "${GREEN}Android 패치 완료!${NC}"
    echo -e "테스터가 앱을 다시 열면 자동으로 업데이트됩니다."
}

patch_ios() {
    print_header "iOS OTA Patch"

    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}iOS 패치는 macOS에서만 가능합니다.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Creating iOS patch...${NC}"
    yes | shorebird patch ios

    echo -e "${GREEN}iOS 패치 완료!${NC}"
    echo -e "테스터가 앱을 다시 열면 자동으로 업데이트됩니다."
}

# ========================================
# Main
# ========================================
main() {
    local PLATFORM="${1:-both}"

    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║   MathLab - Shorebird OTA Patch          ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"

    # Check Shorebird CLI
    if ! command -v shorebird &> /dev/null; then
        echo -e "${RED}Shorebird CLI not found.${NC}"
        echo "Install: curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash"
        exit 1
    fi

    # Check shorebird.yaml
    if [ ! -f "shorebird.yaml" ]; then
        echo -e "${RED}shorebird.yaml not found. Run 'shorebird init' first.${NC}"
        exit 1
    fi

    case "$PLATFORM" in
        android)
            patch_android
            ;;
        ios)
            patch_ios
            ;;
        both)
            patch_android
            patch_ios
            ;;
        *)
            echo -e "${RED}Invalid platform: $PLATFORM${NC}"
            echo "Usage: $0 [android|ios|both]"
            exit 1
            ;;
    esac

    echo -e "\n${GREEN}패치 배포 완료! 테스터 앱이 자동 업데이트됩니다.${NC}"
}

main "$@"
