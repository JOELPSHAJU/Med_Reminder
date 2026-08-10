import 'package:hive/hive.dart';
import 'dose_status_enum.dart';

class DoseOccurrenceModel extends HiveObject {
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

  DoseOccurrenceModel({
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

  DoseOccurrenceModel copyWith({
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
    return DoseOccurrenceModel(
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

class DoseOccurrenceModelAdapter extends TypeAdapter<DoseOccurrenceModel> {
  @override
  final int typeId = 3;

  @override
  DoseOccurrenceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseOccurrenceModel(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      doseId: fields[2] as String,
      scheduledDateTime: fields[3] as DateTime,
      status: fields[4] as DoseStatusEnum,
      actualTakenTime: fields[5] as DateTime?,
      snoozedUntil: fields[6] as DateTime?,
      snoozeCount: fields[7] as int,
      medicineNameSnapshot: fields[8] as String,
      doseQuantitySnapshot: (fields[9] as num).toDouble(),
      doseUnitSnapshot: fields[10] as String,
      foodInstructionSnapshot: fields[11] as String,
      medicineTypeSnapshot: fields[12] as String,
      medicineStrengthSnapshot: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DoseOccurrenceModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.doseId)
      ..writeByte(3)
      ..write(obj.scheduledDateTime)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.actualTakenTime)
      ..writeByte(6)
      ..write(obj.snoozedUntil)
      ..writeByte(7)
      ..write(obj.snoozeCount)
      ..writeByte(8)
      ..write(obj.medicineNameSnapshot)
      ..writeByte(9)
      ..write(obj.doseQuantitySnapshot)
      ..writeByte(10)
      ..write(obj.doseUnitSnapshot)
      ..writeByte(11)
      ..write(obj.foodInstructionSnapshot)
      ..writeByte(12)
      ..write(obj.medicineTypeSnapshot)
      ..writeByte(13)
      ..write(obj.medicineStrengthSnapshot);
  }
}
