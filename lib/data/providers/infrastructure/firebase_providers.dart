/// 🔥 Firebase Providers
///
/// Basic Firebase service providers for the application.
/// Provides access to Firebase Auth, Firestore, and other Firebase services.

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth 인스턴스 Provider
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

/// Firestore 인스턴스 Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// 현재 Firebase 사용자 Provider
final currentUserProvider = Provider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).currentUser;
});

/// Firebase Auth 상태 변경 스트림 Provider
final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Firebase ID 토큰 변경 스트림 Provider
final idTokenChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).idTokenChanges();
});
