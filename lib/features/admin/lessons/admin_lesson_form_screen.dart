import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/lesson/lesson_model.dart';
import '../../../data/providers/admin/admin_lesson_provider.dart';

class AdminLessonFormScreen extends ConsumerStatefulWidget {
  final String unitId;
  final LessonModel? lesson;

  const AdminLessonFormScreen({
    super.key,
    required this.unitId,
    this.lesson,
  });

  @override
  ConsumerState<AdminLessonFormScreen> createState() =>
      _AdminLessonFormScreenState();
}

class _AdminLessonFormScreenState
    extends ConsumerState<AdminLessonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _orderController;
  late final TextEditingController _xpRewardController;
  late final TextEditingController _estimatedMinutesController;
  late final TextEditingController _conceptInputController;
  late LessonType _selectedType;
  late LessonDifficulty _selectedDifficulty;
  late List<String> _concepts;
  bool _saving = false;

  bool get _isEditing => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.lesson?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.lesson?.description ?? '');
    _orderController =
        TextEditingController(text: '${widget.lesson?.order ?? 0}');
    _xpRewardController =
        TextEditingController(text: '${widget.lesson?.xpReward ?? 10}');
    _estimatedMinutesController =
        TextEditingController(text: '${widget.lesson?.estimatedMinutes ?? 5}');
    _conceptInputController = TextEditingController();
    _selectedType = widget.lesson?.type ?? LessonType.standard;
    _selectedDifficulty =
        widget.lesson?.difficulty ?? LessonDifficulty.beginner;
    _concepts = List<String>.from(widget.lesson?.concepts ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    _xpRewardController.dispose();
    _estimatedMinutesController.dispose();
    _conceptInputController.dispose();
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
              title: _isEditing ? '레슨 수정' : '새 레슨',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      _label('제목'),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('레슨 제목'),
                        validator: (v) =>
                            v?.isEmpty ?? true ? '제목을 입력하세요' : null,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Description
                      _label('설명'),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('레슨 설명'),
                        maxLines: 2,
                        validator: (v) =>
                            v?.isEmpty ?? true ? '설명을 입력하세요' : null,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Type + Difficulty row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('유형'),
                                DropdownButtonFormField<LessonType>(
                                  initialValue: _selectedType,
                                  decoration: _inputDecoration(null),
                                  items: LessonType.values.map((t) {
                                    return DropdownMenuItem(
                                      value: t,
                                      child: Text(_typeLabel(t)),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedType = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('난이도'),
                                DropdownButtonFormField<LessonDifficulty>(
                                  initialValue: _selectedDifficulty,
                                  decoration: _inputDecoration(null),
                                  items: LessonDifficulty.values.map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(_difficultyLabel(d)),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedDifficulty = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Order + XP + Minutes row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('순서'),
                                TextFormField(
                                  controller: _orderController,
                                  decoration: _inputDecoration('0'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return '필수';
                                    if (int.tryParse(v!) == null) return '숫자';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('XP 보상'),
                                TextFormField(
                                  controller: _xpRewardController,
                                  decoration: _inputDecoration('10'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return '필수';
                                    if (int.tryParse(v!) == null) return '숫자';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('예상 시간(분)'),
                                TextFormField(
                                  controller: _estimatedMinutesController,
                                  decoration: _inputDecoration('5'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return '필수';
                                    if (int.tryParse(v!) == null) return '숫자';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Concepts
                      _label('개념 태그'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _conceptInputController,
                              decoration:
                                  _inputDecoration('개념 입력 후 추가'),
                              onFieldSubmitted: (_) => _addConcept(),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.mathGreen,
                            onPressed: _addConcept,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _concepts.map((c) {
                          return Chip(
                            label: Text(c, style: AppTextStyles.bodySmall),
                            deleteIcon: const Icon(Icons.close, size: AppDimensions.spacing16),
                            onDeleted: () {
                              setState(() => _concepts.remove(c));
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.spacing32),

                      // Save button
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mathGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: AppDimensions.spacing20,
                                width: AppDimensions.spacing20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(_isEditing ? '수정하기' : '생성하기',
                                style: AppTextStyles.titleMedium),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: AppTextStyles.titleSmall),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: 10),
      hintText: hint,
    );
  }

  void _addConcept() {
    final text = _conceptInputController.text.trim();
    if (text.isNotEmpty && !_concepts.contains(text)) {
      setState(() {
        _concepts.add(text);
        _conceptInputController.clear();
      });
    }
  }

  String _typeLabel(LessonType type) {
    switch (type) {
      case LessonType.standard:
        return '표준';
      case LessonType.story:
        return '스토리';
      case LessonType.practice:
        return '연습';
      case LessonType.review:
        return '복습';
      case LessonType.challenge:
        return '챌린지';
      case LessonType.boss:
        return '보스';
    }
  }

  String _difficultyLabel(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.beginner:
        return '초급';
      case LessonDifficulty.intermediate:
        return '중급';
      case LessonDifficulty.advanced:
        return '고급';
      case LessonDifficulty.expert:
        return '전문가';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final lesson = LessonModel(
      id: widget.lesson?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      order: int.tryParse(_orderController.text.trim()) ?? 0,
      xpReward: int.tryParse(_xpRewardController.text.trim()) ?? 10,
      type: _selectedType,
      difficulty: _selectedDifficulty,
      concepts: _concepts,
      estimatedMinutes: int.tryParse(_estimatedMinutesController.text.trim()) ?? 5,
    );

    try {
      final notifier = ref.read(adminLessonNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateLesson(
            widget.unitId, widget.lesson!.id, lesson);
      } else {
        await notifier.createLesson(widget.unitId, lesson);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(_isEditing ? '레슨이 수정되었습니다' : '레슨이 생성되었습니다')),
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
      if (mounted) setState(() => _saving = false);
    }
  }
}
