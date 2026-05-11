import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/providers/admin/admin_achievement_provider.dart';
import 'widgets/achievement_basic_info_section.dart';
import 'widgets/achievement_criteria_section.dart';
import 'widgets/achievement_icon_image_section.dart';
import 'widgets/achievement_meta_section.dart';
import 'widgets/achievement_rewards_section.dart';
import 'widgets/achievement_save_button.dart';

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
  XFile? _newIconFile;
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
      _existingIconUrl = a.iconUrl.isNotEmpty ? a.iconUrl : null;
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
              gradientColors: AppColors.adminGradient,
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
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + description
                      AchievementBasicInfoSection(
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Category & Rarity
                      AchievementMetaSection(
                        selectedCategory: _selectedCategory,
                        selectedRarity: _selectedRarity,
                        onCategoryChanged: (v) {
                          setState(() {
                            _selectedCategory = v;
                          });
                        },
                        onRarityChanged: (v) {
                          setState(() {
                            _selectedRarity = v;
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Icon image section
                      Text('아이콘 이미지', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppDimensions.spacing8),
                      AchievementIconImageSection(
                        existingIconUrl: _existingIconUrl,
                        newIconFile: _newIconFile,
                        iconDeleted: _iconDeleted,
                        onRemove: () {
                          setState(() {
                            if (_newIconFile != null) {
                              _newIconFile = null;
                            } else {
                              _iconDeleted = true;
                            }
                          });
                        },
                        onPickImage: _pickIconImage,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Criteria
                      AchievementCriteriaSection(
                        selectedCriteriaType: _selectedCriteriaType,
                        onCriteriaTypeChanged: (v) {
                          setState(() {
                            _selectedCriteriaType = v;
                          });
                        },
                        targetValueController: _targetValueController,
                        specificRequirementController:
                            _specificRequirementController,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Rewards
                      AchievementRewardsSection(
                        xpRewardController: _xpRewardController,
                        gemsRewardController: _gemsRewardController,
                      ),
                      const SizedBox(height: AppDimensions.spacing32),

                      // Save button
                      AchievementSaveButton(
                        isSaving: _isSaving,
                        isEditing: _isEditing,
                        onPressed: _save,
                      ),
                      const SizedBox(height: AppDimensions.spacing40),
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

  Future<void> _pickIconImage(ImageSource source) async {
    final imageService = ref.read(adminImageServiceProvider);
    final xFile = await imageService.pickXFile(source: source);
    if (xFile != null) {
      setState(() {
        _newIconFile = xFile;
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
          iconUrl = await imageService.uploadXFile(
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
          try {
            iconUrl = await imageService.uploadXFile(
                'achievements/$docId', _newIconFile!);
            // Update the achievement with the icon URL
            final updatedAchievement = _buildAchievementModel(iconUrl);
            await notifier.updateAchievement(docId, updatedAchievement);
          } catch (uploadError) {
            // Achievement created but image upload failed - notify user
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('업적은 생성되었으나 이미지 업로드에 실패했습니다')),
              );
              Navigator.pop(context, true);
            }
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '업적이 수정되었습니다' : '업적이 생성되었습니다'),
          ),
        );
        Navigator.pop(context, true);
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
}
