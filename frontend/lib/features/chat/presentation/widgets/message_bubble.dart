import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/url_utils.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String timeText;
  final String? imageUrl;
  final bool isRead;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelection;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.timeText,
    this.imageUrl,
    this.isRead = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.primary : AppColors.surfaceVariant;
    final textColor = isMine ? AppColors.white : AppColors.textPrimary;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isMine ? const Radius.circular(20) : const Radius.circular(4),
      bottomRight:
          isMine ? const Radius.circular(4) : const Radius.circular(20),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isSelectionMode && isMine)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Checkbox(
                value: isSelected,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (_) => onToggleSelection?.call(),
              ),
            ),

          // Partner Avatar
          if (!isMine) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: resolveNetworkUrl(imageUrl) != null
                    ? NetworkImage(resolveNetworkUrl(imageUrl)!)
                    : null,
                child: resolveNetworkUrl(imageUrl) == null
                    ? const Icon(Icons.person,
                        color: AppColors.textSecondary, size: 20)
                    : null,
              ),
            ),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isSelectionMode ? onToggleSelection : null,
                  onLongPress: onToggleSelection,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : bubbleColor,
                      borderRadius: borderRadius,
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMine && !isRead)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '1',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    Text(
                      timeText,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
