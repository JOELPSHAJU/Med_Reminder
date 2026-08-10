class AppConstants {
  static const String medicineBoxName = 'medicine_box';
  static const String occurrenceBoxName = 'occurrence_box';
  static const String settingsBoxName = 'settings_box';

  static const String notificationChannelId = 'med_reminder_high_importance';
  static const String notificationChannelName = 'Medicine Reminders';
  static const String notificationChannelDescription = 'Notifications for medicine doses';

  // Rolling scheduling window for ongoing medicines (in days)
  static const int ongoingScheduleWindowDays = 30;

  // Threshold (in days) under which new rolling occurrences are extended
  static const int ongoingExtendThresholdDays = 15;

  // Grace period before pending doses auto-transition to missed (in minutes)
  static const int missedGracePeriodMinutes = 60;
}
