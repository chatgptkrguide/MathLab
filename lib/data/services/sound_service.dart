import 'package:just_audio/just_audio.dart';
import '../../shared/utils/logger.dart';

/// 사운드 효과 서비스
/// Duolingo 스타일의 게이미피케이션 사운드 제공
class SoundService {
  // 싱글톤 패턴
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // 오디오 플레이어 풀
  final Map<SoundType, AudioPlayer> _players = {};

  // 사운드 활성화 여부
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  /// 초기화
  Future<void> initialize() async {
    try {
      // 각 사운드 타입별로 플레이어 생성
      for (final type in SoundType.values) {
        _players[type] = AudioPlayer();
      }
      Logger.info('SoundService initialized', tag: 'SoundService');
    } catch (e) {
      Logger.error('Failed to initialize SoundService', error: e);
    }
  }

  /// 사운드 효과 재생
  Future<void> play(SoundType type) async {
    if (!_soundEnabled) return;

    try {
      final player = _players[type];
      if (player == null) return;

      // 이미 재생 중이면 정지하고 처음부터 재생
      await player.stop();
      await player.seek(Duration.zero);
      await player.setAsset(type.assetPath);
      await player.play();

      Logger.debug('Playing sound: ${type.name}', tag: 'SoundService');
    } catch (e) {
      Logger.error('Failed to play sound: ${type.name}', error: e);
    }
  }

  /// 배경 음악 재생 (반복)
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      final player = _players[SoundType.background];
      if (player == null) return;

      await player.setAsset(SoundType.background.assetPath);
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(0.3); // 배경 음악은 볼륨 낮춤
      await player.play();

      Logger.info('Background music started', tag: 'SoundService');
    } catch (e) {
      Logger.error('Failed to play background music', error: e);
    }
  }

  /// 배경 음악 정지
  Future<void> stopBackgroundMusic() async {
    try {
      final player = _players[SoundType.background];
      await player?.stop();
      Logger.info('Background music stopped', tag: 'SoundService');
    } catch (e) {
      Logger.error('Failed to stop background music', error: e);
    }
  }

  /// 사운드 활성화/비활성화
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    Logger.info('Sound ${enabled ? 'enabled' : 'disabled'}',
        tag: 'SoundService');
  }

  /// 배경 음악 활성화/비활성화
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
    Logger.info('Music ${enabled ? 'enabled' : 'disabled'}',
        tag: 'SoundService');
  }

  /// 사운드 활성화 상태
  bool get soundEnabled => _soundEnabled;

  /// 음악 활성화 상태
  bool get musicEnabled => _musicEnabled;

  /// 정리
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    Logger.info('SoundService disposed', tag: 'SoundService');
  }
}

/// 사운드 타입
enum SoundType {
  // 정답/오답
  correct('assets/sounds/correct.mp3'),
  wrong('assets/sounds/wrong.mp3'),

  // XP 및 레벨
  xpGain('assets/sounds/xp_gain.mp3'),
  levelUp('assets/sounds/level_up.mp3'),

  // 업적 및 보상
  achievement('assets/sounds/achievement.mp3'),
  rewardClaim('assets/sounds/reward_claim.mp3'),

  // 스트릭
  streakMaintain('assets/sounds/streak_maintain.mp3'),
  streakBreak('assets/sounds/streak_break.mp3'),

  // UI 상호작용
  buttonClick('assets/sounds/button_click.mp3'),
  buttonHover('assets/sounds/button_hover.mp3'),

  // 하트
  heartLose('assets/sounds/heart_lose.mp3'),
  heartRecover('assets/sounds/heart_recover.mp3'),

  // 문제 풀이
  problemStart('assets/sounds/problem_start.mp3'),
  problemComplete('assets/sounds/problem_complete.mp3'),
  hintUsed('assets/sounds/hint_used.mp3'),

  // 축하
  celebration('assets/sounds/celebration.mp3'),
  confetti('assets/sounds/confetti.mp3'),

  // 배경 음악 (선택사항)
  background('assets/sounds/background_music.mp3');

  const SoundType(this.assetPath);
  final String assetPath;
}

/// 사운드 효과 헬퍼 (쉬운 사용을 위한 래퍼)
class SoundEffects {
  static final _service = SoundService();

  static Future<void> playCorrect() => _service.play(SoundType.correct);
  static Future<void> playWrong() => _service.play(SoundType.wrong);
  static Future<void> playXPGain() => _service.play(SoundType.xpGain);
  static Future<void> playLevelUp() => _service.play(SoundType.levelUp);
  static Future<void> playAchievement() => _service.play(SoundType.achievement);
  static Future<void> playStreakMaintain() =>
      _service.play(SoundType.streakMaintain);
  static Future<void> playStreakBreak() => _service.play(SoundType.streakBreak);
  static Future<void> playButtonClick() => _service.play(SoundType.buttonClick);
  static Future<void> playHeartLose() => _service.play(SoundType.heartLose);
  static Future<void> playHeartRecover() =>
      _service.play(SoundType.heartRecover);
  static Future<void> playCelebration() => _service.play(SoundType.celebration);
}
