// 👥 Team Screen
//
// Main team screen: shows team details or join/create flow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/team/team_provider.dart';
import '../../data/models/team_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import 'widgets/team_empty_view.dart';
import 'widgets/team_header.dart';
import 'widgets/team_member_card.dart';
import 'widgets/team_search_result_card.dart';
import 'create_team_screen.dart';

class TeamScreen extends ConsumerStatefulWidget {
  /// 코치마크용 GlobalKey
  static final teamHeaderKey = GlobalKey(debugLabel: 'teamHeader');

  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(teamProvider(user.uid).notifier).loadUserTeam();
      ref.read(teamProvider(user.uid).notifier).loadInvitations();
    }
  }

  Future<void> _onRefresh() async {
    final user = ref.read(userProvider);
    if (user != null) {
      await ref.read(teamProvider(user.uid).notifier).loadUserTeam();
      await ref.read(teamProvider(user.uid).notifier).loadInvitations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('팀')),
        body: const Center(child: Text('로그인이 필요합니다')),
      );
    }

    final teamState = ref.watch(teamProvider(user.uid));

    // Listen for snackbar messages
    ref.listen<TeamState>(teamProvider(user.uid), (prev, next) {
      if (prev?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(teamProvider(user.uid).notifier).clearError();
      }
      if (prev?.successMessage != next.successMessage &&
          next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.mathGreen,
          ),
        );
        ref.read(teamProvider(user.uid).notifier).clearSuccess();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.skyBlue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '팀',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (teamState.hasTeam)
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () => _showTeamSettings(context, user.uid, teamState),
              tooltip: '팀 설정',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: teamState.isLoading && !teamState.hasTeam
            ? const Center(child: CircularProgressIndicator())
            : teamState.hasTeam
                ? _buildTeamView(teamState, user.uid)
                : TeamEmptyView(
                    invitations: teamState.invitations,
                    onCreateTeam: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateTeamScreen(),
                      ),
                    ),
                    onSearchTeam: () => _showSearchTeamSheet(context, user.uid),
                    onAcceptInvitation: (inv) => ref
                        .read(teamProvider(user.uid).notifier)
                        .acceptInvitation(inv),
                    onRejectInvitation: (inv) => ref
                        .read(teamProvider(user.uid).notifier)
                        .rejectInvitation(inv.id),
                  ),
      ),
    );
  }

  // ============================
  // Team View (has team)
  // ============================
  Widget _buildTeamView(TeamState teamState, String userId) {
    final team = teamState.currentTeam!;
    final isLeader = team.isLeader(userId);

    return CustomScrollView(
      slivers: [
        // Team Header
        SliverToBoxAdapter(
          child: Container(
            key: TeamScreen.teamHeaderKey,
            child: TeamHeader(
              team: team,
              memberCount: teamState.memberCount,
            ),
          ),
        ),

        // Members Section Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('팀원 순위', style: AppTextStyles.titleLarge),
                if (isLeader)
                  TextButton.icon(
                    onPressed: () => _showInviteDialog(context, userId),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('초대'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.royalBlue,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Member List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final member = teamState.members[index];
              return TeamMemberCard(
                member: member,
                rank: index + 1,
                isCurrentUser: member.userId == userId,
                showActions: isLeader && member.userId != userId,
                onRemove: () => _confirmRemoveMember(
                    context, userId, member),
                onTransferLeader: () => _confirmTransferLeader(
                    context, userId, member),
              );
            },
            childCount: teamState.members.length,
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ============================
  // Dialogs & Bottom Sheets
  // ============================

  void _showTeamSettings(
      BuildContext context, String userId, TeamState teamState) {
    final team = teamState.currentTeam!;
    final isLeader = team.isLeader(userId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                if (isLeader)
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('팀원 초대'),
                    onTap: () {
                      Navigator.pop(context);
                      _showInviteDialog(context, userId);
                    },
                  ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: AppColors.error,
                  ),
                  title: Text(
                    isLeader && team.memberCount > 1
                        ? '팀 탈퇴 (먼저 팀장 위임 필요)'
                        : '팀 탈퇴',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLeaveTeam(context, userId);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String userId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀원 초대'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '사용자 ID 입력',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final toUserId = controller.text.trim();
              if (toUserId.isNotEmpty) {
                ref
                    .read(teamProvider(userId).notifier)
                    .inviteMember(toUserId);
                Navigator.pop(context);
              }
            },
            child: const Text('초대'),
          ),
        ],
      ),
    );
  }

  void _showSearchTeamSheet(BuildContext context, String userId) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final teamState = ref.watch(teamProvider(userId));

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('팀 검색', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '팀 이름으로 검색',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      ref
                          .read(teamProvider(userId).notifier)
                          .searchTeams(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: teamState.searchResults.isEmpty
                        ? Center(
                            child: Text(
                              searchController.text.isEmpty
                                  ? '팀 이름을 입력하세요'
                                  : '검색 결과가 없습니다',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: teamState.searchResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final team = teamState.searchResults[index];
                              return TeamSearchResultCard(
                                team: team,
                                onJoin: () {
                                  ref
                                      .read(teamProvider(userId).notifier)
                                      .joinTeam(team.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmLeaveTeam(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀 탈퇴'),
        content: const Text('정말 팀에서 탈퇴하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(teamProvider(userId).notifier).leaveTeam();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(
      BuildContext context, String userId, TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀원 내보내기'),
        content: Text('${member.displayName}님을 팀에서 내보내시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(teamProvider(userId).notifier)
                  .removeMember(member.userId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('내보내기'),
          ),
        ],
      ),
    );
  }

  void _confirmTransferLeader(
      BuildContext context, String userId, TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀장 위임'),
        content: Text('${member.displayName}님에게 팀장을 위임하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(teamProvider(userId).notifier)
                  .transferLeadership(member.userId);
              Navigator.pop(context);
            },
            child: const Text('위임'),
          ),
        ],
      ),
    );
  }
}
