import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/providers/admin/admin_achievement_provider.dart';

/// Admin gradient colors (purple)
const _adminGradient = [Color(0xFF9C27B0), Color(0xFF7B1FA2)];

class AdminAchievementFormScreen extends ConsumerStatefulWidget {
  final AchievementModel? achievement;

  const AdminAchievementFormScreen({super.key, this.achievement});

  @override
  ConsumerState<AdminAchievementFormScreen> createState() =>
      _AdminAchievementFormScreenState();
}

class _AdminAchievementFormScreenState
    extends ConsumerState<AdminAchievementFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _iconUrlController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _specificRequirementController;
  late final TextEditingController _xpRewardController;
  late final TextEditingController _gemsRewardController;

  AchievementCategory _selectedCategory = AchievementCategory.general;
  AchievementRarity _selectedRarity = AchievementRarity.common;
  AchievementType _selectedCriteriaType = AchievementType.totalXP;

  // Image handling
  String? _existingIconUrl;
  File? _newIconFile;
  bool _iconDeleted = false;

  bool _isSaving = false;

  bool get _isEditing => widget.achievement != null;

  @override
  void initState() {
    super.initState();
    final a = widget.achievement;

    _nameController = TextEditingController(text: a?.name ?? '');
    _descriptionController = TextEditingController(text: a?.description ?? '');
    _iconUrlController = TextEditingController(text: a?.iconUrl ?? '');
    _targetValueController =
        TextEditingController(text: '${a?.criteria.targetValue ?? 1}');
    _specificRequirementController =
        TextEditingController(text: a?.criteria.specificRequirement ?? '');
    _xpRewardController =
        TextEditingController(text: '${a?.rewards['xp'] ?? 0}');
    _gemsRewardController =
        TextEditingController(text: '${a?.rewards['gems'] ?? 0}');

    if (a != null) {
      _selectedCategory = a.category;
      _selectedRarity = a.rarity;
      _selectedCriteriaType = a.criteria.type;
      _existingIconUrl =
          a.iconUrl.isNotEmpty ? a.iconUrl : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconUrlController.dispose();
    _targetValueController.dispose();
    _specificRequirementController.dispose();
    _xpRewardController.dispose();
    _gemsRewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: _isEditing ? '업적 수정' : '새 업적',
              gradientColors: _adminGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.headerText, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildSectionLabel('업적 이름'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '예: 첫 걸음',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? '이름을 입력하세요' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildSectionLabel('설명'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: '예: 첫 번째 레슨을 완료하세요',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? '설명을 입력하세요' : null,
                      ),
                      const SizedBox(height: 16),

                      // Category & Rarity
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('카테고리'),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<AchievementCategory>(
                                  initialValue: _selectedCategory,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: AchievementCategory.values
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              _categoryLabel(c),
                                              style: const TextStyle(
                                                  fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        _selectedCategory = v;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('희귀도'),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<AchievementRarity>(
                                  initialValue: _selectedRarity,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: AchievementRarity.values
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(
                                              _rarityLabel(r),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    Color(_rarityColor(r)),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        _selectedRarity = v;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Icon image section
                      _buildSectionLabel('아이콘 이미지'),
                      const SizedBox(height: 8),
                      _buildIconImageSection(),
                      const SizedBox(height: 16),

                      // Criteria section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '달성 조건',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Criteria type
                            _buildSectionLabel('조건 유형'),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<AchievementType>(
                              initialValue: _selectedCriteriaType,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              items: AchievementType.values
                                  .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(
                                          _criteriaTypeLabel(t),
                                          style:
                                              const TextStyle(fontSize: 14),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _selectedCriteriaType = v;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),

                            // Target value
                            _buildSectionLabel('목표 값'),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _targetValueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '예: 100',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return '목표 값을 입력하세요';
                                }
                                if (int.tryParse(v) == null) {
                                  return '숫자를 입력하세요';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Specific requirement (optional)
                            _buildSectionLabel('특수 조건 (선택)'),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _specificRequirementController,
                              decoration: const InputDecoration(
                                hintText: '예: algebra_unit',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rewards section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '보상',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionLabel('XP 보상'),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _xpRewardController,
                                        keyboardType:
                                            TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10),
                                        ),
                                        validator: (v) {
                                          if (v != null &&
                                              v.isNotEmpty &&
                                              int.tryParse(v) == null) {
                                            return '숫자를 입력하세요';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionLabel('젬 보상'),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _gemsRewardController,
                                        keyboardType:
                                            TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10),
                                        ),
                                        validator: (v) {
                                          if (v != null &&
                                              v.isNotEmpty &&
                                              int.tryParse(v) == null) {
                                            return '숫자를 입력하세요';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mathGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _isEditing ? '수정하기' : '저장하기',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildIconImageSection() {
    final hasExisting =
        _existingIconUrl != null && !_iconDeleted;
    final hasNewFile = _newIconFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasExisting || hasNewFile)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasNewFile
                      ? Image.file(
                          _newIconFile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _existingIconUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: AppColors.backgroundLight,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.textTertiary),
                          ),
                        ),
                ),
                if (hasNewFile)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mathGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (hasNewFile) {
                          _newIconFile = null;
                        } else {
                          _iconDeleted = true;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.mathRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickIconImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('갤러리'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mathBlue,
                side: const BorderSide(color: AppColors.mathBlue),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _pickIconImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('카메라'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mathBlue,
                side: const BorderSide(color: AppColors.mathBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _pickIconImage(ImageSource source) async {
    final imageService = ref.read(adminImageServiceProvider);
    final file = await imageService.pickImage(source: source);
    if (file != null) {
      setState(() {
        _newIconFile = file;
        _iconDeleted = true; // Mark existing as deleted since we have a new one
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(adminAchievementNotifierProvider.notifier);
      final imageService = ref.read(adminImageServiceProvider);

      // Determine icon URL
      String iconUrl = '';

      if (_isEditing) {
        // Editing existing achievement
        final achievementId = widget.achievement!.id;

        // Upload new icon if picked
        if (_newIconFile != null) {
          // Delete old icon if it existed
          if (_existingIconUrl != null && _existingIconUrl!.isNotEmpty) {
            await imageService.deleteImage(_existingIconUrl!);
          }
          iconUrl = await imageService.uploadImage(
              'achievements/$achievementId', _newIconFile!);
        } else if (_iconDeleted) {
          // Icon was deleted but no new one picked
          if (_existingIconUrl != null && _existingIconUrl!.isNotEmpty) {
            await imageService.deleteImage(_existingIconUrl!);
          }
          iconUrl = '';
        } else {
          // Keep existing icon
          iconUrl = _existingIconUrl ?? '';
        }

        final achievement = _buildAchievementModel(iconUrl);
        await notifier.updateAchievement(achievementId, achievement);
      } else {
        // Creating new achievement
        // First create without image to get the docId
        final tempAchievement = _buildAchievementModel('');
        final docId = await notifier.createAchievement(tempAchievement);

        // Upload icon if picked
        if (_newIconFile != null) {
          iconUrl =
              await imageService.uploadImage('achievements/$docId', _newIconFile!);
          // Update the achievement with the icon URL
          final updatedAchievement = _buildAchievementModel(iconUrl);
          await notifier.updateAchievement(docId, updatedAchievement);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '업적이 수정되었습니다' : '업적이 생성되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  AchievementModel _buildAchievementModel(String iconUrl) {
    final xp = int.tryParse(_xpRewardController.text) ?? 0;
    final gems = int.tryParse(_gemsRewardController.text) ?? 0;
    final specificReq = _specificRequirementController.text.trim().isEmpty
        ? null
        : _specificRequirementController.text.trim();

    return AchievementModel(
      id: _isEditing ? widget.achievement!.id : '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      rarity: _selectedRarity,
      iconUrl: iconUrl,
      criteria: AchievementCriteria(
        type: _selectedCriteriaType,
        targetValue: int.tryParse(_targetValueController.text) ?? 1,
        specificRequirement: specificReq,
      ),
      rewards: {
        'xp': xp,
        'gems': gems,
      },
    );
  }

  String _categoryLabel(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.general:
        return '일반';
      case AchievementCategory.streak:
        return '연속학습';
      case AchievementCategory.mastery:
        return '숙달';
      case AchievementCategory.social:
        return '소셜';
      case AchievementCategory.speed:
        return '속도';
      case AchievementCategory.perfectionist:
        return '완벽주의';
      case AchievementCategory.explorer:
        return '탐험가';
    }
  }

  String _rarityLabel(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.rare:
        return '희귀';
      case AchievementRarity.epic:
        return '영웅';
      case AchievementRarity.legendary:
        return '전설';
    }
  }

  int _rarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 0xFFB0BEC5;
      case AchievementRarity.rare:
        return 0xFF64B5F6;
      case AchievementRarity.epic:
        return 0xFF9C27B0;
      case AchievementRarity.legendary:
        return 0xFFFFB74D;
    }
  }

  String _criteriaTypeLabel(AchievementType type) {
    switch (type) {
      case AchievementType.totalXP:
        return '총 XP';
      case AchievementType.streak:
        return '연속학습 일수';
      case AchievementType.lessonsCompleted:
        return '레슨 완료 수';
      case AchievementType.perfectScore:
        return '만점 횟수';
      case AchievementType.fastSolver:
        return '빠른 풀이 횟수';
      case AchievementType.accuracy:
        return '정확도 (%)';
      case AchievementType.problemsSolved:
        return '문제 풀이 수';
      case AchievementType.leagueRank:
        return '리그 순위';
      case AchievementType.helpfulStudent:
        return '도움 횟수';
    }
  }
}
