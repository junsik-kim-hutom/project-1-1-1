import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/profile/presentation/pages/profile_create_page.dart';
import '../../features/profile/presentation/pages/dynamic_profile_create_page.dart';
import '../../features/location/presentation/pages/location_manage_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/payment/presentation/pages/payment_plans_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/permissions/presentation/pages/permissions_page.dart';
import '../../features/eq_test/presentation/pages/eq_test_page.dart';
import '../../features/eq_test/presentation/pages/eq_test_result_page.dart';
import '../../features/eq_test/data/models/eq_result_model.dart';
import '../../features/matching/presentation/pages/matching_action_users_page.dart';

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
        builder: (context, state) => const LocationManagePage(),
      ),
      GoRoute(
        path: '/location/manage',
        builder: (context, state) => const LocationManagePage(),
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
          final roomId = int.tryParse(state.pathParameters['roomId'] ?? '') ?? 0;
          final extra = state.extra as Map<String, dynamic>?;
          final partnerName = extra?['partnerName'] as String? ?? '채팅';
          final partnerUserId = _parseNullableId(extra?['partnerUserId']);
          final partnerImageUrl = extra?['partnerImageUrl'] as String?;
          return ChatRoomPage(
            roomId: roomId,
            partnerName: partnerName,
            partnerUserId: partnerUserId,
            partnerImageUrl: partnerImageUrl,
          );
        },
      ),

      // Matching Activity Routes
      GoRoute(
        path: '/matching/actions',
        builder: (context, state) {
          final action = state.uri.queryParameters['action'] ?? 'LIKE';
          final direction = state.uri.queryParameters['direction'] ?? 'sent';
          return MatchingActionUsersPage(action: action, direction: direction);
        },
      ),

      // Payment Routes
      GoRoute(
        path: '/payment/plans',
        builder: (context, state) => const PaymentPlansPage(),
      ),

      // EQ Test Routes
      GoRoute(
        path: '/eq-test',
        builder: (context, state) => const EQTestPage(),
      ),
      GoRoute(
        path: '/eq-test/result',
        builder: (context, state) {
          final result = state.extra as EQResultModel;
          return EQTestResultPage(result: result);
        },
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

int? _parseNullableId(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
