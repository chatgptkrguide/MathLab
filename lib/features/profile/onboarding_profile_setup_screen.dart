import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/temp_profile_storage.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/logger.dart';

/// 온보딩 스타일 프로필 설정 화면
///
/// 한 질문씩 크게 표시하며 페이지를 넘어가는 방식
class OnboardingProfileSetupScreen extends ConsumerStatefulWidget {
  const OnboardingProfileSetupScreen({super.key});

  @override
  ConsumerState<OnboardingProfileSetupScreen> createState() =>
      _OnboardingProfileSetupScreenState();
}

class _OnboardingProfileSetupScreenState
    extends ConsumerState<OnboardingProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

  // 입력 컨트롤러
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _bioController = TextEditingController();

  // 선택된 값
  DateTime? _selectedBirthDate;
  int? _selectedBirthYear;
  int? _selectedBirthMonth;
  int? _selectedBirthDay;
  String? _selectedGender;
  String _selectedGrade = '중1';

  // 성별 옵션
  final List<Map<String, String>> _genderOptions = [
    {'value': 'male', 'label': '남성', 'icon': '👨'},
    {'value': 'female', 'label': '여성', 'icon': '👩'},
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextPage() {
    Logger.info('_nextPage called: current=$_currentPage, total=$_totalPages',
        tag: 'OnboardingProfileSetup');
    if (_currentPage < _totalPages - 1) {
      // Haptic feedback for smooth transition
      HapticFeedback.lightImpact();
      setState(() => _currentPage++);
      Logger.info('Moving to page $_currentPage',
          tag: 'OnboardingProfileSetup');
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      Logger.info('Already at last page', tag: 'OnboardingProfileSetup');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      // Haptic feedback for going back
      HapticFeedback.lightImpact();
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  bool _canProceed() {
    // 로깅 제거: build 메서드에서 여러 번 호출되므로 로그가 무한 반복될 수 있음
    switch (_currentPage) {
      case 0: // 이름
        return _nameController.text.trim().length >= 2;
      case 1: // 생년월일
        return _selectedBirthDate != null;
      case 2: // 성별
        return _selectedGender != null;
      case 3: // 학년
        return true; // 기본값이 있으므로 항상 true
      case 4: // 학교명 (선택)
        return true; // 선택사항이므로 항상 true
      case 5: // 자기소개 (선택)
        return true; // 선택사항이므로 항상 true
      default:
        return false;
    }
  }

  void _updateBirthDate() {
    if (_selectedBirthYear != null &&
        _selectedBirthMonth != null &&
        _selectedBirthDay != null) {
      try {
        setState(() {
          _selectedBirthDate = DateTime(
              _selectedBirthYear!, _selectedBirthMonth!, _selectedBirthDay!);
        });
      } catch (e) {
        // 유효하지 않은 날짜 (예: 2월 30일) 처리
        setState(() {
          _selectedBirthDate = null;
        });
      }
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _saveProfile() async {
    // Success haptic feedback
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      // TempProfileData 생성
      final tempProfileData = TempProfileData(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        currentGrade: _selectedGrade,
        schoolName: _schoolController.text.trim().isNotEmpty
            ? _schoolController.text.trim()
            : null,
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
      );

      Logger.info('프로필 입력 완료: ${tempProfileData.name}',
          tag: 'OnboardingProfileSetupScreen');

      // Short delay for better UX (show loading state)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Success haptic feedback before closing
        HapticFeedback.heavyImpact();
        // TempProfileData를 반환하고 화면 닫기
        Navigator.of(context).pop(tempProfileData);
      }
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.vibrate();
      Logger.error('프로필 저장 실패', error: e, tag: 'OnboardingProfileSetupScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProgressBar() {
    final progress = (_currentPage + 1) / _totalPages;
    // 듀오링고 녹색
    const duolingoGreen = Color(0xFF58CC02);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16, // 노치 아래 추가 여백
          bottom: 20,
        ),
        child: Column(
          children: [
            // XP 스타일 프로그레스 바
            Row(
              children: [
                // 레벨 아이콘 (듀오링고 녹색)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: duolingoGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: duolingoGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${_currentPage + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 프로그레스 바
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // 배경 그라디언트
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.borderLight.withValues(alpha: 0.3),
                                AppColors.borderLight.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // 진행률 (듀오링고 녹색 그라디언트)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: (MediaQuery.of(context).size.width - 120) *
                              progress,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF89E219), // 밝은 녹색
                                Color(0xFF58CC02), // 듀오링고 녹색
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: duolingoGreen.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 퍼센트 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mathBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 단계 텍스트
            Text(
              '${_currentPage + 1} / $_totalPages 단계',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String question,
    required String subtitle,
    required Widget content,
    String? skipButtonText,
    VoidCallback? onSkip,
  }) {
    return SafeArea(
      child: Column(
        children: [
          // 스크롤 가능한 컨텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 뒤로가기 버튼
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousPage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(height: 24),

                  // 질문 텍스트
                  Text(
                    question,
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 부제목
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 컨텐츠
                  content,

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼 영역 (스크롤 밖)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 계속하기 버튼 (듀오링고 스타일)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _canProceed()
                        ? () {
                            Logger.info('Button tapped: page=$_currentPage',
                                tag: 'OnboardingProfileSetup');
                            if (_currentPage == _totalPages - 1) {
                              _saveProfile();
                            } else {
                              _nextPage();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceed()
                          ? const Color(0xFF58CC02) // 듀오링고 녹색
                          : const Color(0xFFE5E5E5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E5E5),
                      disabledForegroundColor: AppColors.textTertiary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: _canProceed()
                            ? const BorderSide(
                                color: Color(0xFF46A302),
                                width: 0,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _totalPages - 1
                                    ? '🚀 시작하기'
                                    : '계속하기',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_canProceed()) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),

                // 건너뛰기 버튼
                if (onSkip != null || skipButtonText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextButton(
                      onPressed: onSkip ?? _nextPage,
                      child: Text(
                        skipButtonText ?? '건너뛰기',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 듀오링고 스타일 배경 색상 (페이지마다 다른 색상)
    final List<Color> pageColors = [
      const Color(0xFFFFF7ED), // 주황 베이지 - 이름
      const Color(0xFFECFDF5), // 녹색 베이지 - 생년월일
      const Color(0xFFFCE7F3), // 핑크 베이지 - 성별
      const Color(0xFFEEF2FF), // 파랑 베이지 - 학년
      const Color(0xFFFEF3C7), // 노랑 베이지 - 학교
      const Color(0xFFF3E8FF), // 보라 베이지 - 자기소개
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면 조정
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: pageColors[_currentPage],
        ),
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Page 1: 이름
                  _buildPage(
                    question: '👋 이름을 알려주세요',
                    subtitle: '실명 또는 닉네임을 입력하세요',
                    content: TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '이름을 입력하세요',
                        hintStyle: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 24,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.borderLight, width: 2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.mathBlue, width: 2),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),

                  // Page 2: 생년월일
                  _buildPage(
                    question: '🎂 생년월일을\n알려주세요',
                    subtitle: '정확한 학습 추천을 위해 필요해요',
                    content: Column(
                      children: [
                        Row(
                          children: [
                            // 년도 선택
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedBirthYear != null
                                        ? const Color(0xFF58CC02)
                                        : AppColors.borderLight,
                                    width: 2,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedBirthYear,
                                    hint: Text(
                                      '년',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: AppColors.textSecondary,
                                        size: 28),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                    items: List.generate(
                                      DateTime.now().year - 1950 + 1,
                                      (index) => DateTime.now().year - index,
                                    ).map((year) {
                                      return DropdownMenuItem<int>(
                                        value: year,
                                        child: Text('$year년'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                          () => _selectedBirthYear = value);
                                      _updateBirthDate();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 월 선택
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedBirthMonth != null
                                        ? const Color(0xFF58CC02)
                                        : AppColors.borderLight,
                                    width: 2,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedBirthMonth,
                                    hint: Text(
                                      '월',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: AppColors.textSecondary,
                                        size: 28),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                    items:
                                        List.generate(12, (index) => index + 1)
                                            .map((month) {
                                      return DropdownMenuItem<int>(
                                        value: month,
                                        child: Text('$month월'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                          () => _selectedBirthMonth = value);
                                      _updateBirthDate();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 일 선택
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedBirthDay != null
                                        ? const Color(0xFF58CC02)
                                        : AppColors.borderLight,
                                    width: 2,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedBirthDay,
                                    hint: Text(
                                      '일',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: AppColors.textSecondary,
                                        size: 28),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                    items:
                                        List.generate(31, (index) => index + 1)
                                            .map((day) {
                                      return DropdownMenuItem<int>(
                                        value: day,
                                        child: Text('$day일'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedBirthDay = value);
                                      _updateBirthDate();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedBirthDate != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🎉 만 ${_calculateAge(_selectedBirthDate!)}세',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: const Color(0xFF059669),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    skipButtonText: '나중에 입력하기',
                  ),

                  // Page 3: 성별
                  _buildPage(
                    question: '💫 성별을\n선택해주세요',
                    subtitle: '선택사항이에요',
                    content: Column(
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _genderOptions.map((option) {
                            final isSelected =
                                _selectedGender == option['value'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  // Toggle selection: tap again to deselect
                                  if (_selectedGender == option['value']) {
                                    _selectedGender = null;
                                  } else {
                                    _selectedGender = option['value'];
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width:
                                    (MediaQuery.of(context).size.width - 72) /
                                        2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 32,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.mathBlue,
                                            AppColors.mathTeal,
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.mathBlue
                                        : AppColors.borderLight,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.mathBlue
                                                .withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.1 : 1.0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Text(
                                        option['icon']!,
                                        style: const TextStyle(fontSize: 48),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      option['label']!,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        // Add extra spacing to prevent button overlap
                        const SizedBox(height: 40),
                      ],
                    ),
                    skipButtonText: '건너뛰기',
                  ),

                  // Page 4: 학년 - 1단계 (대분류 선택)
                  _buildPage(
                    question: '🎓 현재 학년을\n알려주세요',
                    subtitle: '적절한 난이도의 문제를 제공해드려요',
                    content: Column(
                      children: [
                        // 초등학생
                        _buildMainGradeCard(
                          title: '초등학생',
                          icon: '🎒',
                          grades: ['초1', '초2', '초3', '초4', '초5', '초6'],
                          color: const Color(0xFF58CC02), // Duolingo green
                        ),
                        const SizedBox(height: 10), // Reduced from 12
                        // 중학생
                        _buildMainGradeCard(
                          title: '중학생',
                          icon: '📚',
                          grades: ['중1', '중2', '중3'],
                          color: const Color(0xFF1CB0F6), // Duolingo blue
                        ),
                        const SizedBox(height: 10), // Reduced from 12
                        // 고등학생
                        _buildMainGradeCard(
                          title: '고등학생',
                          icon: '🎓',
                          grades: ['고1', '고2', '고3'],
                          color: const Color(0xFFFF9600), // Duolingo orange
                        ),
                        const SizedBox(height: 10), // Reduced from 12
                        // 성인
                        _buildMainGradeCard(
                          title: '성인',
                          icon: '📖',
                          grades: ['대학생', '성인'],
                          color: const Color(0xFFCE82FF), // Duolingo purple
                        ),
                      ],
                    ),
                  ),

                  // Page 5: 학교명 (선택)
                  _buildPage(
                    question: '🏫 학교를\n알려주세요',
                    subtitle: '같은 학교 친구를 찾을 수 있어요',
                    content: TextField(
                      controller: _schoolController,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '학교명을 입력하세요',
                        hintStyle: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 24,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.borderLight, width: 2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.mathBlue, width: 2),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    skipButtonText: '건너뛰기',
                  ),

                  // Page 6: 자기소개 (선택)
                  _buildPage(
                    question: '✨ 자기소개를\n해주세요',
                    subtitle: '프로필에 표시돼요',
                    content: TextField(
                      controller: _bioController,
                      maxLines: 5,
                      maxLength: 200,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: '간단한 자기소개를 작성해주세요',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.textTertiary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.borderLight, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.borderLight, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.mathBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    skipButtonText: '건너뛰기',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 학년 대분류 카드 (초등/중등/고등/성인)
  Widget _buildMainGradeCard({
    required String title,
    required String icon,
    required List<String> grades,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // 세부 학년 선택 다이얼로그 표시
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘과 제목
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 세부 학년 선택
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: grades.map((grade) {
                      final isSelected = _selectedGrade == grade;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGrade = grade;
                          });
                          Navigator.pop(context); // 다이얼로그 닫기
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : AppColors.borderLight,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              grade,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: grades.contains(_selectedGrade)
                ? color
                : AppColors.borderLight,
            width: 3,
          ),
          boxShadow: grades.contains(_selectedGrade)
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grades.contains(_selectedGrade)
                        ? _selectedGrade
                        : '탭하여 선택',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: grades.contains(_selectedGrade)
                          ? color
                          : AppColors.textSecondary,
                      fontWeight: grades.contains(_selectedGrade)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            // 화살표
            Icon(
              Icons.arrow_forward_ios,
              color: grades.contains(_selectedGrade)
                  ? color
                  : AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
