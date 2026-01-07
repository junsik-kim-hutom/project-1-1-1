import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

import '../providers/matching_provider.dart';
import '../../data/models/match_candidate_model.dart';
import '../../../chat/providers/chat_provider.dart';
import '../widgets/matching_app_bar.dart';
import '../widgets/matching_filter_bar.dart';
import '../widgets/matching_card_stack.dart';
import '../widgets/matching_action_buttons.dart';
import '../widgets/matching_list_view.dart';

class MatchingListPage extends ConsumerStatefulWidget {
  const MatchingListPage({super.key});

  @override
  ConsumerState<MatchingListPage> createState() => _MatchingListPageState();
}

class _MatchingListPageState extends ConsumerState<MatchingListPage> {
  int _selectedDistance = 0;
  int _minAge = 20;
  int _maxAge = 40;
  int _minHeight = 155;
  int _maxHeight = 185;
  // String? _selectedSmoking; // Unused
  // String? _selectedDrinking; // Unused
  // final Set<String> _selectedOccupations = {}; // Unused
  final Set<String> _selectedEducations = {};
  int _currentCardIndex = 0;
  bool _isCardView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            MatchingAppBar(
              isCardView: _isCardView,
              onToggleView: () {
                setState(() {
                  _isCardView = !_isCardView;
                });
              },
              onFilterTap: _showFilterDialog,
            ),

            // Distance Filter (Replace local widget with component)
            MatchingFilterBar(
              selectedDistance: _selectedDistance,
              onDistanceChanged: (distance) {
                setState(() {
                  _selectedDistance = distance;
                  _currentCardIndex = 0;
                });
                ref.invalidate(matchingCandidatesProvider);
              },
            ),

            // Main Content
            Expanded(
              child: _isCardView
                  ? _buildCardView()
                  : MatchingListView(
                      selectedDistance: _selectedDistance,
                      onAction: _handleListAction,
                      onChat: _sendMessageToUser,
                      onRetry: () => ref.invalidate(matchingCandidatesProvider),
                    ),
            ),

