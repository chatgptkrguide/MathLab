import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/user/user_provider.dart';
import '../../../../shared/constants/game_constants.dart';
import '../../../../shared/constants/app_constants.dart';

/// 학년 선택 모달
///
/// 중1~고3 학년을 선택할 수 있는 Bottom Sheet 모달
class GradeSelectionModal extends ConsumerWidget {
  /// 학년 선택 완료 후 콜백
  final Function(String selectedGrade)? onGradeSelected;

  const GradeSelectionModal({
    super.key,
    this.onGradeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 제목
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '학년을 선택하세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // 학년 목록
          ..._getGradeList().map((grade) {
            final gradeInfo = AppConstants.gradeInfoMap[grade]!;
            return _buildGradeOption(
              context,
              ref,
              grade,
              gradeInfo['emoji']!,
              gradeInfo['fullName']!,
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 학년 목록 반환
  List<String> _getGradeList() {
    return ['중1', '중2', '중3', '고1', '고2', '고3'];
  }

  /// 학년 옵션 아이템 빌더
  Widget _buildGradeOption(
    BuildContext context,
    WidgetRef ref,
    String grade,
    String emoji,
    String fullName,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // 학년 업데이트
          ref.read(userProvider.notifier).updateGrade(grade);
          // 콜백 호출
          if (onGradeSelected != null) {
            Future.delayed(
              const Duration(milliseconds: GameConstants.normalAnimationMs),
              () {
                if (context.mounted) {
                  onGradeSelected!(grade);
                }
              },
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 학년 선택 모달 표시 헬퍼 함수
  static Future<void> show(
    BuildContext context, {
    Function(String)? onGradeSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GradeSelectionModal(
        onGradeSelected: onGradeSelected,
      ),
    );
  }
}
