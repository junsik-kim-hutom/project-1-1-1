import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileGallery extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback onAddPhoto;

  const ProfileGallery({
    super.key,
    required this.imageUrls,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Photos', // TODO: Localize to '사진'
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: onAddPhoto,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_rounded,
                            color: AppColors.primary, size: 32),
                        const SizedBox(height: 4),
                        Text('Add',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                );
              }
              final url = imageUrls[index - 1];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  url,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 120,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.broken_image,
                        color: AppColors.textHint),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
