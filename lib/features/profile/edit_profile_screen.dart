import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/app_logger.dart';
import '../../shared/constants/constants.dart';
import '../../data/providers/user/user_provider.dart';

/// 프로필 편집 화면
/// - 프로필 사진 변경
/// - 닉네임 변경
/// - 일일 학습 목표 설정
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;
  int _dailyGoalMinutes = 10;

  static const List<int> _goalOptions = [5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _dailyGoalMinutes = user?.dailyGoalMinutes ?? 10;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필 편집'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: Text(
              '저장',
              style: AppTextStyles.bodyLarge.copyWith(
                color: _isLoading ? AppColors.textTertiary : AppColors.mathBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 사진
              _buildProfilePhoto(user),
              const SizedBox(height: AppDimensions.paddingXLarge),

              // 닉네임 입력
              _buildNameField(),
              const SizedBox(height: AppDimensions.paddingLarge),

              // 이메일 표시 (변경 불가)
              if (user?.email != null) ...[
                _buildReadOnlyField(
                  label: '이메일',
                  value: user!.email!,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
              ],

              // 일일 학습 목표
              _buildDailyGoalSelector(),
              const SizedBox(height: AppDimensions.paddingXLarge),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mathBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '저장하기',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto(dynamic user) {
    return GestureDetector(
      onTap: _handlePhotoChange,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mathBlue.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.mathBlue.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: user?.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.mathBlue,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.mathBlue,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mathBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: '닉네임',
        hintText: '닉네임을 입력해주세요',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.mathBlue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '닉네임을 입력해주세요';
        }
        if (value.trim().length < 2) {
          return '닉네임은 2글자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        filled: true,
        fillColor: AppColors.backgroundLight,
      ),
    );
  }

  Widget _buildDailyGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일일 학습 목표',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: _goalOptions.map((minutes) {
            final isSelected = minutes == _dailyGoalMinutes;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _dailyGoalMinutes = minutes);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mathBlue
                          : AppColors.backgroundLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.mathBlue
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$minutes',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '분',
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handlePhotoChange() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.mathBlue),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.mathBlue),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      final user = ref.read(userProvider);
      if (user == null) return;

      // Firebase Storage에 업로드
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await storageRef.getDownloadURL();

      // 사용자 프로필 업데이트
      await ref.read(userProvider.notifier).updateProfile(
            photoUrl: downloadUrl,
          );

      AppLogger.info('Profile photo updated', tag: 'Profile');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진이 변경되었습니다.')),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to upload profile photo', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진 변경에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userProvider.notifier).updateProfile(
            displayName: _nameController.text.trim(),
          );

      await ref.read(userProvider.notifier).updateSettings(
            dailyGoalMinutes: _dailyGoalMinutes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
