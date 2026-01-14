#!/bin/bash

# Android Release Keystore 생성 스크립트
# MathLab 앱의 릴리즈 서명을 위한 키스토어를 생성합니다.

set -e  # 오류 발생 시 스크립트 중단

echo "=========================================="
echo "  MathLab Android Keystore 생성 도구"
echo "=========================================="
echo ""

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/.."

# 키스토어 저장 디렉토리
KEYSTORE_DIR="$HOME/mathlab-keystore"
KEYSTORE_FILE="$KEYSTORE_DIR/mathlab-release.jks"
KEY_PROPERTIES_FILE="android/key.properties"

# 이미 키스토어가 존재하는지 확인
if [ -f "$KEYSTORE_FILE" ]; then
    echo "⚠️  경고: 키스토어가 이미 존재합니다."
    echo "   위치: $KEYSTORE_FILE"
    echo ""
    read -p "기존 키스토어를 덮어쓰시겠습니까? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "키스토어 생성이 취소되었습니다."
        exit 0
    fi
    echo "기존 키스토어를 삭제합니다..."
    rm -f "$KEYSTORE_FILE"
fi

# 키스토어 디렉토리 생성
mkdir -p "$KEYSTORE_DIR"

echo ""
echo "키스토어 정보를 입력해주세요."
echo "주의: 입력한 정보는 반드시 안전한 곳에 기록해두세요!"
echo ""

# 키스토어 비밀번호 입력
while true; do
    read -sp "Keystore 비밀번호: " STORE_PASSWORD
    echo ""
    read -sp "Keystore 비밀번호 확인: " STORE_PASSWORD_CONFIRM
    echo ""

    if [ "$STORE_PASSWORD" = "$STORE_PASSWORD_CONFIRM" ]; then
        break
    else
        echo "❌ 비밀번호가 일치하지 않습니다. 다시 입력해주세요."
        echo ""
    fi
done

# 키 비밀번호 입력
while true; do
    read -sp "Key 비밀번호: " KEY_PASSWORD
    echo ""
    read -sp "Key 비밀번호 확인: " KEY_PASSWORD_CONFIRM
    echo ""

    if [ "$KEY_PASSWORD" = "$KEY_PASSWORD_CONFIRM" ]; then
        break
    else
        echo "❌ 비밀번호가 일치하지 않습니다. 다시 입력해주세요."
        echo ""
    fi
done

# 키 alias (기본값: mathlab)
read -p "Key alias (기본값: mathlab): " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-mathlab}

echo ""
echo "조직 정보를 입력해주세요 (선택사항, Enter로 건너뛰기 가능)"
echo ""

# 조직 정보 입력
read -p "이름 (CN): " CN
read -p "조직 단위 (OU): " OU
read -p "조직명 (O): " O
read -p "도시 (L): " L
read -p "시/도 (ST): " ST
read -p "국가 코드 (C, 예: KR): " C

# DN(Distinguished Name) 구성
DNAME="CN=${CN:-MathLab}"
[ -n "$OU" ] && DNAME="$DNAME, OU=$OU"
[ -n "$O" ] && DNAME="$DNAME, O=$O"
[ -n "$L" ] && DNAME="$DNAME, L=$L"
[ -n "$ST" ] && DNAME="$DNAME, ST=$ST"
[ -n "$C" ] && DNAME="$DNAME, C=$C"

echo ""
echo "키스토어를 생성하는 중..."
echo ""

# 키스토어 생성
keytool -genkeypair \
    -v \
    -keystore "$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "$DNAME"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 키스토어가 성공적으로 생성되었습니다!"
    echo "   위치: $KEYSTORE_FILE"
else
    echo ""
    echo "❌ 키스토어 생성에 실패했습니다."
    exit 1
fi

# key.properties 파일 생성
echo ""
echo "key.properties 파일을 생성하는 중..."

cat > "$KEY_PROPERTIES_FILE" << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_FILE
EOF

if [ $? -eq 0 ]; then
    echo "✅ key.properties 파일이 생성되었습니다!"
    echo "   위치: $KEY_PROPERTIES_FILE"
else
    echo "❌ key.properties 파일 생성에 실패했습니다."
    exit 1
fi

# .gitignore에 key.properties 추가 (아직 없다면)
if ! grep -q "key.properties" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Android Keystore" >> .gitignore
    echo "android/key.properties" >> .gitignore
    echo "*.jks" >> .gitignore
    echo "*.keystore" >> .gitignore
    echo ""
    echo "✅ .gitignore에 키스토어 관련 항목이 추가되었습니다."
fi

# 중요 정보 백업 파일 생성
BACKUP_FILE="$KEYSTORE_DIR/KEYSTORE_INFO.txt"
cat > "$BACKUP_FILE" << EOF
========================================
  MathLab Android Keystore 정보
========================================

⚠️  중요: 이 정보를 안전한 곳에 보관하세요!
          분실 시 앱 업데이트가 불가능합니다!

생성 날짜: $(date '+%Y-%m-%d %H:%M:%S')

키스토어 파일: $KEYSTORE_FILE
Key Alias: $KEY_ALIAS
Distinguished Name: $DNAME

비밀번호:
- Keystore 비밀번호: [수동으로 기록하세요]
- Key 비밀번호: [수동으로 기록하세요]

키 유효 기간: 10000일 (약 27년)
키 알고리즘: RSA 2048비트

========================================

다음 단계:
1. 이 파일을 안전한 곳(암호화된 저장소)에 백업하세요.
2. 비밀번호를 직접 기록하세요.
3. key.properties 파일이 Git에 커밋되지 않도록 주의하세요.
4. 키스토어 파일을 안전하게 백업하세요.

릴리즈 빌드 명령어:
flutter build appbundle --release
또는
flutter build apk --release
EOF

echo ""
echo "✅ 키스토어 정보 백업 파일이 생성되었습니다!"
echo "   위치: $BACKUP_FILE"
echo ""
echo "=========================================="
echo "  설정 완료!"
echo "=========================================="
echo ""
echo "📝 다음 단계:"
echo ""
echo "1. 키스토어 정보를 안전한 곳에 백업하세요:"
echo "   - 파일: $KEYSTORE_FILE"
echo "   - 정보: $BACKUP_FILE"
echo ""
echo "2. 비밀번호를 백업 파일에 직접 기록하세요."
echo ""
echo "3. 릴리즈 빌드를 실행하세요:"
echo "   flutter build appbundle --release"
echo ""
echo "4. 생성된 App Bundle 위치:"
echo "   build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "⚠️  주의사항:"
echo "   - key.properties와 .jks 파일은 절대 Git에 커밋하지 마세요!"
echo "   - 키스토어를 분실하면 앱 업데이트가 불가능합니다!"
echo "   - 안전한 곳에 백업하세요!"
echo ""
