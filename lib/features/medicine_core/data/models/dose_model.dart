import 'package:hive/hive.dart';

class DoseModel extends HiveObject {
  final String id;
  final String medicineId;
  final int timeHour;
  final int timeMinute;
  final double quantity;
  final String unit;
  final String foodInstruction;

  DoseModel({
    required this.id,
    required this.medicineId,
    required this.timeHour,
    required this.timeMinute,
    required this.quantity,
    required this.unit,
    required this.foodInstruction,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicineId': medicineId,
    'timeHour': timeHour,
    'timeMinute': timeMinute,
    'quantity': quantity,
    'unit': unit,
    'foodInstruction': foodInstruction,
  };

  factory DoseModel.fromJson(Map<String, dynamic> json) => DoseModel(
    id: json['id'] as String,
    medicineId: json['medicineId'] as String,
    timeHour: json['timeHour'] as int,
    timeMinute: json['timeMinute'] as int,
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'] as String,
    foodInstruction: json['foodInstruction'] as String,
  );
}

class DoseModelAdapter extends TypeAdapter<DoseModel> {
  @override
  final int typeId = 1;

  @override
  DoseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseModel(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      timeHour: fields[2] as int,
      timeMinute: fields[3] as int,
      quantity: (fields[4] as num).toDouble(),
      unit: fields[5] as String,
      foodInstruction: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DoseModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.timeHour)
      ..writeByte(3)
      ..write(obj.timeMinute)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.foodInstruction);
  }
}
