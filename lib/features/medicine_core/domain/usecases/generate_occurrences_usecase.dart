import 'package:uuid/uuid.dart';
import 'package:med_reminder/core/constants/app_constants.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';

class GenerateOccurrencesUseCase {
  static List<DoseOccurrenceModel> generateForMedicine({
    required MedicineModel medicine,
    required List<DoseOccurrenceModel> existingOccurrences,
    DateTime? nowOverride,
  }) {
    if (!medicine.isActive) return [];

    final now = nowOverride ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(
      medicine.startDate.year,
      medicine.startDate.month,
      medicine.startDate.day,
    );

    DateTime windowEnd;
    if (!medicine.isOngoing && medicine.endDate != null) {
      windowEnd = DateTime(
        medicine.endDate!.year,
        medicine.endDate!.month,
        medicine.endDate!.day,
      );
    } else {
      windowEnd = today.add(
        const Duration(days: AppConstants.ongoingScheduleWindowDays),
      );
    }

    DateTime currentDay = startDateOnly;
    final List<DoseOccurrenceModel> newOccurrences = [];

    // Map existing occurrences by medicineId + scheduledDateTime key
    final Map<String, DoseOccurrenceModel> existingMap = {
      for (final occ in existingOccurrences)
        if (occ.medicineId == medicine.id)
          _buildKey(occ.medicineId, occ.scheduledDateTime): occ,
    };

    while (!currentDay.isAfter(windowEnd)) {
      for (final dose in medicine.doses) {
        final scheduledDateTime = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          dose.timeHour,
          dose.timeMinute,
        );

        final key = _buildKey(medicine.id, scheduledDateTime);

        if (!existingMap.containsKey(key)) {
          final newOccurrence = DoseOccurrenceModel(
            id: const Uuid().v4(),
            medicineId: medicine.id,
            doseId: dose.id,
            scheduledDateTime: scheduledDateTime,
            status: DoseStatusEnum.pending,
            medicineNameSnapshot: medicine.name,
            doseQuantitySnapshot: dose.quantity,
            doseUnitSnapshot: dose.unit,
            foodInstructionSnapshot: dose.foodInstruction,
            medicineTypeSnapshot: medicine.type,
            medicineStrengthSnapshot: medicine.strength,
          );
          newOccurrences.add(newOccurrence);
        }
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }

    return newOccurrences;
  }

  static String _buildKey(String medicineId, DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${medicineId}_${year}${month}${day}_$hour$minute';
  }
}
