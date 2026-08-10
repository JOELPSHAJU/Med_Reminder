import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;

  SettingsRepositoryImpl({SettingsLocalDataSource? dataSource})
      : _dataSource = dataSource ?? SettingsLocalDataSource();

  @override
  AppSettingsModel getSettings() {
    return _dataSource.getSettings();
  }

  @override
  Future<void> updateSettings(AppSettingsModel settings) async {
    await _dataSource.saveSettings(settings);
  }
}
