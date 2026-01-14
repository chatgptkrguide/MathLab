import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../shared/widgets/headers/common_app_header.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../data/providers/user/user_provider.dart';

/// 친구 초대 화면
///
/// 초대 링크 생성 및 공유 기능
/// - 고유 초대 코드 생성
/// - 카카오톡, 문자, 링크 복사 등 공유
/// - 초대 보상 시스템
class FriendInviteScreen extends ConsumerStatefulWidget {
  const FriendInviteScreen({super.key});

  @override
  ConsumerState<FriendInviteScreen> createState() =>
      _FriendInviteScreenState();
}

class _FriendInviteScreenState extends ConsumerState<FriendInviteScreen> {
  String _inviteCode = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider);
      _inviteCode = user?.id.substring(0, 8).toUpperCase() ?? 'INVITE123';
    } catch (e) {
      _inviteCode = 'INVITE123';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String get _inviteLink =>
      'https://mathlab.app/invite?code=$_inviteCode';

  String get _inviteMessage => '''
🎓 MathLab에서 함께 수학 공부해요!

재미있는 게임처럼 수학을 배울 수 있어요.
초대 코드: $_inviteCode

👉 앱 다운로드: $_inviteLink

친구 초대하고 보너스 100 XP를 받으세요!
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: const CommonAppHeaderWithBack(
        title: '친구 초대',
        icon: Icons.person_add,
        iconColor: AppColors.mathYellow,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRewardCard(),
                  const SizedBox(height: 24),
                  _buildInviteCodeCard(),
                  const SizedBox(height: 24),
                  _buildShareButtons(),
                  const SizedBox(height: 24),
                  _buildHowItWorks(),
                ],
              ),
            ),
    );
  }

  /// 보상 카드
  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerBlueGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard,
              size: 48,
              color: AppColors.mathYellow,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '친구 초대 보상',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '친구가 가입하면',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: AppColors.mathYellow,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '+100 XP',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 초대 코드 카드
  Widget _buildInviteCodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 초대 코드',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _inviteCode,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyInviteCode,
              icon: const Icon(Icons.copy),
              label: const Text('코드 복사'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공유 버튼들
  Widget _buildShareButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '초대 방법',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildShareButton(
          icon: Icons.share,
          title: '일반 공유',
          description: '다양한 앱으로 초대 링크 공유',
          color: AppColors.primary,
          onTap: _shareGeneral,
        ),
        const SizedBox(height: 12),
        _buildShareButton(
          icon: Icons.chat,
          title: '카카오톡으로 초대',
          description: '친구에게 바로 카카오톡 메시지 보내기',
          color: const Color(0xFFFEE500),
          iconColor: Colors.black87,
          onTap: _shareKakao,
        ),
        const SizedBox(height: 12),
        _buildShareButton(
          icon: Icons.message,
          title: '문자로 초대',
          description: 'SMS로 초대 링크 전송',
          color: AppColors.mathGreen,
          onTap: _shareSMS,
        ),
        const SizedBox(height: 12),
        _buildShareButton(
          icon: Icons.link,
          title: '링크 복사',
          description: '초대 링크를 클립보드에 복사',
          color: AppColors.textSecondary,
          onTap: _copyInviteLink,
        ),
      ],
    );
  }

  /// 공유 버튼 위젯
  Widget _buildShareButton({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용 방법
  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '이렇게 사용하세요',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep(1, '친구에게 초대 코드 또는 링크 공유'),
          const SizedBox(height: 12),
          _buildStep(2, '친구가 앱을 다운로드하고 회원가입'),
          const SizedBox(height: 12),
          _buildStep(3, '친구가 초대 코드 입력'),
          const SizedBox(height: 12),
          _buildStep(4, '양쪽 모두 보너스 100 XP 획득!'),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  /// 초대 코드 복사
  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode));
    _showSnackBar('초대 코드가 복사되었습니다');
  }

  /// 초대 링크 복사
  void _copyInviteLink() {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    _showSnackBar('초대 링크가 복사되었습니다');
  }

  /// 일반 공유
  Future<void> _shareGeneral() async {
    try {
      await Share.share(
        _inviteMessage,
        subject: 'MathLab 초대',
      );
    } catch (e) {
      _showSnackBar('공유하기에 실패했습니다');
    }
  }

  /// 카카오톡 공유
  Future<void> _shareKakao() async {
    // 카카오톡 공유는 일반 공유 API를 사용
    // 안드로이드/iOS의 Share Sheet에서 카카오톡 선택 가능
    await _shareGeneral();
  }

  /// SMS 공유
  Future<void> _shareSMS() async {
    // SMS 공유는 일반 공유 API를 사용
    // Share Sheet에서 메시지 앱 선택 가능
    await _shareGeneral();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
