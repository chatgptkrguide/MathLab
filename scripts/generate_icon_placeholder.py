#!/usr/bin/env python3

"""
MathLab 앱 아이콘 플레이스홀더 생성 스크립트

1024x1024 크기의 기본 앱 아이콘을 생성합니다.
실제 디자인된 아이콘으로 교체하기 전까지 사용할 수 있습니다.
"""

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("❌ Pillow 라이브러리가 설치되어 있지 않습니다.")
    print("다음 명령어로 설치하세요:")
    print("  pip3 install Pillow")
    exit(1)

import os

# 색상 정의 (MathLab 브랜드 컬러)
BACKGROUND_COLOR = (59, 130, 246)  # #3B82F6 (Primary Blue)
TEXT_COLOR = (255, 255, 255)  # White
ACCENT_COLOR = (251, 191, 36)  # #FBBF24 (Math Yellow)

# 아이콘 크기
ICON_SIZE = 1024

def create_icon():
    """앱 아이콘 생성"""

    # 이미지 생성
    img = Image.new('RGB', (ICON_SIZE, ICON_SIZE), BACKGROUND_COLOR)
    draw = ImageDraw.Draw(img)

    # 중앙에 원 그리기 (수학 심볼 배경)
    circle_radius = ICON_SIZE // 3
    circle_center = (ICON_SIZE // 2, ICON_SIZE // 2)
    circle_bbox = [
        circle_center[0] - circle_radius,
        circle_center[1] - circle_radius,
        circle_center[0] + circle_radius,
        circle_center[1] + circle_radius
    ]
    draw.ellipse(circle_bbox, fill=ACCENT_COLOR)

    # 수학 기호 그리기 (간단한 + 기호)
    # 가로선
    line_width = ICON_SIZE // 8
    line_length = circle_radius
    draw.rectangle([
        circle_center[0] - line_length // 2,
        circle_center[1] - line_width // 2,
        circle_center[0] + line_length // 2,
        circle_center[1] + line_width // 2
    ], fill=BACKGROUND_COLOR)

    # 세로선
    draw.rectangle([
        circle_center[0] - line_width // 2,
        circle_center[1] - line_length // 2,
        circle_center[0] + line_width // 2,
        circle_center[1] + line_length // 2
    ], fill=BACKGROUND_COLOR)

    # 텍스트 추가 (하단에 "ML" 표시)
    try:
        # 시스템 폰트 시도
        font_size = ICON_SIZE // 6
        try:
            # macOS
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except:
            try:
                # Linux
                font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
            except:
                # 기본 폰트
                font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()

    text = "ML"

    # 텍스트 위치 계산 (하단 중앙)
    # bbox = draw.textbbox((0, 0), text, font=font)
    # text_width = bbox[2] - bbox[0]
    # text_height = bbox[3] - bbox[1]

    # 간단한 중앙 정렬
    text_position = (ICON_SIZE // 2 - font_size, ICON_SIZE - font_size - ICON_SIZE // 8)

    # 텍스트 그림자
    shadow_offset = 4
    draw.text(
        (text_position[0] + shadow_offset, text_position[1] + shadow_offset),
        text,
        fill=(0, 0, 0, 128),
        font=font
    )

    # 텍스트
    draw.text(text_position, text, fill=TEXT_COLOR, font=font)

    return img

def main():
    print("=" * 50)
    print("  MathLab 앱 아이콘 플레이스홀더 생성")
    print("=" * 50)
    print()

    # 프로젝트 루트 디렉토리 경로
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)

    # 이미지 디렉토리 경로
    images_dir = os.path.join(project_root, "assets", "images")
    os.makedirs(images_dir, exist_ok=True)

    # 아이콘 파일 경로
    icon_path = os.path.join(images_dir, "app_icon.png")

    # 기존 아이콘 확인
    if os.path.exists(icon_path):
        response = input(f"⚠️  기존 아이콘이 존재합니다.\n   {icon_path}\n   덮어쓰시겠습니까? (y/N): ")
        if response.lower() != 'y':
            print("취소되었습니다.")
            return

    print("아이콘 생성 중...")

    # 아이콘 생성
    icon = create_icon()

    # 저장
    icon.save(icon_path, 'PNG', optimize=True)

    print(f"✅ 아이콘이 생성되었습니다!")
    print(f"   위치: {icon_path}")
    print()

    # 다양한 크기의 아이콘 생성 (선택사항)
    print("다양한 크기의 아이콘을 생성하시겠습니까?")
    response = input("(iOS, Android 등 다양한 플랫폼용) (y/N): ")

    if response.lower() == 'y':
        sizes = {
            'ios': [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024],
            'android': [36, 48, 72, 96, 144, 192, 512]
        }

        for platform, size_list in sizes.items():
            platform_dir = os.path.join(images_dir, f'icon_{platform}')
            os.makedirs(platform_dir, exist_ok=True)

            print(f"\n{platform.upper()} 아이콘 생성 중...")
            for size in size_list:
                resized_icon = icon.resize((size, size), Image.Resampling.LANCZOS)
                size_path = os.path.join(platform_dir, f'icon_{size}x{size}.png')
                resized_icon.save(size_path, 'PNG', optimize=True)
                print(f"  ✓ {size}x{size}")

        print()
        print("✅ 모든 크기의 아이콘이 생성되었습니다!")
        print(f"   위치: {images_dir}")

    print()
    print("=" * 50)
    print("  완료!")
    print("=" * 50)
    print()
    print("📝 다음 단계:")
    print()
    print("1. 플레이스홀더 아이콘을 실제 디자인으로 교체하세요.")
    print()
    print("2. flutter_launcher_icons로 플랫폼별 아이콘 생성:")
    print("   flutter pub run flutter_launcher_icons")
    print()
    print("3. 아이콘 생성 도구 추천:")
    print("   - https://icon.kitchen/")
    print("   - https://appicon.co/")
    print("   - https://makeappicon.com/")
    print()
    print("⚠️  주의: 이 플레이스홀더는 개발/테스트용입니다.")
    print("        실제 배포 시에는 전문 디자이너의 아이콘을 사용하세요!")
    print()

if __name__ == "__main__":
    main()
