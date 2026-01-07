import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/url_utils.dart';
import '../../data/models/match_candidate_model.dart';

class MatchingListItem extends StatelessWidget {
  final MatchCandidateModel candidate;
  final VoidCallback onLike;
  final VoidCallback onBoost;
  final VoidCallback onChat;

  const MatchingListItem({
    super.key,
    required this.candidate,
    required this.onLike,
    required this.onBoost,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surfaceVariant,
                    image: resolveNetworkUrl(candidate.imageUrl) != null
                        ? DecorationImage(
                            image: NetworkImage(
                                resolveNetworkUrl(candidate.imageUrl)!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: resolveNetworkUrl(candidate.imageUrl) == null
                      ? const Icon(Icons.person,
                          color: AppColors.textHint, size: 32)
                      : null,
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              candidate.displayName,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${candidate.age}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (candidate.occupation != null)
                        Text(
                          candidate.occupation!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              candidate.locationAddress ?? 'Unknown',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _MiniTag(
                            label: '${candidate.matchScore}%',
                            color: AppColors.premium.withValues(alpha: 0.15),
                            textColor: AppColors.premiumDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions (Horizontal at bottom)
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.favorite_rounded,
                    label: 'Like',
                    color: AppColors.primary,
                    onPressed: onLike,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Message',
                    color: AppColors.info,
                    onPressed: onChat,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                  _ActionButton(
                    icon: Icons.bolt_rounded,
                    label: 'Boost',
                    color: AppColors.premium,
                    onPressed: onBoost,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MiniTag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
