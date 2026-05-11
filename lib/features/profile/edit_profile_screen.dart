import 'dart:io' show File;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/app_logger.dart';
import '../../data/providers/user/user_provider.dart';
import 'widgets/edit_profile_email_card.dart';
import 'widgets/edit_profile_goal_card.dart';
import 'widgets/edit_profile_nickname_card.dart';
import 'widgets/edit_profile_photo_header.dart';
import 'widgets/edit_profile_save_button.dart';

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
      backgroundColor: const Color(0xFFF5F6F8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 그라데이션 헤더 + 프로필 사진
            EditProfilePhotoHeader(
              user: user,
              onPickImage: _pickAndUploadImage,
            ),

            // 폼 콘텐츠
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    // 닉네임 카드
                    EditProfileNicknameCard(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      onClear: () {
                        _nameController.clear();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '닉네임을 입력해주세요';
                        }
                        if (value.trim().length < 2) {
                          return '2글자 이상 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 이메일 카드
                    if (user?.email != null) ...[
                      EditProfileEmailCard(email: user!.email!),
                      const SizedBox(height: 14),
                    ],

                    // 학습 목표 카드
                    EditProfileGoalCard(
                      selectedMinutes: _dailyGoalMinutes,
                      onChanged: (minutes) =>
                          setState(() => _dailyGoalMinutes = minutes),
                    ),
                    const SizedBox(height: 28),

                    // 저장 버튼
                    EditProfileSaveButton(
                      isLoading: _isLoading,
                      onSave: _handleSave,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 이미지 업로드
  // ============================================================
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

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        final file = File(pickedFile.path);
        await storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final downloadUrl = await storageRef.getDownloadURL();

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

  // ============================================================
  // 저장
  // ============================================================
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
