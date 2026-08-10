import 'package:med_reminder/core/services/hive_service.dart';
import 'package:med_reminder/features/settings/data/models/app_settings_model.dart';

class SettingsLocalDataSource {
  static const String _settingsKey = 'app_settings';

  AppSettingsModel getSettings() {
    final box = HiveService.settingsBox;
    final settings = box.get(_settingsKey);
    if (settings == null) {
      final defaultSet = AppSettingsModel.defaultSettings();
      box.put(_settingsKey, defaultSet);
      return defaultSet;
    }
    return settings;
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    await HiveService.settingsBox.put(_settingsKey, settings);
  }
}
