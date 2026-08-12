import 'package:flutter_test/flutter_test.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';
import 'package:med_reminder/features/medicine_core/domain/usecases/generate_occurrences_usecase.dart';

void main() {
  group('GenerateOccurrencesUseCase Tests', () {
    test('Generates correct occurrences for fixed duration medicine', () {
      final startDate = DateTime(2026, 8, 1);
      final endDate = DateTime(2026, 8, 3); // 3 days: Aug 1, Aug 2, Aug 3

      final medicine = MedicineModel(
        id: 'med_1',
        name: 'Amoxicillin',
        description: 'Antibiotic',
        type: 'Capsule',
        strength: '500 mg',
        startDate: startDate,
        endDate: endDate,
        isOngoing: false,
        isActive: true,
        createdAt: DateTime.now(),
        doses: [
          DoseModel(
            id: 'dose_1',
            medicineId: 'med_1',
            timeHour: 8,
            timeMinute: 0,
            quantity: 1,
            unit: 'Capsule',
            foodInstruction: 'After food',
          ),
          DoseModel(
            id: 'dose_2',
            medicineId: 'med_1',
            timeHour: 20,
            timeMinute: 0,
            quantity: 1,
            unit: 'Capsule',
            foodInstruction: 'After food',
          ),
        ],
      );

      final occurrences = GenerateOccurrencesUseCase.generateForMedicine(
        medicine: medicine,
        existingOccurrences: [],
      );

      // 3 days * 2 doses per day = 6 total occurrences
      expect(occurrences.length, equals(6));
      expect(occurrences.first.medicineNameSnapshot, equals('Amoxicillin'));
      expect(occurrences.first.status, equals(DoseStatusEnum.pending));
    });

    test(
      'Does not regenerate existing occurrence snapshots even if doseId changes',
      () {
        final startDate = DateTime(2026, 8, 1);
        final endDate = DateTime(2026, 8, 1);

        final medicine = MedicineModel(
          id: 'med_2',
          name: 'Updated Name Aspirin',
          description: 'Pain killer',
          type: 'Tablet',
          strength: '100 mg',
          startDate: startDate,
          endDate: endDate,
          isOngoing: false,
          isActive: true,
          createdAt: DateTime.now(),
          doses: [
            DoseModel(
              id: 'new_dose_uuid_123', // Brand new dose UUID from edit
              medicineId: 'med_2',
              timeHour: 8,
              timeMinute: 0,
              quantity: 1,
              unit: 'Tablet',
              foodInstruction: 'With food',
            ),
          ],
        );

        final existingSnapshot = DoseOccurrenceModel(
          id: 'occ_existing',
          medicineId: 'med_2',
          doseId: 'old_dose_uuid_000',
          scheduledDateTime: DateTime(2026, 8, 1, 8, 0),
          status: DoseStatusEnum.taken,
          medicineNameSnapshot: 'Original Old Name Aspirin',
          doseQuantitySnapshot: 1,
          doseUnitSnapshot: 'Tablet',
          foodInstructionSnapshot: 'With food',
          medicineTypeSnapshot: 'Tablet',
          medicineStrengthSnapshot: '100 mg',
        );

        final occurrences = GenerateOccurrencesUseCase.generateForMedicine(
          medicine: medicine,
          existingOccurrences: [existingSnapshot],
        );

        // Since an occurrence for med_2 at 2026-08-01 08:00 already exists, no duplicate is generated
        expect(occurrences.isEmpty, isTrue);
      },
    );
  });
}
