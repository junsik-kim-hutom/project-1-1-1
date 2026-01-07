import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/url_utils.dart';
import '../providers/matching_provider.dart';

class MatchingActionUsersPage extends ConsumerWidget {
  final String action;
  final String direction;

  const MatchingActionUsersPage({
    super.key,
    required this.action,
    required this.direction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final title = _titleFor(l10n, action: action, direction: direction);
    final usersAsync = ref.watch(
      matchingActionUsersProvider(
        MatchingActionUsersQuery(action: action, direction: direction, limit: 50),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${l10n.error}: $e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.noActivity,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: _Avatar(imageUrl: user.imageUrl, fallbackText: user.displayName),
                  title: Text(
                    user.displayName,
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    user.age != null ? '${user.age}${l10n.years}' : '-',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _titleFor(AppLocalizations l10n, {required String action, required String direction}) {
    final isReceived = direction == 'received';
    switch (action) {
      case 'LIKE':
        return isReceived ? l10n.likesReceived : l10n.likesSent;
      case 'SUPER_LIKE':
        return isReceived ? l10n.boostsReceived : l10n.boostsSent;
      case 'PASS':
        return l10n.pass;
      default:
        return l10n.myActivity;
    }
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;

  const _Avatar({required this.imageUrl, required this.fallbackText});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveNetworkUrl(imageUrl);
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: AppColors.surfaceVariant,
        child: Text(
          fallbackText.isNotEmpty ? fallbackText.substring(0, 1) : '?',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: AppColors.surfaceVariant,
      backgroundImage: NetworkImage(resolvedUrl),
      onBackgroundImageError: (_, __) {},
    );
  }
}
