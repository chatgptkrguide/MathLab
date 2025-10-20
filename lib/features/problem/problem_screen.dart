import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../data/providers/user_provider.dart';

/// 문제 풀이 화면 (Figma 디자인 04)
/// 타일/워드뱅크 방식의 문제 풀이 인터페이스
class ProblemScreen extends ConsumerStatefulWidget {
  final String? lessonId;
  final List<dynamic>? problems;

  const ProblemScreen({
    super.key,
    this.lessonId,
    this.problems,
  });

  @override
  ConsumerState<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  // 예시 데이터
  final String _questionTitle = 'Solve the equation';
  final String _problemText = '2x + 5 = 13';

  // 사용 가능한 타일
  final List<String> _availableTiles = [
    'x = 4',
    'x = 8',
    'x = 2',
    'x = 6',
    'x = 3',
    'x = 5',
    'x = 7',
  ];

  // 선택된 타일들
  final List<String> _selectedTiles = [];

  int _currentProgress = 3;
  int _totalQuestions = 10;
  int _xpPoints = 549;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 제목 + 진행률 + XP)
  Widget _buildHeader(BuildContext context) {
    final progress = _currentProgress / _totalQuestions;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // 뒤로가기 + 제목
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Question',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // 대칭을 위한 공간
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // 진행률 바 + XP
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              // XP 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mathOrange,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hexagon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _xpPoints.toString(),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 메인 컨텐츠
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    _questionTitle,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),
                  // 문제 + 오디오 아이콘
                  _buildProblemCard(),
                  const SizedBox(height: AppDimensions.spacingXL),
                  // 선택된 타일 영역
                  _buildAnswerArea(),
                  const SizedBox(height: AppDimensions.spacingXL),
                  // 사용 가능한 타일들
                  _buildTileBank(),
                ],
              ),
            ),
          ),
          // 하단 버튼
          _buildBottomButton(),
        ],
      ),
    );
  }

  /// 문제 카드 (오디오 아이콘 + 텍스트)
  Widget _buildProblemCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mathOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              Icons.volume_up,
              color: AppColors.mathOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Text(
              _problemText,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 답안 영역 (선택된 타일들이 들어가는 곳)
  Widget _buildAnswerArea() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: _selectedTiles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
                child: Text(
                  'Select answer from below',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : Wrap(
              spacing: AppDimensions.spacingS,
              runSpacing: AppDimensions.spacingS,
              children: _selectedTiles.map((tile) {
                return _buildSelectedTile(tile);
              }).toList(),
            ),
    );
  }

  /// 선택된 타일
  Widget _buildSelectedTile(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.mathButtonBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.mathButtonBlue,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mathButtonBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTiles.remove(text);
              });
            },
            child: Icon(
              Icons.close,
              size: 18,
              color: AppColors.mathButtonBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 타일 뱅크 (사용 가능한 타일들)
  Widget _buildTileBank() {
    return Wrap(
      spacing: AppDimensions.spacingM,
      runSpacing: AppDimensions.spacingM,
      children: _availableTiles.map((tile) {
        final isSelected = _selectedTiles.contains(tile);
        return _buildTile(tile, isSelected);
      }).toList(),
    );
  }

  /// 개별 타일
  Widget _buildTile(String text, bool isSelected) {
    return GestureDetector(
      onTap: isSelected
          ? null
          : () {
              setState(() {
                _selectedTiles.add(text);
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.background
              : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected
                ? AppColors.borderLight
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.titleMedium.copyWith(
            color: isSelected
                ? AppColors.textSecondary.withValues(alpha: 0.5)
                : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    final hasAnswer = _selectedTiles.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingXL,
        right: AppDimensions.paddingXL,
        top: AppDimensions.paddingL,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingL,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasAnswer ? _checkAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasAnswer
                ? AppColors.mathButtonBlue
                : AppColors.textSecondary.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            ),
            elevation: 0,
          ),
          child: Text(
            'CHECK ANSWER',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    // 답안 확인 로직
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답안 확인'),
        content: Text('선택한 답안: ${_selectedTiles.join(", ")}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedTiles.clear();
              });
            },
            child: const Text('다시 풀기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 다음 문제로 이동
            },
            child: const Text('다음 문제'),
          ),
        ],
      ),
    );
  }
}
