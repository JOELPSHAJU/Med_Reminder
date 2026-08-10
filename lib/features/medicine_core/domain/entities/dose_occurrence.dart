import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

class DoseOccurrence {
  final String id;
  final String medicineId;
  final String doseId;
  final DateTime scheduledDateTime;
  final DoseStatusEnum status;
  final DateTime? actualTakenTime;
  final DateTime? snoozedUntil;
  final int snoozeCount;
  final String medicineNameSnapshot;
  final double doseQuantitySnapshot;
  final String doseUnitSnapshot;
  final String foodInstructionSnapshot;
  final String medicineTypeSnapshot;
  final String medicineStrengthSnapshot;

  const DoseOccurrence({
    required this.id,
    required this.medicineId,
    required this.doseId,
    required this.scheduledDateTime,
    required this.status,
    this.actualTakenTime,
    this.snoozedUntil,
    this.snoozeCount = 0,
    required this.medicineNameSnapshot,
    required this.doseQuantitySnapshot,
    required this.doseUnitSnapshot,
    required this.foodInstructionSnapshot,
    required this.medicineTypeSnapshot,
    required this.medicineStrengthSnapshot,
  });

  DoseOccurrence copyWith({
    String? id,
    String? medicineId,
    String? doseId,
    DateTime? scheduledDateTime,
    DoseStatusEnum? status,
    DateTime? actualTakenTime,
    DateTime? snoozedUntil,
    int? snoozeCount,
    String? medicineNameSnapshot,
    double? doseQuantitySnapshot,
    String? doseUnitSnapshot,
    String? foodInstructionSnapshot,
    String? medicineTypeSnapshot,
    String? medicineStrengthSnapshot,
  }) {
    return DoseOccurrence(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      doseId: doseId ?? this.doseId,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      status: status ?? this.status,
      actualTakenTime: actualTakenTime ?? this.actualTakenTime,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      medicineNameSnapshot: medicineNameSnapshot ?? this.medicineNameSnapshot,
      doseQuantitySnapshot: doseQuantitySnapshot ?? this.doseQuantitySnapshot,
      doseUnitSnapshot: doseUnitSnapshot ?? this.doseUnitSnapshot,
      foodInstructionSnapshot:
          foodInstructionSnapshot ?? this.foodInstructionSnapshot,
      medicineTypeSnapshot: medicineTypeSnapshot ?? this.medicineTypeSnapshot,
      medicineStrengthSnapshot:
          medicineStrengthSnapshot ?? this.medicineStrengthSnapshot,
    );
  }
}
