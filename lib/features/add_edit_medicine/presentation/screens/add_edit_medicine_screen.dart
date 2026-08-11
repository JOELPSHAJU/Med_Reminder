import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/add_edit_medicine/presentation/widgets/dose_input_tile.dart';
import 'package:med_reminder/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/medicine_model.dart';
import 'package:uuid/uuid.dart';

class AddEditMedicineScreen extends ConsumerStatefulWidget {
  final MedicineModel? existingMedicine;

  const AddEditMedicineScreen({super.key, this.existingMedicine});

  @override
  ConsumerState<AddEditMedicineScreen> createState() =>
      _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState
    extends ConsumerState<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _strengthController;

  String _selectedType = 'Tablet';
  bool _isOngoing = true;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;

  List<DoseInputData> _doses = [];

  final Map<String, IconData> _typeIcons = {
    'Tablet': Icons.medication_rounded,
    'Capsule': Icons.medication_liquid_rounded,
    'Syrup': Icons.sanitizer_rounded,
    'Injection': Icons.vaccines_rounded,
    'Drops': Icons.water_drop_rounded,
    'Topical': Icons.clean_hands_rounded,
    'Inhaler': Icons.air_rounded,
  };

  @override
  void initState() {
    super.initState();
    final med = widget.existingMedicine;

    _nameController = TextEditingController(text: med?.name ?? '');
    _descController = TextEditingController(text: med?.description ?? '');
    _strengthController = TextEditingController(text: med?.strength ?? '');

    if (med != null) {
      _selectedType = med.type;
      _isOngoing = med.isOngoing;
      _startDate = med.startDate;
      _endDate = med.endDate;

      _doses = med.doses.map((d) {
        return DoseInputData(
          time: TimeOfDay(hour: d.timeHour, minute: d.timeMinute),
          quantity: d.quantity,
          unit: d.unit,
          foodInstruction: d.foodInstruction,
        );
      }).toList();
    }

    if (_doses.isEmpty) {
      _doses.add(
        DoseInputData(
          time: const TimeOfDay(hour: 8, minute: 0),
          quantity: 1.0,
          unit: 'Tablet',
          foodInstruction: 'After food',
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  void _saveMedicine() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_doses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one dose schedule.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final medicineId = widget.existingMedicine?.id ?? const Uuid().v4();

      final List<DoseModel> doseModels = _doses.map((d) {
        return DoseModel(
          id: const Uuid().v4(),
          medicineId: medicineId,
          timeHour: d.time.hour,
          timeMinute: d.time.minute,
          quantity: d.quantity,
          unit: d.unit,
          foodInstruction: d.foodInstruction,
        );
      }).toList();

      final newMedicine = MedicineModel(
        id: medicineId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        type: _selectedType,
        strength: _strengthController.text.trim().isEmpty
            ? '1 dose'
            : _strengthController.text.trim(),
        startDate: _startDate,
        endDate: _isOngoing ? null : _endDate,
        isOngoing: _isOngoing,
        isActive: widget.existingMedicine?.isActive ?? true,
        createdAt: widget.existingMedicine?.createdAt ?? DateTime.now(),
        doses: doseModels,
      );

      await ref
          .read(medicineStateNotifierProvider.notifier)
          .addOrUpdateMedicine(newMedicine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingMedicine == null
                  ? 'Medicine added successfully!'
                  : 'Medicine updated successfully!',
            ),
            backgroundColor: AppColors.statusTaken,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving medicine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMedicine == null ? 'Add Medicine' : 'Edit Medicine',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _saveMedicine,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.check_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section Header
              Text(
                'General Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  hintText: 'e.g. Paracetamol, Amoxicillin',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Medicine Type Chips Selector
              Text(
                'Medicine Form',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _typeIcons.entries.map((entry) {
                    final typeName = entry.key;
                    final iconData = entry.value;
                    final isSelected = typeName == _selectedType;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        showCheckmark: false,
                        selected: isSelected,
                        avatar: Icon(
                          iconData,
                          size: 16,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                        label: Text(typeName),
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : const Color(0xFFF1F5F9),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isSelected
                              ? AppColors.primaryDark
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = typeName);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _strengthController,
                decoration: const InputDecoration(
                  labelText: 'Dosage / Strength',
                  hintText: 'e.g. 500 mg, 10 ml',
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes / Instructions (Optional)',
                  hintText: 'e.g. Take with a full glass of water',
                ),
              ),
              const SizedBox(height: 24),

              // Treatment Duration Card
              Text(
                'Treatment Duration',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Ongoing Treatment (No End Date)',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Schedule will automatically extend 30 days into the future.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                      value: _isOngoing,
                      onChanged: (val) {
                        setState(() {
                          _isOngoing = val;
                          if (!_isOngoing && _endDate == null) {
                            _endDate =
                                DateTime.now().add(const Duration(days: 7));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date *',
                              ),
                              child: Text(
                                DateFormatter.formatShortDate(_startDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!_isOngoing) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ??
                                      DateTime.now()
                                          .add(const Duration(days: 7)),
                                  firstDate: _startDate,
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 730)),
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Date *',
                                ),
                                child: Text(
                                  _endDate != null
                                      ? DateFormatter.formatShortDate(_endDate!)
                                      : 'Select Date',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daily Dose Schedule Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Dose Times',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _doses.add(
                          DoseInputData(
                            time: const TimeOfDay(hour: 20, minute: 0),
                            quantity: 1.0,
                            unit: _selectedType,
                            foodInstruction: 'After food',
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Dose Time'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _doses.length,
                itemBuilder: (context, index) {
                  return DoseInputTile(
                    doseIndex: index,
                    data: _doses[index],
                    onDelete: () {
                      setState(() {
                        _doses.removeAt(index);
                      });
                    },
                    onTimePick: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _doses[index].time,
                      );
                      if (picked != null) {
                        setState(() {
                          _doses[index].time = picked;
                        });
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveMedicine,
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : Text(
                          widget.existingMedicine == null
                              ? 'Save & Schedule Reminders'
                              : 'Update Medicine Reminders',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
