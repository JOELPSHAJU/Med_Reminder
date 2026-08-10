import '../../data/models/app_settings_model.dart';

abstract class SettingsRepository {
  AppSettingsModel getSettings();
  Future<void> updateSettings(AppSettingsModel settings);
}
