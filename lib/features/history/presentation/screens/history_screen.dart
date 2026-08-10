import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/core/theme/app_colors.dart';
import 'package:med_reminder/core/utils/date_formatter.dart';
import 'package:med_reminder/features/history/domain/usecases/filter_history_usecase.dart';
import 'package:med_reminder/features/history/presentation/providers/history_providers.dart';
import 'package:med_reminder/features/history/presentation/widgets/history_item_widget.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_occurrence_model.dart';
import 'package:med_reminder/features/medicine_core/data/models/dose_status_enum.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrences = ref.watch(filteredHistoryOccurrencesProvider);
    final dateFilter = ref.watch(historyDateFilterProvider);
    final statusFilter = ref.watch(historyStatusFilterProvider);
    final timeScope = ref.watch(historyTimeScopeProvider);
    final searchQuery = ref.watch(historySearchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final grouped = _groupOccurrencesByDate(occurrences);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dose Logs',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Modern Search Input
                TextField(
                  onChanged: (val) {
                    ref.read(historySearchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search medicine, notes...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              ref
                                  .read(historySearchQueryProvider.notifier)
                                  .state = '';
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Filter Chips Row
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Scope Segment Chips
                      _buildScopeChip(
                        ref,
                        label: 'Past & Today',
                        scope: HistoryTimeScope.pastAndToday,
                        currentScope: timeScope,
                        icon: Icons.history_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildScopeChip(
                        ref,
                        label: 'Upcoming',
                        scope: HistoryTimeScope.upcoming,
                        currentScope: timeScope,
                        icon: Icons.schedule_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildScopeChip(
                        ref,
                        label: 'All Logs',
                        scope: HistoryTimeScope.all,
                        currentScope: timeScope,
                        icon: Icons.list_alt_rounded,
                        isDark: isDark,
                      ),

                      const VerticalDivider(width: 16, indent: 6, endIndent: 6),

                      // Date Picker Chip
                      ActionChip(
                        avatar: Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: dateFilter != null
                              ? Colors.white
                              : AppColors.primary,
                        ),
                        label: Text(
                          dateFilter != null
                              ? DateFormatter.formatShortDate(dateFilter)
                              : 'Date Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: dateFilter != null
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                        backgroundColor: dateFilter != null
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface),
                        side: BorderSide(
                          color: dateFilter != null
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dateFilter ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            ref.read(historyDateFilterProvider.notifier).state =
                                picked;
                          }
                        },
                      ),
                      if (dateFilter != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            ref.read(historyDateFilterProvider.notifier).state =
                                null;
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(Icons.cancel_rounded,
                                size: 18, color: Colors.grey),
                          ),
                        ),
                      ],

                      const SizedBox(width: 6),

                      // Status Filter Chips
                      ...DoseStatusEnum.values.map((status) {
                        final isSelected = statusFilter == status;
                        final color = _getStatusColor(status);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: FilterChip(
                            showCheckmark: false,
                            selected: isSelected,
                            label: Text(
                              status.name.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                            selectedColor: color,
                            backgroundColor: color.withValues(alpha: 0.1),
                            side: BorderSide(color: color.withValues(alpha: 0.3)),
                            onSelected: (selected) {
                              ref
                                  .read(historyStatusFilterProvider.notifier)
                                  .state = selected ? status : null;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Occurrence History Grouped List
          Expanded(
            child: occurrences.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_toggle_off_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No Dose Records Found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try clearing search query or changing date filters.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, dateIndex) {
                      final dateHeader = grouped.keys.elementAt(dateIndex);
                      final itemsForDate = grouped[dateHeader]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateHeader,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${itemsForDate.length}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...itemsForDate.map(
                            (occ) => HistoryItemWidget(occurrence: occ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip(
    WidgetRef ref, {
    required String label,
    required HistoryTimeScope scope,
    required HistoryTimeScope currentScope,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = scope == currentScope;

    return ChoiceChip(
      showCheckmark: false,
      selected: isSelected,
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected
              ? Colors.white
              : (isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary),
        ),
      ),
      selectedColor: AppColors.primary,
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      onSelected: (selected) {
        if (selected) {
          ref.read(historyTimeScopeProvider.notifier).state = scope;
        }
      },
    );
  }

  Map<String, List<DoseOccurrenceModel>> _groupOccurrencesByDate(
      List<DoseOccurrenceModel> occurrences) {
    final Map<String, List<DoseOccurrenceModel>> grouped = {};
    final now = DateTime.now();

    for (final occ in occurrences) {
      final dateStr = DateFormatter.formatDate(occ.scheduledDateTime);
      String headerLabel = dateStr;
      if (DateFormatter.isSameDay(occ.scheduledDateTime, now)) {
        headerLabel = 'Today ($dateStr)';
      } else if (DateFormatter.isSameDay(
          occ.scheduledDateTime, now.add(const Duration(days: 1)))) {
        headerLabel = 'Tomorrow ($dateStr)';
      }

      grouped.putIfAbsent(headerLabel, () => []).add(occ);
    }
    return grouped;
  }

  Color _getStatusColor(DoseStatusEnum status) {
    switch (status) {
      case DoseStatusEnum.taken:
        return AppColors.statusTaken;
      case DoseStatusEnum.pending:
        return AppColors.statusPending;
      case DoseStatusEnum.missed:
        return AppColors.statusMissed;
      case DoseStatusEnum.skipped:
        return AppColors.statusSkipped;
    }
  }
}
