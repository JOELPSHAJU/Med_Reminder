import 'package:med_reminder/core/services/hive_service.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';

class MedicineLocalDataSource {
  List<MedicineModel> getAllMedicines() {
    return HiveService.medicineBox.values.toList();
  }

  MedicineModel? getMedicineById(String id) {
    return HiveService.medicineBox.get(id);
  }

  Future<void> saveMedicine(MedicineModel medicine) async {
    await HiveService.medicineBox.put(medicine.id, medicine);
  }

  Future<void> deleteMedicine(String id) async {
    await HiveService.medicineBox.delete(id);
  }

  List<DoseOccurrenceModel> getAllOccurrences() {
    return HiveService.occurrenceBox.values.toList();
  }

  Future<void> saveOccurrences(List<DoseOccurrenceModel> occurrences) async {
    final Map<String, DoseOccurrenceModel> entries = {
      for (final occ in occurrences) occ.id: occ
    };
    await HiveService.occurrenceBox.putAll(entries);
  }

  Future<void> updateOccurrence(DoseOccurrenceModel occurrence) async {
    await HiveService.occurrenceBox.put(occurrence.id, occurrence);
  }

  Future<void> deleteOccurrencesForMedicine(String medicineId) async {
    final box = HiveService.occurrenceBox;
    final keysToDelete = box.values
        .where((occ) => occ.medicineId == medicineId && occ.status.name == 'pending')
        .map((occ) => occ.id)
        .toList();
    await box.deleteAll(keysToDelete);
  }
}
