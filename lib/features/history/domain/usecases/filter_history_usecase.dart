import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

enum HistoryTimeScope {
  pastAndToday,
  upcoming,
  all,
}

class FilterHistoryUseCase {
  static List<DoseOccurrenceModel> filter({
    required List<DoseOccurrenceModel> occurrences,
    required String searchQuery,
    DateTime? selectedDate,
    DoseStatusEnum? statusFilter,
    HistoryTimeScope timeScope = HistoryTimeScope.pastAndToday,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return occurrences.where((occ) {
      // 1. Time Scope Filter (if no specific date is selected)
      if (selectedDate == null) {
        if (timeScope == HistoryTimeScope.pastAndToday) {
          if (occ.scheduledDateTime.isAfter(endOfToday)) return false;
        } else if (timeScope == HistoryTimeScope.upcoming) {
          if (!occ.scheduledDateTime.isAfter(endOfToday)) return false;
        }
      }

      // 2. Search Query Filter (Case-Insensitive)
      if (query.isNotEmpty) {
        final nameMatch = occ.medicineNameSnapshot.toLowerCase().contains(query);
        final strengthMatch =
            occ.medicineStrengthSnapshot.toLowerCase().contains(query);
        final foodMatch =
            occ.foodInstructionSnapshot.toLowerCase().contains(query);
        if (!nameMatch && !strengthMatch && !foodMatch) {
          return false;
        }
      }

      // 3. Specific Date Filter
      if (selectedDate != null) {
        if (!DateFormatter.isSameDay(occ.scheduledDateTime, selectedDate)) {
          return false;
        }
      }

      // 4. Status Filter
      if (statusFilter != null) {
        if (occ.status != statusFilter) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.scheduledDateTime.compareTo(a.scheduledDateTime));
  }
}
