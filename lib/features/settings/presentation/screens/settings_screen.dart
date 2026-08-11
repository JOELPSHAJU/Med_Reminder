import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:med_reminder/core/services/notification_service.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Branding Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Med Reminder',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Version 1.0.0 • Offline First',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section: Notifications & Alerts
          Text(
            'Notifications & Sound',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(
                    'Master Notifications',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Enable or disable all dose reminders'),
                  value: settings.notificationsEnabled,
                  onChanged: (val) {
                    settingsNotifier.toggleNotifications(val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  title: Text(
                    'Vibration',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Vibrate phone when alarm triggers'),
                  value: settings.vibrationEnabled,
                  onChanged: (val) {
                    settingsNotifier.toggleVibration(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.music_note_rounded),
                  title: Text(
                    'Reminder Tone',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Selected: ${settings.soundTheme.toUpperCase()}'),
                  trailing: DropdownButton<String>(
                    value: settings.soundTheme,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'default', child: Text('Default')),
                      DropdownMenuItem(value: 'gentle', child: Text('Gentle Chime')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent Alarm')),
                    ],
                    onChanged: (val) {
                      if (val != null) settingsNotifier.updateSoundTheme(val);
                    },
                  ),
                ),
                /*
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                  title: Text(
                    'Instant Test Notification',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Sends an immediate test alert'),
                  trailing: const Icon(Icons.send_rounded, size: 18),
                  onTap: () async {
                    await NotificationService().showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent! Check your notification bar.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer_outlined, color: Colors.orange),
                  title: Text(
                    'Test Background Alarm (10s)',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Schedules alarm in 10s. Close/lock app now to test!'),
                  trailing: const Icon(Icons.alarm_add_rounded, size: 18),
                  onTap: () async {
                    await NotificationService().scheduleTestNotification(delaySeconds: 10);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⏰ Alarm set for 10s from now! Close the app or lock screen now.'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                ),
                */
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: General & Preferences
          Text(
            'General Preferences',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(
                    'Dark Theme',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Switch between Light and Dark mode'),
                  value: settings.isDarkMode,
                  onChanged: (val) {
                    settingsNotifier.toggleDarkMode(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.snooze_rounded),
                  title: Text(
                    'Default Snooze Duration',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${settings.defaultSnoozeMinutes} minutes'),
                  trailing: DropdownButton<int>(
                    value: settings.defaultSnoozeMinutes,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 mins')),
                      DropdownMenuItem(value: 10, child: Text('10 mins')),
                      DropdownMenuItem(value: 15, child: Text('15 mins')),
                      DropdownMenuItem(value: 30, child: Text('30 mins')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        settingsNotifier.setDefaultSnoozeMinutes(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
