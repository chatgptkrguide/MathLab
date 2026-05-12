// 👥 Team provider — team search & message clearing
//
// part of team_provider.dart.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'team_provider.dart';

extension TeamSearch on TeamNotifier {
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
