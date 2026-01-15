import '../models/user/app_settings.dart';
import 'base/base_repository.dart';

class SettingsRepository extends BaseRepository<AppSettings> {
  SettingsRepository()
      : super(
          collectionPath: 'settings',
          fromFirestore: AppSettings.fromFirestore,
          repositoryName: 'SettingsRepository',
          enableCache: true,
        );

  Future<RepositoryResult<AppSettings?>> getUserSettings(String userId) async {
    final result = await getById(userId);
    if (result.isSuccess && result.data != null) {
      return result;
    }
    return RepositoryResult.success(data: null);
  }

  Future<RepositoryResult<AppSettings>> updateUserSettings(
    String userId,
    AppSettings settings,
  ) async {
    final existing = await getUserSettings(userId);
    if (existing.data != null) {
      return update(settings);
    }
    return create(settings);
  }
}
