import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';

abstract class MedicineRepository {
  List<MedicineModel> getAllMedicines();
  MedicineModel? getMedicineById(String id);
  Future<void> saveMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String id);
  Future<void> toggleMedicineActiveStatus(String id);

  List<DoseOccurrenceModel> getAllOccurrences();
  Future<void> saveOccurrences(List<DoseOccurrenceModel> occurrences);
  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    DoseStatusEnum newStatus, {
    DateTime? takenTime,
  });
  Future<void> snoozeOccurrence(
    String occurrenceId,
    int snoozeMinutes,
  );
  Future<void> checkAndSyncOccurrences();
}
