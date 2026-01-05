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

class _MatchingListPageState extends ConsumerState<MatchingListPage> {
  int _selectedDistance = 10;
  int _minAge = 20;
  int _maxAge = 40;
  int _minHeight = 155;
  int _maxHeight = 185;
  String? _selectedSmoking;
  String? _selectedDrinking;
  final Set<String> _selectedOccupations = {};
  final Set<String> _selectedEducations = {};
  int _currentCardIndex = 0;

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('고급 설정 기능은 준비 중입니다'),
                    ),
                  );
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.distance,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [5, 10, 20, 30, 50].map((distance) {
                final isSelected = _selectedDistance == distance;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${distance}${l10n.km}'),
                    selected: isSelected,
                    showCheckmark: false,
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
                      color:
                          isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
        'occupation': [
          l10n.developer,
          l10n.designer,
          l10n.marketer,
          l10n.planner,
          l10n.teacher,
        ][index],
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
        final isTop = index == 0;

        return Positioned(
          top: offset,
          left: AppTheme.spacingMedium,
          right: AppTheme.spacingMedium,
          bottom: 88 + offset,
          child: Transform.scale(
            scale: scale,
            child: isTop
                ? _buildSwipeableCard(
                    key: ValueKey('match-$actualIndex'),
                    child: _MatchCard(
                      match: match,
                      isTop: true,
                      onLike: () => _handleAction(true),
                      onPass: () => _handleAction(false),
                      onBoost: _handleBoost,
                    ),
                  )
                : _MatchCard(
                    match: match,
                    isTop: false,
                    onLike: () => _handleAction(true),
                    onPass: () => _handleAction(false),
                    onBoost: _handleBoost,
                  ),
          ),
        );
      }).reversed.toList(),
    );
  }

  Widget _buildSwipeableCard({required Widget child, required Key key}) {
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: key,
      direction: DismissDirection.horizontal,
      background: _SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.primary,
        icon: Icons.thumb_up_alt_rounded,
        label: l10n.interest,
      ),
      secondaryBackground: _SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: AppColors.textSecondary,
        icon: Icons.close_rounded,
        label: l10n.pass,
      ),
      onDismissed: (direction) {
        _handleAction(direction == DismissDirection.startToEnd);
      },
      child: child,
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
      child: Row(
        children: [
          Expanded(
            child: _MatchActionButton(
              icon: Icons.close_rounded,
              label: l10n.pass,
              color: AppColors.textSecondary,
              filled: false,
              onTap: () => _handleAction(false),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: _MatchActionButton(
              icon: Icons.bolt_rounded,
              label: l10n.boost,
              color: AppColors.secondary,
              filled: false,
              onTap: _handleBoost,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: _MatchActionButton(
              icon: Icons.thumb_up_alt_rounded,
              label: l10n.interest,
              color: AppColors.primary,
              filled: true,
              onTap: () => _handleAction(true),
            ),
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

  void _handleBoost() {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _currentCardIndex++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.superLike),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    final educationOptions = [
      l10n.educationHighSchool,
      l10n.educationCollege,
      l10n.educationGraduate,
    ];
    final occupationOptions = [
      l10n.developer,
      l10n.designer,
      l10n.marketer,
      l10n.planner,
      l10n.teacher,
    ];
    final lifestyleOptions = [l10n.no, l10n.sometimes, l10n.yes];

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
            content: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    l10n.height,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_minHeight${l10n.cm}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_maxHeight${l10n.cm}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(
                      _minHeight.toDouble(),
                      _maxHeight.toDouble(),
                    ),
                    min: 140,
                    max: 200,
                    divisions: 30,
                    activeColor: AppColors.primary,
                    onChanged: (values) {
                      setDialogState(() {
                        _minHeight = values.start.toInt();
                        _maxHeight = values.end.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    l10n.education,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: educationOptions.map((option) {
                      final isSelected = _selectedEducations.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              _selectedEducations.add(option);
                            } else {
                              _selectedEducations.remove(option);
                            }
                          });
                        },
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    l10n.occupation,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: occupationOptions.map((option) {
                      final isSelected = _selectedOccupations.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              _selectedOccupations.add(option);
                            } else {
                              _selectedOccupations.remove(option);
                            }
                          });
                        },
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    l10n.smoking,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: lifestyleOptions.map((option) {
                      final isSelected = _selectedSmoking == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            _selectedSmoking = selected ? option : null;
                          });
                        },
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    l10n.drinking,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: lifestyleOptions.map((option) {
                      final isSelected = _selectedDrinking == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            _selectedDrinking = selected ? option : null;
                          });
                        },
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
  final VoidCallback onBoost;

  const _MatchCard({
    required this.match,
    required this.isTop,
    required this.onLike,
    required this.onPass,
    required this.onBoost,
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
                              Icons.auto_awesome_rounded,
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
                      if (isTop) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InlineActionChip(
                              icon: Icons.close_rounded,
                              label: l10n.pass,
                              color: AppColors.textSecondary,
                              onTap: onPass,
                            ),
                            _InlineActionChip(
                              icon: Icons.bolt_rounded,
                              label: l10n.boost,
                              color: AppColors.secondary,
                              onTap: onBoost,
                            ),
                            _InlineActionChip(
                              icon: Icons.thumb_up_alt_rounded,
                              label: l10n.interest,
                              color: AppColors.primary,
                              onTap: onLike,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (isTop)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _SwipeHint(label: l10n.swipeHint),
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

class _SwipeActionBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _MatchActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = filled ? color : color.withValues(alpha: 0.12);
    final borderColor =
        filled ? Colors.transparent : color.withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? AppColors.white : color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: filled ? AppColors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _InlineActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final String label;

  const _SwipeHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.swipe_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
