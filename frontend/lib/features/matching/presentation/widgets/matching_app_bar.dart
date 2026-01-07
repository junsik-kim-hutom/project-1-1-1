import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MatchingAppBar extends StatelessWidget {
  final bool isCardView;
  final VoidCallback onToggleView;
  final VoidCallback onFilterTap;

  const MatchingAppBar({
    super.key,
    required this.isCardView,
    required this.onToggleView,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                l10n.matchingTitle,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800, // Bolder title
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Seoul', // TODO: Dynamic location
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              // View Toggle Button with animation
              GestureDetector(
                onTap: onToggleView,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _ToggleIcon(
                        icon: Icons.style_rounded, // Card Stack
                        isSelected: isCardView,
                      ),
                      _ToggleIcon(
                        icon: Icons.grid_view_rounded, // List/Grid
                        isSelected: !isCardView,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _ToggleIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
                const BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Icon(
        icon,
        size: 20,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
