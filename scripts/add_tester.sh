#!/bin/bash
# ========================================
# MathLab - Add TestFlight Tester
# ========================================
#
# iOS TestFlight External 그룹에 테스터 1명 추가 + 초대 이메일 자동 발송
# Beta App Review 통과 후에만 실제 초대 이메일이 전송됨
#
# Usage:
#   ./scripts/add_tester.sh <email> [first_name] [last_name]
#
# Examples:
#   ./scripts/add_tester.sh test@example.com
#   ./scripts/add_tester.sh test@example.com "홍" "길동"

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -lt 1 ]; then
    echo -e "${RED}사용법: $0 <email> [first_name] [last_name]${NC}"
    exit 1
fi

EMAIL="$1"
FIRST_NAME="${2:-Tester}"
LAST_NAME="${3:-}"

APP_ID="6762421843"
GROUP_ID="ba7e7cd4-428a-4829-86c4-199081236059"
KEY_ID="3RYV62XWSP"
ISSUER_ID="d3533159-bf11-4529-a45d-ce8022d0322f"
KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8"

if [ ! -f "$KEY_PATH" ]; then
    echo -e "${RED}App Store Connect API Key 파일 없음: $KEY_PATH${NC}"
    exit 1
fi

echo -e "${CYAN}MathLab TestFlight 테스터 추가${NC}"
echo "  Email: $EMAIL"
echo "  Name: $FIRST_NAME $LAST_NAME"
echo ""

python3 <<PY
import jwt, time, json, urllib.request, urllib.error

with open('$KEY_PATH') as f:
    pk = f.read()

def tok():
    p = {'iss':'$ISSUER_ID','iat':int(time.time()),'exp':int(time.time())+1200,'aud':'appstoreconnect-v1'}
    return jwt.encode(p, pk, algorithm='ES256', headers={'kid':'$KEY_ID'})

def api(method, path, body=None):
    req = urllib.request.Request(f'https://api.appstoreconnect.apple.com{path}',
        headers={'Authorization':f'Bearer {tok()}','Content-Type':'application/json'},
        method=method, data=json.dumps(body).encode() if body else None)
    try:
        with urllib.request.urlopen(req) as r:
            c = r.read()
            return json.loads(c) if c else {}
    except urllib.error.HTTPError as e:
        return {'_err': e.code, '_body': e.read().decode()[:300]}

# 기존 테스터 조회
r = api('GET', f'/v1/betaTesters?filter[email]=$EMAIL')
if r.get('data'):
    tester_id = r['data'][0]['id']
    print(f'  ✅ 기존 테스터 발견: {tester_id}')
else:
    # 신규 생성 (Beta Group 연결)
    res = api('POST', '/v1/betaTesters', {
        'data': {
            'type': 'betaTesters',
            'attributes': {'email': '$EMAIL', 'firstName': '$FIRST_NAME', 'lastName': '$LAST_NAME'},
            'relationships': {'betaGroups': {'data': [{'type': 'betaGroups', 'id': '$GROUP_ID'}]}}
        }
    })
    if '_err' in res:
        print(f'  ❌ 생성 실패: {res["_body"]}')
        exit(1)
    tester_id = res['data']['id']
    print(f'  ✅ 신규 생성 및 그룹 추가: {tester_id}')

# 초대 전송 (Beta App Review 통과 시에만 성공)
res = api('POST', '/v1/betaTesterInvitations', {
    'data': {
        'type': 'betaTesterInvitations',
        'relationships': {
            'app': {'data': {'type': 'apps', 'id': '$APP_ID'}},
            'betaTester': {'data': {'type': 'betaTesters', 'id': tester_id}}
        }
    }
})
if '_err' in res:
    if 'NO_INSTALLABLE_BUILDS' in res.get('_body', ''):
        print(f'  ⏳ 테스터는 그룹에 추가됨. Beta App Review 승인 후 자동으로 이메일 발송됨.')
    else:
        print(f'  ⚠️  초대 전송 에러: {res["_body"]}')
else:
    print(f'  ✅ TestFlight 초대 이메일 즉시 발송 완료')
PY

echo ""
echo -e "${GREEN}완료.${NC} 테스터 목록 확인: https://appstoreconnect.apple.com/apps/${APP_ID}/testflight/ios"
