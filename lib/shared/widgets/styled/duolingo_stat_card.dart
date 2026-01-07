import 'package:flutter/material.dart';
import 'duolingo_card.dart';
import '../../constants/duolingo_styles.dart';

/// 듀오링고 스타일 스탯 카드 위젯
///
/// XP, 레벨, 연속 일수 등의 통계 정보를 표시하는 재사용 가능한 카드 컴포넌트
class DuolingoStatCard extends StatelessWidget {
  /// 아이콘 경로 또는 위젯
  final dynamic icon;

  /// 라벨 텍스트 (예: 'XP', '레벨', '연속')
  final String label;

  /// 값 텍스트 (예: '549', 'H Lv1', '0일')
  final String value;

  /// 클릭 이벤트 핸들러
  final VoidCallback? onTap;

  /// 아이콘 크기
  final double iconSize;

  const DuolingoStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.iconSize = 26, // 22 → 26 (UX 개선: 더 잘 보이도록)
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DuolingoCard(
        theme: DuolingoCardTheme.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              // 아이콘
              _buildIcon(),
              const SizedBox(height: DuolingoStyles.spacing8),
              // 라벨
              Text(
                label,
                style: DuolingoStyles.cardLabelStyle,
              ),
              const SizedBox(height: DuolingoStyles.spacing4),
              // 값
              Text(
                value,
                style: DuolingoStyles.cardValueDarkStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 아이콘 빌더
  Widget _buildIcon() {
    return Container(
      width: 40, // 36 → 40 (UX 개선)
      height: 40, // 36 → 40 (UX 개선)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Center(
        child: _buildIconContent(),
      ),
    );
  }

  /// 아이콘 콘텐츠 (String 경로 또는 Widget)
  Widget _buildIconContent() {
    if (icon is String) {
      // 이미지 경로인 경우
      return Image.asset(
        icon as String,
        width: iconSize,
        height: iconSize,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.star,
            size: iconSize,
            color: Colors.blue.shade400,
          );
        },
      );
    } else if (icon is Widget) {
      // Widget인 경우
      return icon as Widget;
    } else {
      // 기본 아이콘
      return Icon(
        Icons.star,
        size: iconSize,
        color: Colors.blue.shade400,
      );
    }
  }
}
