import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../shared/utils/logger.dart';

// 에러 타입 분류
enum NetworkErrorType {
  noConnection,      // 인터넷 연결 없음
  timeout,          // 요청 시간 초과
  serverError,      // 서버 오류 (5xx)
  clientError,      // 클라이언트 오류 (4xx)
  unauthorized,     // 인증 실패
  rateLimited,      // Rate limit 초과
  parseError,       // 데이터 파싱 오류
  cancelled,        // 요청 취소됨
  unknown,          // 알 수 없는 오류
}

/// 네트워크 에러 정보
class NetworkError {
  final NetworkErrorType type;
  final String message;
  final String userMessage;
  final int? statusCode;
  final dynamic originalError;
  final bool isRetryable;
  final Duration? retryAfter;

  const NetworkError({
    required this.type,
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.originalError,
    this.isRetryable = false,
    this.retryAfter,
  });

  /// 사용자에게 표시할 메시지 (한국어)
  String get localizedMessage {
    switch (type) {
      case NetworkErrorType.noConnection:
        return '인터넷 연결을 확인해주세요 📶';
      case NetworkErrorType.timeout:
        return '서버 응답이 느립니다. 잠시 후 다시 시도해주세요 ⏱️';
      case NetworkErrorType.serverError:
        return '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요 🔧';
      case NetworkErrorType.clientError:
        if (statusCode == 404) {
          return '요청한 정보를 찾을 수 없습니다 🔍';
        }
        return '요청을 처리할 수 없습니다. 다시 시도해주세요 ❌';
      case NetworkErrorType.unauthorized:
        return '로그인이 필요합니다. 다시 로그인해주세요 🔐';
      case NetworkErrorType.rateLimited:
        return '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요 ⏳';
      case NetworkErrorType.parseError:
        return '데이터 처리 중 오류가 발생했습니다 📊';
      case NetworkErrorType.cancelled:
        return '요청이 취소되었습니다 ⛔';
      case NetworkErrorType.unknown:
      default:
        return '알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요 ❓';
    }
  }

  /// 액션 버튼 텍스트
  String get actionButtonText {
    if (isRetryable) {
      return '다시 시도';
    }
    switch (type) {
      case NetworkErrorType.noConnection:
        return '설정으로 이동';
      case NetworkErrorType.unauthorized:
        return '다시 로그인';
      default:
        return '확인';
    }
  }
}

/// 네트워크 에러 처리 서비스
///
/// 네트워크 관련 에러를 체계적으로 처리하고 사용자 친화적인 메시지를 제공
/// 재시도 로직, 백오프 전략, 오프라인 큐 관리 기능 포함
class NetworkErrorHandler {
  static const String _tag = 'NetworkError';

  // 재시도 설정
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const double backoffMultiplier = 2.0;
  static const Duration maxRetryDelay = Duration(seconds: 30);

  /// 에러 분석 및 NetworkError 객체 생성
  static NetworkError analyzeError(dynamic error) {
    Logger.error('네트워크 에러 분석', error: error, tag: _tag);

    // DioException 처리
    if (error is DioException) {
      return _analyzeDioError(error);
    }

    // SocketException 처리 (네트워크 연결 없음)
    if (error is SocketException) {
      return NetworkError(
        type: NetworkErrorType.noConnection,
        message: error.message,
        userMessage: '인터넷 연결을 확인해주세요',
        originalError: error,
        isRetryable: true,
      );
    }

    // TimeoutException 처리
    if (error is TimeoutException) {
      return NetworkError(
        type: NetworkErrorType.timeout,
        message: error.message ?? 'Request timeout',
        userMessage: '요청 시간이 초과되었습니다',
        originalError: error,
        isRetryable: true,
      );
    }

    // FormatException 처리 (파싱 오류)
    if (error is FormatException) {
      return NetworkError(
        type: NetworkErrorType.parseError,
        message: error.message,
        userMessage: '데이터 형식 오류',
        originalError: error,
        isRetryable: false,
      );
    }

    // 기타 오류
    return NetworkError(
      type: NetworkErrorType.unknown,
      message: error.toString(),
      userMessage: '알 수 없는 오류가 발생했습니다',
      originalError: error,
      isRetryable: false,
    );
  }