            // Actions (only for Card View)
            if (_isCardView) ...[
              const SizedBox(height: 16),
              MatchingActionButtons(
                onPass: () => _handleCardAction('PASS'),
                onLike: () => _handleCardAction('LIKE'),
                onBoost: () => _handleCardAction('SUPER_LIKE'),
                onMessage: _handleCardMessage,
                onActionHistory: (action) => _openActionHistory(action),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardView() {
    final matchesAsync = ref.watch(
      matchingCandidatesProvider(
        MatchingQuery(distanceKm: _selectedDistance, limit: 20),
      ),
    );
    final l10n = AppLocalizations.of(context)!;

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => MatchingCardStack(
        matches: const [],
        currentIndex: 0,
        onSwipe: (_) {},
        onRetry: () => ref.invalidate(matchingCandidatesProvider),
        onViewAgain: () {},
        isError: true,
        errorMessage: e.toString(),
      ),
      data: (candidates) {
        final matches = _toCardMaps(candidates, l10n);

        return MatchingCardStack(
          matches: matches,
          currentIndex: _currentCardIndex,
          onSwipe: _handleCardAction,
          onRetry: () => ref.invalidate(matchingCandidatesProvider),
          onViewAgain: () {
            setState(() => _currentCardIndex = 0);
            ref.invalidate(matchingCandidatesProvider);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _toCardMaps(
    List<MatchCandidateModel> candidates,
    AppLocalizations l10n,
  ) {
    return candidates.map((c) {
      return {
        'userId': c.userId,
        'name': c.displayName,
        'age': c.age,
        'occupation': c.occupation ?? '-',
        'location': c.locationAddress ?? '',
        'distance': c.distanceKm.toStringAsFixed(1),
        'matchScore': c.matchScore,
        'bio': c.bio ?? l10n.greeting,
        'imageUrl': c.imageUrl,
      };
    }).toList();
  }

  void _openActionHistory(String action) {
    context.push('/matching/actions?action=$action&direction=sent');
  }

  Future<void> _handleCardMessage() async {
    final matches = ref.read(
      matchingCandidatesProvider(
        MatchingQuery(distanceKm: _selectedDistance, limit: 20),
      ),
    );
    final current = matches.valueOrNull;
    if (current == null || _currentCardIndex >= current.length) return;
    final candidate = current[_currentCardIndex];

    await _sendMessageToUser(candidate);
  }

  Future<void> _handleCardAction(String action) async {
    final l10n = AppLocalizations.of(context)!;

    final matches = ref.read(
      matchingCandidatesProvider(
        MatchingQuery(distanceKm: _selectedDistance, limit: 20),
      ),
    );

    final current = matches.valueOrNull;
    if (current == null || _currentCardIndex >= current.length) return;
    final candidate = current[_currentCardIndex];

    try {
      if (!mounted) return;
      setState(() => _currentCardIndex++);

      await ref.read(matchingRepositoryProvider).recordAction(
            targetUserId: candidate.userId,
            action: action,
            matchScore: candidate.matchScore,
          );
      ref.invalidate(matchingActivityProvider);

      if (!mounted) return;
      final message = switch (action) {
        'LIKE' => l10n.likeSent,
        'SUPER_LIKE' => l10n.superLike,
        _ => l10n.nextMatch,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleListAction(dynamic candidate, String action) async {
    // Cast candidate to MatchCandidateModel safely if needed, or update signature
    if (candidate is! MatchCandidateModel) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(matchingRepositoryProvider).recordAction(
            targetUserId: candidate.userId,
            action: action,
            matchScore: candidate.matchScore,
          );
      ref.invalidate(matchingActivityProvider);

      if (!mounted) return;
      final message = switch (action) {
        'LIKE' => l10n.likeSent,
        'SUPER_LIKE' => l10n.superLike,
        _ => l10n.nextMatch,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Kept logic for sending message
  Future<void> _sendMessageToUser(dynamic candidate) async {
    if (candidate is! MatchCandidateModel) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      final targetUserId = _parseNullableId(candidate.userId);
      if (targetUserId == null) {
        throw Exception('Invalid target user id');
      }
      final chatRepo = ref.read(chatRepositoryProvider);
      final data =
          await chatRepo.createOrGetDirectRoom(targetUserId: targetUserId);
      final roomId = _parseNullableId(data['roomId'] ?? data['id']) ?? 0;
      final partnerName =
          (data['partnerName'] ?? candidate.displayName).toString();
      final partnerUserId =
          _parseNullableId(data['partnerUserId']) ?? targetUserId;
      final rawPartnerImageUrl = data['partnerImageUrl']?.toString();
      final partnerImageUrl =
          (rawPartnerImageUrl != null && rawPartnerImageUrl.trim().isNotEmpty)
              ? rawPartnerImageUrl
              : candidate.imageUrl;
      if (!mounted) return;
      ref.invalidate(chatRoomsProvider);
      context.push(
        '/chat/rooms/$roomId',
        extra: {
          'partnerName': partnerName,
          'partnerUserId': partnerUserId,
          if (partnerImageUrl != null) 'partnerImageUrl': partnerImageUrl,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    final educationOptions = [
      l10n.educationHighSchool,
      l10n.educationCollege,
      l10n.educationGraduate,
    ];
    // Keep dialog logic as is but maybe improve visuals later if needed.
    // ... existing dialog logic ...
    // For brevity, using the existing dialog logic but simplified or copied from previous.
    // I need to ensure I don't lose the existing dialog implementation.
    // Ideally I should extract FilterDialog too.

    // I will extract FilterDialog to a new file `matching_filter_dialog.dart`
    // but for now I'll just use a simplified placeholder or copy-paste it if I recall it.
    // Actually, I can keep the monolithic method here or do it right.
    // Let's do it right. I'll create `matching_filter_dialog.dart`.

    showDialog(
      context: context,
      builder: (context) => _MatchingFilterDialog(
        initialMinAge: _minAge,
        initialMaxAge: _maxAge,
        initialMinHeight: _minHeight,
        initialMaxHeight: _maxHeight,
        selectedEducations: _selectedEducations,
        onApply: (minAge, maxAge, minHeight, maxHeight, educations) {
          setState(() {
            _minAge = minAge;
            _maxAge = maxAge;
            _minHeight = minHeight;
            _maxHeight = maxHeight;
            _selectedEducations.clear();
            _selectedEducations.addAll(educations);
          });
        },
      ),
    );
  }
}

int? _parseNullableId(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

// I'll create `_MatchingFilterDialog` as a private class here or separate file.
// Separate file is better. `matching_filter_dialog.dart`.

class _MatchingFilterDialog extends StatefulWidget {
  final int initialMinAge;
  final int initialMaxAge;
  final int initialMinHeight;
  final int initialMaxHeight;
  final Set<String> selectedEducations;
  final Function(int, int, int, int, Set<String>) onApply;

  const _MatchingFilterDialog({
    required this.initialMinAge,
    required this.initialMaxAge,
    required this.initialMinHeight,
    required this.initialMaxHeight,
    required this.selectedEducations,
    required this.onApply,
  });

  @override
  State<_MatchingFilterDialog> createState() => _MatchingFilterDialogState();
}

class _MatchingFilterDialogState extends State<_MatchingFilterDialog> {
  late int _minAge;
  late int _maxAge;
  late int _minHeight;
  late int _maxHeight;
  late Set<String> _selectedEducations;

  @override
  void initState() {
    super.initState();
    _minAge = widget.initialMinAge;
    _maxAge = widget.initialMaxAge;
    _minHeight = widget.initialMinHeight;
    _maxHeight = widget.initialMaxHeight;
    _selectedEducations = Set.from(widget.selectedEducations);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final educationOptions = [
      l10n.educationHighSchool,
      l10n.educationCollege,
      l10n.educationGraduate,
    ];

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
                setState(() {
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
                setState(() {
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
                    setState(() {
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(
                _minAge, _maxAge, _minHeight, _maxHeight, _selectedEducations);
            Navigator.pop(context);
          },
          child: Text(l10n.apply),
        )
      ],
    );
  }
}
