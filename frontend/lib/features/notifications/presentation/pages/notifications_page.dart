import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_app_bar.dart';
import '../widgets/notification_list_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: NotificationAppBar(
          tabs: [
            l10n.chat,
            l10n.boost,
            l10n.interest,
          ],
        ),
        body: const TabBarView(
          children: [
            _NotificationsList(types: ['CHAT_NEW_MESSAGE']),
            _NotificationsList(types: ['MATCH_SUPER_LIKE']),
            _NotificationsList(types: ['MATCH_LIKE']),
          ],
        ),
      ),
    );
  }
}

class _NotificationsList extends ConsumerWidget {
  final List<String> types;

  const _NotificationsList({required this.types});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    final notificationsAsync = ref.watch(
      notificationsListProvider(NotificationsQuery(types: types, limit: 50)),
    );

    return notificationsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                '${l10n.error}: $e',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(notificationsListProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
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
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.noNotifications,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 1), // Divider is built into item
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final title = notification.getLocalizedTitle(languageCode);
            final message = notification.getLocalizedMessage(languageCode);

            return NotificationListItem(
              title: title,
              message: message,
              iconContent: notification.icon,
              isUnread: !notification.isRead,
              createdAt: notification.createdAt,
              onTap: () {
                final url = notification.actionUrl?.trim();
                // Mark as read potentially?
                if (url != null && url.isNotEmpty) {
                  context.push(url);
                }
              },
            );
          },
        );
      },
    );
  }
}
