/// ð League Timer Widget
///
/// Displays countdown timer for current league

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class LeagueTimer extends StatefulWidget {
  final DateTime endDate;

  const LeagueTimer({
    super.key,
    required this.endDate,
  });

  @override
  State<LeagueTimer> createState() => _LeagueTimerState();
}

class _LeagueTimerState extends State<LeagueTimer> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = widget.endDate.difference(DateTime.now());
      if (_timeRemaining.isNegative) {
        _timeRemaining = Duration.zero;
      }
    });
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '$days| $hoursÜ';
    } else if (hours > 0) {
      return '$hoursÜ $minutes„';
    } else if (minutes > 0) {
      return '$minutes„ $seconds';
    } else {
      return '$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '¬ø …ÌLÀ',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            _formatDuration(_timeRemaining),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: _timeRemaining.inHours < 24
                  ? Colors.red
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
