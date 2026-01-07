import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../generated/l10n/app_localizations.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController? tabController;
  final List<String> tabs;

  const NotificationAppBar({
    super.key,
    this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.background,
      title: Text(
        l10n.notifications,
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelLarge
                .copyWith(fontWeight: FontWeight.normal),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: AppColors.primary),
              insets: EdgeInsets.symmetric(horizontal: 8),
            ),
            dividerColor: Colors.transparent,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}
