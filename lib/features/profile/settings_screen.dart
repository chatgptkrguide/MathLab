import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/animations/fade_in_widget.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/user_provider.dart';
import '../auth/auth_screen.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentAccount = ref.watch(currentAccountProvider);
    final user = ref.watch(userProvider);

    final isGuest = currentAccount?.id.startsWith('guest_') ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () async {
            await AppHapticFeedback.selectionClick();
            if (context.mounted) Navigator.pop(context);
          },
        ),
        title: Text(
          '설정',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 계정 섹션
              _buildSectionTitle('계정'),
              const SizedBox(height: AppDimensions.spacingM),
              _buildAccountSection(context, ref, isGuest, currentAccount?.email, user?.name),
              const SizedBox(height: AppDimensions.spacingXL),

              // 일반 설정 섹션
              _buildSectionTitle('일반'),
              const SizedBox(height: AppDimensions.spacingM),
              _buildGeneralSettings(context, ref, settings),
              const SizedBox(height: AppDimensions.spacingXL),

              // 학습 설정 섹션
              _buildSectionTitle('학습'),
              const SizedBox(height: AppDimensions.spacingM),
              _buildLearningSettings(context, ref, settings),
              const SizedBox(height: AppDimensions.spacingXL),

              // 기타 섹션
              _buildSectionTitle('기타'),
              const SizedBox(height: AppDimensions.spacingM),
              _buildOtherSettings(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 400),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    bool isGuest,
    String? email,
    String? userName,
  ) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLight.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // 계정 정보
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.mathButtonGradient,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (userName != null && userName.isNotEmpty) ? userName[0] : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
              title: Text(
                userName ?? '게스트',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isGuest ? '게스트 모드' : (email ?? ''),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Divider(height: 1),
            // 로그인/로그아웃 버튼 - 강조된 디자인
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: isGuest
                  ? _buildLoginButton(context, ref)
                  : _buildLogoutButton(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(BuildContext context, WidgetRef ref, settings) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLight.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('알림'),
              subtitle: const Text('학습 리마인더 및 업적 알림'),
              value: settings.notificationsEnabled,
              activeColor: AppColors.mathGreen,
              onChanged: (value) async {
                await AppHapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('사운드'),
              subtitle: const Text('버튼 클릭 및 효과음'),
              value: settings.soundEnabled,
              activeColor: AppColors.mathGreen,
              onChanged: (value) async {
                await AppHapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setSoundEnabled(value);
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('진동'),
              subtitle: const Text('햅틱 피드백'),
              value: settings.vibrationEnabled,
              activeColor: AppColors.mathGreen,
              onChanged: (value) async {
                await AppHapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setVibrationEnabled(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningSettings(BuildContext context, WidgetRef ref, settings) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLight.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: const Text('일일 목표'),
              subtitle: Text('현재: ${settings.dailyGoalXP} XP'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDailyGoalDialog(context, ref, settings.dailyGoalXP),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('학습 리마인더'),
              subtitle: Text(
                settings.reminderEnabled && settings.reminderTime != null
                    ? '${settings.reminderTime}에 알림'
                    : '리마인더 꺼짐',
              ),
              value: settings.reminderEnabled,
              activeColor: AppColors.mathGreen,
              onChanged: (value) async {
                await AppHapticFeedback.selectionClick();
                if (value) {
                  // 리마인더 시간 설정 다이얼로그 표시
                  _showReminderTimeDialog(context, ref);
                } else {
                  ref.read(settingsProvider.notifier).setReminderEnabled(false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettings(BuildContext context, WidgetRef ref) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLight.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: const Text('앱 정보'),
              subtitle: const Text('버전 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAppInfo(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('이용약관'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTerms(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('개인정보처리방침'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPrivacyPolicy(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                '데이터 초기화',
                style: TextStyle(color: AppColors.mathRed),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.mathRed),
              onTap: () => _showResetDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 버튼 (강조된 디자인)
  Widget _buildLoginButton(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.05),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        // 애니메이션 반복을 위한 상태 관리가 필요하지만 여기서는 간단하게 처리
      },
      child: InkWell(
        onTap: () => _handleLogin(context, ref),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.mathGreen, AppColors.mathTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.mathGreen.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.login,
                color: AppColors.surface,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                '로그인하고 데이터 동기화하기',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              const Icon(
                Icons.chevron_right,
                color: AppColors.surface,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 로그아웃 버튼 (덜 강조된 디자인)
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _handleLogout(context, ref),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: AppColors.mathRed.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: AppColors.mathRed,
              size: 24,
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              '로그아웃',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mathRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            const Icon(
              Icons.chevron_right,
              color: AppColors.mathRed,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 처리
  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    await AppHapticFeedback.selectionClick();

    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('로그인'),
        content: const Text(
          '로그인 화면으로 이동하시겠습니까?\n현재 게스트 계정의 학습 기록은 유지됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '이동',
              style: TextStyle(color: AppColors.mathGreen),
            ),
          ),
        ],
      ),
    );

    if (shouldNavigate == true && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  // 로그아웃 처리
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await AppHapticFeedback.selectionClick();

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('로그아웃'),
        content: const Text(
          '정말 로그아웃 하시겠습니까?\n학습 기록은 안전하게 저장됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppColors.mathRed),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  // 일일 목표 설정 다이얼로그
  void _showDailyGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final goals = [10, 20, 30, 50, 100];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('일일 목표 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) {
            final isSelected = goal == currentGoal;
            return ListTile(
              title: Text('$goal XP'),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.mathGreen) : null,
              onTap: () async {
                await AppHapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setDailyGoalXP(goal);
                if (context.mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 리마인더 시간 설정 다이얼로그
  Future<void> _showReminderTimeDialog(BuildContext context, WidgetRef ref) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mathGreen,
              onPrimary: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final timeString = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      await ref.read(settingsProvider.notifier).setReminderTime(timeString);
      await ref.read(settingsProvider.notifier).setReminderEnabled(true);
    }
  }

  // 앱 정보 다이얼로그
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('GoMath'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('재미있게 수학을 배우는 앱'),
            SizedBox(height: 8),
            Text('© 2025 GoMath Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 이용약관 다이얼로그
  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '이용약관 내용이 여기에 표시됩니다.\n\n'
            '1. 서비스 이용\n'
            '2. 사용자 권리\n'
            '3. 서비스 제공자 권리\n'
            '...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 개인정보처리방침 다이얼로그
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('개인정보처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '개인정보처리방침 내용이 여기에 표시됩니다.\n\n'
            '1. 수집하는 개인정보\n'
            '2. 개인정보 이용 목적\n'
            '3. 개인정보 보관 기간\n'
            '...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 데이터 초기화 다이얼로그
  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('데이터 초기화'),
        content: const Text(
          '정말 모든 데이터를 초기화하시겠습니까?\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '초기화',
              style: TextStyle(color: AppColors.mathRed),
            ),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      await ref.read(userProvider.notifier).resetUser();
      await ref.read(settingsProvider.notifier).resetSettings();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('데이터가 초기화되었습니다'),
            backgroundColor: AppColors.mathGreen,
          ),
        );
      }
    }
  }
}
