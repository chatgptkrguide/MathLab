import 'package:flutter_riverpod/flutter_riverpod.dart';

// FCM Service Provider stub
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

class FCMService {
  Future<void> initialize() async {
    // TODO: Implement FCM initialization
  }

  void dispose() {
    // TODO: Implement cleanup
  }
}
