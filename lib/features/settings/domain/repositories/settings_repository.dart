import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Stream<AppSettings> watchSettings();
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);

  // Backup & Restore
  Future<String> exportDataAsJson();
  Future<void> importDataFromJson(
    String jsonStr, {
    required bool mergeWithExisting,
  });
  Future<void> clearAllAppData();
}
