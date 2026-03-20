import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/effects/noise_texture.dart';

/// Data class for demo problems (no Firebase dependency)
class DemoProblem {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const DemoProblem({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Demo lesson screen for unauthenticated users.
/// Runs entirely offline with hardcoded problems.
class DemoLessonScreen extends StatefulWidget {
  const DemoLessonScreen({super.key});

  @override
  State<DemoLessonScreen> createState() => _DemoLessonScreenState();
}

class _DemoLessonScreenState extends State<DemoLessonScreen>
    with SingleTickerProviderStateMixin {
  static const _problems = [
    DemoProblem(
      question: '3 + 5 = ?',
      options: ['6', '7', '8', '9'],
      correctIndex: 2,
      explanation: '3과 5를 더하면 8입니다.',
    ),
    DemoProblem(
      question: '12 - 7 = ?',
      options: ['4', '5', '6', '3'],
      correctIndex: 1,
      explanation: '12에서 7을 빼면 5입니다.',
    ),
    DemoProblem(
      question: '4 × 3 = ?',
      options: ['10', '11', '12', '14'],
      correctIndex: 2,
      explanation: '4에 3을 곱하면 12입니다.',
    ),
    DemoProblem(
      question: '다음 중 소수는?',
      options: ['4', '6', '7', '9'],
      correctIndex: 2,
      explanation: '7은 1과 자기 자신으로만 나눠지는 소수입니다.',
    ),
  ];

  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _isCompleted = false;

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered || _selectedOption != null) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _problems[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
    _feedbackController.forward(from: 0);
  }

  void _nextProblem() {
    if (_currentIndex < _problems.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() => _isCompleted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildResultScreen();
    }
    return _buildProblemScreen();
  }

  Widget _buildProblemScreen() {
    final problem = _problems[_currentIndex];
    final progress = (_currentIndex + 1) / _problems.length;

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        child: Stack(
          children: [
            const NoiseTexture(opacity: 0.02, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Close button + progress
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.mathGreen,
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_currentIndex + 1}/${_problems.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Question
                  Text(
                    problem.question,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // Options
                  ...List.generate(problem.options.length, (i) {
                    final isSelected = _selectedOption == i;
                    final isCorrect = i == problem.correctIndex;
                    Color bgColor;
                    Color borderColor;
                    Color textColor;

                    if (!_answered) {
                      bgColor = Colors.white;
                      borderColor = Colors.white.withValues(alpha: 0.3);
                      textColor = AppColors.textDark;
                    } else if (isCorrect) {
                      bgColor = AppColors.mathGreen.withValues(alpha: 0.15);
                      borderColor = AppColors.mathGreen;
                      textColor = AppColors.mathGreen;
                    } else if (isSelected) {
                      bgColor = AppColors.mathRed.withValues(alpha: 0.15);
                      borderColor = AppColors.mathRed;
                      textColor = AppColors.mathRed;
                    } else {
                      bgColor = Colors.white.withValues(alpha: 0.5);
                      borderColor = Colors.transparent;
                      textColor = AppColors.textSecondary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _selectOption(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected || (_answered && isCorrect)
                                  ? 2.5
                                  : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  problem.options[i],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (_answered && isCorrect)
                                const Icon(Icons.check_circle,
                                    color: AppColors.mathGreen, size: 22),
                              if (_answered && isSelected && !isCorrect)
                                const Icon(Icons.cancel,
                                    color: AppColors.mathRed, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Feedback + next button
                  if (_answered)
                    FadeTransition(
                      opacity: _feedbackAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              problem.explanation,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _nextProblem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mathGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _currentIndex < _problems.length - 1
                                    ? '다음 문제'
                                    : '결과 보기',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!_answered) const SizedBox(height: 80),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final allCorrect = _correctCount == _problems.length;

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        child: Stack(
          children: [
            const NoiseTexture(opacity: 0.02, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Result icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      allCorrect ? Icons.star_rounded : Icons.emoji_events,
                      size: 56,
                      color: AppColors.mathYellow,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    '체험 완료!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Score
                  Text(
                    '$_correctCount/${_problems.length} 정답'
                    '${allCorrect ? " - 훌륭해요!" : ""}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'MathLab에서 더 많은 문제를 풀어보세요.\n매일 학습하면 수학 실력이 쑥쑥 올라요!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // CTA: Sign up
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mathGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '가입하고 계속하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Secondary: dismiss
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '나중에 할게요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
