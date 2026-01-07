import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MatchingCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final bool isTop;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onBoost;
  final VoidCallback? onMessage;

  const MatchingCard({
    super.key,
    required this.match,
    required this.isTop,
    required this.onLike,
    required this.onPass,
    required this.onBoost,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // Increased radius
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        color: AppColors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          _buildImage(match['imageUrl']),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                Row(
                  children: [
                    _Tag(
                      label: '${match['matchScore']}% Match',
                      color: AppColors.premium,
                      textColor: AppColors.black,
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(width: 8),
                    _Tag(
                      label: '${match['distance']}km',
                      color: AppColors.white.withValues(alpha: 0.2),
                      textColor: AppColors.white,
                      icon: Icons.location_on,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name & Age
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match['name']}, ${match['age']}',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            match['occupation'] ?? 'Unknown',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTop)
                      InkWell(
                        onTap: () {
                          // Info tap
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),

                // Bio / Location
                const SizedBox(height: 12),
                Text(
                  match['bio'] ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // const SizedBox(height: 90), // Space for action buttons
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    final resolvedUrl = resolveNetworkUrl(imageUrl);
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
          );
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 80,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
