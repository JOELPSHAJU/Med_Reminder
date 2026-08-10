import 'package:med_reminder/core/services/hive_service.dart';
import 'package:med_reminder/core/services/notification_service.dart';
import 'package:med_reminder/features/medicine_core/data/datasources/medicine_local_datasource.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';
import 'package:med_reminder/features/medicine_core/domain/repositories/medicine_repository.dart';
import 'package:med_reminder/features/medicine_core/domain/usecases/check_missed_occurrences_usecase.dart';
import 'package:med_reminder/features/medicine_core/domain/usecases/generate_occurrences_usecase.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineLocalDataSource _localDataSource;
  final NotificationService _notificationService;

  MedicineRepositoryImpl({
    MedicineLocalDataSource? localDataSource,
    NotificationService? notificationService,
  })  : _localDataSource = localDataSource ?? MedicineLocalDataSource(),
        _notificationService = notificationService ?? NotificationService();

  @override
  List<MedicineModel> getAllMedicines() {
    return _localDataSource.getAllMedicines();
  }

  @override
  MedicineModel? getMedicineById(String id) {
    return _localDataSource.getMedicineById(id);
  }

  @override
  Future<void> saveMedicine(MedicineModel medicine) async {
    await _localDataSource.saveMedicine(medicine);

    // De-duplicate any existing entries first
    await _cleanDuplicateOccurrences();

    // Generate occurrences
    final existing = _localDataSource.getAllOccurrences();
    final newOccurrences = GenerateOccurrencesUseCase.generateForMedicine(
      medicine: medicine,
      existingOccurrences: existing,
    );

    if (newOccurrences.isNotEmpty) {
      await _localDataSource.saveOccurrences(newOccurrences);
      for (final occ in newOccurrences) {
        if (occ.status == DoseStatusEnum.pending &&
            occ.scheduledDateTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleDoseNotification(
            occurrenceId: occ.id,
            medicineName: occ.medicineNameSnapshot,
            doseDetails: '${occ.doseQuantitySnapshot} ${occ.doseUnitSnapshot}',
            scheduledDateTime: occ.scheduledDateTime,
            foodInstruction: occ.foodInstructionSnapshot,
          );
        }
      }
    }
  }

  @override
  Future<void> deleteMedicine(String id) async {
    final occurrences = _localDataSource.getAllOccurrences();
    for (final occ in occurrences) {
      if (occ.medicineId == id && occ.status == DoseStatusEnum.pending) {
        await _notificationService.cancelNotification(occ.id);
      }
    }
    await _localDataSource.deleteOccurrencesForMedicine(id);
    await _localDataSource.deleteMedicine(id);
  }

  @override
  Future<void> toggleMedicineActiveStatus(String id) async {
    final med = _localDataSource.getMedicineById(id);
    if (med == null) return;

    final updated = med.copyWith(isActive: !med.isActive);
    await _localDataSource.saveMedicine(updated);

    if (!updated.isActive) {
      // Cancel pending notifications when paused
      final occurrences = _localDataSource.getAllOccurrences();
      for (final occ in occurrences) {
        if (occ.medicineId == id && occ.status == DoseStatusEnum.pending) {
          await _notificationService.cancelNotification(occ.id);
        }
      }
    } else {
      // Regenerate when resumed
      await saveMedicine(updated);
    }
  }

  @override
  List<DoseOccurrenceModel> getAllOccurrences() {
    return _localDataSource.getAllOccurrences();
  }

  @override
  Future<void> saveOccurrences(List<DoseOccurrenceModel> occurrences) async {
    await _localDataSource.saveOccurrences(occurrences);
  }

  @override
  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    DoseStatusEnum newStatus, {
    DateTime? takenTime,
  }) async {
    final all = _localDataSource.getAllOccurrences();
    final index = all.indexWhere((occ) => occ.id == occurrenceId);
    if (index == -1) return;

    final occ = all[index];
    final updated = occ.copyWith(
      status: newStatus,
      actualTakenTime: newStatus == DoseStatusEnum.taken
          ? (takenTime ?? DateTime.now())
          : null,
      snoozedUntil: null,
    );

    await _localDataSource.updateOccurrence(updated);
    await _notificationService.cancelNotification(occurrenceId);
  }

  @override
  Future<void> snoozeOccurrence(String occurrenceId, int snoozeMinutes) async {
    final all = _localDataSource.getAllOccurrences();
    final index = all.indexWhere((occ) => occ.id == occurrenceId);
    if (index == -1) return;

    final occ = all[index];
    final snoozedUntil = DateTime.now().add(Duration(minutes: snoozeMinutes));

    final updated = occ.copyWith(
      snoozedUntil: snoozedUntil,
      snoozeCount: occ.snoozeCount + 1,
    );

    await _localDataSource.updateOccurrence(updated);

    // Schedule notification for snoozed time
    await _notificationService.scheduleDoseNotification(
      occurrenceId: occurrenceId,
      medicineName: occ.medicineNameSnapshot,
      doseDetails:
          '[Snoozed] ${occ.doseQuantitySnapshot} ${occ.doseUnitSnapshot}',
      scheduledDateTime: snoozedUntil,
      foodInstruction: occ.foodInstructionSnapshot,
    );
  }

  @override
  Future<void> checkAndSyncOccurrences() async {
    // 0. Clean duplicate occurrences if any exist from prior runs
    await _cleanDuplicateOccurrences();

    final allOccurrences = _localDataSource.getAllOccurrences();

    // 1. Auto-transition past pending occurrences to missed
    final evaluated = CheckMissedOccurrencesUseCase.evaluateMissedOccurrences(
      allOccurrences,
    );

    for (final occ in evaluated) {
      if (occ.status == DoseStatusEnum.missed) {
        final original = allOccurrences.firstWhere((o) => o.id == occ.id);
        if (original.status == DoseStatusEnum.pending) {
          await _localDataSource.updateOccurrence(occ);
          await _notificationService.cancelNotification(occ.id);
        }
      }
    }

    // 2. Extend rolling generation for ongoing active medicines
    final medicines = _localDataSource.getAllMedicines();
    final freshOccurrences = _localDataSource.getAllOccurrences();

    for (final med in medicines) {
      if (med.isActive) {
        final newGen = GenerateOccurrencesUseCase.generateForMedicine(
          medicine: med,
          existingOccurrences: freshOccurrences,
        );
        if (newGen.isNotEmpty) {
          await _localDataSource.saveOccurrences(newGen);
          for (final occ in newGen) {
            if (occ.status == DoseStatusEnum.pending &&
                occ.scheduledDateTime.isAfter(DateTime.now())) {
              await _notificationService.scheduleDoseNotification(
                occurrenceId: occ.id,
                medicineName: occ.medicineNameSnapshot,
                doseDetails:
                    '${occ.doseQuantitySnapshot} ${occ.doseUnitSnapshot}',
                scheduledDateTime: occ.scheduledDateTime,
                foodInstruction: occ.foodInstructionSnapshot,
              );
            }
          }
        }
      }
    }
  }

  Future<void> _cleanDuplicateOccurrences() async {
    final all = _localDataSource.getAllOccurrences();
    final Map<String, List<DoseOccurrenceModel>> grouped = {};

    for (final occ in all) {
      final key =
          '${occ.medicineId}_${occ.scheduledDateTime.year}_${occ.scheduledDateTime.month}_${occ.scheduledDateTime.day}_${occ.scheduledDateTime.hour}_${occ.scheduledDateTime.minute}';
      grouped.putIfAbsent(key, () => []).add(occ);
    }

    for (final list in grouped.values) {
      if (list.length > 1) {
        // Sort: Non-pending (taken/missed/skipped) first, then snoozed, then earliest created
        list.sort((a, b) {
          if (a.status != DoseStatusEnum.pending &&
              b.status == DoseStatusEnum.pending) {
            return -1;
          }
          if (a.status == DoseStatusEnum.pending &&
              b.status != DoseStatusEnum.pending) {
            return 1;
          }
          return 0;
        });

        // Retain the primary entry, remove duplicates from Hive & cancel notifications
        for (int i = 1; i < list.length; i++) {
          final dup = list[i];
          await _notificationService.cancelNotification(dup.id);
          await HiveService.occurrenceBox.delete(dup.id);
        }
      }
    }
  }
}
