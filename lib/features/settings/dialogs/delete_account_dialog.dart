import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../data/providers/auth/auth_provider.dart';

/// 계정 탈퇴 확인 다이얼로그
class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _confirmController = TextEditingController();
  bool _isDeleteEnabled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: Row(
        children: [
          Icon(Icons.delete_forever, color: AppColors.mathRed, size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '계정 탈퇴',
              style: AppTextStyles.headlineSmall,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.mathRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.mathRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '계정을 삭제하면:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- 모든 학습 데이터가 삭제됩니다\n'
                    '- XP, 레벨, 스트릭이 초기화됩니다\n'
                    '- 업적 및 뱃지가 삭제됩니다\n'
                    '- 이 작업은 되돌릴 수 없습니다',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              '확인을 위해 "삭제"를 입력해주세요.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(
                hintText: '삭제',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isDeleteEnabled = value.trim() == '삭제';
                });
              },
            ),
          ],
        ),
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
        ElevatedButton(
          onPressed: _isDeleteEnabled && !_isLoading
              ? _handleDeleteAccount
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mathRed,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.mathRed.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('계정 삭제'),
        ),
      ],
    );
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).deleteAccount();

      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정이 삭제되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정 삭제에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정 삭제 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
