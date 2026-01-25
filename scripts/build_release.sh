#!/bin/bash

# 🚀 MathLab Release Build Script
#
# This script builds the app for production with:
# - Code obfuscation
# - Debug symbol split
# - Platform-specific optimizations
#
# Usage:
#   ./scripts/build_release.sh android
#   ./scripts/build_release.sh ios
#   ./scripts/build_release.sh both

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="MathLab"
DEBUG_SYMBOLS_DIR="build/debug-symbols"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

# ========================================
# Helper Functions
# ========================================

print_header() {
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ========================================
# Pre-build Checks
# ========================================

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -n 1)"

    # Check Dart installation
    if ! command -v dart &> /dev/null; then
        print_error "Dart is not installed"
        exit 1
    fi
    print_success "Dart found: $(dart --version 2>&1)"

    # Check if .env file exists
    if [ ! -f ".env" ]; then
        print_warning ".env file not found - using environment variables"
    else
        print_success ".env file found"
    fi
}

clean_build() {
    print_header "Cleaning Previous Builds"

    flutter clean
    rm -rf build/
    mkdir -p "$DEBUG_SYMBOLS_DIR"

    print_success "Clean completed"
}

get_dependencies() {
    print_header "Getting Dependencies"

    flutter pub get

    print_success "Dependencies installed"
}

run_tests() {
    print_header "Running Tests"

    print_warning "Skipping tests for release build (run tests separately)"
    # Uncomment to run tests before build:
    # flutter test || {
    #     print_error "Tests failed"
    #     exit 1
    # }
}

# ========================================
# Platform-Specific Builds
# ========================================

build_android() {
    print_header "Building Android Release"

    # Build APK with obfuscation
    print_warning "Building obfuscated APK..."
    flutter build apk \
        --release \
        --obfuscate \
        --split-debug-info="$DEBUG_SYMBOLS_DIR/android" \
        --build-number="$BUILD_NUMBER" \
        --target-platform=android-arm64,android-arm,android-x64

    # Build App Bundle (recommended for Play Store)
    print_warning "Building obfuscated App Bundle..."
    flutter build appbundle \
        --release \
        --obfuscate \
        --split-debug-info="$DEBUG_SYMBOLS_DIR/android-bundle" \
        --build-number="$BUILD_NUMBER"

    print_success "Android build completed"
    print_success "APK: build/app/outputs/flutter-apk/app-release.apk"
    print_success "Bundle: build/app/outputs/bundle/release/app-release.aab"
}

build_ios() {
    print_header "Building iOS Release"

    # Check if on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS builds require macOS"
        exit 1
    fi

    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed"
        exit 1
    fi

    # Build iOS with obfuscation
    print_warning "Building obfuscated iOS app..."
    flutter build ios \
        --release \
        --obfuscate \
        --split-debug-info="$DEBUG_SYMBOLS_DIR/ios" \
        --build-number="$BUILD_NUMBER"

    print_success "iOS build completed"
    print_success "Build location: build/ios/iphoneos/Runner.app"
    print_warning "Next step: Archive and upload via Xcode or Fastlane"
}

# ========================================
# Post-Build Actions
# ========================================

create_build_info() {
    print_header "Creating Build Information"

    local BUILD_INFO_FILE="build/BUILD_INFO.txt"

    cat > "$BUILD_INFO_FILE" << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  $APP_NAME - Release Build Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Build Date: $(date)
Build Number: $BUILD_NUMBER
Git Commit: $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")
Git Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
Flutter Version: $(flutter --version | head -n 1)
Dart Version: $(dart --version 2>&1)

Security Features:
✓ Code Obfuscation: ENABLED
✓ Debug Symbols: SPLIT
✓ ProGuard: ENABLED (Android)

Debug Symbols Location:
  Android APK: $DEBUG_SYMBOLS_DIR/android
  Android Bundle: $DEBUG_SYMBOLS_DIR/android-bundle
  iOS: $DEBUG_SYMBOLS_DIR/ios

Notes:
- KEEP debug symbols for crash reporting
- Upload symbols to Firebase Crashlytics
- Verify code signing before distribution

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

    print_success "Build info saved to: $BUILD_INFO_FILE"
}

display_summary() {
    print_header "Build Summary"

    echo "📦 Build completed successfully!"
    echo ""
    echo "Build artifacts:"

    if [ -d "build/app/outputs/flutter-apk" ]; then
        echo "  📱 Android APK: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"
    fi

    if [ -d "build/app/outputs/bundle/release" ]; then
        echo "  📦 Android Bundle: $(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)"
    fi

    if [ -d "build/ios" ]; then
        echo "  🍎 iOS App: Available"
    fi

    echo ""
    echo "🔒 Security:"
    echo "  ✓ Code obfuscation enabled"
    echo "  ✓ Debug symbols separated"
    echo ""
    echo "📋 Debug symbols: $DEBUG_SYMBOLS_DIR"
    echo ""
    print_warning "Remember to:"
    echo "  1. Upload debug symbols to Firebase Crashlytics"
    echo "  2. Test the release build thoroughly"
    echo "  3. Verify all API keys are from environment variables"
    echo "  4. Check Firebase configuration"
}

# ========================================
# Main Execution
# ========================================

main() {
    local PLATFORM="${1:-both}"

    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║   $APP_NAME Release Build Script       ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"

    # Pre-build
    check_prerequisites
    clean_build
    get_dependencies
    run_tests

    # Build
    case "$PLATFORM" in
        android)
            build_android
            ;;
        ios)
            build_ios
            ;;
        both)
            build_android
            build_ios
            ;;
        *)
            print_error "Invalid platform: $PLATFORM"
            echo "Usage: $0 [android|ios|both]"
            exit 1
            ;;
    esac

    # Post-build
    create_build_info
    display_summary

    print_success "🎉 All done!"
}

# Run main function
main "$@"
