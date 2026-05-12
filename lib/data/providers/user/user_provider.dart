// 👤 User Provider
//
// Manages user data operations with Firestore integration.
// Handles user CRUD operations, profile updates, and gamification data.
//
// Null/Error Strategy (호출 측이 의존해도 되는 계약):
//   * build() — 미로그인 상태에서 UserModel? null 을 반환.
//   * loadUser(uid) — 문서가 없으면 createUser 로 자동 생성 후 state 갱신.
//     Firestore 오류는 AppLogger.error 로 기록하고 state 는 변경하지 않음 (rethrow 안 함).
//   * updateXxx() 류 — state 가 null 이면 조용히 return (선택적 작업).
//   * deleteAccount(), createUser() — 실패 시 Exception throw (필수 작업).
//
// 한 마디로: state read 작업은 silent-fail, 사용자 가시적 mutation 은 throw.
// 새 메서드 추가 시 위 분류 중 어느 쪽인지 명시할 것.
//
// 구현은 도메인별 part 파일로 분리되어 있다:
//   * user_provider.crud.dart          — load/create/update/delete/clear
//   * user_provider.progress.dart      — XP / streak / study date / reset
//   * user_provider.gamification.dart  — hearts / gems / achievements / league
//   * user_provider.settings.dart      — settings / notifications / streak freeze / last login

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/user/user_model.dart';

part 'user_provider.g.dart';
part 'user_provider.crud.dart';
part 'user_provider.progress.dart';
part 'user_provider.gamification.dart';
part 'user_provider.settings.dart';

@Riverpod(keepAlive: true)
class User extends _$User {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  UserModel? build() {
    return null;
  }
}
