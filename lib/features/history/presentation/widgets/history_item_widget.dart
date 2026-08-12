import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_reminder/features/dashboard/presentation/providers/dashboard_providers.dart';

class HistoryItemWidget extends ConsumerWidget {
  final DoseOccurrenceModel occurrence;

  const HistoryItemWidget({super.key, required this.occurrence});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _getStatusColor(occurrence.status).withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getStatusColor(occurrence.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getStatusIcon(occurrence.status),
              color: _getStatusColor(occurrence.status),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusPill(),
                        if (occurrence.status != DoseStatusEnum.pending) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              ref
                                  .read(medicineStateNotifierProvider.notifier)
                                  .updateOccurrenceStatus(
                                    occurrence.id,
                                    DoseStatusEnum.pending,
                                  );
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reset ${occurrence.medicineNameSnapshot} to Pending',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.undo_rounded,
                                    size: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  const SizedBox(width: 2),
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
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${occurrence.doseQuantitySnapshot} ${occurrence.doseUnitSnapshot} • ${occurrence.medicineStrengthSnapshot}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDateTime(
                            occurrence.scheduledDateTime,
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (occurrence.actualTakenTime != null)
                      Text(
                        '• Taken at ${DateFormatter.formatTime(occurrence.actualTakenTime!)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.statusTakenText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(DoseStatusEnum status) {
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

  Widget _buildStatusPill() {
    Color bg;
    Color text;

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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        occurrence.status.name.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
