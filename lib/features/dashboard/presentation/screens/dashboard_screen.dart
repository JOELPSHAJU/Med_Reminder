import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:med_reminder/features/dashboard/presentation/widgets/reminder_item_widget.dart';
import 'package:med_reminder/features/dashboard/presentation/widgets/snooze_modal_dialog.dart';
import 'package:med_reminder/features/dashboard/presentation/widgets/stats_card_widget.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/settings/presentation/providers/settings_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  String _getEarlyTimeString(DateTime scheduled, DateTime now) {
    final diff = scheduled.difference(now);
    if (diff.inHours > 0) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} early';
    } else {
      return '${diff.inMinutes} mins early';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final todayReminders = ref.watch(todayOccurrencesProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Med Reminder',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                ref.read(selectedDashboardDateProvider.notifier).state = picked;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () {
              ref.read(medicineStateNotifierProvider.notifier).syncAndRefresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(medicineStateNotifierProvider.notifier)
              .syncAndRefresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header & Selected Date Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatDate(selectedDate),
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (!DateFormatter.isSameDay(selectedDate, DateTime.now()))
                    TextButton.icon(
                      onPressed: () {
                        ref.read(selectedDashboardDateProvider.notifier).state =
                            DateTime.now();
                      },
                      icon: const Icon(Icons.today_rounded, size: 16),
                      label: const Text('Today'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Statistics Card
              StatsCardWidget(stats: stats),

              const SizedBox(height: 24),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today Reminders',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${todayReminders.length} Doses',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reminders List or Empty State
              if (todayReminders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 56,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Doses Scheduled',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + button below to schedule a new medicine.',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayReminders.length,
                  itemBuilder: (context, index) {
                    final occ = todayReminders[index];
                    return ReminderItemWidget(
                      occurrence: occ,
                      onTaken: () async {
                        final now = DateTime.now();

                        // Real-time Check: Warning if marking taken before scheduled time (>15 mins early)
                        if (occ.scheduledDateTime.isAfter(
                            now.add(const Duration(minutes: 15)))) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.orange, size: 28),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Early Dose Warning',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'This dose for ${occ.medicineNameSnapshot} is scheduled for ${DateFormatter.formatTime(occ.scheduledDateTime)} (${_getEarlyTimeString(occ.scheduledDateTime, now)}).\n\nAre you sure you want to log it as taken early?',
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusTaken,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(
                                    'Log Taken Early',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;
                        }

                        ref
                            .read(medicineStateNotifierProvider.notifier)
                            .updateOccurrenceStatus(
                              occ.id,
                              DoseStatusEnum.taken,
                            );
                      },
                      onSnooze: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (modalContext) {
                            return SnoozeModalDialog(
                              defaultMinutes: settings.defaultSnoozeMinutes,
                              onSnoozeSelected: (minutes) {
                                ref
                                    .read(medicineStateNotifierProvider.notifier)
                                    .snoozeOccurrence(occ.id, minutes);
                              },
                            );
                          },
                        );
                      },
                      onSkip: () {
                        ref
                            .read(medicineStateNotifierProvider.notifier)
                            .updateOccurrenceStatus(
                              occ.id,
                              DoseStatusEnum.skipped,
                            );
                      },
                      onUndo: () {
                        ref
                            .read(medicineStateNotifierProvider.notifier)
                            .updateOccurrenceStatus(
                              occ.id,
                              DoseStatusEnum.pending,
                            );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
