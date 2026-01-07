import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/profile_provider.dart';
import '../../../../core/models/profile_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_gallery.dart';
import '../widgets/profile_menu_item.dart';

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
      Future.microtask(
          () => ref.read(profileProvider.notifier).loadMyProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final errorMessage = profileState.error ?? '';
    // Error States
    if (errorMessage.contains('PROFILE_NOT_FOUND')) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            title: Text(l10n.myProfile), backgroundColor: Colors.transparent),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle_outlined,
                    size: 80, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(
                  l10n.profileNotFoundMessage,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                l10n.failedToLoadProfile,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
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
        backgroundColor: AppColors.background,
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Prepare Data
    final displayName = (profile?.displayName.isNotEmpty ?? false)
        ? profile!.displayName
        : l10n.user;
    final subtitleParts = <String>[];
    if (profile != null) {
      subtitleParts.add('${profile.calculatedAge}${l10n.years}');
      if (profile.occupation != null && profile.occupation!.isNotEmpty) {
        subtitleParts.add(_occupationLabel(l10n, profile.occupation!));
      }
    }
    final subtitleText =
        subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : '';
    final avatarUrl = _preferredAvatarUrl(profile);

    final infoItems = _buildProfileItems(l10n, profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            ProfileHeader(
              imageUrl: avatarUrl,
              displayName: displayName,
              subtitle: subtitleText,
              onEditTap: (profile == null)
                  ? () {}
                  : () => context.push('/profile/edit'),
            ),

            const SizedBox(height: 24),

            // Photos Gallery
            if (profile != null && profile.images != null)
              ProfileGallery(
                imageUrls: profile.images!
                    .where((img) =>
                        !img.isMain) // Exclude main if preferred, or show all
                    .map((img) => img.imageUrl)
                    .toList(),
                onAddPhoto: () => context
                    .push('/profile/edit'), // Redirect to edit for adding
              ),

            const SizedBox(height: 24),

            // Info Section
            ProfileInfoSection(
              title: l10n.myProfile, // Using 'myProfile' instead of 'aboutMe'
              items: infoItems,
              showMore: _showAllDetails,
              onToggleShowMore: () {
                setState(() {
                  _showAllDetails = !_showAllDetails;
                });
              },
            ),

            const SizedBox(height: 24),

            // Settings / Account
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.settings_rounded,
                          title: l10n.settings,
                          iconColor: AppColors.textSecondary,
                          onTap: () => context.push('/settings'),
                        ),
                        // Add more menu items if needed (Help, etc.)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<ProfileInfoItem> _buildProfileItems(
    AppLocalizations l10n,
    ProfileModel? profile,
  ) {
    return [
      ProfileInfoItem(
        icon: Icons.work_outline_rounded,
        label: l10n.occupation,
        value: profile?.occupation != null
            ? _occupationLabel(l10n, profile!.occupation!)
            : null,
      ),
      ProfileInfoItem(
        icon: Icons.school_outlined,
        label: l10n.education,
        value: profile?.education != null
            ? _educationLabel(l10n, profile!.education!)
            : null,
      ),
      ProfileInfoItem(
        icon: Icons.height_rounded,
        label: l10n.height,
        value: profile?.heightText,
      ),
      ProfileInfoItem(
        icon: Icons.smoking_rooms_outlined,
        label: l10n.smoking,
        value: _yesNoSometimesLabel(l10n, profile?.smoking),
      ),
      ProfileInfoItem(
        icon: Icons.local_bar_outlined,
        label: l10n.drinking,
        value: _yesNoSometimesLabel(l10n, profile?.drinking),
      ),
      ProfileInfoItem(
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
