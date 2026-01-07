import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    logger.i('[SPLASH] Starting auth check');
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      logger.d('[SPLASH] Calling checkAuthStatus');
      await ref.read(authProvider.notifier).checkAuthStatus();
      final authState = ref.read(authProvider);

      logger.d(
          '[SPLASH] Auth state - isAuthenticated: ${authState.isAuthenticated}, hasProfile: ${authState.hasProfile}');

      if (mounted) {
        if (authState.isAuthenticated) {
          // Check if user has profile
          if (authState.hasProfile == null) {
            // Profile status unknown - need to check from backend
            logger.i(
                '[SPLASH] hasProfile is null, redirecting to profile/create to be safe');
            context.go('/profile/create');
          } else if (authState.hasProfile == false) {
            // No profile - redirect to profile creation
            logger.i(
                '[SPLASH] Navigating to /profile/create (hasProfile: false)');
            context.go('/profile/create');
          } else {
            // Has profile - go to main
            logger.i('[SPLASH] Navigating to /main (hasProfile: true)');
            context.go('/main');
          }
        } else {
          logger.i('[SPLASH] Navigating to /login (not authenticated)');
          context.go('/login');
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.accent,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 100,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'TruePair',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  '특별한 사람과의 만남',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
