import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../matching/presentation/providers/matching_provider.dart';
import '../providers/main_navigation_provider.dart'; // Ensure correct import for navigation

class HomeStatsSection extends ConsumerWidget {
  const HomeStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activityAsync = ref.watch(matchingActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.myActivity,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        activityAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(), // Graceful fallback
          data: (activity) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatCard(
                  icon: Icons.favorite_rounded,
                  label: l10n.likesReceived,
                  value: activity.interestReceived.toString(),
                  color: AppColors.primary,
                  onTap: () => context
                      .push('/matching/actions?action=LIKE&direction=received'),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.thumb_up_alt_rounded,
                  label: l10n.likesSent,
                  value: activity.interestSent.toString(),
                  color: AppColors.secondary,
                  onTap: () => context
                      .push('/matching/actions?action=LIKE&direction=sent'),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.bolt_rounded,
                  label: l10n.boostsSent,
                  value: activity.boostSent.toString(),
                  color: AppColors.premium,
                  onTap: () => context.push(
                      '/matching/actions?action=SUPER_LIKE&direction=sent'),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.chat_bubble_rounded,
                  label: l10n.ongoingChats,
                  value: activity.ongoingChats.toString(),
                  color: AppColors.success,
                  onTap: () =>
                      ref.read(selectedIndexProvider.notifier).state = 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 110, // Fixed width for consistency
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
