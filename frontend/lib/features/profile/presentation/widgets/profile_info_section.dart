import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<ProfileInfoItem> items;
  final bool showMore;
  final VoidCallback? onToggleShowMore;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.items,
    this.showMore = false,
    this.onToggleShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = (onToggleShowMore != null && !showMore)
        ? items.take(3).toList()
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < visibleItems.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                    indent: 50, // Align with text start approximately
                  ),
                _InfoTile(item: visibleItems[i]),
              ],
            ],
          ),
        ),
        if (onToggleShowMore != null && items.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: onToggleShowMore,
                icon: Icon(
                  showMore
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  showMore
                      ? 'See Less'
                      : 'See More', // TODO: Localize or pass label
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProfileInfoItem {
  final IconData icon;
  final String label;
  final String? value;

  const ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoTile extends StatelessWidget {
  final ProfileInfoItem item;

  const _InfoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(item.icon,
              color: AppColors.primary.withValues(alpha: 0.7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  item.value ?? '-',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
