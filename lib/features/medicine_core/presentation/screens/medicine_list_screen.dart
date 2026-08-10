import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/add_edit_medicine/presentation/screens/add_edit_medicine_screen.dart';
import 'package:med_reminder/features/dashboard/presentation/providers/dashboard_providers.dart';

class MedicineListScreen extends ConsumerWidget {
  const MedicineListScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'capsule':
        return Icons.medication_liquid_rounded;
      case 'syrup':
        return Icons.sanitizer_rounded;
      case 'injection':
        return Icons.vaccines_rounded;
      case 'drops':
        return Icons.water_drop_rounded;
      case 'inhaler':
        return Icons.air_rounded;
      case 'topical':
        return Icons.clean_hands_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(allMedicinesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Medicines',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: medicines.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 72,
                      height: 72,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Medicines Added Yet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + button below to add your first medicine.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: med.isActive
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Compact Left Accent Bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              gradient: med.isActive
                                  ? AppColors.primaryGradient
                                  : AppColors.skippedGradient,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Icon + Name/Type + Status Badge
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: med.isActive
                                          ? AppColors.primaryGradient
                                          : null,
                                      color: med.isActive
                                          ? null
                                          : (isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getIconForType(med.type),
                                      color: med.isActive
                                          ? Colors.white
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                med.name,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            _buildActiveBadge(med.isActive),
                                          ],
                                        ),
                                        Text(
                                          '${med.type} • ${med.strength}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
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

                              if (med.description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  med.description,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              const SizedBox(height: 8),

                              // Dose Schedules Pills Row
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: med.doses.map((dose) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.access_time_filled_rounded,
                                          size: 11,
                                          color: AppColors.primaryDark,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          DateFormatter.formatTimeOfDay(
                                              dose.timeHour, dose.timeMinute),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 8),

                              // Duration Row
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      med.isOngoing
                                          ? 'Started ${DateFormatter.formatShortDate(med.startDate)} (Ongoing)'
                                          : '${DateFormatter.formatShortDate(med.startDate)} - ${med.endDate != null ? DateFormatter.formatShortDate(med.endDate!) : "N/A"}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Divider(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                height: 1,
                              ),
                              const SizedBox(height: 6),

                              // Compact Action Buttons Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Pause / Resume Button
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(medicineStateNotifierProvider
                                              .notifier)
                                          .toggleMedicineActive(med.id);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: Icon(
                                      med.isActive
                                          ? Icons.pause_circle_outline_rounded
                                          : Icons.play_circle_outline_rounded,
                                      size: 14,
                                    ),
                                    label: Text(
                                      med.isActive ? 'Pause' : 'Resume',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Edit Button
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditMedicineScreen(
                                            existingMedicine: med,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit_rounded,
                                        size: 14),
                                    label: Text(
                                      'Edit',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),

                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Medicine'),
                                          content: Text(
                                              'Are you sure you want to delete ${med.name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        ref
                                            .read(medicineStateNotifierProvider
                                                .notifier)
                                            .deleteMedicine(med.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildActiveBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.statusTakenContainer
            : AppColors.statusSkippedContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'PAUSED',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isActive
              ? AppColors.statusTakenText
              : AppColors.statusSkippedText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
