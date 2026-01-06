import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../data/models/models.dart';
import '../../data/providers/learning/study_timer_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../constants/app_colors.dart';

/// 공부 타이머 위젯
/// 학습 시간을 실시간으로 추적하고 표시합니다.
class StudyTimerWidget extends ConsumerStatefulWidget {
  final StudyActivityType activityType;
  final bool autoStart;

  const StudyTimerWidget({
    super.key,
    required this.activityType,
    this.autoStart = true,
  });

  @override
  ConsumerState<StudyTimerWidget> createState() => _StudyTimerWidgetState();
}

class _StudyTimerWidgetState extends ConsumerState<StudyTimerWidget> {
  StreamSubscription<int>? _timeSubscription;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timeSubscription?.cancel();
    super.dispose();
  }

  /// 타이머 시작
  Future<void> _startTimer() async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final notifier = ref.read(currentStudySessionProvider.notifier);
    await notifier.startTimer(
      userId: user.id,
      activityType: widget.activityType,
    );

    // 타이머 스트림 구독
    final stream = notifier.rawTimeStream;
    if (stream != null) {
      _timeSubscription = stream.listen((milliseconds) {
        if (mounted) {
          setState(() {
            _currentSeconds = milliseconds ~/ 1000;
          });
        }
      });
    }
  }

  /// 타이머 일시정지
  void _pauseTimer() {
    ref.read(currentStudySessionProvider.notifier).pauseTimer();
  }

  /// 타이머 재개
  void _resumeTimer() {
    ref.read(currentStudySessionProvider.notifier).resumeTimer();
  }

  /// 타이머 중지
  Future<void> _stopTimer() async {
    final notifier = ref.read(currentStudySessionProvider.notifier);
    await notifier.stopTimer();
    _timeSubscription?.cancel();
    if (mounted) {
      setState(() {
        _currentSeconds = 0;
      });
    }
  }

  /// 시간 포맷팅 (HH:MM:SS)
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentStudySessionProvider);
    final isRunning = ref.read(currentStudySessionProvider.notifier).isRunning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 타이머 아이콘
          Icon(
            Icons.timer_outlined,
            color: session != null ? AppColors.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),

          // 시간 표시
          Text(
            _formatTime(_currentSeconds),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: session != null ? AppColors.textPrimary : Colors.grey,
              fontFamily: 'Inter',
            ),
          ),

          if (session != null) ...[
            const SizedBox(width: 12),

            // 일시정지/재개 버튼
            InkWell(
              onTap: isRunning ? _pauseTimer : _resumeTimer,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isRunning ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 4),

            // 중지 버튼
            InkWell(
              onTap: _stopTimer,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.stop,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 간단한 타이머 표시 위젯 (컨트롤 없음)
class StudyTimerDisplay extends ConsumerWidget {
  const StudyTimerDisplay({super.key});

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분 $secs초';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(todayStudyTimeProvider).when(
          data: (totalSeconds) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '오늘 ${_formatTime(totalSeconds)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}
