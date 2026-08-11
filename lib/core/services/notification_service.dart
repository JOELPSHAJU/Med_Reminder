import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

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

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveBackgroundNotificationResponse: _notificationBackgroundHandler,
    );

    _initialized = true;
  }

  /// Maps the device's local UTC offset to a named timezone location.
  void _setLocalTimezone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final locations = tz.timeZoneDatabase.locations;

      tz.Location? match;
      for (final loc in locations.values) {
        final tzNow = tz.TZDateTime.now(loc);
        if (tzNow.timeZoneOffset == offset) {
          match = loc;
          break;
        }
      }
      if (match != null) {
        tz.setLocalLocation(match);
      }
    } catch (_) {
      // Fall back to UTC if detection fails
    }
  }

  Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
      // Request battery optimization exemption so alarms survive
      // aggressive OEM power management (MIUI, OneUI, ColorOS, etc.)
      await _requestBatteryOptimizationExemption();
    }

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Requests the user to disable battery optimization for this app.
  /// This ensures AlarmManager exact alarms fire even when the app is
  /// force-stopped or the device is in Doze mode on OEM Android devices.
  Future<void> _requestBatteryOptimizationExemption() async {
    try {
      const platform = MethodChannel('med_reminder/battery');
      await platform.invokeMethod('requestBatteryOptimization');
    } on PlatformException {
      // Not supported on this device/version — safe to ignore
    } catch (_) {
      // Fallback: ignore silently
    }
  }

  int _getNotificationId(String occurrenceId) {
    return occurrenceId.hashCode.abs() % 2147483647;
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
    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

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
      category: AndroidNotificationCategory.reminder,
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
  }

  Future<void> cancelNotification(String occurrenceId) async {
    final id = _getNotificationId(occurrenceId);
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00796B),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.show(
      99999,
      '💊 Med Reminder',
      'Notifications are configured and working properly!',
      details,
    );
  }
}
