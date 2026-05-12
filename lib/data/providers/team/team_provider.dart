// 👥 Team Provider
//
// Manages team state and Firestore operations.
//
// Method implementations are split into part files by responsibility:
//   * team_provider.membership.dart  — load / create / join / leave / member ops
//   * team_provider.invitations.dart — invite / accept / reject invitations
//   * team_provider.search.dart      — team search & message clearing
// Splitting uses Dart `part` so that private fields (_firestore, refs) remain
// accessible from extensions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/team_model.dart';

part 'team_provider.membership.dart';
part 'team_provider.invitations.dart';
part 'team_provider.search.dart';

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
}

/// Team Provider (family by userId)
final teamProvider =
    StateNotifierProvider.family<TeamNotifier, TeamState, String>(
  (ref, userId) => TeamNotifier(userId),
);
