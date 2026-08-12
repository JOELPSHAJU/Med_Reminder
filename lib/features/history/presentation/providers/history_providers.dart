import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_reminder/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:med_reminder/features/history/domain/usecases/filter_history_usecase.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

final historySearchQueryProvider = StateProvider<String>((ref) => '');
final historyDateFilterProvider = StateProvider<DateTime?>((ref) => null);
final historyDateRangeFilterProvider = StateProvider<DateTimeRange?>(
  (ref) => null,
);
final historyStatusFilterProvider = StateProvider<DoseStatusEnum?>(
  (ref) => null,
);
final historyTimeScopeProvider = StateProvider<HistoryTimeScope>(
  (ref) => HistoryTimeScope.pastAndToday,
);

final filteredHistoryOccurrencesProvider = Provider<List<DoseOccurrenceModel>>((
  ref,
) {
  final occurrences = ref.watch(allOccurrencesProvider);
  final searchQuery = ref.watch(historySearchQueryProvider);
  final dateFilter = ref.watch(historyDateFilterProvider);
  final dateRangeFilter = ref.watch(historyDateRangeFilterProvider);
  final statusFilter = ref.watch(historyStatusFilterProvider);
  final timeScope = ref.watch(historyTimeScopeProvider);

  return FilterHistoryUseCase.filter(
    occurrences: occurrences,
    searchQuery: searchQuery,
    selectedDate: dateFilter,
    selectedDateRange: dateRangeFilter,
    statusFilter: statusFilter,
    timeScope: timeScope,
  );
});
