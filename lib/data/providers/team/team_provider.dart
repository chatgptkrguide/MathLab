// 👥 Team Provider
//
// Manages team state and Firestore operations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/team_model.dart';

class TeamState {
  final TeamModel? currentTeam;
  final List<TeamMember> members;
  final List<TeamInvitation> invitations;
  final List<TeamModel> searchResults;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const TeamState({
    this.currentTeam,
    this.members = const [],
    this.invitations = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  TeamState copyWith({
    TeamModel? currentTeam,
    List<TeamMember>? members,
    List<TeamInvitation>? invitations,
    List<TeamModel>? searchResults,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearTeam = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TeamState(
      currentTeam: clearTeam ? null : (currentTeam ?? this.currentTeam),
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get hasTeam => currentTeam != null;
  int get memberCount => members.length;
}

class TeamNotifier extends StateNotifier<TeamState> {
  final String userId;
  final FirebaseFirestore _firestore;

  TeamNotifier(this.userId, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const TeamState()) {
    loadUserTeam();
    loadInvitations();
  }

  CollectionReference get _teamsRef => _firestore.collection('teams');
  CollectionReference get _invitationsRef =>
      _firestore.collection('team_invitations');

  /// Load user's current team
  Future<void> loadUserTeam() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Find team where user is a member
      final snapshot = await _teamsRef
          .where('memberIds', arrayContains: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        state = state.copyWith(isLoading: false, clearTeam: true);
        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final team = TeamModel.fromJson(data);

      // Load member details
      await _loadTeamMembers(team);

      AppLogger.info('Loaded team: ${team.name}', tag: 'Team');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(isLoading: false, error: appError.userMessage);
    }
  }

  /// Load team member details from users collection (batch query)
  Future<void> _loadTeamMembers(TeamModel team) async {
    try {
      if (team.memberIds.isEmpty) {
        state = state.copyWith(
          currentTeam: team,
          members: [],
          isLoading: false,
        );
        return;
      }

      // Batch query: Firestore whereIn supports up to 30 items
      final chunks = <List<String>>[];
      for (var i = 0; i < team.memberIds.length; i += 30) {
        chunks.add(team.memberIds.sublist(
          i,
          i + 30 > team.memberIds.length ? team.memberIds.length : i + 30,
        ));
      }

      final members = <TeamMember>[];
      for (final chunk in chunks) {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          final userData = doc.data();
          members.add(TeamMember(
            userId: doc.id,
            displayName: userData['displayName'] as String? ?? '알 수 없음',
            avatarUrl: userData['photoUrl'] as String?,
            role: doc.id == team.leaderId
                ? TeamRole.leader
                : TeamRole.member,
            xp: userData['totalXp'] as int? ?? 0,
            weeklyXp: userData['dailyXP'] as int? ?? 0,
            streak: userData['streak'] as int? ?? 0,
            level: userData['level'] as int? ?? 1,
            joinedAt: DateTime.now(),
          ));
        }
      }

      // Sort: leader first, then by XP descending
      members.sort((a, b) {
        if (a.isLeader) return -1;
        if (b.isLeader) return 1;
        return b.xp.compareTo(a.xp);
      });

      state = state.copyWith(
        currentTeam: team,
        members: members,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      AppLogger.warning('Failed to load team members: $e', tag: 'Team');
      AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(
        currentTeam: team,
        members: [],
        isLoading: false,
      );
    }
  }

  /// Create a new team
  Future<bool> createTeam({
    required String name,
    String? description,
    String? iconEmoji,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Check if user already has a team
      if (state.hasTeam) {
        state = state.copyWith(
          isLoading: false,
          error: '이미 팀에 가입되어 있습니다.',
        );
        return false;
      }

      final docRef = await _teamsRef.add({
        'name': name,
        'description': description ?? '',
        'iconEmoji': iconEmoji ?? '📚',
        'leaderId': userId,
        'memberIds': [userId],
        'maxMembers': 10,
        'totalXp': 0,
        'weeklyXp': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Created team: $name (${docRef.id})', tag: 'Team');

      await loadUserTeam();
      state = state.copyWith(successMessage: '팀이 생성되었습니다!');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(isLoading: false, error: appError.userMessage);
      return false;
    }
  }

  /// Join an existing team
  Future<bool> joinTeam(String teamId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (state.hasTeam) {
        state = state.copyWith(
          isLoading: false,
          error: '이미 팀에 가입되어 있습니다.',
        );
        return false;
      }

      final teamDoc = await _teamsRef.doc(teamId).get();
      if (!teamDoc.exists) {
        state = state.copyWith(isLoading: false, error: '팀을 찾을 수 없습니다.');
        return false;
      }

      final teamData = teamDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(teamData['memberIds'] ?? []);
      final maxMembers = teamData['maxMembers'] as int? ?? 10;

      if (memberIds.length >= maxMembers) {
        state = state.copyWith(isLoading: false, error: '팀이 가득 찼습니다.');
        return false;
      }

      if (memberIds.contains(userId)) {
        state =
            state.copyWith(isLoading: false, error: '이미 이 팀의 멤버입니다.');
        return false;
      }

      await _teamsRef.doc(teamId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Joined team: $teamId', tag: 'Team');

      await loadUserTeam();
      state = state.copyWith(successMessage: '팀에 가입했습니다!');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(isLoading: false, error: appError.userMessage);
      return false;
    }
  }

  /// Leave team
  Future<bool> leaveTeam() async {
    if (!state.hasTeam) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final team = state.currentTeam!;

      if (team.isLeader(userId) && team.memberCount > 1) {
        state = state.copyWith(
          isLoading: false,
          error: '팀장은 팀원이 있을 때 탈퇴할 수 없습니다.\n팀장을 위임하거나 팀원을 내보내세요.',
        );
        return false;
      }

      if (team.isLeader(userId) && team.memberCount == 1) {
        // Last member leaves → delete team
        await _teamsRef.doc(team.id).delete();
        AppLogger.info('Deleted team (last member left): ${team.id}',
            tag: 'Team');
      } else {
        await _teamsRef.doc(team.id).update({
          'memberIds': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      state = state.copyWith(
        isLoading: false,
        clearTeam: true,
        members: [],
        successMessage: '팀에서 탈퇴했습니다.',
      );
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(isLoading: false, error: appError.userMessage);
      return false;
    }
  }

  /// Remove a member (leader only)
  Future<bool> removeMember(String memberId) async {
    if (!state.hasTeam || !state.currentTeam!.isLeader(userId)) return false;

    try {
      await _teamsRef.doc(state.currentTeam!.id).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Removed member: $memberId', tag: 'Team');
      await loadUserTeam();
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

  /// Transfer leadership
  Future<bool> transferLeadership(String newLeaderId) async {
    if (!state.hasTeam || !state.currentTeam!.isLeader(userId)) return false;

    try {
      await _teamsRef.doc(state.currentTeam!.id).update({
        'leaderId': newLeaderId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Transferred leadership to: $newLeaderId', tag: 'Team');
      await loadUserTeam();
      state = state.copyWith(successMessage: '팀장을 위임했습니다.');
      return true;
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(error: appError.userMessage);
      return false;
    }
  }

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

      // Get sender name
      String fromUserName = '';
      try {
        final userDoc =
            await _firestore.collection('users').doc(userId).get();
        fromUserName = userDoc.data()?['displayName'] as String? ?? '';
      } catch (_) {}

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

  /// Search teams by name (minimum 2 characters)
  Future<void> searchTeams(String query) async {
    if (query.trim().length < 2) {
      state = state.copyWith(searchResults: []);
      return;
    }

    try {
      final trimmed = query.trim();
      final endQuery = trimmed.substring(0, trimmed.length - 1) +
          String.fromCharCode(trimmed.codeUnitAt(trimmed.length - 1) + 1);

      final snapshot = await _teamsRef
          .where('name', isGreaterThanOrEqualTo: trimmed)
          .where('name', isLessThan: endQuery)
          .limit(20)
          .get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TeamModel.fromJson(data);
      }).toList();

      state = state.copyWith(searchResults: results);
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
    }
  }

  /// Clear messages
  void clearError() => state = state.copyWith(clearError: true);
  void clearSuccess() => state = state.copyWith(clearSuccess: true);
}

/// Team Provider (family by userId)
final teamProvider =
    StateNotifierProvider.family<TeamNotifier, TeamState, String>(
  (ref, userId) => TeamNotifier(userId),
);
