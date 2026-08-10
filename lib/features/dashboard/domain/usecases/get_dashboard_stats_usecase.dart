import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

class DashboardStats {
  final int totalDoses;
  final int pendingCount;
  final int takenCount;
  final int missedCount;
  final int skippedCount;
  final double completionPercentage;

  DashboardStats({
    required this.totalDoses,
    required this.pendingCount,
    required this.takenCount,
    required this.missedCount,
    required this.skippedCount,
    required this.completionPercentage,
  });

  factory DashboardStats.empty() => DashboardStats(
    totalDoses: 0,
    pendingCount: 0,
    takenCount: 0,
    missedCount: 0,
    skippedCount: 0,
    completionPercentage: 0.0,
  );
}

class GetDashboardStatsUseCase {
  static DashboardStats calculateForDate(
    List<DoseOccurrenceModel> allOccurrences,
    DateTime date,
  ) {
    final todaysOccurrences = allOccurrences.where((occ) {
      return DateFormatter.isSameDay(occ.scheduledDateTime, date);
    }).toList();

    if (todaysOccurrences.isEmpty) {
      return DashboardStats.empty();
    }

    int pending = 0;
    int taken = 0;
    int missed = 0;
    int skipped = 0;

    for (final occ in todaysOccurrences) {
      switch (occ.status) {
        case DoseStatusEnum.pending:
          pending++;
          break;
        case DoseStatusEnum.taken:
          taken++;
          break;
        case DoseStatusEnum.missed:
          missed++;
          break;
        case DoseStatusEnum.skipped:
          skipped++;
          break;
      }
    }

    final total = todaysOccurrences.length;
    final completionPct = total > 0 ? (taken / total) * 100 : 0.0;

    return DashboardStats(
      totalDoses: total,
      pendingCount: pending,
      takenCount: taken,
      missedCount: missed,
      skippedCount: skipped,
      completionPercentage: completionPct,
    );
  }
}
