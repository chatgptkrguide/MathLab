// Team empty view — shown when the user has no team. Provides create/search
// CTAs and lists pending invitations.
import 'package:flutter/material.dart';

import '../../../data/models/team_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import 'team_invitation_card.dart';

class TeamEmptyView extends StatelessWidget {
  final List<TeamInvitation> invitations;
  final VoidCallback onCreateTeam;
  final VoidCallback onSearchTeam;
  final ValueChanged<TeamInvitation> onAcceptInvitation;
  final ValueChanged<TeamInvitation> onRejectInvitation;

  const TeamEmptyView({
    super.key,
    required this.invitations,
    required this.onCreateTeam,
    required this.onSearchTeam,
    required this.onAcceptInvitation,
    required this.onRejectInvitation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),

        // Illustration
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_rounded,
              size: 56,
              color: AppColors.skyBlue.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 28),

        Text(
          '아직 팀이 없어요',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '팀을 만들거나 친구의 팀에 합류해서\n함께 학습해보세요!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),

        // Create Team Button
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onCreateTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.skyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              '팀 만들기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Join Team Button
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: onSearchTeam,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.skyBlue,
              side: BorderSide(color: AppColors.skyBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '팀 검색하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Invitations
        if (invitations.isNotEmpty) ...[
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '받은 초대 (${invitations.length})',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...invitations.map(
            (inv) => TeamInvitationCard(
              invitation: inv,
              onAccept: () => onAcceptInvitation(inv),
              onReject: () => onRejectInvitation(inv),
            ),
          ),
        ],
      ],
    );
  }
}
