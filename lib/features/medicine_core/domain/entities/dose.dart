class Dose {
  final String id;
  final String medicineId;
  final int timeHour;
  final int timeMinute;
  final double quantity;
  final String unit;
  final String foodInstruction;

  const Dose({
    required this.id,
    required this.medicineId,
    required this.timeHour,
    required this.timeMinute,
    required this.quantity,
    required this.unit,
    required this.foodInstruction,
  });

  Dose copyWith({
    String? id,
    String? medicineId,
    int? timeHour,
    int? timeMinute,
    double? quantity,
    String? unit,
    String? foodInstruction,
  }) {
    return Dose(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      timeHour: timeHour ?? this.timeHour,
      timeMinute: timeMinute ?? this.timeMinute,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      foodInstruction: foodInstruction ?? this.foodInstruction,
    );
  }
}
