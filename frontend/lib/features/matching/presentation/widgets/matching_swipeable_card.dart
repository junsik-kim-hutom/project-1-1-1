import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MatchingSwipeableCard extends StatelessWidget {
  final Widget child;
  final Key? keyOverride;
  final Function(String direction) onSwiped;

  const MatchingSwipeableCard({
    super.key,
    required this.child,
    this.keyOverride,
    required this.onSwiped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: keyOverride ?? UniqueKey(),
      direction: DismissDirection.horizontal,
      background: _SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.primary,
        icon: Icons.favorite_rounded,
        label: l10n.interest,
      ),
      secondaryBackground: _SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: AppColors.textSecondary, // Or a separate "pass" color
        icon: Icons.close_rounded,
        label: l10n.pass,
      ),
      onDismissed: (direction) {
        onSwiped(direction == DismissDirection.startToEnd ? 'LIKE' : 'PASS');
      },
      child: child,
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 24), // Match card margin roughly if needed
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
