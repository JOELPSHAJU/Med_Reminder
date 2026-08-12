import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';

class DoseInputData {
  TimeOfDay time;
  double quantity;
  String unit;
  String foodInstruction;

  DoseInputData({
    required this.time,
    required this.quantity,
    required this.unit,
    required this.foodInstruction,
  });
}

class DoseInputTile extends StatelessWidget {
  final int doseIndex;
  final DoseInputData data;
  final VoidCallback onDelete;
  final VoidCallback onTimePick;

  const DoseInputTile({
    super.key,
    required this.doseIndex,
    required this.data,
    required this.onDelete,
    required this.onTimePick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foodInstructions = [
      'No instruction',
      'Before food',
      'After food',
      'With food',
      'Empty stomach',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Dose #${doseIndex + 1}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Time Picker Button Tile
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: onTimePick,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF8FAFC),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatTimeOfDay(
                            data.time.hour,
                            data.time.minute,
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Dose Quantity Input
              Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: data.quantity.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Qty',
                    isDense: true,
                  ),
                  onChanged: (val) {
                    data.quantity = double.tryParse(val) ?? 1.0;
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Dose Unit Input
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: data.unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'tablet',
                    isDense: true,
                  ),
                  onChanged: (val) {
                    data.unit = val;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Food Instruction Dropdown
          DropdownButtonFormField<String>(
            initialValue: foodInstructions.contains(data.foodInstruction)
                ? data.foodInstruction
                : foodInstructions.first,
            decoration: const InputDecoration(
              labelText: 'Food Instruction',
              isDense: true,
            ),
            items: foodInstructions.map((instruction) {
              return DropdownMenuItem(
                value: instruction,
                child: Text(
                  instruction,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) data.foodInstruction = val;
            },
          ),
        ],
      ),
    );
  }
}
