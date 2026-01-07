import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'matching_card.dart';
import 'matching_swipeable_card.dart';

class MatchingCardStack extends StatelessWidget {
  final List<Map<String, dynamic>> matches;
  final int currentIndex;
  final Function(String direction) onSwipe;
  final VoidCallback onRetry;
  final VoidCallback onViewAgain;
  final bool isEmpty;
  final bool isError;
  final String? errorMessage;

  const MatchingCardStack({
    super.key,
    required this.matches,
    required this.currentIndex,
    required this.onSwipe,
    required this.onRetry,
    required this.onViewAgain,
    this.isEmpty = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: AppColors.error),
              const SizedBox(height: 10),
              Text(
                '${l10n.error}: $errorMessage',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (matches.isEmpty || currentIndex >= matches.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.allMatchesViewed,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.findingNewMatches,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onViewAgain,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.viewAgain),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: List.generate(
        math.min(3, matches.length - currentIndex),
        (index) {
          final actualIndex = currentIndex + index;
          if (actualIndex >= matches.length) return const SizedBox.shrink();

          final match = matches[actualIndex];
          // Determine scale and offset for the stacking effect
          final double offset = index * 12.0;
          final double scale = 1.0 - (index * 0.05);
          final bool isTop = index == 0;

          // Add a slight rotation to cards behind the top one for a "messy" natural look
          final double rotation =
              index == 0 ? 0 : (index.isEven ? 0.02 : -0.02);

          return Positioned(
            top: offset + 10, // Add top padding
            left: AppTheme.spacingMedium,
            right: AppTheme.spacingMedium,
            bottom: 20 + (index * 10), // Adjust bottom to visually stack
            child: Transform.translate(
              offset: Offset(0, offset),
              child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: isTop
                      ? MatchingSwipeableCard(
                          keyOverride: ValueKey('match-${match['userId']}'),
                          onSwiped: onSwipe,
                          child: MatchingCard(
                            match: match,
                            isTop: true,
                            onLike: () => onSwipe('LIKE'),
                            onPass: () => onSwipe('PASS'),
                            onBoost: () => onSwipe('SUPER_LIKE'),
                            onMessage:
                                null, // Logic handled in parent if needed
                          ),
                        )
                      : MatchingCard(
                          match: match,
                          isTop: false,
                          onLike: () {},
                          onPass: () {},
                          onBoost: () {},
                          onMessage: null,
                        ),
                ),
              ),
            ),
          );
        },
      ).reversed.toList(),
    );
  }
}
