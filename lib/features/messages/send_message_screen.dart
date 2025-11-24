import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/providers/message_provider.dart';
import '../../data/models/models.dart';

/// 메시지 보내기 화면 (질문/문의 작성)
class SendMessageScreen extends ConsumerStatefulWidget {
  const SendMessageScreen({super.key});

  @override
  ConsumerState<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends ConsumerState<SendMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = '일반 문의';
  final List<String> _categories = [
    '일반 문의',
    '학습 관련',
    '기술 지원',
    '계정/결제',
    '제안/피드백',
    '버그 신고',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 통합 헤더
            AdaptiveAppHeader(
              title: '문의하기',
              gradientColors: AppColors.headerBlueGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.headerText, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // 메인 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 안내 카드
                      _buildInfoCard(),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // 카테고리 선택
                      Text(
                        '문의 유형',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      _buildCategorySelector(),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // 제목 입력
                      Text(
                        '제목',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      _buildTitleField(),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // 내용 입력
                      Text(
                        '문의 내용',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      _buildContentField(),

                      const SizedBox(height: AppDimensions.spacingXXL),

                      // 전송 버튼
                      _buildSubmitButton(),

                      const SizedBox(height: 100), // 네비게이션 바 공간
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.mathBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.mathBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.mathBlue,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Text(
              '문의사항을 남겨주시면\n24시간 이내에 답변드리겠습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mathBlue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.mathBlue),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: '제목을 입력하세요',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.mathBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '제목을 입력해주세요';
        }
        if (value.trim().length < 2) {
          return '제목은 최소 2자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      maxLines: 10,
      decoration: InputDecoration(
        hintText: '문의 내용을 상세히 작성해주세요\n\n예시:\n- 어떤 문제가 발생했나요?\n- 언제 발생했나요?\n- 어떤 기능을 사용 중이었나요?',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.mathBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '문의 내용을 입력해주세요';
        }
        if (value.trim().length < 10) {
          return '문의 내용은 최소 10자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mathBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '문의하기',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 메시지 생성
      final message = Message(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        type: MessageType.system, // 사용자 문의는 시스템 메시지로 저장
        senderId: 'user',
        senderName: '사용자',
        title: '[$_selectedCategory] ${_titleController.text.trim()}',
        body: _contentController.text.trim(),
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Provider에 저장
      await ref.read(messageProvider.notifier).addMessage(message);

      // TODO: 실제 서버로 전송하는 로직 추가
      await Future.delayed(const Duration(seconds: 1)); // 서버 전송 시뮬레이션

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('문의가 성공적으로 전송되었습니다'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('문의 전송 실패: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
