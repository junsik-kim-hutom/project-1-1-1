import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/url_utils.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String partnerName;
  final String? partnerImageUrl;
  final bool selectionMode;
  final int selectedCount;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExitSelectionMode;
  final VoidCallback onMorePressed;

  const ChatRoomAppBar({
    super.key,
    required this.partnerName,
    this.partnerImageUrl,
    this.selectionMode = false,
    this.selectedCount = 0,
    required this.onDeleteSelected,
    required this.onExitSelectionMode,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (selectionMode) {
      return AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: onExitSelectionMode,
        ),
        title: Text(
          '$selectedCount selected', // TODO: Localize
          style:
              AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: selectedCount > 0 ? onDeleteSelected : null,
          ),
        ],
        centerTitle: false,
      );
    }

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: resolveNetworkUrl(partnerImageUrl) != null
                ? NetworkImage(resolveNetworkUrl(partnerImageUrl)!)
                : null,
            child: resolveNetworkUrl(partnerImageUrl) == null
                ? Text(
                    partnerName.isNotEmpty ? partnerName[0] : '?',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.textSecondary),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            partnerName,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textSecondary),
          onPressed: onMorePressed,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
