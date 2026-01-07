import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/matching_provider.dart';
import 'matching_list_item.dart';

class MatchingListView extends ConsumerWidget {
  final int selectedDistance;
  final Function(dynamic candidate, String action) onAction;
  final Function(dynamic candidate) onChat;
  final VoidCallback onRetry;

  const MatchingListView({
    super.key,
    required this.selectedDistance,
    required this.onAction,
    required this.onChat,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final matchesAsync = ref.watch(
      matchingCandidatesProvider(
        MatchingQuery(distanceKm: selectedDistance, limit: 50),
      ),
    );

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: AppColors.error),
              const SizedBox(height: 10),
              Text(
                '${l10n.error}: $e',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (candidates) {
        if (candidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.allMatchesViewed,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.findingNewMatches,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: candidates.length,
          itemBuilder: (context, index) {
            final candidate = candidates[index];
            return MatchingListItem(
              candidate: candidate,
              onLike: () => onAction(candidate, 'LIKE'),
              onBoost: () => onAction(candidate, 'SUPER_LIKE'),
              onChat: () => onChat(candidate),
            );
          },
        );
      },
    );
  }
}
