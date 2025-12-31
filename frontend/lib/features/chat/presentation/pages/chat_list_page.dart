import 'package:flutter/material.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatTitle),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(
              '${l10n.user} ${index + 1}',
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              l10n.greeting,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '오전 10:30',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (index < 2)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '1',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to chat room
            },
          );
        },
      ),
    );
  }
}
