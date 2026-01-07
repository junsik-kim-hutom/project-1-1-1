import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MatchingFilterBar extends StatelessWidget {
  final int selectedDistance;
  final ValueChanged<int> onDistanceChanged;

  const MatchingFilterBar({
    super.key,
    required this.selectedDistance,
    required this.onDistanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final distances = [0, 5, 10, 20, 30, 50];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Quick Filter Label
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                ...distances.map((distance) {
                  final isSelected = selectedDistance == distance;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                          distance == 0 ? l10n.all : '$distance${l10n.km}'),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          onDistanceChanged(distance);
                        }
                      },
                      backgroundColor: AppColors.white,
                      selectedColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
