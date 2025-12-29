import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 언어 선택 다이얼로그
class LanguageSelectionDialog extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelectionDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageSelectionDialog> createState() => _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('언어 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption('한국어'),
          _buildLanguageOption('English'),
          _buildLanguageOption('日本語'),
          _buildLanguageOption('中文'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        widget.onLanguageChanged(value!);
        Navigator.pop(context);
      },
      title: Text(language),
      activeColor: AppColors.mathBlue,
    );
  }
}
