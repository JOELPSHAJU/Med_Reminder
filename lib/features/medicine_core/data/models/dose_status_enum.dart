import 'package:hive/hive.dart';

enum DoseStatusEnum { pending, taken, missed, skipped }

class DoseStatusAdapter extends TypeAdapter<DoseStatusEnum> {
  @override
  final int typeId = 0;

  @override
  DoseStatusEnum read(BinaryReader reader) {
    switch (reader.readInt()) {
      case 0:
        return DoseStatusEnum.pending;
      case 1:
        return DoseStatusEnum.taken;
      case 2:
        return DoseStatusEnum.missed;
      case 3:
        return DoseStatusEnum.skipped;
      default:
        return DoseStatusEnum.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DoseStatusEnum obj) {
    switch (obj) {
      case DoseStatusEnum.pending:
        writer.writeInt(0);
        break;
      case DoseStatusEnum.taken:
        writer.writeInt(1);
        break;
      case DoseStatusEnum.missed:
        writer.writeInt(2);
        break;
      case DoseStatusEnum.skipped:
        writer.writeInt(3);
        break;
    }
  }
}
