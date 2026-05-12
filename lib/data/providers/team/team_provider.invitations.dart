// 👥 Team provider — invitation flows
//
// part of team_provider.dart. Owns inviteMember, loadInvitations, acceptInvitation,
// rejectInvitation.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'team_provider.dart';

extension TeamInvitations on TeamNotifier {
  /// Send team invitation
  Future<bool> inviteMember(String toUserId) async {
    if (!state.hasTeam) return false;

    try {
      final team = state.currentTeam!;

      if (team.isFull) {
        state = state.copyWith(error: '팀이 가득 찼습니다.');
        return false;
      }

      if (team.isMember(toUserId)) {
        state = state.copyWith(error: '이미 팀원입니다.');
        return false;
      }

      // Check existing pending invitation
      final existing = await _invitationsRef
          .where('teamId', isEqualTo: team.id)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        state = state.copyWith(error: '이미 초대를 보냈습니다.');
        return false;
      }

      // Get sender name (best-effort — 빈 값이어도 초대 자체는 진행)
      String fromUserName = '';
      try {
        final userDoc =
            await _firestore.collection('users').doc(userId).get();
        fromUserName = userDoc.data()?['displayName'] as String? ?? '';
      } catch (e) {
        AppLogger.warning(
          'Failed to fetch inviter display name',
          tag: 'Team',
          error: e,
          data: {'userId': userId},
        );
      }

      await _invitationsRef.add({
        'teamId': team.id,
        'teamName': team.name,
        'fromUserId': userId,
        'fromUserName': fromUserName,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Sent team invitation to: $toUserId', tag: 'Team');
      state = state.copyWith(successMessage: '초대를 보냈습니다.');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Load pending invitations for this user
  Future<void> loadInvitations() async {
    try {
      final snapshot = await _invitationsRef
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final invitations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return TeamInvitation.fromJson(data);
      }).toList();

      state = state.copyWith(invitations: invitations);
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
    }
  }

  /// Accept team invitation
  Future<bool> acceptInvitation(TeamInvitation invitation) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (state.hasTeam) {
        state = state.copyWith(
          isLoading: false,
          error: '이미 팀에 가입되어 있습니다. 먼저 탈퇴해주세요.',
        );
        return false;
      }

      // Update invitation status
      await _invitationsRef.doc(invitation.id).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Join team
      final joined = await joinTeam(invitation.teamId);
      if (joined) {
        await loadInvitations();
      }
      return joined;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(isLoading: false, error: appError.userMessage);
      return false;
    }
  }

  /// Reject team invitation
  Future<bool> rejectInvitation(String invitationId) async {
    try {
      await _invitationsRef.doc(invitationId).update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await loadInvitations();
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }
}
