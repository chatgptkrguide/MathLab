import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/lesson/unit_model.dart';
import '../infrastructure/firebase_providers.dart';

/// Fetches all units with their lessons for admin management
final adminUnitsProvider = FutureProvider<List<UnitModel>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  final snapshot =
      await firestore.collection('units').orderBy('order').get();

  final units = <UnitModel>[];
  for (final doc in snapshot.docs) {
    final data = doc.data();
    data['id'] = doc.id;

    final lessonsSnapshot = await firestore
        .collection('units')
        .doc(doc.id)
        .collection('lessons')
        .orderBy('order')
        .get();

    data['lessons'] = lessonsSnapshot.docs.map((lessonDoc) {
      final lessonData = lessonDoc.data();
      lessonData['id'] = lessonDoc.id;
      return lessonData;
    }).toList();

    units.add(UnitModel.fromJson(data));
  }

  AppLogger.info('Admin: ${units.length} units loaded', tag: 'AdminUnit');
  return units;
});

/// Notifier for admin unit CRUD operations
class AdminUnitNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  AdminUnitNotifier(this._firestore) : super(const AsyncValue.data(null));

  /// Create a new unit
  Future<String> createUnit(UnitModel unit) async {
    state = const AsyncValue.loading();
    try {
      final data = unit.toJson();
      data.remove('id');
      data.remove('lessons');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('units').add(data);
      AppLogger.info('Unit created: ${docRef.id}', tag: 'AdminUnit');
      state = const AsyncValue.data(null);
      return docRef.id;
    } catch (e, st) {
      AppLogger.error('Failed to create unit', tag: 'AdminUnit', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update an existing unit
  Future<void> updateUnit(String id, UnitModel unit) async {
    state = const AsyncValue.loading();
    try {
      final data = unit.toJson();
      data.remove('id');
      data.remove('lessons');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('units').doc(id).update(data);
      AppLogger.info('Unit updated: $id', tag: 'AdminUnit');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to update unit', tag: 'AdminUnit', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a unit and cascade delete all its lessons and associated problems
  Future<void> deleteUnit(String id) async {
    state = const AsyncValue.loading();
    try {
      // Delete all lessons in the unit
      final lessonsSnapshot = await _firestore
          .collection('units')
          .doc(id)
          .collection('lessons')
          .get();

      // Collect lesson IDs for problem deletion
      final lessonIds = <String>[];
      for (final lessonDoc in lessonsSnapshot.docs) {
        lessonIds.add(lessonDoc.id);
      }

      // Batch delete lessons + unit (chunk to stay under 500-doc limit)
      final lessonRefs = lessonsSnapshot.docs.map((d) => d.reference).toList();
      lessonRefs.add(_firestore.collection('units').doc(id));
      await _batchDelete(lessonRefs);

      // Delete problems associated with those lessons
      for (final lessonId in lessonIds) {
        final problemsSnapshot = await _firestore
            .collection('problems')
            .where('lessonId', isEqualTo: lessonId)
            .get();
        if (problemsSnapshot.docs.isNotEmpty) {
          await _batchDelete(
              problemsSnapshot.docs.map((d) => d.reference).toList());
        }
      }

      AppLogger.info(
        'Unit deleted: $id (${lessonsSnapshot.docs.length} lessons cascaded)',
        tag: 'AdminUnit',
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete unit', tag: 'AdminUnit', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Helper to batch-delete documents in chunks of 499 (Firestore limit is 500)
  Future<void> _batchDelete(List<DocumentReference> refs) async {
    const chunkSize = 499;
    for (var i = 0; i < refs.length; i += chunkSize) {
      final chunk = refs.sublist(
          i, i + chunkSize > refs.length ? refs.length : i + chunkSize);
      final batch = _firestore.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  /// Reorder units by updating their order fields
  Future<void> reorderUnits(List<UnitModel> units) async {
    state = const AsyncValue.loading();
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < units.length; i++) {
        batch.update(
          _firestore.collection('units').doc(units[i].id),
          {'order': i, 'updatedAt': FieldValue.serverTimestamp()},
        );
      }
      await batch.commit();
      AppLogger.info('Units reordered (${units.length})', tag: 'AdminUnit');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to reorder units', tag: 'AdminUnit', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminUnitNotifierProvider =
    StateNotifierProvider<AdminUnitNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return AdminUnitNotifier(firestore);
});
