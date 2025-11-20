import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/models/problem.dart';
import '../../data/repositories/problem_repository.dart';
import '../../shared/constants/app_colors.dart';

/// 문제 풀이 화면 (듀오링고 스타일)
class ProblemSolvingScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const ProblemSolvingScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<ProblemSolvingScreen> createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends State<ProblemSolvingScreen>
    with SingleTickerProviderStateMixin {
  // 문제 목록
  List<Problem> _problems = [];
  int _currentProblemIndex = 0;
  bool _isLoading = true;
  final ProblemRepository _repository = ProblemRepository();

  // 답변 관련 상태
  int? _selectedAnswerIndex;
  String _textAnswer = '';
  bool _isAnswered = false;
  bool _isCorrect = false;

  // 힌트 시스템
  int _hintsUsed = 0;

  // 하트 시스템
  int _hearts = 5;
  int _correctAnswers = 0;

  // 타이머
  Timer? _timer;
  int _timeRemaining = 60;

  // 애니메이션
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadProblems(); // 문제 로드 시 자동으로 타이머 시작

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProblems() async {
    try {
      // 레슨 ID에 따라 문제 로드
      final problems = await _repository.loadProblemsByLesson(widget.lessonId);

      setState(() {
        _problems = problems;
        _isLoading = false;
      });

      if (_problems.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      print('문제 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    setState(() {
      _hearts--;
      if (_hearts > 0) {
        _nextProblem();
      } else {
        _showGameOver();
      }
    });
  }

  Widget _buildQuestionText(String question) {
    return Text(
      question,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _checkAnswer() {
    final problem = _problems[_currentProblemIndex];
    bool isCorrect = false;

    if (problem.type == ProblemType.multipleChoice && _selectedAnswerIndex != null) {
      // answer가 int (index)인 경우 처리
      if (problem.answer is int) {
        isCorrect = _selectedAnswerIndex == problem.answer;
      } else {
        // answer가 String인 경우 처리
        isCorrect = problem.choices[_selectedAnswerIndex!] == problem.answer;
      }
    } else if (problem.type == ProblemType.shortAnswer) {
      isCorrect = _textAnswer.trim() == problem.answer.toString();
    } else {
      return;
    }

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;

      if (_isCorrect) {
        _correctAnswers++;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      } else {
        _hearts--;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (_hearts > 0) {
        if (_isCorrect || _currentProblemIndex < _problems.length - 1) {
          _nextProblem();
        } else {
          _showGameOver();
        }
      } else {
        _showGameOver();
      }
    });
  }

  void _nextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _selectedAnswerIndex = null;
        _textAnswer = '';
        _isAnswered = false;
        _isCorrect = false;
        _hintsUsed = 0;
        _timeRemaining = 60;
      });
      _timer?.cancel();
      _startTimer();
    } else {
      _showCompletion();
    }
  }

  void _showHintDialog() {
    final problem = _problems[_currentProblemIndex];
    if (problem.hints.isNotEmpty && _hintsUsed < problem.hints.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('힌트 ${_hintsUsed + 1}/${problem.hints.length}'),
          content: Text(
            problem.hints[_hintsUsed],
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hintsUsed++;
                });
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('게임 오버!'),
        content: Text('맞춘 문제: $_correctAnswers / ${_problems.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentProblemIndex = 0;
                _hearts = 5;
                _correctAnswers = 0;
                _selectedAnswerIndex = null;
                _textAnswer = '';
                _isAnswered = false;
                _hintsUsed = 0;
                _timeRemaining = 60;
              });
              _timer?.cancel();
              _startTimer();
            },
            child: const Text('다시 시작'),
          ),
        ],
      ),
    );
  }

  void _showCompletion() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('축하합니다!'),
        content: Text(
          '모든 문제를 완료했습니다!\n'
          '맞춘 문제: $_correctAnswers / ${_problems.length}\n'
          '남은 하트: $_hearts',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '로딩 중...',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_problems.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '문제 없음',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: const Center(
          child: Text('문제를 불러올 수 없습니다.'),
        ),
      );
    }

    final problem = _problems[_currentProblemIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.lessonTitle.isNotEmpty ? widget.lessonTitle : '학습하기',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (_currentProblemIndex + 1) / _problems.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mathBlue),
            ),
          ],
        ),
        actions: [
          // 하트 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < _hearts ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 타이머
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문제 ${_currentProblemIndex + 1}/${_problems.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _timeRemaining > 10 ? AppColors.mathBlue : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_timeRemaining초',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 문제
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 힌트 버튼 (문제 위쪽으로 이동)
                    if (problem.hints.isNotEmpty && _hintsUsed < problem.hints.length && !_isAnswered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.mathPurple.withOpacity(0.1),
                                AppColors.mathYellow.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.mathPurple.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showHintDialog,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: AppColors.mathYellow,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '힌트 보기 ($_hintsUsed/${problem.hints.length})',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mathPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 문제 이미지 또는 텍스트
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 문제 이미지 (있을 경우)
                          if (problem.imageUrl != null && problem.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                problem.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildQuestionText(problem.question);
                                },
                              ),
                            )
                          else
                            _buildQuestionText(problem.question),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 답변 영역
                    if (problem.type == ProblemType.multipleChoice)
                      ...problem.choices.asMap().entries.map((entry) {
                        final index = entry.key;
                        final choice = entry.value;
                        final isSelected = _selectedAnswerIndex == index;

                        // 정답 확인
                        bool isCorrectAnswer = false;
                        if (problem.answer is int) {
                          isCorrectAnswer = index == problem.answer;
                        } else {
                          isCorrectAnswer = choice == problem.answer;
                        }

                        Color? backgroundColor;
                        if (_isAnswered) {
                          if (isCorrectAnswer) {
                            backgroundColor = Colors.green[100];
                          } else if (isSelected && !_isCorrect) {
                            backgroundColor = Colors.red[100];
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: backgroundColor ?? (isSelected ? AppColors.mathBlue.withOpacity(0.1) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _isAnswered ? null : () {
                                setState(() {
                                  _selectedAnswerIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? AppColors.mathBlue : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.mathBlue : Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        choice,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    if (_isAnswered && isCorrectAnswer)
                                      const Icon(Icons.check_circle, color: Colors.green),
                                    if (_isAnswered && isSelected && !_isCorrect)
                                      const Icon(Icons.cancel, color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                    else
                      TextField(
                        enabled: !_isAnswered,
                        onChanged: (value) {
                          setState(() {
                            _textAnswer = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '답을 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.mathBlue, width: 2),
                          ),
                        ),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 제출 버튼
            if (!_isAnswered)
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: (_selectedAnswerIndex != null || _textAnswer.isNotEmpty)
                      ? _checkAnswer
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '제출하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _nextProblem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect ? AppColors.successGreen : AppColors.mathBlue,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isCorrect ? '다음 문제' : '계속하기',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
