import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/logger.dart';
import '../../models/user/user.dart' as user_model;

/// 그룹 학습 모델
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> memberIds;
  final int memberCount;
  final int maxMembers;
  final String grade;
  final DateTime createdAt;
  final String? groupImageUrl;
  final int totalXp;
  final int totalProblemsCompleted;
  final bool isPublic;
  final DateTime? lastActivityAt;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.memberIds,
    required this.memberCount,
    required this.maxMembers,
    required this.grade,
    required this.isPublic,
    required this.createdAt,
    required this.totalXp,
    required this.totalProblemsCompleted,
    this.groupImageUrl,
    this.lastActivityAt,
  });

  factory StudyGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyGroup(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      memberCount: data['memberCount'] ?? 0,
      maxMembers: data['maxMembers'] ?? 10,
      grade: data['grade'] ?? '중1',
      isPublic: data['isPublic'] ?? true,
      totalXp: data['totalXp'] ?? 0,
      totalProblemsCompleted: data['totalProblemsCompleted'] ?? 0,
      groupImageUrl: data['groupImageUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActivityAt: data['lastActivityAt'] != null
          ? (data['lastActivityAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'grade': grade,
      'isPublic': isPublic,
      'totalXp': totalXp,
      'totalProblemsCompleted': totalProblemsCompleted,
      'groupImageUrl': groupImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivityAt':
          lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
    };
  }
}

/// 그룹 학습 Provider
class StudyGroupProvider extends StateNotifier<AsyncValue<List<StudyGroup>>> {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  StudyGroupProvider({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        super(const AsyncValue.loading()) {
    _initialize();
  }

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<void> _initialize() async {
    try {
      await loadMyGroups();
    } catch (e, stack) {
      Logger.error('그룹 로드 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 내 그룹 목록 로드
  Future<void> loadMyGroups() async {
    if (_currentUserId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();

      final groups = await _firestore
          .collection('study_groups')
          .where('memberIds', arrayContains: _currentUserId)
          .orderBy('lastActivityAt', descending: true)
          .get();

      final groupList = groups.docs
          .map((doc) => StudyGroup.fromFirestore(doc))
          .toList();

      state = AsyncValue.data(groupList);
      Logger.info('그룹 목록 로드 완료: ${groupList.length}개');
    } catch (e, stack) {
      Logger.error('그룹 목록 로드 실패', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 그룹 생성
  Future<String?> createStudyGroup({
    required String name,
    required String description,
    required String grade,
    int maxMembers = 10,
  }) async {
    if (_currentUserId == null) return null;

    try {
      // 현재 사용자 정보
      final userDoc =
          await _firestore.collection('users').doc(_currentUserId).get();
      final user = user_model.User.fromFirestore(userDoc);

      // 그룹 생성
      final groupData = {
        'name': name,
        'description': description,
        'creatorId': _currentUserId,
        'creatorName': user.name,
        'memberIds': [_currentUserId],
        'memberCount': 1,
        'maxMembers': maxMembers,
        'grade': grade,
        'isPublic': true,
        'totalXp': 0,
        'totalProblemsCompleted': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('study_groups').add(groupData);

      await Logger.analytics('study_group_created', parameters: {
        'group_id': docRef.id,
        'max_members': maxMembers,
      });

      await loadMyGroups();

      return docRef.id;
    } catch (e, stack) {
      Logger.error('그룹 생성 실패', error: e, stackTrace: stack);
      return null;
    }
  }

  /// 그룹 가입
  Future<bool> joinGroup(String groupId) async {
    if (_currentUserId == null) return false;

    try {
      final groupDoc =
          await _firestore.collection('study_groups').doc(groupId).get();

      if (!groupDoc.exists) return false;

      final data = groupDoc.data()!;
      final memberIds = List<String>.from(data['memberIds'] ?? []);
      final maxMembers = data['maxMembers'] as int;

      // 이미 가입되어 있는지 확인
      if (memberIds.contains(_currentUserId)) {
        return true;
      }

      // 정원 확인
      if (memberIds.length >= maxMembers) {
        Logger.warning('그룹이 가득 찼습니다');
        return false;
      }

      // 멤버 추가
      await _firestore.collection('study_groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([_currentUserId]),
        'memberCount': FieldValue.increment(1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      await Logger.analytics('study_group_joined', parameters: {
        'group_id': groupId,
      });

      await loadMyGroups();

      return true;
    } catch (e, stack) {
      Logger.error('그룹 가입 실패', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 그룹 탈퇴
  Future<bool> leaveGroup(String groupId) async {
    if (_currentUserId == null) return false;

    try {
      await _firestore.collection('study_groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([_currentUserId]),
        'memberCount': FieldValue.increment(-1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      await Logger.analytics('study_group_left', parameters: {
        'group_id': groupId,
      });

      await loadMyGroups();

      return true;
    } catch (e, stack) {
      Logger.error('그룹 탈퇴 실패', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 그룹 목록 스트림
  Stream<List<StudyGroup>> getGroups() {
    return _firestore
        .collection('study_groups')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudyGroup.fromFirestore(doc))
            .toList());
  }

  /// 내 그룹 목록 스트림
  Stream<List<StudyGroup>> getMyGroups() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('study_groups')
        .where('memberIds', arrayContains: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudyGroup.fromFirestore(doc))
            .toList());
  }

  /// 그룹 상세 정보 스트림
  Stream<StudyGroup?> getGroupDetails(String groupId) {
    return _firestore
        .collection('study_groups')
        .doc(groupId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return StudyGroup.fromFirestore(doc);
    });
  }
}

/// Provider 정의
final studyGroupProvider =
    StateNotifierProvider<StudyGroupProvider, AsyncValue<List<StudyGroup>>>(
        (ref) {
  return StudyGroupProvider();
});

/// 내가 속한 그룹 목록 (실시간 업데이트)
final myGroupsProvider = StreamProvider<List<StudyGroup>>((ref) {
  final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('study_groups')
      .where('memberIds', arrayContains: currentUserId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => StudyGroup.fromFirestore(doc)).toList();
  });
});

/// 그룹 멤버 목록
final groupMembersProvider =
    FutureProvider.family<List<user_model.User>, String>((ref, groupId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final groupDoc = await firestore.collection('study_groups').doc(groupId).get();
    if (!groupDoc.exists) return [];

    final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);

    if (memberIds.isEmpty) return [];

    // 멤버 정보 가져오기 (배치로 10명씩)
    final List<user_model.User> members = [];
    for (var i = 0; i < memberIds.length; i += 10) {
      final batch = memberIds.skip(i).take(10).toList();
      final usersSnapshot = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      members.addAll(
        usersSnapshot.docs.map((doc) => user_model.User.fromFirestore(doc)),
      );
    }

    return members;
  } catch (e, stack) {
    Logger.error('그룹 멤버 로드 실패', error: e, stackTrace: stack);
    return [];
  }
});

/// 그룹 상세 정보
final groupDetailsProvider =
    StreamProvider.family<StudyGroup?, String>((ref, groupId) {
  return FirebaseFirestore.instance
      .collection('study_groups')
      .doc(groupId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return StudyGroup.fromFirestore(doc);
  });
});
