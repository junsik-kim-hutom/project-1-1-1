import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../providers/profile_provider.dart';
import '../../../../core/models/profile_model.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  bool _showAllDetails = false;
  bool _requestedProfile = false;

  @override
  void initState() {
    super.initState();
    final profileState = ref.read(profileProvider);
    if (!_requestedProfile &&
        !profileState.isLoading &&
        profileState.profile == null &&
        profileState.error == null) {
      _requestedProfile = true;
      Future.microtask(() => ref.read(profileProvider.notifier).loadMyProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final errorMessage = profileState.error ?? '';
    if (errorMessage.contains('PROFILE_NOT_FOUND')) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.myProfile),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profileNotFoundMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/profile/create'),
                  child: Text(l10n.createProfile),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (profileState.error != null && profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.failedToLoadProfile),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(profileProvider.notifier).loadMyProfile(force: true);
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (profileState.isLoading && profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayName =
        (profile?.displayName.isNotEmpty ?? false) ? profile!.displayName : l10n.user;
    final subtitleParts = <String>[];
    if (profile != null) {
      subtitleParts.add('${profile.calculatedAge}${l10n.years}');
      if (profile.occupation != null && profile.occupation!.isNotEmpty) {
        subtitleParts.add(_occupationLabel(l10n, profile.occupation!));
      }
    }
    final subtitleText = subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : '';
    final items = _buildProfileItems(l10n, profile);
    final visibleItems = _showAllDetails ? items : items.take(3).toList();
    final avatarUrl = _preferredAvatarUrl(profile);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                tooltip: l10n.editProfile,
                icon: const Icon(Icons.edit_outlined),
                onPressed: profile == null ? null : () => context.push('/profile/edit'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _ProfileAvatar(imageUrl: avatarUrl),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingSmall),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (subtitleText.isNotEmpty)
                          Text(
                            subtitleText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  Text(
                    l10n.myProfile,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  CustomCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < visibleItems.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _ProfileItem(
                            icon: visibleItems[i].icon,
                            label: visibleItems[i].label,
                            value: visibleItems[i].value,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (items.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                          child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllDetails = !_showAllDetails;
                            });
                          },
                          child: Text(_showAllDetails ? l10n.seeLess : l10n.seeMore),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  CustomCard(
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(l10n.settings),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/settings');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ProfileItemData> _buildProfileItems(
    AppLocalizations l10n,
    ProfileModel? profile,
  ) {
    return [
      _ProfileItemData(
        icon: Icons.work_outline,
        label: l10n.occupation,
        value: profile?.occupation != null
            ? _occupationLabel(l10n, profile!.occupation!)
            : null,
      ),
      _ProfileItemData(
        icon: Icons.school_outlined,
        label: l10n.education,
        value: profile?.education != null
            ? _educationLabel(l10n, profile!.education!)
            : null,
      ),
      _ProfileItemData(
        icon: Icons.height,
        label: l10n.height,
        value: profile?.heightText,
      ),
      _ProfileItemData(
        icon: Icons.smoking_rooms_outlined,
        label: l10n.smoking,
        value: _yesNoSometimesLabel(l10n, profile?.smoking),
      ),
      _ProfileItemData(
        icon: Icons.local_bar_outlined,
        label: l10n.drinking,
        value: _yesNoSometimesLabel(l10n, profile?.drinking),
      ),
      _ProfileItemData(
        icon: Icons.notes_rounded,
        label: l10n.bio,
        value: profile?.bio,
      ),
    ];
  }

  String? _preferredAvatarUrl(ProfileModel? profile) {
    if (profile == null) return null;
    final approvedMain = profile.mainImageUrl;
    if (approvedMain != null && approvedMain.isNotEmpty) return approvedMain;
    final images = profile.images;
    if (images == null || images.isEmpty) return null;
    final main = images.where((img) => img.isMain).firstOrNull ?? images.first;
    return main.imageUrl;
  }

  String _yesNoSometimesLabel(AppLocalizations l10n, String? value) {
    switch (value) {
      case 'yes':
        return l10n.yes;
      case 'no':
        return l10n.no;
      case 'sometimes':
        return l10n.sometimes;
      default:
        return value ?? '';
    }
  }

  String _occupationLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case '회사원':
        return l10n.occupationOfficeWorker;
      case '공무원':
        return l10n.occupationPublicServant;
      case '자영업':
        return l10n.occupationSelfEmployed;
      case '전문직':
      case '전문직 (의사, 변호사 등)':
        return l10n.occupationProfessional;
      case '개발자':
      case '개발자/IT':
        return l10n.occupationDeveloper;
      case '교육':
      case '교육/강사':
        return l10n.occupationEducation;
      case '서비스업':
        return l10n.occupationService;
      case '예술/디자인':
        return l10n.occupationArtDesign;
      case '학생':
        return l10n.occupationStudent;
      case '기타':
        return l10n.occupationOther;
      default:
        return value;
    }
  }

  String _educationLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case '고등학교 졸업':
        return l10n.educationHighSchoolGraduate;
      case '전문대 졸업':
        return l10n.educationJuniorCollegeGraduate;
      case '대학교 졸업':
        return l10n.educationUniversityGraduate;
      case '대학원 석사':
        return l10n.educationMasters;
      case '대학원 박사':
        return l10n.educationPhd;
      case '기타':
        return l10n.educationOther;
      default:
        return value;
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: colorScheme.surface,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: colorScheme.surface,
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }
}

class _ProfileItemData {
  final IconData icon;
  final String label;
  final String? value;

  const _ProfileItemData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final displayValue =
        (value != null && value!.trim().isNotEmpty) ? value! : l10n.notEntered;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
