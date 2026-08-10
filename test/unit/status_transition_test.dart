import 'package:flutter_test/flutter_test.dart';
import 'package:med_reminder/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/domain/usecases/check_missed_occurrences_usecase.dart';

void main() {
  group('Status Transition & Stats Tests', () {
    test('CheckMissedOccurrencesUseCase auto-transitions past due pending items to missed', () {
      final now = DateTime(2026, 8, 10, 12, 0); // 12:00 PM
      final pastScheduled = DateTime(2026, 8, 10, 10, 0); // 10:00 AM (2 hours ago)

      final occurrence = DoseOccurrenceModel(
        id: 'occ_1',
        medicineId: 'med_1',
        doseId: 'dose_1',
        scheduledDateTime: pastScheduled,
        status: DoseStatusEnum.pending,
        medicineNameSnapshot: 'Vitamin D',
        doseQuantitySnapshot: 1,
        doseUnitSnapshot: 'Capsule',
        foodInstructionSnapshot: 'No instruction',
        medicineTypeSnapshot: 'Capsule',
        medicineStrengthSnapshot: '1000 IU',
      );

      final result = CheckMissedOccurrencesUseCase.evaluateMissedOccurrences(
        [occurrence],
        nowOverride: now,
      );

      expect(result.first.status, equals(DoseStatusEnum.missed));
    });

    test('GetDashboardStatsUseCase accurately calculates adherence stats', () {
      final targetDate = DateTime(2026, 8, 10);

      final occurrences = [
        DoseOccurrenceModel(
          id: 'occ_1',
          medicineId: 'med_1',
          doseId: 'dose_1',
          scheduledDateTime: DateTime(2026, 8, 10, 8, 0),
          status: DoseStatusEnum.taken,
          medicineNameSnapshot: 'Med A',
          doseQuantitySnapshot: 1,
          doseUnitSnapshot: 'tab',
          foodInstructionSnapshot: '',
          medicineTypeSnapshot: 'Tablet',
          medicineStrengthSnapshot: '500 mg',
        ),
        DoseOccurrenceModel(
          id: 'occ_2',
          medicineId: 'med_1',
          doseId: 'dose_2',
          scheduledDateTime: DateTime(2026, 8, 10, 14, 0),
          status: DoseStatusEnum.pending,
          medicineNameSnapshot: 'Med A',
          doseQuantitySnapshot: 1,
          doseUnitSnapshot: 'tab',
          foodInstructionSnapshot: '',
          medicineTypeSnapshot: 'Tablet',
          medicineStrengthSnapshot: '500 mg',
        ),
        DoseOccurrenceModel(
          id: 'occ_3',
          medicineId: 'med_2',
          doseId: 'dose_1',
          scheduledDateTime: DateTime(2026, 8, 10, 20, 0),
          status: DoseStatusEnum.missed,
          medicineNameSnapshot: 'Med B',
          doseQuantitySnapshot: 1,
          doseUnitSnapshot: 'tab',
          foodInstructionSnapshot: '',
          medicineTypeSnapshot: 'Tablet',
          medicineStrengthSnapshot: '250 mg',
        ),
      ];

      final stats = GetDashboardStatsUseCase.calculateForDate(occurrences, targetDate);

      expect(stats.totalDoses, equals(3));
      expect(stats.takenCount, equals(1));
      expect(stats.pendingCount, equals(1));
      expect(stats.missedCount, equals(1));
      expect(stats.completionPercentage, closeTo(33.33, 0.1));
    });
  });
}
