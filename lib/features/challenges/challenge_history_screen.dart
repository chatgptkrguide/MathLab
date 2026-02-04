// Challenge History Screen (Figma "03" Frame)
//
// Displays challenge progress, calendar view, and level info.
// Teal-green header with learning path nodes + white card body.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/figma_colors.dart';

class ChallengeHistoryScreen extends ConsumerWidget {
  const ChallengeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildHeader(),
              _buildWhiteCardSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header: teal-green background with learning path nodes
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: FigmaColors.tealGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Section label
          const Text(
            'UNIT 3',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '챌린지 학습',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Learning-path nodes row
          _buildPathNodes(),
        ],
      ),
    );
  }

  Widget _buildPathNodes() {
    // 7 nodes: first 3 completed, 4th active, rest locked
    final List<_NodeState> nodes = [
      _NodeState.completed,
      _NodeState.completed,
      _NodeState.completed,
      _NodeState.active,
      _NodeState.locked,
      _NodeState.locked,
      _NodeState.locked,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(nodes.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line between nodes
          final leftState = nodes[i ~/ 2];
          final isCompleted = leftState == _NodeState.completed;
          return Container(
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.white : const Color(0xFFE4E9EA),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
        return _buildSingleNode(nodes[i ~/ 2]);
      }),
    );
  }

  Widget _buildSingleNode(_NodeState state) {
    const double size = 28;

    switch (state) {
      case _NodeState.completed:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 16, color: FigmaColors.tealGreen),
        );
      case _NodeState.active:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.star, size: 16, color: FigmaColors.tealGreen),
        );
      case _NodeState.locked:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFFE4E9EA),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock, size: 14, color: Colors.grey.shade500),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // White card body (675px design height)
  // ---------------------------------------------------------------------------
  Widget _buildWhiteCardSection() {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title
            const Text(
              '챌린지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: FigmaColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Two stat cards side-by-side
            _buildStatCardsRow(),
            const SizedBox(height: 24),

            // 3. Calendar
            _buildCalendarSection(),
            const SizedBox(height: 24),

            // 4. Level progress
            _buildLevelProgress(),
            const SizedBox(height: 24),

            // 5. Subject info
            _buildSubjectInfo(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Stat cards
  // ---------------------------------------------------------------------------
  Widget _buildStatCardsRow() {
    return Row(
      children: [
        Expanded(child: _buildChallengeDoneCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildRemainingCard()),
      ],
    );
  }

  Widget _buildChallengeDoneCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FigmaColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
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
                  color: FigmaColors.gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 18,
                  color: FigmaColors.gold,
                ),
              ),
              const Spacer(),
              const Text(
                'Challenge Done',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '6/12',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: FigmaColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 6 / 12,
              minHeight: 6,
              backgroundColor: FigmaColors.gold.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(FigmaColors.gold),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '50% completed',
            style: TextStyle(
              fontSize: 11,
              color: FigmaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FigmaColors.tealGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
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
                  color: FigmaColors.tealGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: FigmaColors.tealGreen,
                ),
              ),
              const Spacer(),
              const Text(
                'Remaining',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '6 ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: FigmaColors.textDark,
                  ),
                ),
                TextSpan(
                  text: 'Days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: FigmaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '/ 10 Days',
            style: TextStyle(
              fontSize: 12,
              color: FigmaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '4 days left',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: FigmaColors.tealGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Calendar section
  // ---------------------------------------------------------------------------
  Widget _buildCalendarSection() {
    return Column(
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'December 2022',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: FigmaColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.skyBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Day-of-week headers
        _buildDayHeaders(),
        const SizedBox(height: 8),

        // Date grid (December 2022 starts on Thursday)
        _buildDateGrid(),
      ],
    );
  }

  Widget _buildDayHeaders() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateGrid() {
    // December 2022: starts Thursday (offset 3), 31 days
    const int startOffset = 3; // Mon=0 ... Thu=3
    const int totalDays = 31;

    // Days the user studied (sample data matching design)
    const Set<int> studiedDays = {1, 2, 5, 6, 7, 8, 12, 13, 14, 19, 20, 26, 27};

    final totalCells = startOffset + totalDays;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > totalDays) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final isStudied = studiedDays.contains(dayNum);

              return Expanded(
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: isStudied
                        ? BoxDecoration(
                            color: studiedDayColor(dayNum),
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isStudied ? FontWeight.w700 : FontWeight.w400,
                        color: isStudied ? Colors.white : FigmaColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  /// Returns the background color for a studied calendar day.
  static Color studiedDayColor(int day) {
    if (day <= 2) return FigmaColors.tealGreen;
    if (day <= 8) return FigmaColors.skyBlue;
    if (day <= 14) return FigmaColors.gold;
    if (day <= 20) return FigmaColors.tealGreen;
    return FigmaColors.skyBlue;
  }

  // ---------------------------------------------------------------------------
  // 4. Level progress
  // ---------------------------------------------------------------------------
  Widget _buildLevelProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: FigmaColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'G',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Progress info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gold Rank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FigmaColors.textDark,
                      ),
                    ),
                    Text(
                      '50%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FigmaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 8,
                    backgroundColor: Color(0xFFE4E9EA),
                    valueColor: AlwaysStoppedAnimation<Color>(FigmaColors.gold),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '549 / 1100 XP to Diamond',
                  style: TextStyle(
                    fontSize: 11,
                    color: FigmaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Subject info row
  // ---------------------------------------------------------------------------
  Widget _buildSubjectInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Subject chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: FigmaColors.tealGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '소인수분해',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FigmaColors.tealGreen,
              ),
            ),
          ),
          const Spacer(),

          // Streak
          _buildInfoPill(Icons.local_fire_department, '6', FigmaColors.streakGold),
          const SizedBox(width: 10),

          // XP
          _buildInfoPill(Icons.bolt, '549', FigmaColors.skyBlue),
          const SizedBox(width: 10),

          // Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: FigmaColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'HLv1',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FigmaColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal node-state enum for the header path visualisation
// ---------------------------------------------------------------------------
enum _NodeState { completed, active, locked }
