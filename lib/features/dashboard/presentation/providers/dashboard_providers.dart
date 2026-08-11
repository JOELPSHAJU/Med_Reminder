import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_reminder/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';
import 'package:med_reminder/features/medicine_core/data/repositories/medicine_repository_impl.dart';
import 'package:med_reminder/features/medicine_core/domain/repositories/medicine_repository.dart';

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepositoryImpl();
});

class MedicineStateNotifier extends StateNotifier<AsyncValue<void>> {
  final MedicineRepository _repository;

  MedicineStateNotifier(this._repository) : super(const AsyncValue.data(null)) {
    syncAndRefresh();
  }

  Future<void> syncAndRefresh() async {
    state = const AsyncValue.loading();
    try {
      await _repository.checkAndSyncOccurrences();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdateMedicine(MedicineModel medicine) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveMedicine(medicine);
      await syncAndRefresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteMedicine(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMedicine(id);
      await syncAndRefresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleMedicineActive(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleMedicineActiveStatus(id);
      await syncAndRefresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    DoseStatusEnum status,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateOccurrenceStatus(occurrenceId, status);
      await syncAndRefresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> snoozeOccurrence(
    String occurrenceId,
    int minutes,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repository.snoozeOccurrence(occurrenceId, minutes);
      await syncAndRefresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final medicineStateNotifierProvider =
    StateNotifierProvider<MedicineStateNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(medicineRepositoryProvider);
  return MedicineStateNotifier(repo);
});

final allMedicinesProvider = Provider<List<MedicineModel>>((ref) {
  ref.watch(medicineStateNotifierProvider);
  final repo = ref.watch(medicineRepositoryProvider);
  return repo.getAllMedicines();
});

final allOccurrencesProvider = Provider<List<DoseOccurrenceModel>>((ref) {
  ref.watch(medicineStateNotifierProvider);
  final repo = ref.watch(medicineRepositoryProvider);
  return repo.getAllOccurrences();
});

final selectedDashboardDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final todayOccurrencesProvider = Provider<List<DoseOccurrenceModel>>((ref) {
  final occurrences = ref.watch(allOccurrencesProvider);
  final targetDate = ref.watch(selectedDashboardDateProvider);

  final filtered = occurrences.where((occ) {
    return occ.scheduledDateTime.year == targetDate.year &&
        occ.scheduledDateTime.month == targetDate.month &&
        occ.scheduledDateTime.day == targetDate.day;
  }).toList();

  filtered.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  return filtered;
});

/// Only pending (upcoming) doses scheduled after current time — used by the dashboard list.
/// Past doses, taken, skipped, and missed doses are excluded from the front page.
final upcomingOccurrencesProvider = Provider<List<DoseOccurrenceModel>>((ref) {
  final all = ref.watch(todayOccurrencesProvider);
  final targetDate = ref.watch(selectedDashboardDateProvider);
  final now = DateTime.now();

  final isToday = targetDate.year == now.year &&
      targetDate.month == now.month &&
      targetDate.day == now.day;

  return all.where((occ) {
    if (occ.status != DoseStatusEnum.pending) return false;

    if (isToday) {
      final effectiveTime = occ.snoozedUntil ?? occ.scheduledDateTime;
      return effectiveTime.isAfter(now.subtract(const Duration(minutes: 1)));
    }

    return targetDate.isAfter(now);
  }).toList();
});

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final occurrences = ref.watch(allOccurrencesProvider);
  final targetDate = ref.watch(selectedDashboardDateProvider);
  return GetDashboardStatsUseCase.calculateForDate(occurrences, targetDate);
});
