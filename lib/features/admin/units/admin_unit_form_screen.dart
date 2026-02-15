import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/lesson/unit_model.dart';
import '../../../data/providers/admin/admin_unit_provider.dart';

class AdminUnitFormScreen extends ConsumerStatefulWidget {
  final UnitModel? unit;

  const AdminUnitFormScreen({super.key, this.unit});

  @override
  ConsumerState<AdminUnitFormScreen> createState() =>
      _AdminUnitFormScreenState();
}

class _AdminUnitFormScreenState extends ConsumerState<AdminUnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _emojiController;
  late final TextEditingController _orderController;
  late UnitTheme _selectedTheme;
  bool _saving = false;

  bool get _isEditing => widget.unit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.unit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.unit?.description ?? '');
    _emojiController = TextEditingController(text: widget.unit?.emoji ?? '📐');
    _orderController =
        TextEditingController(text: '${widget.unit?.order ?? 0}');
    _selectedTheme = widget.unit?.theme ?? UnitTheme.blue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emojiController.dispose();
    _orderController.dispose();
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
              title: _isEditing ? '유닛 수정' : '새 유닛',
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
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Emoji
                      const Text('이모지',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emojiController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          hintText: '📐',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? '이모지를 입력하세요' : null,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text('제목',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          hintText: '유닛 제목',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? '제목을 입력하세요' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      const Text('설명',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          hintText: '유닛 설명',
                        ),
                        maxLines: 2,
                        validator: (v) =>
                            v?.isEmpty ?? true ? '설명을 입력하세요' : null,
                      ),
                      const SizedBox(height: 16),

                      // Order
                      const Text('순서',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _orderController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v?.isEmpty ?? true) return '순서를 입력하세요';
                          if (int.tryParse(v!) == null) return '숫자를 입력하세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Theme
                      const Text('테마',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<UnitTheme>(
                        initialValue: _selectedTheme,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: UnitTheme.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.name),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedTheme = v);
                        },
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mathGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(_isEditing ? '수정하기' : '생성하기',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final unit = UnitModel(
      id: widget.unit?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      emoji: _emojiController.text.trim(),
      order: int.parse(_orderController.text.trim()),
      theme: _selectedTheme,
    );

    try {
      final notifier = ref.read(adminUnitNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateUnit(widget.unit!.id, unit);
      } else {
        await notifier.createUnit(unit);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(_isEditing ? '유닛이 수정되었습니다' : '유닛이 생성되었습니다')),
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
