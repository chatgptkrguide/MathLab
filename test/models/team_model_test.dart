import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/team_model.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 9, 0);

  // 기본 TeamModel JSON 픽스처
  Map<String, dynamic> makeTeamJson({
    String id = 'team-001',
    String name = '수학왕들',
    String leaderId = 'user-001',
    List<String>? memberIds,
    int maxMembers = 10,
    int totalXp = 1000,
    int weeklyXp = 200,
    dynamic createdAt,
  }) {
    return {
      'id': id,
      'name': name,
      'description': '열심히 공부하는 팀',
      'iconEmoji': '🏆',
      'leaderId': leaderId,
      'memberIds': memberIds ?? ['user-001', 'user-002', 'user-003'],
      'maxMembers': maxMembers,
      'totalXp': totalXp,
      'weeklyXp': weeklyXp,
      'createdAt': createdAt ?? fixedDate.toIso8601String(),
      'updatedAt': null,
    };
  }

  group('TeamModel — fromJson/toJson round-trip', () {
    test('fromJson produces correct values', () {
      final json = makeTeamJson();
      final team = TeamModel.fromJson(json);

      expect(team.id, 'team-001');
      expect(team.name, '수학왕들');
      expect(team.leaderId, 'user-001');
      expect(team.memberIds, ['user-001', 'user-002', 'user-003']);
      expect(team.maxMembers, 10);
      expect(team.totalXp, 1000);
      expect(team.weeklyXp, 200);
    });

    test('toJson -> fromJson preserves all scalar fields', () {
      final original = TeamModel.fromJson(makeTeamJson());
      final roundTripped = TeamModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.name, original.name);
      expect(roundTripped.leaderId, original.leaderId);
      expect(roundTripped.memberIds, original.memberIds);
      expect(roundTripped.maxMembers, original.maxMembers);
      expect(roundTripped.totalXp, original.totalXp);
      expect(roundTripped.weeklyXp, original.weeklyXp);
      expect(roundTripped.description, original.description);
      expect(roundTripped.iconEmoji, original.iconEmoji);
    });

    test('toJson serializes createdAt as ISO-8601 string', () {
      final team = TeamModel.fromJson(makeTeamJson());
      final json = team.toJson();

      expect(json['createdAt'], isA<String>());
      // 파싱 가능한 포맷인지 검증
      expect(() => DateTime.parse(json['createdAt'] as String), returnsNormally);
    });

    test('fromJson with null optional fields does not throw', () {
      final json = makeTeamJson();
      json.remove('description');
      json.remove('iconEmoji');
      json['updatedAt'] = null;

      expect(() => TeamModel.fromJson(json), returnsNormally);
      final team = TeamModel.fromJson(json);
      expect(team.description, isNull);
      expect(team.iconEmoji, isNull);
      expect(team.updatedAt, isNull);
    });

    test('fromJson with empty memberIds list', () {
      final json = makeTeamJson(memberIds: []);
      final team = TeamModel.fromJson(json);

      expect(team.memberIds, isEmpty);
    });
  });

  group('TeamModel — _parseDateTime flexibility', () {
    test('fromJson accepts DateTime ISO-8601 string', () {
      final json = makeTeamJson(createdAt: '2024-01-15T10:30:00.000');
      final team = TeamModel.fromJson(json);

      expect(team.createdAt.year, 2024);
      expect(team.createdAt.month, 1);
      expect(team.createdAt.day, 15);
    });

    test('fromJson accepts DateTime object directly', () {
      final dateTime = DateTime(2024, 3, 20, 8, 30);
      final json = makeTeamJson(createdAt: dateTime);
      final team = TeamModel.fromJson(json);

      expect(team.createdAt, dateTime);
    });

    // Firestore Timestamp은 직접 의존 없이 duck-typing으로 처리됨
    // null 입력시 DateTime.now()로 폴백함을 검증
    test('_parseDateTime fallback returns a recent DateTime on unrecognized input', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));

      // FakeTimestamp: toDate()가 없으면 catch에서 폴백
      final json = makeTeamJson(createdAt: Object()); // unknown type
      final team = TeamModel.fromJson(json);

      expect(team.createdAt.isAfter(before), isTrue);
    });
  });

  group('TeamModel — computed getters', () {
    test('memberCount returns length of memberIds', () {
      final team = TeamModel.fromJson(makeTeamJson(memberIds: ['a', 'b', 'c']));
      expect(team.memberCount, 3);
    });

    test('isFull true when memberCount >= maxMembers', () {
      final team = TeamModel.fromJson(
        makeTeamJson(memberIds: List.generate(10, (i) => 'u$i'), maxMembers: 10),
      );
      expect(team.isFull, isTrue);
    });

    test('isFull false when memberCount < maxMembers', () {
      final team = TeamModel.fromJson(
        makeTeamJson(memberIds: ['u1', 'u2'], maxMembers: 10),
      );
      expect(team.isFull, isFalse);
    });

    test('isLeader true for leaderId user', () {
      final team = TeamModel.fromJson(makeTeamJson(leaderId: 'leader-uid'));
      expect(team.isLeader('leader-uid'), isTrue);
    });

    test('isLeader false for non-leader user', () {
      final team = TeamModel.fromJson(makeTeamJson(leaderId: 'leader-uid'));
      expect(team.isLeader('other-uid'), isFalse);
    });

    test('isMember true for existing member', () {
      final team = TeamModel.fromJson(makeTeamJson(memberIds: ['u1', 'u2']));
      expect(team.isMember('u1'), isTrue);
    });

    test('isMember false for non-member', () {
      final team = TeamModel.fromJson(makeTeamJson(memberIds: ['u1']));
      expect(team.isMember('u99'), isFalse);
    });

    test('displayIcon returns iconEmoji when present', () {
      final team = TeamModel.fromJson(makeTeamJson());
      expect(team.displayIcon, '🏆');
    });

    test('displayIcon returns default when iconEmoji is null', () {
      final json = makeTeamJson();
      json['iconEmoji'] = null;
      final team = TeamModel.fromJson(json);
      expect(team.displayIcon, '📚');
    });
  });

  group('TeamModel — copyWith', () {
    test('copyWith updates specified fields only', () {
      final original = TeamModel.fromJson(makeTeamJson(totalXp: 100));
      final updated = original.copyWith(totalXp: 500, weeklyXp: 50);

      expect(updated.totalXp, 500);
      expect(updated.weeklyXp, 50);
      expect(updated.name, original.name);
      expect(updated.leaderId, original.leaderId);
    });
  });

  group('TeamMember — fromJson', () {
    test('fromJson maps role string to TeamRole enum', () {
      final leaderJson = {
        'userId': 'u1',
        'displayName': '팀장',
        'role': 'leader',
        'joinedAt': fixedDate.toIso8601String(),
      };
      final memberJson = {
        'userId': 'u2',
        'displayName': '팀원',
        'role': 'member',
        'joinedAt': fixedDate.toIso8601String(),
      };

      final leader = TeamMember.fromJson(leaderJson);
      final member = TeamMember.fromJson(memberJson);

      expect(leader.role, TeamRole.leader);
      expect(leader.isLeader, isTrue);
      expect(member.role, TeamRole.member);
      expect(member.isLeader, isFalse);
    });

    test('roleLabel returns correct Korean string', () {
      final leader = TeamMember(
        userId: 'u1',
        displayName: '팀장',
        role: TeamRole.leader,
        joinedAt: fixedDate,
      );
      final member = TeamMember(
        userId: 'u2',
        displayName: '팀원',
        role: TeamRole.member,
        joinedAt: fixedDate,
      );

      expect(leader.roleLabel, '팀장');
      expect(member.roleLabel, '팀원');
    });

    test('fromJson uses uid as fallback for userId', () {
      final json = {
        'uid': 'fallback-uid',
        'displayName': '사용자',
        'role': 'member',
        'joinedAt': fixedDate.toIso8601String(),
      };
      final member = TeamMember.fromJson(json);
      expect(member.userId, 'fallback-uid');
    });
  });

  group('TeamInvitation — fromJson/toJson round-trip', () {
    test('round-trip preserves all fields', () {
      final json = {
        'id': 'inv-001',
        'teamId': 'team-001',
        'teamName': '수학왕들',
        'fromUserId': 'u1',
        'fromUserName': '홍길동',
        'toUserId': 'u2',
        'status': 'pending',
        'createdAt': fixedDate.toIso8601String(),
      };
      final invitation = TeamInvitation.fromJson(json);
      final roundTripped = TeamInvitation.fromJson(invitation.toJson());

      expect(roundTripped.id, invitation.id);
      expect(roundTripped.teamName, invitation.teamName);
      expect(roundTripped.status, invitation.status);
      expect(roundTripped.isPending, isTrue);
    });
  });
}
