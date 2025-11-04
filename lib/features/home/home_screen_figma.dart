import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';

/// 피그마 디자인과 100% 동일한 홈 화면
/// Figma: 00 home 화면 구현
class HomeScreenFigma extends ConsumerWidget {
  const HomeScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF61A1D8), // 피그마 정확한 상단 색상
              Color(0xFFA1C9E8), // 피그마 정확한 하단 색상
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 상단 헤더 (햄버거 메뉴 - GoMATH - 프로필)
                _buildHeader(),

                const SizedBox(height: 50),

                // 로봇 캐릭터
                _buildRobotCharacter(),

                const SizedBox(height: 35),

                // 흰색 카드 (오늘의 학습 + START 버튼)
                _buildMainCard(context),

                const SizedBox(height: 25),

                // 하단 카드들 (English, Spanish)
                _buildBottomCards(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 햄버거 메뉴
          GestureDetector(
            onTap: () {
              // 메뉴 동작 추가 예정
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // GoMATH 로고
          const Text(
            'GoMATH',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),

          // 프로필 아이콘
          GestureDetector(
            onTap: () {
              // 프로필 동작 추가 예정
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotCharacter() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🤖',
          style: TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // 오늘의 학습
          Text(
            '오늘의 학습',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          // 메인 텍스트
          const Text(
            '수학의 세계로\n떠나볼까요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 25),

          // START 버튼
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, '/lessons');
        // 임시로 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('학습 화면으로 이동'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3B5BFF),
              Color(0xFF2B4BEF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B5BFF).withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '학습 시작하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLanguageCard('📚', 'English'),
          const SizedBox(width: 14),
          _buildLanguageCard('🗣️', 'Spanish'),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(String emoji, String label) {
    return Expanded(
      child: Container(
        height: 95,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}