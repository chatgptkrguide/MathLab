import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';

/// Figma Screen 04: ProblemScreen (문제 풀이)
/// 정확한 Figma 디자인 구현
class ProblemScreen extends ConsumerStatefulWidget {
  const ProblemScreen({super.key});

  @override
  ConsumerState<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  final List<String> _selectedWords = [];
  final List<String> _availableWords = [
    'The',
    'man',
    'woman',
    'I',
    'am',
    'you',
    'a',
    'is',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),
              // 진행 바
              _buildProgressBar(),
              const SizedBox(height: 40),
              // 문제 제목
              _buildQuestionTitle(),
              const SizedBox(height: 40),
              // 답안 영역
              _buildAnswerArea(),
              const Spacer(),
              // 선택 가능한 단어들
              _buildWordOptions(),
              const SizedBox(height: 40),
              // 체크 버튼
              _buildCheckButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더: 닫기 버튼
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 48), // 균형을 위한 공간
        ],
      ),
    );
  }

  /// 진행 바
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: 0.3,
          minHeight: 12,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mathTeal),
        ),
      ),
    );
  }

  /// 문제 제목
  Widget _buildQuestionTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Translate this sentence',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// 답안 영역 (선택된 단어들)
  Widget _buildAnswerArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedWords.map((word) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWords.remove(word);
                _availableWords.add(word);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 선택 가능한 단어 옵션들
  Widget _buildWordOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _availableWords.map((word) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _availableWords.remove(word);
                _selectedWords.add(word);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 체크 버튼
  Widget _buildCheckButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B5BFF), Color(0xFF2A45CC)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B5BFF).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedWords.isEmpty ? null : () {
            // 답안 체크 로직
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('답안 제출'),
                content: Text('선택한 답: ${_selectedWords.join(' ')}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: const Text(
            'CHECK',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
