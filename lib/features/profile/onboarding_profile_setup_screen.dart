import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/infrastructure/navigation_provider.dart';
import '../../data/services/onboarding_profile_storage.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../core/utils/app_logger.dart';
import 'widgets/widgets.dart';

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
  final int _totalPages = 3; // 6 → 3 페이지로 단순화

  // 입력 컨트롤러
  final _nameController = TextEditingController();

  // 선택된 값
  String _selectedGrade = '중1';

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!mounted) return;
    AppLogger.info('_nextPage called: current=$_currentPage, total=$_totalPages',
        tag: 'OnboardingProfileSetup');
    if (_currentPage < _totalPages - 1) {
      // Dismiss keyboard before transitioning
      FocusScope.of(context).unfocus();
      // Haptic feedback for smooth transition
      HapticFeedback.lightImpact();
      setState(() => _currentPage++);
      AppLogger.info('Moving to page $_currentPage',
          tag: 'OnboardingProfileSetup');
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      AppLogger.info('Already at last page', tag: 'OnboardingProfileSetup');
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
    switch (_currentPage) {
      case 0: // 이름
        return _nameController.text.trim().length >= 2;
      case 1: // 학년
        return true; // 기본값이 있으므로 항상 true
      case 2: // 완료 확인
        return true;
      default:
        return false;
    }
  }

  Future<void> _saveProfile() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final tempProfileData = TempProfileData(
        name: name,
        birthDate: null,
        gender: null,
        currentGrade: _selectedGrade,
        schoolName: null,
        bio: null,
      );

      AppLogger.info('프로필 입력 완료: $name ($_selectedGrade)',
          tag: 'OnboardingProfileSetupScreen');

      // Provider를 통해 직접 프로필 저장 (AuthWrapper 자동 리빌드)
      await ref.read(userProvider.notifier).updateProfile(displayName: name, currentGrade: _selectedGrade);

      if (!mounted) return;
      HapticFeedback.heavyImpact();

      // 온보딩 완료 후 홈 탭으로 이동하도록 설정
      ref.read(navigationProvider.notifier).goToHome();

      // Navigator.push로 열린 경우 pop, 아니면 AuthWrapper가 자동 처리
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(tempProfileData);
      }
    } catch (e) {
      HapticFeedback.vibrate();
      AppLogger.error('프로필 저장 실패', error: e, tag: 'OnboardingProfileSetupScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
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



  @override
  Widget build(BuildContext context) {
    // 듀오링고 스타일 배경 색상 (3페이지)
    final List<Color> pageColors = [
      AppColors.beigOrange, // 주황 베이지 - 이름
      AppColors.beigBlue, // 파랑 베이지 - 학년
      AppColors.beigGreen, // 녹색 베이지 - 완료
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
            OnboardingProgressBar(
              currentPage: _currentPage,
              totalPages: _totalPages,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Page 1: 이름 (필수)
                  OnboardingPageWrapper(
                    question: '👋 이름을 알려주세요',
                    subtitle: '실명 또는 닉네임을 입력하세요',
                    showBackButton: _currentPage > 0,
                    onBack: _previousPage,
                    canProceed: _canProceed(),
                    onContinue: () {
                      AppLogger.info('Button tapped: page=$_currentPage',
                          tag: 'OnboardingProfileSetup');
                      if (_currentPage == _totalPages - 1) {
                        _saveProfile();
                      } else {
                        _nextPage();
                      }
                    },
                    isLastPage: false,
                    isLoading: _isLoading,
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

                  // Page 2: 학년 (필수)
                  OnboardingPageWrapper(
                    question: '🎓 현재 학년을\n알려주세요',
                    subtitle: '적절한 난이도의 문제를 제공해드려요',
                    showBackButton: _currentPage > 0,
                    onBack: _previousPage,
                    canProceed: _canProceed(),
                    onContinue: () {
                      AppLogger.info('Button tapped: page=$_currentPage',
                          tag: 'OnboardingProfileSetup');
                      if (_currentPage == _totalPages - 1) {
                        _saveProfile();
                      } else {
                        _nextPage();
                      }
                    },
                    isLastPage: false,
                    isLoading: _isLoading,
                    content: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        GradeSelectionCard(
                          title: '초등학생',
                          icon: '🎒',
                          grades: ['초1', '초2', '초3', '초4', '초5', '초6'],
                          color: AppColors.mathGreen,
                          selectedGrade: _selectedGrade,
                          onGradeSelected: (grade) {
                            setState(() => _selectedGrade = grade);
                            Future.delayed(const Duration(milliseconds: 200), _nextPage);
                          },
                        ),
                        GradeSelectionCard(
                          title: '중학생',
                          icon: '📚',
                          grades: ['중1', '중2', '중3'],
                          color: AppColors.mathBlue,
                          selectedGrade: _selectedGrade,
                          onGradeSelected: (grade) {
                            setState(() => _selectedGrade = grade);
                            Future.delayed(const Duration(milliseconds: 200), _nextPage);
                          },
                        ),
                        GradeSelectionCard(
                          title: '고등학생',
                          icon: '🎓',
                          grades: ['고1', '고2', '고3'],
                          color: AppColors.mathOrange,
                          selectedGrade: _selectedGrade,
                          onGradeSelected: (grade) {
                            setState(() => _selectedGrade = grade);
                            Future.delayed(const Duration(milliseconds: 200), _nextPage);
                          },
                        ),
                        GradeSelectionCard(
                          title: '성인',
                          icon: '📖',
                          grades: ['대학생', '성인'],
                          color: AppColors.mathPurple,
                          selectedGrade: _selectedGrade,
                          onGradeSelected: (grade) {
                            setState(() => _selectedGrade = grade);
                            Future.delayed(const Duration(milliseconds: 200), _nextPage);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Page 3: 완료 (확인 페이지)
                  OnboardingPageWrapper(
                    question: '🎉 준비 완료!',
                    subtitle: '${_nameController.text.trim()}님, 환영합니다!\n지금 바로 학습을 시작해보세요.',
                    showBackButton: _currentPage > 0,
                    onBack: _previousPage,
                    canProceed: _canProceed(),
                    onContinue: () {
                      AppLogger.info('Button tapped: page=$_currentPage',
                          tag: 'OnboardingProfileSetup');
                      _saveProfile();
                    },
                    isLastPage: true,
                    isLoading: _isLoading,
                    content: Column(
                      children: [
                        // 프로필 요약 카드
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.mathGreen, width: 2),
                          ),
                          child: Row(
                            children: [
                              // 이름
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('👤', style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('이름', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                          Text(
                                            _nameController.text.trim(),
                                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 36, color: AppColors.borderLight),
                              // 학년
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🎓', style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('학년', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                        Text(_selectedGrade, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 안내 텍스트
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.beigOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '나머지 정보는 프로필에서 언제든지 추가할 수 있어요',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
