/// 앱 환경 설정
///
/// 개발/스테이징/프로덕션 환경별 설정 관리
class AppConfig {
  // Singleton 패턴
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// 현재 환경
  AppEnvironment _environment = AppEnvironment.development;
  AppEnvironment get environment => _environment;

  /// 환경 설정
  void setEnvironment(AppEnvironment env) {
    _environment = env;
  }

  /// API Base URL
  String get apiBaseUrl {
    switch (_environment) {
      case AppEnvironment.development:
        return 'http://localhost:3000';
      case AppEnvironment.staging:
        return 'https://staging-api.mathlab.com';
      case AppEnvironment.production:
        return 'https://api.mathlab.com';
    }
  }

  /// API 버전
  String get apiVersion => 'v1';

  /// 전체 API URL
  String get fullApiUrl => '$apiBaseUrl/api/$apiVersion';

  /// 타임아웃 설정 (초)
  Duration get connectTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);
  Duration get sendTimeout => const Duration(seconds: 30);

  /// 재시도 설정
  int get maxRetries => 3;
  Duration get retryDelay => const Duration(seconds: 2);

  /// 로깅 활성화
  bool get enableLogging {
    switch (_environment) {
      case AppEnvironment.development:
        return true;
      case AppEnvironment.staging:
        return true;
      case AppEnvironment.production:
        return false;
    }
  }

  /// Firebase 설정
  Map<String, String> get firebaseConfig {
    switch (_environment) {
      case AppEnvironment.development:
        return {
          'projectId': 'mathlab-dev',
          'storageBucket': 'mathlab-dev.appspot.com',
        };
      case AppEnvironment.staging:
        return {
          'projectId': 'mathlab-staging',
          'storageBucket': 'mathlab-staging.appspot.com',
        };
      case AppEnvironment.production:
        return {
          'projectId': 'mathlab-prod',
          'storageBucket': 'mathlab-prod.appspot.com',
        };
    }
  }

  /// Analytics 활성화
  bool get enableAnalytics => _environment == AppEnvironment.production;

  /// Crash Reporting 활성화
  bool get enableCrashReporting => _environment != AppEnvironment.development;

  /// 디버그 모드
  bool get isDebug => _environment == AppEnvironment.development;

  /// 환경 이름
  String get environmentName {
    switch (_environment) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  /// 환경별 앱 이름
  String get appName {
    switch (_environment) {
      case AppEnvironment.development:
        return 'MathLab (Dev)';
      case AppEnvironment.staging:
        return 'MathLab (Staging)';
      case AppEnvironment.production:
        return 'MathLab';
    }
  }
}

/// 앱 환경 타입
enum AppEnvironment {
  development,
  staging,
  production,
}
