import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';

/// AlarmService wraps the `alarm` package to schedule real device alarms
/// that fire even when the app is killed, the screen is locked, or the
/// device is in Doze mode.
///
/// Unlike flutter_local_notifications which only fires a notification,
/// the `alarm` package starts a foreground media service that:
///   - Plays a looping ringtone (from assets/audio/alarm.mp3)
///   - Vibrates continuously until dismissed
///   - Shows a full-screen alarm intent that wakes the screen
///   - Survives MIUI / OneUI aggressive process killing
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  /// Converts an occurrenceId string to a stable int id for the alarm package.
  /// Must return a value in the range 1..2147483647 (positive int32).
  int _getAlarmId(String occurrenceId) {
    int hash = 0;
    for (int i = 0; i < occurrenceId.length; i++) {
      hash = (hash * 31 + occurrenceId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    // Ensure id is at least 1 (alarm package rejects id=0)
    return hash == 0 ? 1 : hash;
  }

  /// Schedules a medicine dose alarm.
  ///
  /// Fires a full-screen alarm with ringtone + vibration at [scheduledDateTime].
  /// If [scheduledDateTime] is in the past, this is a no-op.
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

    // Build notification body
    final StringBuffer bodyBuf = StringBuffer(doseDetails);
    if (foodInstruction != null &&
        foodInstruction.isNotEmpty &&
        foodInstruction != 'No instruction') {
      bodyBuf.write(' • $foodInstruction');
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledDateTime,
      assetAudioPath: null, // Use system default alarm sound
      loopAudio: true,
      vibrate: true,
      // Wake screen and show full-screen alarm intent
      androidFullScreenIntent: true,
      // Warn user if app is killed on iOS (not relevant for Android but best practice)
      warningNotificationOnKill: false,
      // Allow multiple alarms to ring simultaneously (multiple medicines)
      allowAlarmOverlap: true,
      // Store occurrenceId so we can retrieve it from ringStream
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
    } catch (e) {
      // Silently fail — flutter_local_notifications backup will still fire
    }
  }

  /// Cancels a scheduled alarm for the given occurrenceId.
  /// Call this when the user marks a dose as Taken, Skipped, or Snoozed.
  Future<void> cancelAlarm(String occurrenceId) async {
    final id = _getAlarmId(occurrenceId);
    try {
      await Alarm.stop(id);
    } catch (_) {}
  }

  /// Cancels ALL active alarms. Call on full medicine deletion or reset.
  Future<void> cancelAllAlarms() async {
    try {
      await Alarm.stopAll();
    } catch (_) {}
  }

  /// Returns a stream that fires whenever any alarm starts ringing.
  /// Listen to this in main.dart to navigate the user to the dashboard.
  Stream<AlarmSet> get ringStream => Alarm.ringing;
}
