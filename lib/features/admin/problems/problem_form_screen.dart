import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/problem/problem_model.dart';
import '../../../data/providers/admin/admin_problem_provider.dart';
import '../../../data/providers/curriculum/curriculum_provider.dart';
import '../widgets/admin_image_picker_section.dart';
import 'widgets/problem_form_basic_section.dart';
import 'widgets/problem_form_hints_section.dart';
import 'widgets/problem_form_options_section.dart';
import 'widgets/problem_form_save_button.dart';

class AdminProblemFormScreen extends ConsumerStatefulWidget {
  final ProblemModel? problem;

  const AdminProblemFormScreen({super.key, this.problem});

  @override
  ConsumerState<AdminProblemFormScreen> createState() =>
      _AdminProblemFormScreenState();
}

class _AdminProblemFormScreenState
    extends ConsumerState<AdminProblemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _questionController;
  late final TextEditingController _correctAnswerController;
  late final TextEditingController _explanationController;
  late final TextEditingController _pointsController;

  String? _selectedLessonId;
  ProblemType _selectedType = ProblemType.multipleChoice;
  ProblemDifficulty _selectedDifficulty = ProblemDifficulty.easy;

  // Options for multiple choice
  List<TextEditingController> _optionControllers = [];

  // Hints
  List<TextEditingController> _hintControllers = [];

  // Images
  List<String> _existingImageUrls = [];
  final List<XFile> _newImageFiles = [];
  final List<String> _deletedImageUrls = [];

  bool _isSaving = false;
  bool _showLatexPreview = false;

  bool get _isEditing => widget.problem != null;

  @override
  void initState() {
    super.initState();
    final p = widget.problem;

    _questionController = TextEditingController(text: p?.question ?? '');
    _correctAnswerController =
        TextEditingController(text: p?.correctAnswer ?? '');
    _explanationController =
        TextEditingController(text: p?.explanation ?? '');
    _pointsController =
        TextEditingController(text: '${p?.points ?? 10}');

    if (p != null) {
      _selectedLessonId = p.lessonId;
      _selectedType = p.type;
      _selectedDifficulty = p.difficulty;
      _existingImageUrls = List.from(p.allImages);

      _optionControllers =
          p.options.map((o) => TextEditingController(text: o)).toList();
      _hintControllers =
          p.allHints.map((h) => TextEditingController(text: h)).toList();
    }

    // Ensure at least 4 options for multipleChoice
    if (_selectedType == ProblemType.multipleChoice) {
      while (_optionControllers.length < 4) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _correctAnswerController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    for (final c in _hintControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curriculumAsync = ref.watch(curriculumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: _isEditing ? '문제 수정' : '새 문제',
              gradientColors: AppColors.headerBlueGradient,
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
                      ProblemFormBasicSection(
                        lessonSelector: curriculumAsync.when(
                          data: (units) => ProblemFormLessonSelector(
                            units: units,
                            selectedLessonId: _selectedLessonId,
                            onChanged: (v) =>
                                setState(() => _selectedLessonId = v),
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text('커리큘럼 로드 실패'),
                        ),
                        questionController: _questionController,
                        showLatexPreview: _showLatexPreview,
                        onToggleLatexPreview: () => setState(() {
                          _showLatexPreview = !_showLatexPreview;
                        }),
                        onQuestionChanged: (_) {
                          if (_showLatexPreview) setState(() {});
                        },
                        selectedType: _selectedType,
                        onTypeChanged: (v) {
                          setState(() {
                            _selectedType = v;
                            if (v == ProblemType.multipleChoice) {
                              while (_optionControllers.length < 4) {
                                _optionControllers
                                    .add(TextEditingController());
                              }
                            }
                          });
                        },
                        selectedDifficulty: _selectedDifficulty,
                        onDifficultyChanged: (v) =>
                            setState(() => _selectedDifficulty = v),
                        pointsController: _pointsController,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Options (for multipleChoice)
                      if (_selectedType == ProblemType.multipleChoice)
                        ProblemFormOptionsSection(
                          optionControllers: _optionControllers,
                          onAdd: () => setState(() {
                            _optionControllers.add(TextEditingController());
                          }),
                          onRemove: (index) => setState(() {
                            _optionControllers[index].dispose();
                            _optionControllers.removeAt(index);
                          }),
                        ),

                      // Correct answer + Explanation
                      ProblemFormAnswerSection(
                        correctAnswerController: _correctAnswerController,
                        explanationController: _explanationController,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Hints
                      ProblemFormHintsSection(
                        hintControllers: _hintControllers,
                        onAdd: () => setState(() {
                          _hintControllers.add(TextEditingController());
                        }),
                        onRemove: (index) => setState(() {
                          _hintControllers[index].dispose();
                          _hintControllers.removeAt(index);
                        }),
                      ),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Images
                      AdminImagePickerSection(
                        existingUrls: _existingImageUrls,
                        newFiles: _newImageFiles,
                        deletedUrls: _deletedImageUrls,
                        onPickFromGallery: () => _pickImage(ImageSource.gallery),
                        onPickFromCamera: () => _pickImage(ImageSource.camera),
                        onRemoveExisting: (url) {
                          setState(() {
                            _deletedImageUrls.add(url);
                          });
                        },
                        onRemoveNew: (index) {
                          setState(() {
                            _newImageFiles.removeAt(index);
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing32),

                      // Save button
                      ProblemFormSaveButton(
                        isSaving: _isSaving,
                        isEditing: _isEditing,
                        onSave: _save,
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

  Future<void> _pickImage(ImageSource source) async {
    final imageService = ref.read(problemImageServiceProvider);
    final xFile = await imageService.pickXFile(source: source);
    if (xFile != null) {
      setState(() {
        _newImageFiles.add(xFile);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(adminProblemNotifierProvider.notifier);
      final imageService = ref.read(problemImageServiceProvider);

      // Build options list
      final options = _optionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Build hints list
      final hints = _hintControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Delete removed images
      for (final url in _deletedImageUrls) {
        await imageService.deleteImage(url);
      }

      // Determine the problem ID for image upload
      final String problemId;
      if (_isEditing) {
        problemId = widget.problem!.id;
      } else {
        // Create Firestore document first (without images) to get the real docId
        final tempProblem = ProblemModel(
          id: '',
          lessonId: _selectedLessonId!,
          question: _questionController.text.trim(),
          type: _selectedType,
          difficulty: _selectedDifficulty,
          options: options,
          correctAnswer: _correctAnswerController.text.trim(),
          explanation: _explanationController.text.trim().isEmpty
              ? null
              : _explanationController.text.trim(),
          hints: hints,
          points: int.tryParse(_pointsController.text) ?? 10,
        );
        problemId = await notifier.createProblem(tempProblem);
      }

      // Upload new images with the correct problemId
      final newImageUrls = <String>[];
      for (final xFile in _newImageFiles) {
        final url = await imageService.uploadXFile(problemId, xFile);
        newImageUrls.add(url);
      }

      // Build final imageUrls list
      final finalImageUrls = [
        ..._existingImageUrls.where((u) => !_deletedImageUrls.contains(u)),
        ...newImageUrls,
      ];

      final problem = ProblemModel(
        id: problemId,
        lessonId: _selectedLessonId!,
        question: _questionController.text.trim(),
        type: _selectedType,
        difficulty: _selectedDifficulty,
        options: options,
        correctAnswer: _correctAnswerController.text.trim(),
        explanation: _explanationController.text.trim().isEmpty
            ? null
            : _explanationController.text.trim(),
        hints: hints,
        points: int.tryParse(_pointsController.text) ?? 10,
        imageUrls: finalImageUrls,
      );

      if (_isEditing) {
        await notifier.updateProblem(problemId, problem);
      } else if (newImageUrls.isNotEmpty) {
        // New problem with images: update with image URLs
        await notifier.updateProblem(problemId, problem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '문제가 수정되었습니다' : '문제가 생성되었습니다'),
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
}
