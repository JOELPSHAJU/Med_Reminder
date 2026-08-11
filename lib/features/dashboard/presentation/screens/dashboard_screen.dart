import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:med_reminder/features/dashboard/presentation/widgets/reminder_item_widget.dart';
import 'package:med_reminder/features/dashboard/presentation/widgets/snooze_modal_dialog.dart';
import 'package:med_reminder/features/dashboard/presentation/widgets/stats_card_widget.dart';
import 'package:med_reminder/features/history/presentation/screens/history_screen.dart';
import 'package:med_reminder/features/add_edit_medicine/presentation/screens/add_edit_medicine_screen.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';
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
    final upcomingReminders = ref.watch(upcomingOccurrencesProvider);
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Doses',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        upcomingReminders.isEmpty
                            ? '${todayReminders.length} dose${todayReminders.length == 1 ? '' : 's'} today — all done!'
                            : '${upcomingReminders.length} remaining of ${todayReminders.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Reminders List or Empty State
              if (upcomingReminders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            todayReminders.isEmpty
                                ? Icons.medication_outlined
                                : Icons.check_circle_rounded,
                            size: 52,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          todayReminders.isEmpty
                              ? 'No Doses Scheduled'
                              : 'No Doses Remaining Today 🎉',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          todayReminders.isEmpty
                              ? 'Tap + below to schedule a new medicine.'
                              : 'No upcoming doses scheduled after current time.',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (todayReminders.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          // Today's Skipped & Missed Summary Badges
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSummaryChip(
                                  label: 'Skipped',
                                  count: stats.skippedCount,
                                  color: AppColors.statusSkippedText,
                                  bg: AppColors.statusSkippedContainer,
                                ),
                                const SizedBox(width: 8),
                                _buildSummaryChip(
                                  label: 'Missed',
                                  count: stats.missedCount,
                                  color: AppColors.statusMissedText,
                                  bg: AppColors.statusMissedContainer,
                                ),
                                const SizedBox(width: 8),
                                _buildSummaryChip(
                                  label: 'Taken',
                                  count: stats.takenCount,
                                  color: AppColors.statusTakenText,
                                  bg: AppColors.statusTakenContainer,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingReminders.length > 5 ? 5 : upcomingReminders.length,
                  itemBuilder: (context, index) {
                    final occ = upcomingReminders[index];
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

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${occ.medicineNameSnapshot} marked as Taken'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: AppColors.primary,
                                onPressed: () {
                                  ref
                                      .read(medicineStateNotifierProvider
                                          .notifier)
                                      .updateOccurrenceStatus(
                                        occ.id,
                                        DoseStatusEnum.pending,
                                      );
                                },
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
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

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${occ.medicineNameSnapshot} marked as Skipped'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: AppColors.primary,
                                onPressed: () {
                                  ref
                                      .read(medicineStateNotifierProvider
                                          .notifier)
                                      .updateOccurrenceStatus(
                                        occ.id,
                                        DoseStatusEnum.pending,
                                      );
                                },
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      onUndo: () {
                        ref
                            .read(medicineStateNotifierProvider.notifier)
                            .updateOccurrenceStatus(
                              occ.id,
                              DoseStatusEnum.pending,
                            );
                      },
                      onEdit: () {
                        final allMeds = ref.read(allMedicinesProvider);
                        final med = allMeds.firstWhere(
                          (m) => m.id == occ.medicineId,
                          orElse: () => MedicineModel(
                            id: occ.medicineId,
                            name: occ.medicineNameSnapshot,
                            description: '',
                            type: occ.medicineTypeSnapshot,
                            strength: occ.medicineStrengthSnapshot,
                            startDate: occ.scheduledDateTime,
                            isOngoing: true,
                            createdAt: DateTime.now(),
                            doses: [],
                          ),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditMedicineScreen(existingMedicine: med),
                          ),
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


  Widget _buildSummaryChip({
    required String label,
    required int count,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

