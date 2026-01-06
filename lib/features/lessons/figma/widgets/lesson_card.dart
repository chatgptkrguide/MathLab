import 'package:flutter/material.dart';

/// 개별 레슨 카드 위젯
class LessonCard extends StatelessWidget {
  final String image;
  final String label;
  final bool isLocked;
  final bool isCurrent;
  final bool isCompleted;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LessonCard({
    super.key,
    required this.image,
    required this.label,
    required this.isLocked,
    required this.isCurrent,
    required this.isCompleted,
    required this.height,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.38;

    return GestureDetector(
      onTap: !isLocked && onTap != null ? onTap : null,
      onLongPress: !isLocked && onLongPress != null ? onLongPress : null,
      child: Container(
        width: cardWidth,
        height: height,
        decoration: BoxDecoration(
          color: isLocked
              ? const Color(0xFFD8E7F3) // 잠긴 카드는 밝은 파란색
              : isCompleted
                  ? const Color(0xFF4CAF50) // 완료된 카드는 초록색
                  : const Color(0xFF4A90E2), // 활성 카드는 진한 파란색
          borderRadius: BorderRadius.circular(20),
          border: isCurrent && !isLocked
              ? Border.all(
                  color: const Color(0xFFFFD700), // 현재 진행중은 금색 테두리
                  width: 4,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isCurrent && !isLocked
                  ? const Color(0xFFFFD700).withOpacity(0.5)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isCurrent && !isLocked ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 이미지
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.book,
                      size: 60,
                      color: isLocked
                          ? Colors.grey.shade400
                          : Colors.white.withOpacity(0.7),
                    );
                  },
                ),
              ),
            ),

            // 잠금 오버레이
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),

            // 완료 체크 표시
            if (isCompleted && !isLocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 20,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),

            // 현재 진행중 표시
            if (isCurrent && !isLocked && !isCompleted)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    '진행중',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
