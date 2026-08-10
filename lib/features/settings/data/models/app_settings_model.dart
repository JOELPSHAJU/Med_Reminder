import 'package:hive/hive.dart';

class AppSettingsModel extends HiveObject {
  final String soundTheme;
  final bool vibrationEnabled;
  final int defaultSnoozeMinutes;
  final bool notificationsEnabled;
  final bool isDarkMode;

  AppSettingsModel({
    required this.soundTheme,
    required this.vibrationEnabled,
    required this.defaultSnoozeMinutes,
    required this.notificationsEnabled,
    required this.isDarkMode,
  });

  factory AppSettingsModel.defaultSettings() => AppSettingsModel(
        soundTheme: 'default',
        vibrationEnabled: true,
        defaultSnoozeMinutes: 10,
        notificationsEnabled: true,
        isDarkMode: false,
      );

  AppSettingsModel copyWith({
    String? soundTheme,
    bool? vibrationEnabled,
    int? defaultSnoozeMinutes,
    bool? notificationsEnabled,
    bool? isDarkMode,
  }) {
    return AppSettingsModel(
      soundTheme: soundTheme ?? this.soundTheme,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultSnoozeMinutes: defaultSnoozeMinutes ?? this.defaultSnoozeMinutes,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 4;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsModel(
      soundTheme: fields[0] as String,
      vibrationEnabled: fields[1] as bool,
      defaultSnoozeMinutes: fields[2] as int,
      notificationsEnabled: fields[3] as bool,
      isDarkMode: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.soundTheme)
      ..writeByte(1)
      ..write(obj.vibrationEnabled)
      ..writeByte(2)
      ..write(obj.defaultSnoozeMinutes)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.isDarkMode);
  }
}
