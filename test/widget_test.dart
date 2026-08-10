import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:med_reminder/core/constants/app_constants.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';
import 'package:med_reminder/features/settings/data/models/app_settings_model.dart';
import 'package:med_reminder/main.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_widget_test');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(DoseStatusAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DoseModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(MedicineModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DoseOccurrenceModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AppSettingsModelAdapter());

    await Hive.openBox<MedicineModel>(AppConstants.medicineBoxName);
    await Hive.openBox<DoseOccurrenceModel>(AppConstants.occurrenceBoxName);
    await Hive.openBox<AppSettingsModel>(AppConstants.settingsBoxName);
  });

  testWidgets('App renders SplashScreen and transitions to MainNavigationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MedReminderApp(),
      ),
    );
    await tester.pump();

    // Verify SplashScreen is rendered initially
    expect(find.text('Med Reminder'), findsOneWidget);
    expect(find.text('Your Daily Health & Dose Companion'), findsOneWidget);

    // Pump time for splash screen timer navigation
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify MainNavigationScreen is rendered after splash transition
    expect(find.text('DAILY PROGRESS TRACKER'), findsOneWidget);
  });
}
