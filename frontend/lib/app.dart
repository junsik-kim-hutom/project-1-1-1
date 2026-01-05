import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/network_provider.dart';
import 'core/network/network_service.dart';
import 'core/router/app_router.dart';
import 'core/providers/settings_provider.dart';

class MarriageMatchingApp extends ConsumerWidget {
  const MarriageMatchingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Marriage Matching',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,

      // Routing
      routerConfig: router,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // Korean
        Locale('ja', 'JP'), // Japanese
        Locale('en', 'US'), // English
      ],

      builder: (context, child) => NetworkAwareWidget(child: child),

      debugShowCheckedModeBanner: false,
    );
  }
}

class NetworkAwareWidget extends ConsumerWidget {
  final Widget? child;
  const NetworkAwareWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(networkStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status == NetworkStatus.offline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('네트워크 연결이 끊겼습니다. 연결을 확인해주세요.'),
              backgroundColor: Colors.red,
              duration: Duration(days: 1),
              behavior: SnackBarBehavior.fixed,
            ),
          );
        } else if (status == NetworkStatus.online &&
            previous?.value == NetworkStatus.offline) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('네트워크가 다시 연결되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    });

    // Watch to keep stream alive
    ref.watch(networkStatusProvider);

    return child ?? const SizedBox.shrink();
  }
}
