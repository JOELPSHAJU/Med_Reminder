import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  int _getAlarmId(String occurrenceId) {
    int hash = 0;
    for (int i = 0; i < occurrenceId.length; i++) {
      hash = (hash * 31 + occurrenceId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash;
  }

  Future<void> scheduleAlarm({
    required String occurrenceId,
    required String medicineName,
    required String doseDetails,
    required DateTime scheduledDateTime,
    String? foodInstruction,
  }) async {
    final now = DateTime.now();
    if (scheduledDateTime.isBefore(now)) return;

    final id = _getAlarmId(occurrenceId);

    final StringBuffer bodyBuf = StringBuffer(doseDetails);
    if (foodInstruction != null &&
        foodInstruction.isNotEmpty &&
        foodInstruction != 'No instruction') {
      bodyBuf.write(' • $foodInstruction');
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledDateTime,
      assetAudioPath: null,
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      warningNotificationOnKill: false,
      allowAlarmOverlap: true,
      payload: occurrenceId,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: '💊 Time to take $medicineName',
        body: bodyBuf.toString(),
        stopButton: 'Dismiss',
        icon: 'mipmap/ic_launcher',
      ),
    );

    try {
      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {}
  }

  Future<void> cancelAlarm(String occurrenceId) async {
    final id = _getAlarmId(occurrenceId);
    try {
      await Alarm.stop(id);
    } catch (_) {}
  }

  Future<void> cancelAllAlarms() async {
    try {
      await Alarm.stopAll();
    } catch (_) {}
  }

  Stream<AlarmSet> get ringStream => Alarm.ringing;
}
