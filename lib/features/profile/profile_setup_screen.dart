import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/widgets/buttons/unified_button.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/logger.dart';

/// 프로필 설정 화면
///
/// 온보딩 과정에서 사용자의 기본 정보를 입력받는 화면
/// Google 로그인 후 처음 로그인하는 사용자에게 표시됨
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  String _selectedGrade = '중1'; // 기본값
  bool _isLoading = false;

  // 학년 옵션
  final List<String> _gradeOptions = [
    '초1',
    '초2',
    '초3',
    '초4',
    '초5',
    '초6',
    '중1',
    '중2',
    '중3',
    '고1',
    '고2',
    '고3',
    '대학생',
    '성인'
  ];

  // 성별 옵션
  final List<Map<String, String>> _genderOptions = [
    {'value': 'male', 'label': '남성'},
    {'value': 'female', 'label': '여성'},
    {'value': 'other', 'label': '기타'},
    {'value': 'prefer_not_to_say', 'label': '비공개'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final user = ref.read(userProvider);
    if (user != null) {
      _nameController.text = user.name;
      _selectedBirthDate = user.birthDate;
      _selectedGender = user.gender;
      _selectedGrade = user.currentGrade;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      _schoolController.text = user.schoolName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final currentDate = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(currentDate.year - 15);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mathBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }

  int? _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(userProvider);
      if (currentUser == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      // 업데이트된 사용자 정보 생성
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        schoolName: _schoolController.text.trim().isNotEmpty
            ? _schoolController.text.trim()
            : null,
        currentGrade: _selectedGrade,
        isProfileComplete: true,
        updatedAt: DateTime.now(),
      );

      // UserProvider를 통해 프로필 업데이트
      await ref.read(userProvider.notifier).updateProfile(updatedUser);

      Logger.info('프로필 설정 완료', tag: 'ProfileSetupScreen');

      if (mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 성공적으로 저장되었습니다!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        // 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      Logger.error('프로필 저장 실패', error: e, tag: 'ProfileSetupScreen');

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.mathBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mathBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '프로필 설정',
              actions: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // 건너뛰기 - 최소 정보로 진행
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                  child: Text(
                    '건너뛰기',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀 섹션
                      Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '프로필을 완성해주세요',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '맞춤형 학습 경험을 제공하기 위해 필요한 정보입니다',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 이름 (필수)
                      _buildTextField(
                        controller: _nameController,
                        label: '이름 (필수)',
                        hint: '실명 또는 닉네임을 입력하세요',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          if (value.trim().length < 2) {
                            return '이름은 2자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),

                      // 생년월일 선택
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: _selectBirthDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: '생년월일',
                              prefixIcon: const Icon(
                                Icons.cake,
                                color: AppColors.mathBlue,
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.borderLight),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Text(
                              _selectedBirthDate != null
                                  ? '${_formatDate(_selectedBirthDate!)} (만 ${_calculateAge(_selectedBirthDate!)}세)'
                                  : '생년월일을 선택하세요',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: _selectedBirthDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 성별 선택
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.wc,
                                    size: 20,
                                    color: AppColors.mathBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '성별',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _genderOptions.map((option) {
                                final isSelected =
                                    _selectedGender == option['value'];
                                return ChoiceChip(
                                  label: Text(option['label']!),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedGender =
                                          selected ? option['value'] : null;
                                    });
                                  },
                                  selectedColor: AppColors.mathBlue,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.mathBlue
                                        : AppColors.borderLight,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // 학년 선택
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: _selectedGrade,
                          decoration: InputDecoration(
                            labelText: '학년',
                            prefixIcon: const Icon(
                              Icons.school,
                              color: AppColors.mathBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.borderLight),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _gradeOptions.map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGrade = value ?? '중1';
                            });
                          },
                        ),
                      ),

                      // 학교명 (선택)
                      _buildTextField(
                        controller: _schoolController,
                        label: '학교명 (선택)',
                        hint: '재학 중인 학교를 입력하세요',
                        icon: Icons.business,
                      ),

                      // 전화번호 (선택)
                      _buildTextField(
                        controller: _phoneController,
                        label: '전화번호 (선택)',
                        hint: '010-0000-0000',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                          LengthLimitingTextInputFormatter(13),
                        ],
                      ),

                      // 자기소개 (선택)
                      _buildTextField(
                        controller: _bioController,
                        label: '자기소개 (선택)',
                        hint: '간단한 자기소개를 작성해주세요',
                        icon: Icons.edit_note,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // 저장 버튼
                      UnifiedButton(
                        text: _isLoading ? '저장 중...' : '프로필 저장',
                        onPressed: _isLoading ? null : _saveProfile,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
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
