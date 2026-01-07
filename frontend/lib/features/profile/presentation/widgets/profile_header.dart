import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/url_utils.dart';

class ProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final String subtitle;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.displayName,
    required this.subtitle,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveNetworkUrl(imageUrl);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Edit Badge
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 4),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage:
                      (resolvedUrl != null) ? NetworkImage(resolvedUrl) : null,
                  child: (resolvedUrl == null)
                      ? const Icon(Icons.person,
                          size: 60, color: AppColors.textHint)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Subtitle
          Text(
            displayName,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
