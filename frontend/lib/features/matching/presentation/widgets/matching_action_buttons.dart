import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MatchingActionButtons extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onBoost;
  final VoidCallback onMessage;
  final Function(String action) onActionHistory;

  const MatchingActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
    required this.onBoost,
    required this.onMessage,
    required this.onActionHistory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pass Button
          _ActionButton(
            icon: Icons.close_rounded,
            color: AppColors.textSecondary,
            backgroundColor: AppColors.white,
            size: 56,
            onTap: onPass,
            onLongPress: () => onActionHistory('PASS'),
          ),
          const SizedBox(width: 20),

          // Boost Button
          _ActionButton(
            icon: Icons.bolt_rounded,
            color: AppColors.premium, // Gold/Premium
            backgroundColor: AppColors.white,
            size: 48, // Slightly smaller
            onTap: onBoost,
            onLongPress: () => onActionHistory('SUPER_LIKE'),
            isSmall: true,
          ),
          const SizedBox(width: 20),

          // Message Button (New)
          _ActionButton(
            icon: Icons.chat_bubble_rounded,
            color: AppColors.info,
            backgroundColor: AppColors.white,
            size: 48,
            onTap: onMessage,
            onLongPress: () => onActionHistory('MESSAGE'),
            isSmall: true,
          ),
          const SizedBox(width: 20),

          // Like Button
          _ActionButton(
            icon: Icons.favorite_rounded,
            color: AppColors.primary, // Brand Color
            backgroundColor: AppColors.white,
            size: 56,
            onTap: onLike,
            onLongPress: () => onActionHistory('LIKE'),
            hasShadow: true, // Elevate the like button
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSmall;
  final bool hasShadow;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.size,
    required this.onTap,
    required this.onLongPress,
    this.isSmall = false,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [
                  const BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }
}
