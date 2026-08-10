import 'dose.dart';

class Medicine {
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
  final List<Dose> doses;

  const Medicine({
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

  Medicine copyWith({
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
    List<Dose>? doses,
  }) {
    return Medicine(
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
