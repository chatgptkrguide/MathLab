#!/bin/bash

# Fastlane 설정 스크립트
# iOS와 Android 스토어 배포를 자동화합니다.

echo "=========================================="
echo "  Fastlane 설정 도구"
echo "=========================================="
echo ""

# Fastlane 설치 확인
if ! command -v fastlane &> /dev/null; then
    echo "Fastlane이 설치되어 있지 않습니다."
    echo "설치하시겠습니까? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        gem install fastlane
    else
        echo "Fastlane이 필요합니다. 종료합니다."
        exit 1
    fi
fi

echo "✅ Fastlane 설치 확인 완료"
echo ""

# Android Fastlane 초기화
echo "Android Fastlane 설정..."
cd android
fastlane init || echo "Android fastlane 이미 설정됨"
cd ..

# iOS Fastlane 초기화  
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "iOS Fastlane 설정..."
    cd ios
    fastlane init || echo "iOS fastlane 이미 설정됨"
    cd ..
fi

echo ""
echo "✅ Fastlane 설정 완료!"
echo ""
echo "사용 방법:"
echo "  Android: cd android && fastlane beta"
echo "  iOS: cd ios && fastlane beta"
