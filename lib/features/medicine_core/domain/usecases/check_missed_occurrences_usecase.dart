import 'package:med_reminder/core/constants/app_constants.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

class CheckMissedOccurrencesUseCase {
  static List<DoseOccurrenceModel> evaluateMissedOccurrences(
    List<DoseOccurrenceModel> occurrences, {
    DateTime? nowOverride,
  }) {
    final now = nowOverride ?? DateTime.now();
    final List<DoseOccurrenceModel> updatedList = [];

    for (final occ in occurrences) {
      if (occ.status == DoseStatusEnum.pending) {
        final targetTime = occ.snoozedUntil ?? occ.scheduledDateTime;
        final graceTime = targetTime.add(
          const Duration(minutes: AppConstants.missedGracePeriodMinutes),
        );
        if (now.isAfter(graceTime)) {
          updatedList.add(occ.copyWith(status: DoseStatusEnum.missed));
          continue;
        }
      }
      updatedList.add(occ);
    }

    return updatedList;
  }
}