  /// DioException 분석
  static NetworkError _analyzeDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError(
          type: NetworkErrorType.timeout,
          message: error.message ?? 'Timeout',
          userMessage: '연결 시간 초과',
          statusCode: statusCode,
          originalError: error,
          isRetryable: true,
        );

      case DioExceptionType.connectionError:
        return NetworkError(
          type: NetworkErrorType.noConnection,
          message: error.message ?? 'Connection error',
          userMessage: '네트워크 연결 오류',
          statusCode: statusCode,
          originalError: error,
          isRetryable: true,
        );

      case DioExceptionType.badResponse:
        if (statusCode != null) {
          // 4xx 클라이언트 오류
          if (statusCode >= 400 && statusCode < 500) {
            if (statusCode == 401) {
              return NetworkError(
                type: NetworkErrorType.unauthorized,
                message: 'Unauthorized',
                userMessage: '인증 실패',
                statusCode: statusCode,
                originalError: error,
                isRetryable: false,
              );
            } else if (statusCode == 429) {
              // Rate limiting
              final retryAfter = _parseRetryAfter(response?.headers);
              return NetworkError(
                type: NetworkErrorType.rateLimited,
                message: 'Rate limited',
                userMessage: 'API 호출 제한 초과',
                statusCode: statusCode,
                originalError: error,
                isRetryable: true,
                retryAfter: retryAfter,
              );
            } else {
              return NetworkError(
                type: NetworkErrorType.clientError,
                message: 'Client error: $statusCode',
                userMessage: '요청 오류',
                statusCode: statusCode,
                originalError: error,
                isRetryable: false,
              );
            }
          }
          // 5xx 서버 오류
          else if (statusCode >= 500) {
            return NetworkError(
              type: NetworkErrorType.serverError,
              message: 'Server error: $statusCode',
              userMessage: '서버 오류',
              statusCode: statusCode,
              originalError: error,
              isRetryable: true,
            );
          }
        }
        return NetworkError(
          type: NetworkErrorType.unknown,
          message: error.message ?? 'Bad response',
          userMessage: '응답 오류',
          statusCode: statusCode,
          originalError: error,
          isRetryable: false,
        );

      case DioExceptionType.cancel:
        return NetworkError(
          type: NetworkErrorType.cancelled,
          message: 'Request cancelled',
          userMessage: '요청 취소됨',
          statusCode: statusCode,
          originalError: error,
          isRetryable: false,
        );

