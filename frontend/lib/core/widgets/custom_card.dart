import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final double? elevation;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.gradient,
    this.elevation,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardTheme = theme.cardTheme;
    final effectiveElevation = elevation ?? 0;
    final shadowColor = theme.brightness == Brightness.dark
        ? colorScheme.shadow.withAlpha((0.35 * 255).round())
        : colorScheme.shadow.withAlpha((0.12 * 255).round());

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? cardTheme.color ?? colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: border ??
            Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
        boxShadow: effectiveElevation > 0
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: effectiveElevation * 2,
                  offset: Offset(0, effectiveElevation),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}
