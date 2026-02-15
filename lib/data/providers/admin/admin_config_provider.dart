import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../infrastructure/firebase_providers.dart';

/// Fetches app configuration from Firestore config/app document
final adminConfigProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  try {
    final doc = await firestore.collection('config').doc('app').get();

    if (doc.exists && doc.data() != null) {
      AppLogger.info('App config loaded', tag: 'AdminConfig');
      return doc.data()!;
    }

    AppLogger.info('App config document does not exist, returning empty map',
        tag: 'AdminConfig');
    return {};
  } catch (e) {
    AppLogger.error('Failed to load app config',
        tag: 'AdminConfig', error: e);
    rethrow;
  }
});

/// Notifier for updating app configuration
class AdminConfigNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  AdminConfigNotifier(this._firestore) : super(const AsyncValue.data(null));

  /// Update app configuration with merge
  Future<void> updateConfig(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('config')
          .doc('app')
          .set(updateData, SetOptions(merge: true));

      AppLogger.info('App config updated', tag: 'AdminConfig');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to update app config',
          tag: 'AdminConfig', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminConfigNotifierProvider =
    StateNotifierProvider<AdminConfigNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return AdminConfigNotifier(firestore);
});