      case DioExceptionType.badCertificate:
        return NetworkError(
          type: NetworkErrorType.unknown,
          message: 'Bad certificate',
          userMessage: '보안 인증서 오류',
          statusCode: statusCode,
          originalError: error,
          isRetryable: false,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkError(
          type: NetworkErrorType.unknown,
          message: error.message ?? 'Unknown error',
          userMessage: '알 수 없는 오류',
          statusCode: statusCode,
          originalError: error,
          isRetryable: false,
        );
    }
  }

  /// Retry-After 헤더 파싱
  static Duration? _parseRetryAfter(Headers? headers) {
    if (headers == null) return null;

    final retryAfter = headers.value('retry-after');
    if (retryAfter == null) return null;

    // 초 단위로 파싱 시도
    final seconds = int.tryParse(retryAfter);
    if (seconds != null) {
      return Duration(seconds: seconds);
    }

    // HTTP-date 형식 파싱 (예: "Wed, 21 Oct 2025 07:28:00 GMT")
    try {
      final date = HttpDate.parse(retryAfter);
      final now = DateTime.now();
      final diff = date.difference(now);
      return diff.isNegative ? Duration.zero : diff;
    } catch (e) {
      Logger.warning('Retry-After 헤더 파싱 실패: $retryAfter', tag: _tag);
      return null;
    }
  }

  /// 재시도 가능한 요청 실행 (지수 백오프 포함)
  static Future<T> executeWithRetry<T>(
    Future<T> Function() request, {
    int maxRetries = maxRetries,
    Duration initialDelay = initialRetryDelay,
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = initialDelay;
    final random = Random();

    while (attempt <= maxRetries) {
      try {
        return await request();
      } catch (error) {
        attempt++;

        // 재시도 가능 여부 확인
        final networkError = analyzeError(error);
        final canRetry = shouldRetry?.call(error) ?? networkError.isRetryable;

        if (!canRetry || attempt > maxRetries) {
          Logger.error(
            '요청 실패 (재시도 불가 또는 최대 재시도 초과)',
            error: error,
            tag: _tag,
          );
          rethrow;
        }

        // Rate limit의 경우 Retry-After 헤더 우선
        if (networkError.retryAfter != null) {
          currentDelay = networkError.retryAfter!;
        }

        // Jitter 추가 (±25%)
        final jitter = random.nextDouble() * 0.5 - 0.25;
        final delayWithJitter = currentDelay * (1 + jitter);

        Logger.warning(
          '재시도 대기 (시도 $attempt/$maxRetries, 대기 시간: ${delayWithJitter.inSeconds}초)',
          tag: _tag,
        );

        // 콜백 호출
        onRetry?.call(attempt, error);

        // 대기
        await Future.delayed(delayWithJitter);

        // 다음 재시도를 위한 지연 시간 증가 (지수 백오프)
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
        );
        if (currentDelay > maxRetryDelay) {
          currentDelay = maxRetryDelay;
        }
      }
    }

    // 이 코드는 실행되지 않아야 함
    throw Exception('Unexpected retry loop exit');
  }

  /// 네트워크 연결 상태 확인
  static Future<bool> isConnected() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      Logger.error('네트워크 상태 확인 실패', error: e, tag: _tag);
      return false;
    }
  }

  /// 네트워크 상태 스트림
  static Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map((results) {
      return !results.contains(ConnectivityResult.none);
    });
  }

  /// 에러 다이얼로그 표시
  static Future<void> showErrorDialog(
    BuildContext context,
    NetworkError error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: _getErrorColor(error.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getErrorTitle(error.type),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(error.localizedMessage),
        actions: [
          if (onDismiss != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss();
              },
              child: const Text('취소'),
            ),
          if (error.isRetryable && onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(error.actionButtonText),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
        ],
      ),
    );
  }

  /// 에러 타입별 아이콘
  static IconData _getErrorIcon(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return Icons.wifi_off;
      case NetworkErrorType.timeout:
        return Icons.timer_off;
      case NetworkErrorType.serverError:
        return Icons.cloud_off;
      case NetworkErrorType.clientError:
        return Icons.error_outline;
      case NetworkErrorType.unauthorized:
        return Icons.lock_outline;
      case NetworkErrorType.rateLimited:
        return Icons.speed;
      case NetworkErrorType.parseError:
        return Icons.code_off;
      case NetworkErrorType.cancelled:
        return Icons.cancel;
      case NetworkErrorType.unknown:
      default:
        return Icons.help_outline;
    }
  }

  /// 에러 타입별 색상
  static Color _getErrorColor(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
      case NetworkErrorType.timeout:
        return Colors.orange;
      case NetworkErrorType.serverError:
      case NetworkErrorType.clientError:
        return Colors.red;
      case NetworkErrorType.unauthorized:
        return Colors.amber;
      case NetworkErrorType.rateLimited:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  /// 에러 타입별 제목
  static String _getErrorTitle(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return '네트워크 연결 없음';
      case NetworkErrorType.timeout:
        return '연결 시간 초과';
      case NetworkErrorType.serverError:
        return '서버 오류';
      case NetworkErrorType.clientError:
        return '요청 오류';
      case NetworkErrorType.unauthorized:
        return '인증 필요';
      case NetworkErrorType.rateLimited:
        return '요청 제한';
      case NetworkErrorType.parseError:
        return '데이터 오류';
      case NetworkErrorType.cancelled:
        return '요청 취소됨';
      case NetworkErrorType.unknown:
      default:
        return '오류 발생';
    }
  }
}