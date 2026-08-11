import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

class ReminderItemWidget extends StatelessWidget {
  final DoseOccurrenceModel occurrence;
  final VoidCallback onTaken;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;
  final VoidCallback? onUndo;

  const ReminderItemWidget({
    super.key,
    required this.occurrence,
    required this.onTaken,
    required this.onSnooze,
    required this.onSkip,
    this.onUndo,
  });

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(occurrence.status);
    final isPending = occurrence.status == DoseStatusEnum.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left Status Color Accent Bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(occurrence.status),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconForType(occurrence.medicineTypeSnapshot),
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    occurrence.medicineNameSnapshot,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildStatusBadge(),
                              ],
                            ),
                            Text(
                              '${occurrence.doseQuantitySnapshot} ${occurrence.doseUnitSnapshot} • ${occurrence.medicineStrengthSnapshot}',
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
                  const SizedBox(height: 8),

                  // Scheduled Time & Food Instruction Pills
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.formatTime(
                                  occurrence.scheduledDateTime),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (occurrence.foodInstructionSnapshot.isNotEmpty &&
                          occurrence.foodInstructionSnapshot !=
                              'No instruction') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            occurrence.foodInstructionSnapshot,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (occurrence.snoozedUntil != null && isPending) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.statusSkippedContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.snooze_rounded,
                              size: 13, color: AppColors.statusSkippedText),
                          const SizedBox(width: 4),
                          Text(
                            'Snoozed until ${DateFormatter.formatTime(occurrence.snoozedUntil!)}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.statusSkippedText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Action Buttons Row (Pending vs Completed)
                  if (isPending)
                    Row(
                      children: [
                        // Taken Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onTaken,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusTaken,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_rounded,
                                size: 14, color: Colors.white),
                            label: Text(
                              'Taken',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Snooze Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onSnooze,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusSkipped,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.snooze_rounded,
                                size: 14, color: Colors.white),
                            label: Text(
                              'Snooze',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Skip Button
                        TextButton.icon(
                          onPressed: onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.close_rounded, size: 14),
                          label: Text(
                            'Skip',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Completed Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getBannerBgColor(occurrence.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStatusBannerIcon(occurrence.status),
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusBannerText(occurrence),
                                style: GoogleFonts.plusJakartaSans(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          if (onUndo != null)
                            GestureDetector(
                              onTap: onUndo,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.undo_rounded,
                                      size: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Undo',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DoseStatusEnum status) {
    switch (status) {
      case DoseStatusEnum.taken:
        return AppColors.statusTaken;
      case DoseStatusEnum.pending:
        return AppColors.statusPending;
      case DoseStatusEnum.missed:
        return AppColors.statusMissed;
      case DoseStatusEnum.skipped:
        return AppColors.statusSkipped;
    }
  }

  LinearGradient _getStatusGradient(DoseStatusEnum status) {
    switch (status) {
      case DoseStatusEnum.taken:
        return AppColors.takenGradient;
      case DoseStatusEnum.pending:
        return AppColors.pendingGradient;
      case DoseStatusEnum.missed:
        return AppColors.missedGradient;
      case DoseStatusEnum.skipped:
        return AppColors.skippedGradient;
    }
  }

  Color _getBannerBgColor(DoseStatusEnum status) {
    switch (status) {
      case DoseStatusEnum.taken:
        return AppColors.statusTakenContainer;
      case DoseStatusEnum.pending:
        return AppColors.statusPendingContainer;
      case DoseStatusEnum.missed:
        return AppColors.statusMissedContainer;
      case DoseStatusEnum.skipped:
        return AppColors.statusSkippedContainer;
    }
  }

  IconData _getStatusBannerIcon(DoseStatusEnum status) {
    switch (status) {
      case DoseStatusEnum.taken:
        return Icons.check_circle_rounded;
      case DoseStatusEnum.pending:
        return Icons.schedule_rounded;
      case DoseStatusEnum.missed:
        return Icons.error_rounded;
      case DoseStatusEnum.skipped:
        return Icons.block_rounded;
    }
  }

  String _getStatusBannerText(DoseOccurrenceModel occ) {
    switch (occ.status) {
      case DoseStatusEnum.taken:
        return occ.actualTakenTime != null
            ? 'Dose Taken at ${DateFormatter.formatTime(occ.actualTakenTime!)}'
            : 'Dose Completed';
      case DoseStatusEnum.skipped:
        return 'Dose Skipped';
      case DoseStatusEnum.missed:
        return 'Dose Missed';
      case DoseStatusEnum.pending:
        return 'Pending';
    }
  }

  Widget _buildStatusBadge() {
    Color bg;
    Color text;
    String label = occurrence.status.name.toUpperCase();

    switch (occurrence.status) {
      case DoseStatusEnum.taken:
        bg = AppColors.statusTakenContainer;
        text = AppColors.statusTakenText;
        break;
      case DoseStatusEnum.pending:
        bg = AppColors.statusPendingContainer;
        text = AppColors.statusPendingText;
        break;
      case DoseStatusEnum.missed:
        bg = AppColors.statusMissedContainer;
        text = AppColors.statusMissedText;
        break;
      case DoseStatusEnum.skipped:
        bg = AppColors.statusSkippedContainer;
        text = AppColors.statusSkippedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
