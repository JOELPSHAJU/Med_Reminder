import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';
import 'alarm_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Top-level handler required for background notification taps (Android).
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
void _notificationBackgroundHandler(NotificationResponse details) {
  // Handle background notification tap — payload contains occurrenceId
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize all timezone data and set local timezone
    tz.initializeTimeZones();
    _setLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Foreground / tapped notification — payload contains occurrenceId
      },
      onDidReceiveBackgroundNotificationResponse:
          _notificationBackgroundHandler,
    );

    _initialized = true;
  }

  /// Sets the local timezone location using device timezone info and offset matching.
  void _setLocalTimezone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final timeZoneName = now.timeZoneName;

      // 1. Try direct timezone name lookup
      if (tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        return;
      }

      // 2. Match location by current UTC offset
      final locations = tz.timeZoneDatabase.locations;
      for (final loc in locations.values) {
        final tzNow = tz.TZDateTime.now(loc);
        if (tzNow.timeZoneOffset == offset) {
          tz.setLocalLocation(loc);
          return;
        }
      }
    } catch (_) {}
  }

  Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
      // Request battery optimization exemption and Xiaomi autostart permission ONLY ONCE
      final box = await Hive.openBox('app_flags');
      final hasRequestedBackground = box.get(
        'hasRequestedBackground',
        defaultValue: false,
      );

      if (!hasRequestedBackground) {
        await _requestBatteryOptimizationExemption();
        await _requestAutostartPermission();
        await box.put('hasRequestedBackground', true);
      }
    }

    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Requests the user to disable battery optimization for this app.
  Future<void> _requestBatteryOptimizationExemption() async {
    try {
      const platform = MethodChannel('med_reminder/battery');
      await platform.invokeMethod('requestBatteryOptimization');
    } on PlatformException {
    } catch (_) {}
  }

  /// Requests Autostart manager screen on Xiaomi/Redmi devices.
  Future<void> _requestAutostartPermission() async {
    try {
      const platform = MethodChannel('med_reminder/battery');
      await platform.invokeMethod('requestAutostart');
    } on PlatformException {
    } catch (_) {}
  }

  int _getNotificationId(String occurrenceId) {
    int hash = 0;
    for (int i = 0; i < occurrenceId.length; i++) {
      hash = (hash * 31 + occurrenceId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  Future<void> scheduleDoseNotification({
    required String occurrenceId,
    required String medicineName,
    required String doseDetails,
    required DateTime scheduledDateTime,
    String? foodInstruction,
  }) async {
    final now = DateTime.now();
    if (scheduledDateTime.isBefore(now)) return;

    final id = _getNotificationId(occurrenceId);

    // Build wall-clock exact TZDateTime to prevent UTC/DST hour offset shifts
    final tzScheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDateTime.year,
      scheduledDateTime.month,
      scheduledDateTime.day,
      scheduledDateTime.hour,
      scheduledDateTime.minute,
      scheduledDateTime.second,
    );

    // Build rich body text
    final StringBuffer bodyBuf = StringBuffer(doseDetails);
    if (foodInstruction != null &&
        foodInstruction.isNotEmpty &&
        foodInstruction != 'No instruction') {
      bodyBuf.write('\n🍽️ $foodInstruction');
    }
    final String body = bodyBuf.toString();

    // Rich expanded text for Android
    final bigTextStyle = BigTextStyleInformation(
      body,
      contentTitle: '💊 $medicineName',
      summaryText: AppConstants.notificationChannelName,
    );

    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      // Rich notification style
      styleInformation: bigTextStyle,
      category: AndroidNotificationCategory.alarm,
      // Teal tint matching app theme (#00796B)
      color: const Color(0xFF00796B),
      ledColor: const Color(0xFF00796B),
      ledOnMs: 1000,
      ledOffMs: 500,
      // Sub-text showing scheduled time
      subText: 'Scheduled dose',
      ticker: 'Time to take $medicineName',
      // Action buttons
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_taken',
          '✅  Mark Taken',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'action_snooze',
          '⏰  Snooze 10 min',
          showsUserInterface: false,
        ),
      ],
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: doseDetails,
      // Group all dose notifications together on iOS
      threadIdentifier: 'med_reminder_doses',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // PRIMARY: Schedule a real device alarm via alarm package
    // This fires a foreground media service with ringtone + vibration +
    // full-screen intent — works even when app is killed on MIUI/HyperOS.
    await AlarmService().scheduleAlarm(
      occurrenceId: occurrenceId,
      medicineName: medicineName,
      doseDetails: doseDetails,
      scheduledDateTime: scheduledDateTime,
      foodInstruction: foodInstruction,
    );

    // BACKUP: Also schedule a standard notification so the user sees it
    // even if they dismiss the full-screen alarm quickly.
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        '💊 Time to take $medicineName',
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: occurrenceId,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          '💊 Time to take $medicineName',
          body,
          tzScheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: occurrenceId,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelNotification(String occurrenceId) async {
    // Cancel both the alarm (ringtone) and the backup notification
    await AlarmService().cancelAlarm(occurrenceId);
    final id = _getNotificationId(occurrenceId);
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AlarmService().cancelAllAlarms();
    await _notificationsPlugin.cancelAll();
  }
}
