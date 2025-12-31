import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class MatchingListPage extends ConsumerStatefulWidget {
  const MatchingListPage({super.key});

  @override
  ConsumerState<MatchingListPage> createState() => _MatchingListPageState();
}

class _MatchingListPageState extends ConsumerState<MatchingListPage>
    with SingleTickerProviderStateMixin {
  int _selectedDistance = 10;
  int _minAge = 20;
  int _maxAge = 40;
  int _currentCardIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Distance Filter
            _buildDistanceFilter(),

            // Card Stack
            Expanded(
              child: _buildCardStack(),
            ),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: AppTheme.spacingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.matchingTitle,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterDialog,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () {
                  // TODO: Advanced settings
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Row(
        children: [10, 20, 30, 40].map((distance) {
          final isSelected = _selectedDistance == distance;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${distance}km'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDistance = distance;
                  });
                }
              },
              backgroundColor: AppColors.surfaceVariant,
              selectedColor: AppColors.primaryLight,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardStack() {
    final l10n = AppLocalizations.of(context)!;

    // Sample data
    final matches = List.generate(5, (index) {
      return {
        'name': '${l10n.user} ${index + 1}',
        'age': 25 + index,
        'occupation': [l10n.developer, l10n.designer, l10n.marketer, l10n.planner, l10n.teacher][index],
        'location': l10n.seoulGangnam,
        'distance': (5.0 + index * 2).toStringAsFixed(1),
        'matchScore': 85 - index * 5,
        'bio': l10n.greeting,
      };
    });

    if (_currentCardIndex >= matches.length) {
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
              onPressed: () {
                setState(() {
                  _currentCardIndex = 0;
                });
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.viewAgain),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: List.generate(math.min(3, matches.length - _currentCardIndex),
          (index) {
        final actualIndex = _currentCardIndex + index;
        if (actualIndex >= matches.length) return const SizedBox.shrink();

        final match = matches[actualIndex];
        final offset = index * 10.0;
        final scale = 1.0 - (index * 0.05);

        return Positioned(
          top: offset,
          left: AppTheme.spacingMedium,
          right: AppTheme.spacingMedium,
          bottom: 80 + offset,
          child: Transform.scale(
            scale: scale,
            child: _MatchCard(
              match: match,
              isTop: index == 0,
              onLike: () => _handleAction(true),
              onPass: () => _handleAction(false),
            ),
          ),
        );
      }).reversed.toList(),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _ActionButton(
            icon: Icons.close_rounded,
            color: AppColors.error,
            size: 60,
            iconSize: 32,
            onTap: () => _handleAction(false),
          ),

          // Super Like Button
          _ActionButton(
            icon: Icons.star_rounded,
            color: AppColors.info,
            size: 48,
            iconSize: 24,
            onTap: () {
              final l10n = AppLocalizations.of(context)!;
              // TODO: Super like
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.superLike)),
              );
            },
          ),

          // Like Button
          _ActionButton(
            icon: Icons.favorite_rounded,
            color: AppColors.success,
            size: 60,
            iconSize: 32,
            onTap: () => _handleAction(true),
          ),
        ],
      ),
    );
  }

  void _handleAction(bool isLike) {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _currentCardIndex++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLike ? l10n.likeSent : l10n.nextMatch),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: AppTheme.iconSizeLarge,
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(l10n.filterSettings, style: AppTextStyles.titleLarge),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.age,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_minAge${l10n.years}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_maxAge${l10n.years}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_minAge.toDouble(), _maxAge.toDouble()),
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: AppColors.primary,
                  onChanged: (values) {
                    setDialogState(() {
                      _minAge = values.start.toInt();
                      _maxAge = values.end.toInt();
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: Text(l10n.apply),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final bool isTop;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const _MatchCard({
    required this.match,
    required this.isTop,
    required this.onLike,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        // TODO: Show profile detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: Stack(
            children: [
              // Profile Image Placeholder
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.3),
                      AppColors.secondaryLight.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 120,
                    color: AppColors.textHint,
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match Score Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.matchPercent(match['matchScore'] as int),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name and Age
                      Text(
                        '${match['name']}, ${match['age']}${l10n.years}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Occupation and Location
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            size: 18,
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            match['occupation'],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${match['location']} • ${match['distance']}${l10n.km}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bio
                      Text(
                        match['bio'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Info Button
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.info_outline_rounded),
                    color: AppColors.primary,
                    onPressed: () {
                      // TODO: Show full profile
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
