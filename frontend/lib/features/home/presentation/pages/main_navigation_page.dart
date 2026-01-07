import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import 'home_page.dart';
import '../../../matching/presentation/pages/matching_list_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../profile/presentation/pages/my_profile_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../providers/main_navigation_provider.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final List<Widget> pages = [
      const HomePage(),
      const MatchingListPage(),
      const ChatListPage(),
      const NotificationsPage(),
      const MyProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _ModernBottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}

class _ModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _ModernBottomNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: l10n.home,
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _NavBarItem(
                icon: Icons.explore_rounded,
                label: l10n.matching,
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _NavBarItem(
                icon: Icons.chat_bubble_rounded,
                label: l10n.chat,
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              _NavBarItem(
                icon: Icons.notifications_rounded,
                label: l10n.notifications,
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected(3),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                isSelected: selectedIndex == 4,
                onTap: () => onItemSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.fastAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.animationDuration,
          curve: AppTheme.animationCurve,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? AppColors.white
                    : AppColors.textSecondary,
                size: 24,
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
