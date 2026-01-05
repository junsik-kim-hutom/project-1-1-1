import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/profile/presentation/pages/profile_create_page.dart';
import '../../features/profile/presentation/pages/dynamic_profile_create_page.dart';
import '../../features/location/presentation/pages/location_setup_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/payment/presentation/pages/payment_plans_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/permissions/presentation/pages/permissions_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash & Auth
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Permissions
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsPage(),
      ),

      // Main App
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigationPage(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile/create',
        builder: (context, state) => const ProfileCreatePage(),
      ),
      GoRoute(
        path: '/profile/create-dynamic',
        builder: (context, state) => const DynamicProfileCreatePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileCreatePage(),
      ),

      // Location Routes
      GoRoute(
        path: '/location/setup',
        builder: (context, state) => const LocationSetupPage(),
      ),
      GoRoute(
        path: '/location/manage',
        builder: (context, state) => const LocationSetupPage(),
      ),

      // Settings Routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Chat Routes
      GoRoute(
        path: '/chat/rooms/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final partnerName = extra?['partnerName'] as String? ?? '채팅';
          return ChatRoomPage(
            roomId: roomId,
            partnerName: partnerName,
          );
        },
      ),

      // Payment Routes
      GoRoute(
        path: '/payment/plans',
        builder: (context, state) => const PaymentPlansPage(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('페이지를 찾을 수 없습니다: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    ),
  );
});
