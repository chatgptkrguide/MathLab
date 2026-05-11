// Edit profile nickname input card with clear button and validator
import 'package:flutter/material.dart';

import '../../../shared/constants/constants.dart';

class EditProfileNicknameCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FormFieldValidator<String>? validator;

  const EditProfileNicknameCard({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.mathBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.badge_outlined,
                      size: 18, color: AppColors.mathBlue),
                ),
                const SizedBox(width: 10),
                const Text(
                  '닉네임',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.mathBlue, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.mathRed),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: onClear,
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textTertiary),
                      )
                    : null,
              ),
              validator: validator,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
