import 'package:hive/hive.dart';
import 'dose_model.dart';

class MedicineModel extends HiveObject {
  final String id;
  final String name;
  final String description;
  final String type;
  final String strength;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final bool isActive;
  final DateTime createdAt;
  final List<DoseModel> doses;

  MedicineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.strength,
    required this.startDate,
    this.endDate,
    required this.isOngoing,
    this.isActive = true,
    required this.createdAt,
    required this.doses,
  });

  MedicineModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? strength,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOngoing,
    bool? isActive,
    DateTime? createdAt,
    List<DoseModel>? doses,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isOngoing: isOngoing ?? this.isOngoing,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      doses: doses ?? this.doses,
    );
  }
}

class MedicineModelAdapter extends TypeAdapter<MedicineModel> {
  @override
  final int typeId = 2;

  @override
  MedicineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as String,
      strength: fields[4] as String,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      isOngoing: fields[7] as bool,
      isActive: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      doses: (fields[10] as List).cast<DoseModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, MedicineModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.strength)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.isOngoing)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.doses);
  }
}
