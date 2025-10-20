import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/lesson_provider.dart';
import '../../shared/widgets/fade_in_widget.dart';

/// Figma Screen 01: LessonsScreen (학습 카드 그리드)
/// 정확한 Figma 디자인 구현 + 실제 데이터 연동
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final lessons = ref.watch(lessonProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(context),
              const SizedBox(height: 16),
              // 사용자 정보 바
              _buildUserStatsBar(user),
              const SizedBox(height: 20),
              // 학습 카드 그리드 (흰색 배경)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildLessonGrid(lessons),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더: 햄버거 메뉴 + 학습 + GoMATH 로고
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 햄버거 메뉴 (클릭 가능)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // 메뉴 열기 기능 (추후 구현)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('메뉴 기능은 추후 구현 예정입니다'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          // 학습 타이틀
          const Text(
            '학습',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // GoMATH 로고
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Go',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF61A1D8),
                    ),
                  ),
                  TextSpan(
                    text: 'MATH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B5BFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자 정보 바: 현재 단원 + 통계
  Widget _buildUserStatsBar(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 현재 학습 중인 단원
          Flexible(
            child: Text(
              user?.currentGrade ?? '중1 수학',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 통계
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                '${user?.streak ?? 6}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text('🔶', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                '${user?.xp ?? 549}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text('⭐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                '${user?.level ?? 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 학습 카드 그리드
  Widget _buildLessonGrid(List lessons) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // START! 카드
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: _buildStartCard(),
          ),
          const SizedBox(height: 32),

          // 섹션 제목
          const Text(
            '학습 단원',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 레슨 카드 그리드
          _buildResponsiveGrid(lessons),

          const SizedBox(height: 100), // 하단 네비게이션 공간
        ],
      ),
    );
  }

  /// 반응형 그리드
  Widget _buildResponsiveGrid(List lessons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 너비에 따라 컬럼 수 조정
        int crossAxisCount = 3;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 4;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 5;
        }

        // 실제 데이터가 있으면 사용, 없으면 기본 아이콘
        final icons = lessons.isNotEmpty
            ? lessons.take(9).map((lesson) => lesson.icon ?? '📚').toList()
            : ['🎒', '⏰', '🏆', '💻', '🌍', '📋', '⚛️', '🔬', '📖'];

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            return FadeInWidget(
              delay: Duration(milliseconds: 200 + (index * 50)),
              child: _buildLessonCard(
                icons[index],
                index,
                lessons.isNotEmpty && index < lessons.length
                    ? lessons[index]
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  /// START! 카드
  Widget _buildStartCard() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B5BFF), Color(0xFF2A45CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5BFF).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 문제 풀이 화면으로 이동 (추후 구현)
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 좌측: 아이콘과 텍스트
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📚',
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'START!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '학습 시작하기',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // 우측: 화살표 아이콘
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 개별 레슨 카드
  Widget _buildLessonCard(String icon, int index, dynamic lesson) {
    final bool isCompleted = lesson?.isCompleted ?? (index % 3 == 0);
    final double progress = lesson?.progress ?? (index * 0.15).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: AppColors.duolingoGreen, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 레슨 상세 화면으로 이동
          },
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 메인 아이콘
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    if (progress > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColors.duolingoGreen
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 완료 체크 마크
              if (isCompleted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.duolingoGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              // 진행률 바 (하단)
              if (progress > 0 && !isCompleted)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mathTeal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
