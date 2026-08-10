import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

class SettingsNotifier extends StateNotifier<AppSettingsModel> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> updateSoundTheme(String theme) async {
    final updated = state.copyWith(soundTheme: theme);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleVibration(bool enabled) async {
    final updated = state.copyWith(vibrationEnabled: enabled);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> setDefaultSnoozeMinutes(int minutes) async {
    final updated = state.copyWith(defaultSnoozeMinutes: minutes);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleDarkMode(bool isDark) async {
    final updated = state.copyWith(isDarkMode: isDark);
    await _repository.updateSettings(updated);
    state = updated;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsModel>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
