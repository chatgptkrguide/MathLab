import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/friend_model.dart';

void main() {
  final fixedDate = DateTime(2024, 5, 10, 14, 0);

  // FriendModel 픽스처
  Map<String, dynamic> makeFriendJson({
    String id = 'fr-001',
    String userId = 'me',
    String friendId = 'friend-1',
    String friendName = '김철수',
    String status = 'accepted',
  }) {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatar': null,
      'status': status,
      'createdAt': fixedDate.toIso8601String(),
      'acceptedAt': null,
    };
  }

  group('FriendModel — fromJson/toJson round-trip', () {
    test('fromJson produces correct values', () {
      final model = FriendModel.fromJson(makeFriendJson());

      expect(model.id, 'fr-001');
      expect(model.friendName, '김철수');
      expect(model.status, FriendshipStatus.accepted);
    });

    test('toJson -> fromJson preserves all fields', () {
      final original = FriendModel.fromJson(makeFriendJson());
      final roundTripped = FriendModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.userId, original.userId);
      expect(roundTripped.friendId, original.friendId);
      expect(roundTripped.friendName, original.friendName);
      expect(roundTripped.status, original.status);
    });

    test('toJson serializes status as string name', () {
      final model = FriendModel.fromJson(makeFriendJson(status: 'pending'));
      final json = model.toJson();

      expect(json['status'], 'pending');
    });
  });

  group('FriendModel — FriendshipStatus enum', () {
    test('accepted status maps correctly', () {
      final model = FriendModel.fromJson(makeFriendJson(status: 'accepted'));
      expect(model.status, FriendshipStatus.accepted);
      expect(model.isActive, isTrue);
      expect(model.isPending, isFalse);
    });

    test('pending status maps correctly', () {
      final model = FriendModel.fromJson(makeFriendJson(status: 'pending'));
      expect(model.status, FriendshipStatus.pending);
      expect(model.isPending, isTrue);
      expect(model.isActive, isFalse);
    });

    test('blocked status maps correctly', () {
      final model = FriendModel.fromJson(makeFriendJson(status: 'blocked'));
      expect(model.status, FriendshipStatus.blocked);
      expect(model.isActive, isFalse);
      expect(model.isPending, isFalse);
    });

    test('unknown status falls back to pending', () {
      final model = FriendModel.fromJson(makeFriendJson(status: 'INVALID'));
      expect(model.status, FriendshipStatus.pending);
    });
  });

  group('FriendModel — statusLabel', () {
    test('returns correct Korean label for each status', () {
      expect(
        FriendModel.fromJson(makeFriendJson(status: 'accepted')).statusLabel,
        '친구',
      );
      expect(
        FriendModel.fromJson(makeFriendJson(status: 'pending')).statusLabel,
        '대기중',
      );
      expect(
        FriendModel.fromJson(makeFriendJson(status: 'blocked')).statusLabel,
        '차단됨',
      );
    });
  });

  group('FriendModel — copyWith', () {
    test('copyWith updates status correctly', () {
      final pending = FriendModel.fromJson(makeFriendJson(status: 'pending'));
      final accepted = pending.copyWith(status: FriendshipStatus.accepted);

      expect(accepted.status, FriendshipStatus.accepted);
      expect(accepted.friendName, pending.friendName);
    });
  });

  group('FriendRequestModel — fromJson/toJson round-trip', () {
    Map<String, dynamic> makeRequestJson({String status = 'pending'}) => {
          'id': 'req-001',
          'fromUserId': 'u1',
          'fromUserName': '발신자',
          'fromUserAvatar': null,
          'toUserId': 'u2',
          'status': status,
          'createdAt': fixedDate.toIso8601String(),
          'respondedAt': null,
        };

    test('fromJson produces correct values', () {
      final req = FriendRequestModel.fromJson(makeRequestJson());

      expect(req.fromUserId, 'u1');
      expect(req.toUserId, 'u2');
      expect(req.status, RequestStatus.pending);
      expect(req.isPending, isTrue);
    });

    test('toJson -> fromJson round-trip preserves status', () {
      final original = FriendRequestModel.fromJson(makeRequestJson(status: 'accepted'));
      final roundTripped = FriendRequestModel.fromJson(original.toJson());

      expect(roundTripped.status, RequestStatus.accepted);
      expect(roundTripped.isPending, isFalse);
    });

    test('rejected status round-trips correctly', () {
      final req = FriendRequestModel.fromJson(makeRequestJson(status: 'rejected'));
      expect(req.status, RequestStatus.rejected);
    });
  });

  group('FriendActivityModel — fromJson/toJson', () {
    test('fromJson maps ActivityType enum correctly', () {
      final json = {
        'id': 'act-001',
        'userId': 'u1',
        'userName': '사용자',
        'userAvatar': null,
        'type': 'lessonCompleted',
        'description': '레슨 완료',
        'metadata': null,
        'timestamp': fixedDate.toIso8601String(),
      };
      final activity = FriendActivityModel.fromJson(json);

      expect(activity.type, ActivityType.lessonCompleted);
      expect(activity.activityIcon, '✅');
    });

    test('unknown ActivityType falls back to other', () {
      final json = {
        'id': 'act-002',
        'userId': 'u1',
        'userName': '사용자',
        'type': 'UNKNOWN_TYPE',
        'description': '기타',
        'timestamp': fixedDate.toIso8601String(),
      };
      final activity = FriendActivityModel.fromJson(json);

      expect(activity.type, ActivityType.other);
      expect(activity.activityIcon, '📌');
    });

    test('toJson -> fromJson round-trip preserves type', () {
      final json = {
        'id': 'act-003',
        'userId': 'u2',
        'userName': '테스터',
        'type': 'streakMilestone',
        'description': '7일 연속!',
        'timestamp': fixedDate.toIso8601String(),
      };
      final original = FriendActivityModel.fromJson(json);
      final roundTripped = FriendActivityModel.fromJson(original.toJson());

      expect(roundTripped.type, ActivityType.streakMilestone);
      expect(roundTripped.activityIcon, '🔥');
    });
  });
}
