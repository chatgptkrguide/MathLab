import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_storage_service.dart';
import '../../repositories/lesson_repository.dart';
import '../../repositories/league_repository.dart';
import '../../repositories/user_repository.dart';
import '../../models/user/user.dart' as app_user;

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Authentication State Provider (Firebase User)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value;
});

/// User Profile Provider (Firestore app_user.User)
final userProfileProvider = StreamProvider<app_user.User?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  final authService = ref.watch(authServiceProvider);
  return authService.userProfileStream(user.uid);
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value != null;
});

/// Is Email Verified Provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

/// Local Storage Service Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Lesson Repository Provider
final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  return LessonRepository(
    firestoreService: firestoreService,
    localStorageService: localStorageService,
  );
});

/// League Repository Provider
final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  return LeagueRepository(
    firestoreService: firestoreService,
    localStorageService: localStorageService,
  );
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  return UserRepository(
    firestoreService: firestoreService,
    localStorageService: localStorageService,
  );
});
