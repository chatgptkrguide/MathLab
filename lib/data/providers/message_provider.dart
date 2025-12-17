import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'base/base_notifier.dart';
import 'auth_provider.dart';

/// 메시지 상태 관리 (BaseNotifier 최적화 버전)
class MessageNotifier extends BaseNotifier<List<Message>> {
  final Ref ref;

  MessageNotifier(this.ref) : super([], 'MessageProvider') {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      logWarning('No logged in account');
      return null;
    }
    return 'messages_${currentAccount.id}';
  }

  /// 초기화 및 데이터 로드
  Future<void> _initialize() async {
    await _loadMessages();
  }

  /// 메시지 로드
  Future<void> _loadMessages() async {
    try {
      final key = _storageKey;
      if (key == null) {
        // 로그인된 계정 없음 - 빈 상태로 초기화
        state = [];
        return;
      }

      final messages = await loadList<Message>(
        key: key,
        fromJson: Message.fromJson,
      );

      if (messages.isNotEmpty) {
        state = messages;
        logInfo('메시지 ${messages.length}개 로드 완료');
      } else {
        // 초기 샘플 메시지 생성
        _createInitialMessages();
      }
    } catch (e) {
      logError('메시지 로드 실패', error: e);
      _createInitialMessages();
    }
  }

  /// 초기 샘플 메시지 생성
  void _createInitialMessages() {
    final now = DateTime.now();

    final initialMessages = [
      Message(
        id: 'welcome_1',
        type: MessageType.system,
        senderId: 'system',
        senderName: 'MathLab',
        title: '🎉 MathLab에 오신 것을 환영합니다!',
        body: '매일 수학 문제를 풀고 스트릭을 유지하세요. 꾸준한 학습이 실력 향상의 지름길입니다!',
        actionText: '시작하기',
        actionRoute: '/home',
        isImportant: true,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Message(
        id: 'tip_1',
        type: MessageType.system,
        senderId: 'system',
        senderName: 'MathLab',
        title: '💡 학습 팁',
        body: '매일 같은 시간에 학습하면 습관을 만들기 쉬워요. 알림 설정을 활용해보세요!',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    state = initialMessages;
    _saveMessages();
    logInfo('초기 메시지 생성 완료');
  }

  /// 메시지 저장
  Future<void> _saveMessages() async {
    try {
      final key = _storageKey;
      if (key == null) {
        logWarning('Cannot save messages - no logged in account');
        return;
      }

      await saveList<Message>(
        key: key,
        items: state,
        toJson: (message) => message.toJson(),
      );
      logDebug('메시지 저장 완료');
    } catch (e) {
      logError('메시지 저장 실패', error: e);
    }
  }

  /// 새 메시지 추가
  Future<void> addMessage(Message message) async {
    state = [message, ...state];
    await _saveMessages();
    logInfo('새 메시지 추가: ${message.title}');

    // 중요한 메시지는 푸시 알림 전송
    if (message.isImportant && !message.isRead) {
      _sendNotification(message);
    }
  }

  /// 메시지 읽음 표시
  Future<void> markAsRead(String messageId) async {
    final index = state.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final updatedMessage = state[index].copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );

    state = [
      ...state.sublist(0, index),
      updatedMessage,
      ...state.sublist(index + 1),
    ];

    await _saveMessages();
    logDebug('메시지 읽음 표시: $messageId');
  }

  /// 모든 메시지 읽음 표시
  Future<void> markAllAsRead() async {
    final now = DateTime.now();
    state = state.map((message) {
      if (!message.isRead) {
        return message.copyWith(isRead: true, readAt: now);
      }
      return message;
    }).toList();

    await _saveMessages();
    logInfo('모든 메시지 읽음 표시');
  }

  /// 메시지 삭제
  Future<void> deleteMessage(String messageId) async {
    state = state.where((m) => m.id != messageId).toList();
    await _saveMessages();
    logInfo('메시지 삭제: $messageId');
  }

  /// 타입별 메시지 가져오기
  List<Message> getMessagesByType(MessageType type) {
    return state.where((m) => m.type == type).toList();
  }

  /// 읽지 않은 메시지 개수
  int get unreadCount => state.where((m) => !m.isRead).length;

  /// 읽지 않은 메시지 목록
  List<Message> get unreadMessages => state.where((m) => !m.isRead).toList();

  /// 중요 메시지 목록
  List<Message> get importantMessages => state.where((m) => m.isImportant).toList();

  /// 푸시 알림 전송
  void _sendNotification(Message message) {
    try {
      // TODO: Firebase Cloud Messaging을 통한 실제 푸시 알림 구현
      logInfo('푸시 알림 전송: ${message.title}');
    } catch (e) {
      logError('푸시 알림 전송 실패', error: e);
    }
  }

  /// 스트릭 메시지 생성
  Future<void> createStreakMessage(int streakDays) async {
    String title;
    String body;
    bool isImportant = false;

    if (streakDays == 1) {
      title = '🔥 첫 스트릭 시작!';
      body = '오늘부터 연속 학습을 시작했어요. 내일도 이어서 학습해보세요!';
    } else if (streakDays == 7) {
      title = '🔥 7일 연속 학습 달성!';
      body = '일주일 동안 꾸준히 학습했어요. 대단해요!';
      isImportant = true;
    } else if (streakDays == 30) {
      title = '🔥 30일 연속 학습 달성!';
      body = '한 달 동안 하루도 빠짐없이 학습했어요. 정말 대단합니다!';
      isImportant = true;
    } else if (streakDays == 100) {
      title = '🔥 100일 연속 학습 달성!';
      body = '100일 동안 꾸준히 학습한 당신은 진정한 수학 마스터입니다!';
      isImportant = true;
    } else if (streakDays % 10 == 0) {
      title = '🔥 ${streakDays}일 연속 학습!';
      body = '${streakDays}일 동안 꾸준히 학습했어요. 계속 유지해보세요!';
    } else {
      return; // 특별한 날이 아니면 메시지 생성 안 함
    }

    final message = Message(
      id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.streak,
      senderId: 'system',
      senderName: 'MathLab',
      title: title,
      body: body,
      actionText: '계속 학습하기',
      actionRoute: '/home',
      isImportant: isImportant,
      createdAt: DateTime.now(),
    );

    await addMessage(message);
  }

  /// 업적 메시지 생성
  Future<void> createAchievementMessage({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    final message = Message(
      id: 'achievement_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.achievement,
      senderId: 'system',
      senderName: 'MathLab',
      title: '🏆 새로운 업적 달성!',
      body: '$achievementTitle을(를) 달성했어요! $achievementDescription',
      actionText: '업적 보기',
      actionRoute: '/achievements',
      isImportant: true,
      createdAt: DateTime.now(),
    );

    await addMessage(message);
  }

  /// 리그 승급/강등 메시지 생성
  Future<void> createLeagueMessage({
    required String leagueName,
    required bool isPromotion,
  }) async {
    final message = Message(
      id: 'league_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.league,
      senderId: 'system',
      senderName: 'MathLab',
      title: isPromotion ? '⬆️ 리그 승급!' : '⬇️ 리그 강등',
      body: isPromotion
          ? '$leagueName 리그로 승급했어요! 축하합니다!'
          : '$leagueName 리그로 강등되었어요. 다음 주에 다시 도전해보세요!',
      actionText: '리그 보기',
      actionRoute: '/league',
      isImportant: true,
      createdAt: DateTime.now(),
    );

    await addMessage(message);
  }
}

/// 메시지 Provider
final messageProvider = StateNotifierProvider<MessageNotifier, List<Message>>(
  (ref) => MessageNotifier(ref),
);

/// 읽지 않은 메시지 개수 Provider
final unreadMessageCountProvider = Provider<int>((ref) {
  final messages = ref.watch(messageProvider);
  return messages.where((m) => !m.isRead).length;
});
