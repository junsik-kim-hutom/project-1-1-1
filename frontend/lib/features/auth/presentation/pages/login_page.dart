import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  static const String _googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _googleServerClientId.isEmpty ? null : _googleServerClientId,
  );

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    print('[LOGIN] Starting Google Sign-In');
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        print('[LOGIN] Google account obtained');
        final GoogleSignInAuthentication auth = await account.authentication;
        final String? idToken = auth.idToken;

        if (idToken != null) {
          print('[LOGIN] ID token obtained, calling googleLogin');
          final authNotifier = ref.read(authProvider.notifier);
          final response = await authNotifier.googleLogin(idToken);

          print('[LOGIN] Login response: ${response != null ? "Success" : "Failed"}');
          if (response != null) {
            print('[LOGIN] Response hasProfile: ${response.hasProfile}');
          }

          if (response != null && mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.loginSuccess),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            // Navigate to permissions page first for new users
            if (response.isNewUser) {
              print('[LOGIN] Navigating to /permissions (new user)');
              context.go('/permissions');
            } else if (!response.hasProfile) {
              // Navigate to profile creation page for users without profile
              print('[LOGIN] Navigating to /profile/create (hasProfile: false)');
              context.go('/profile/create');
            } else {
              // Navigate to home page for users with profile
              print('[LOGIN] Navigating to /main (hasProfile: true)');
              context.go('/main');
            }
          } else if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            final error = ref.read(authProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('${l10n.loginFailed}: ${error ?? l10n.unknownError}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      }
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.loginFailed}: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),

                    // App Icon with minimal design
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Title - Modern & Clean
                    Text(
                      l10n.appTitle,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      l10n.appSubtitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 60),

                    // Login Buttons - Minimal & Modern
                    _buildModernButton(
                      label: l10n.startWithGoogle,
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: _handleGoogleSignIn,
                      isLoading: _isLoading,
                      gradient: AppColors.primaryGradient,
                    ),

                    const SizedBox(height: 12),

                    _buildMinimalButton(
                      label: l10n.startWithLine,
                      icon: Icons.chat_bubble_rounded,
                      color: const Color(0xFF00B900),
                      onPressed: () => _showComingSoon(context, 'LINE'),
                    ),

                    const SizedBox(height: 12),

                    _buildMinimalButton(
                      label: l10n.startWithYahoo,
                      icon: Icons.language_rounded,
                      color: const Color(0xFF5F01D1),
                      onPressed: () => _showComingSoon(context, 'Yahoo'),
                    ),

                    const SizedBox(height: 40),

                    // Terms and Privacy - Minimal
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Text.rich(
                        TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: l10n.termsAgreement),
                            TextSpan(
                              text: l10n.termsOfService,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: l10n.and),
                            TextSpan(
                              text: l10n.privacyPolicy,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: l10n.termsAgreementEnd),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Gradient gradient,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  Icon(
                    icon,
                    color: AppColors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.comingSoon,
              style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          l10n.comingSoonMessage(provider),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
