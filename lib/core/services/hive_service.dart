import 'package:hive_flutter/hive_flutter.dart';
import '../../features/medicine_core/data/models/dose_status_enum.dart';
import '../../features/medicine_core/data/models/dose_model.dart';
import '../../features/medicine_core/data/models/medicine_model.dart';
import '../../features/medicine_core/data/models/dose_occurrence_model.dart';
import '../../features/settings/data/models/app_settings_model.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Type Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DoseStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DoseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MedicineModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DoseOccurrenceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsModelAdapter());
    }

    // Open Boxes
    await Hive.openBox<MedicineModel>(AppConstants.medicineBoxName);
    await Hive.openBox<DoseOccurrenceModel>(AppConstants.occurrenceBoxName);
    await Hive.openBox<AppSettingsModel>(AppConstants.settingsBoxName);
  }

  static Box<MedicineModel> get medicineBox =>
      Hive.box<MedicineModel>(AppConstants.medicineBoxName);

  static Box<DoseOccurrenceModel> get occurrenceBox =>
      Hive.box<DoseOccurrenceModel>(AppConstants.occurrenceBoxName);

  static Box<AppSettingsModel> get settingsBox =>
      Hive.box<AppSettingsModel>(AppConstants.settingsBoxName);
}
