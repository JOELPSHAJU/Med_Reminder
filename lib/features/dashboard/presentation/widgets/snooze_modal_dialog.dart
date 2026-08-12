import 'package:flutter/material.dart';
import 'package:med_reminder/core/theme/app_colors.dart';

class SnoozeModalDialog extends StatelessWidget {
  final int defaultMinutes;
  final Function(int minutes) onSnoozeSelected;

  const SnoozeModalDialog({
    super.key,
    required this.defaultMinutes,
    required this.onSnoozeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = [5, 10, 15, 30];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Snooze Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select how long you want to snooze this dose reminder.',
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((minutes) {
              final isDefault = minutes == defaultMinutes;
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onSnoozeSelected(minutes);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDefault
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$minutes mins${isDefault ? ' (Default)' : ''}',
                    style: TextStyle(
                      color: isDefault
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
