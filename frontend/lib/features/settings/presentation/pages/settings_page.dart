import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../../../../core/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionTitle(context, l10n.accountSettings),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.editProfile),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/profile/edit');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(l10n.manageLocations),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/location/manage');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.privacySettings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.navigateToPrivacySettings)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Settings Section
          _buildSectionTitle(context, l10n.appSettings),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.notificationSettings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.navigateToNotificationSettings)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.languageSettings),
                  subtitle: Text(_languageLabel(l10n, settings.locale.languageCode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog(
                      context,
                      ref,
                      settings.locale.languageCode,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.themeSettings),
                  subtitle: Text(_themeLabel(l10n, settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showThemeDialog(context, ref, settings.themeMode);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Subscription Section
          _buildSectionTitle(context, l10n.subscriptionAndPayment),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.card_membership_outlined),
                  title: Text(l10n.myPasses),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/payment/plans');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payment_outlined),
                  title: Text(l10n.paymentHistory),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/payment/plans');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle(context, l10n.support),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(l10n.customerSupport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.navigateToCustomerSupport)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.navigateToTermsOfService)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.navigateToPrivacyPolicy)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutApp),
                  subtitle: Text('${l10n.version} 1.0.0'),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Actions Section
          _buildSectionTitle(context, l10n.account),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: Text(l10n.logout, style: const TextStyle(color: AppColors.error)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LogoutButton(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text(l10n.deleteAccount, style: const TextStyle(color: AppColors.error)),
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, String languageCode) {
    switch (languageCode) {
      case 'ja':
        return l10n.languageJapanese;
      case 'en':
        return l10n.languageEnglish;
      case 'ko':
      default:
        return l10n.languageKorean;
    }
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
      default:
        return l10n.themeSystem;
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.languageSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.languageKorean),
                value: 'ko',
                groupValue: currentLanguageCode,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateLocale(value);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.languageChanged)),
                  );
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.languageJapanese),
                value: 'ja',
                groupValue: currentLanguageCode,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateLocale(value);
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.languageEnglish),
                value: 'en',
                groupValue: currentLanguageCode,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateLocale(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentThemeMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.themeSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.themeLight),
                value: 'light',
                groupValue: _themeModeToValue(currentThemeMode),
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateThemeMode(ref, value);
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.themeDark),
                value: 'dark',
                groupValue: _themeModeToValue(currentThemeMode),
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateThemeMode(ref, value);
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.themeSystem),
                value: 'system',
                groupValue: _themeModeToValue(currentThemeMode),
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateThemeMode(ref, value);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _themeModeToValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  void _updateThemeMode(WidgetRef ref, String? value) {
    final mode = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    ref.read(settingsProvider.notifier).updateThemeMode(mode);
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '${l10n.version} 1.0.0',
      applicationIcon: const Icon(Icons.favorite, size: 48, color: AppColors.primary),
      children: [
        Text(l10n.aboutDescription),
        const SizedBox(height: 16),
        Text(l10n.aboutLegal),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(l10n.deleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.deleteAccountCompleted),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              child: Text(
                l10n.deleteAccountAction,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
