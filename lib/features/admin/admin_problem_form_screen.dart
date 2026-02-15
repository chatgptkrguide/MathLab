import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/constants.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/models/problem/problem_model.dart';
import '../../data/models/lesson/unit_model.dart';
import '../../data/models/lesson/lesson_model.dart';
import '../../data/providers/admin/admin_problem_provider.dart';
import '../../data/providers/curriculum/curriculum_provider.dart';
import 'widgets/admin_image_picker_section.dart';

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
  final List<File> _newImageFiles = [];
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lesson selector
                      curriculumAsync.when(
                        data: (units) => _buildLessonSelector(units),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('커리큘럼 로드 실패'),
                      ),
                      const SizedBox(height: 16),

                      // Question
                      _buildSectionLabel('질문 (LaTeX 지원)'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _questionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: r'예: $x^2 + 2x + 1 = 0$의 근은?',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showLatexPreview
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.mathBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                _showLatexPreview = !_showLatexPreview;
                              });
                            },
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? '질문을 입력하세요' : null,
                        onChanged: (_) {
                          if (_showLatexPreview) setState(() {});
                        },
                      ),
                      if (_showLatexPreview) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: _buildLatexPreview(_questionController.text),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Type & Difficulty
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('문제 유형'),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<ProblemType>(
                                  initialValue: _selectedType,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: ProblemType.values
                                      .map((t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(_typeLabel(t),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('난이도'),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<ProblemDifficulty>(
                                  initialValue: _selectedDifficulty,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: ProblemDifficulty.values
                                      .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(_difficultyLabel(d),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        _selectedDifficulty = v;
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

                      // Points
                      _buildSectionLabel('포인트'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return '포인트를 입력하세요';
                          if (int.tryParse(v) == null) return '숫자를 입력하세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Options (for multipleChoice)
                      if (_selectedType == ProblemType.multipleChoice) ...[
                        _buildSectionLabel('선택지'),
                        const SizedBox(height: 4),
                        ..._optionControllers.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '${entry.key + 1}.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: entry.value,
                                    decoration: InputDecoration(
                                      hintText: '선택지 ${entry.key + 1}',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ),
                                if (_optionControllers.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        size: 20, color: AppColors.mathRed),
                                    onPressed: () {
                                      setState(() {
                                        _optionControllers[entry.key].dispose();
                                        _optionControllers
                                            .removeAt(entry.key);
                                      });
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.only(left: 4),
                                  ),
                              ],
                            ),
                          );
                        }),
                        if (_optionControllers.length < 6)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _optionControllers
                                    .add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('선택지 추가'),
                          ),
                        const SizedBox(height: 8),
                      ],

                      // Correct answer
                      _buildSectionLabel('정답'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _correctAnswerController,
                        decoration: const InputDecoration(
                          hintText: '정답을 입력하세요',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? '정답을 입력하세요' : null,
                      ),
                      const SizedBox(height: 16),

                      // Explanation
                      _buildSectionLabel('해설 (선택)'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _explanationController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: '문제 해설을 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hints
                      _buildSectionLabel('힌트 (선택)'),
                      const SizedBox(height: 4),
                      ..._hintControllers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    hintText: '힌트 ${entry.key + 1}',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 20, color: AppColors.mathRed),
                                onPressed: () {
                                  setState(() {
                                    _hintControllers[entry.key].dispose();
                                    _hintControllers.removeAt(entry.key);
                                  });
                                },
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.only(left: 4),
                              ),
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _hintControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('힌트 추가'),
                      ),
                      const SizedBox(height: 16),

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

  Widget _buildLessonSelector(List<UnitModel> units) {
    // Flatten all lessons with unit info
    final allLessons = <MapEntry<UnitModel, LessonModel>>[];
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        allLessons.add(MapEntry(unit, lesson));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('레슨'),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _selectedLessonId,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: allLessons
              .map((entry) => DropdownMenuItem(
                    value: entry.value.id,
                    child: Text(
                      '${entry.key.emoji} ${entry.key.title} > ${entry.value.title}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() {
              _selectedLessonId = v;
            });
          },
          validator: (v) => v == null || v.isEmpty ? '레슨을 선택하세요' : null,
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

  Widget _buildLatexPreview(String text) {
    // Simple LaTeX extraction: look for $...$
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\$(.+?)\$');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ));
      }
      // Add LaTeX as widget span
      parts.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          match.group(1)!,
          textStyle: const TextStyle(fontSize: 18),
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      ));
    }

    if (parts.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }

    return RichText(text: TextSpan(children: parts));
  }

  Future<void> _pickImage(ImageSource source) async {
    final imageService = ref.read(problemImageServiceProvider);
    final file = await imageService.pickImage(source: source);
    if (file != null) {
      setState(() {
        _newImageFiles.add(file);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(adminProblemNotifierProvider.notifier);
      final imageService = ref.read(problemImageServiceProvider);

      // Determine the problem ID for image upload
      String problemId;
      if (_isEditing) {
        problemId = widget.problem!.id;
      } else {
        // Create a temporary ID for a new problem - we'll create first then upload
        problemId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Upload new images
      final newImageUrls = <String>[];
      for (final file in _newImageFiles) {
        final url = await imageService.uploadImage(problemId, file);
        newImageUrls.add(url);
      }

      // Delete removed images
      for (final url in _deletedImageUrls) {
        await imageService.deleteImage(url);
      }

      // Build final imageUrls list
      final finalImageUrls = [
        ..._existingImageUrls.where((u) => !_deletedImageUrls.contains(u)),
        ...newImageUrls,
      ];

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

      final problem = ProblemModel(
        id: _isEditing ? widget.problem!.id : '',
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
        await notifier.updateProblem(widget.problem!.id, problem);
      } else {
        final docId = await notifier.createProblem(problem);

        // If we uploaded images with a temp ID, we need to handle it
        // For simplicity, we use the docId after creation
        // Images were already uploaded with the temp ID, let's update with correct URLs if needed
        if (newImageUrls.isNotEmpty) {
          // Re-upload images with correct problemId
          final correctedUrls = <String>[];
          for (final file in _newImageFiles) {
            final url = await imageService.uploadImage(docId, file);
            correctedUrls.add(url);
          }
          // Delete temp images
          for (final url in newImageUrls) {
            await imageService.deleteImage(url);
          }
          // Update the problem with correct URLs
          if (correctedUrls.isNotEmpty) {
            await notifier.updateProblem(
              docId,
              ProblemModel(
                id: docId,
                lessonId: problem.lessonId,
                question: problem.question,
                type: problem.type,
                difficulty: problem.difficulty,
                options: problem.options,
                correctAnswer: problem.correctAnswer,
                explanation: problem.explanation,
                hints: problem.hints,
                points: problem.points,
                imageUrls: correctedUrls,
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '문제가 수정되었습니다' : '문제가 생성되었습니다'),
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

  String _typeLabel(ProblemType type) {
    switch (type) {
      case ProblemType.multipleChoice:
        return '객관식';
      case ProblemType.trueFalse:
        return 'O/X';
      case ProblemType.fillInBlank:
        return '빈칸 채우기';
      case ProblemType.matching:
        return '매칭';
      case ProblemType.dragAndDrop:
        return '드래그 앤 드롭';
    }
  }

  String _difficultyLabel(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return '쉬움';
      case ProblemDifficulty.medium:
        return '보통';
      case ProblemDifficulty.hard:
        return '어려움';
    }
  }
}
