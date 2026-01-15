import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/repositories/achievement_repository.dart';

void main() {
  group('AchievementRepository', () {
    late AchievementRepository repository;

    setUp(() {
      repository = AchievementRepository();
    });

    test('should be created', () {
      expect(repository, isNotNull);
      expect(repository.repositoryName, 'AchievementRepository');
    });

    // TODO: Add more tests with Firebase emulator
  });
}
