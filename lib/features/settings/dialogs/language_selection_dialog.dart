import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

/// 언어 선택 다이얼로그
class LanguageSelectionDialog extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelectionDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  static const List<_LanguageOption> _languages = [
    _LanguageOption(name: '한국어', code: 'ko', flag: '🇰🇷'),
    _LanguageOption(name: 'English', code: 'en', flag: '🇺🇸'),
    _LanguageOption(name: '日本語', code: 'ja', flag: '🇯🇵'),
    _LanguageOption(name: '中文', code: 'zh', flag: '🇨🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Text(
        '언어 선택',
        style: AppTextStyles.headlineSmall,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _languages.map((language) {
          final isSelected = language.name == currentLanguage;
          return ListTile(
            leading: Text(
              language.flag,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              language.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.mathBlue : AppColors.textPrimary,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.mathBlue,
                  )
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            selectedTileColor: AppColors.mathBlue.withValues(alpha: 0.05),
            selected: isSelected,
            onTap: () {
              onLanguageChanged(language.name);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption {
  final String name;
  final String code;
  final String flag;

  const _LanguageOption({
    required this.name,
    required this.code,
    required this.flag,
  });
}
