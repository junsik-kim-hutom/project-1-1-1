import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'core/providers/network_provider.dart';
import 'core/network/network_service.dart';

class MarriageMatchingApp extends ConsumerWidget {
  const MarriageMatchingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to network status changes
    ref.listen(networkStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status == NetworkStatus.offline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('네트워크 연결이 끊겼습니다. 연결을 확인해주세요.'),
              backgroundColor: Colors.red,
              duration: Duration(days: 1), // Keep visible until online
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

    // Ensure the stream is watched to stay active
    ref.watch(networkStatusProvider);

    return MaterialApp(
      title: 'Marriage Matching',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

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

      // Wrap home with a Builder to provide a Scaffold context for SnackBar safely in some hierarchical setups,
      // though MaterialApp's navigator usually handles it.
      // Ideally, specific screens have Scaffolds.
      // To show Global SnackBar, we usually need a ScaffoldMessenger.
      // The ScaffoldMessenger is provided by MaterialApp.
      // But we need a context below MaterialApp to find it if we were showing it immediately,
      // but ref.listen happens in this widget's build scope, using the context passed to build.
      // The context passed to build is ABOVE MaterialApp, so ScaffoldMessenger.of(context) would fail.

      // FIX: moving listener to a child widget or using a builder.
      builder: (context, child) => NetworkAwareWidget(child: child),

      home: const SplashPage(),

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
