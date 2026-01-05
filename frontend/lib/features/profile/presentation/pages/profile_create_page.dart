import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/core/models/profile_model.dart';
import 'package:marriage_matching_app/core/widgets/custom_card.dart';
import 'package:marriage_matching_app/features/auth/providers/auth_provider.dart';
import 'package:marriage_matching_app/features/profile/providers/profile_provider.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../widgets/profile_image_upload_widget.dart';

class ProfileCreatePage extends ConsumerStatefulWidget {
  const ProfileCreatePage({super.key});

  @override
  ConsumerState<ProfileCreatePage> createState() => _ProfileCreatePageState();
}

class _ProfileCreatePageState extends ConsumerState<ProfileCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _heightController = TextEditingController();
  final _bioController = TextEditingController();
  final _residenceController = TextEditingController();
  final _incomeController = TextEditingController();
  final _charmPointController = TextEditingController();
  final _idealPartnerController = TextEditingController();
  final _holidayActivityController = TextEditingController();

  String _gender = 'male';
  DateTime? _birthDate;
  int? _height;
  String? _occupation;
  String? _education;
  String? _smoking = 'no';
  String? _drinking = 'no';
  String? _bodyType;
  String? _marriageIntention;
  String? _childrenPlan;
  String? _marriageTiming;
  String? _dateCostSharing;
  String? _importantValue;
  String? _houseworkSharing;
  final List<String> _interests = [];
  List<String> _profileImageUrls = [];
  int? _mainImageIndex;

  bool _initializedEditLoad = false;
  bool _didPrefill = false;

  static const List<String> _occupationValues = <String>[
    '회사원',
    '공무원',
    '자영업',
    '전문직 (의사, 변호사 등)',
    '개발자/IT',
    '교육/강사',
    '서비스업',
    '예술/디자인',
    '학생',
    '기타',
  ];

  static const List<String> _educationValues = <String>[
    '고등학교 졸업',
    '전문대 졸업',
    '대학교 졸업',
    '대학원 석사',
    '대학원 박사',
    '기타',
  ];

  String? _normalizeOccupationForForm(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    switch (trimmed) {
      case '전문직':
        return '전문직 (의사, 변호사 등)';
      case '개발자':
        return '개발자/IT';
      case '교육':
        return '교육/강사';
      default:
        return _occupationValues.contains(trimmed) ? trimmed : null;
    }
  }

  String? _normalizeEducationForForm(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return _educationValues.contains(trimmed) ? trimmed : null;
  }

  bool get _isEditMode {
    final path = GoRouterState.of(context).uri.path;
    return path == '/profile/edit';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isEditMode || _initializedEditLoad) return;
    _initializedEditLoad = true;

    final profile = ref.read(profileProvider).profile;
    if (profile == null) {
      Future.microtask(
        () => ref.read(profileProvider.notifier).loadMyProfile(force: true),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _bioController.dispose();
    _residenceController.dispose();
    _incomeController.dispose();
    _charmPointController.dispose();
    _idealPartnerController.dispose();
    _holidayActivityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = _formatBirthDate(picked);
      });
    }
  }

  String _formatBirthDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int? _coerceMainImageIndex(int? index, int length) {
    if (length <= 0) return null;
    if (length == 1) return 0;
    if (index == null) return null;
    if (index < 0 || index >= length) return null;
    return index;
  }

  List<String> _orderedProfileImages() {
    final mainIndex = _coerceMainImageIndex(_mainImageIndex, _profileImageUrls.length);
    if (_profileImageUrls.isEmpty) return const [];
    if (mainIndex == null) return List<String>.from(_profileImageUrls);
    final mainUrl = _profileImageUrls[mainIndex];
    return <String>[
      mainUrl,
      for (var i = 0; i < _profileImageUrls.length; i++)
        if (i != mainIndex) _profileImageUrls[i],
    ];
  }

  void _prefillFromProfile(ProfileModel profile) {
    _nameController.text = profile.displayName;
    _gender = profile.gender.toLowerCase();
    _birthDate = profile.birthDate;
    _birthDateController.text = _formatBirthDate(profile.birthDate);
    _height = profile.height;
    _heightController.text = profile.height?.toString() ?? '';
    _occupation = _normalizeOccupationForForm(profile.occupation);
    _education = _normalizeEducationForForm(profile.education);
    _smoking = profile.smoking;
    _drinking = profile.drinking;
    _incomeController.text = profile.income ?? '';
    _bioController.text = profile.bio;

    final images = (profile.images ?? [])
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    _profileImageUrls = images.map((e) => e.imageUrl).toList();
    _mainImageIndex = _coerceMainImageIndex(
      images.indexWhere((img) => img.isMain),
      _profileImageUrls.length,
    );

    _didPrefill = true;
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loginRequired)),
        );
        context.go('/login');
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectBirthDate)),
      );
      return;
    }

    final mainIndex = _coerceMainImageIndex(_mainImageIndex, _profileImageUrls.length);
    if (_profileImageUrls.length > 1 && mainIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectMainPhoto)),
      );
      return;
    }

    final profileData = {
      'displayName': _nameController.text,
      'gender': _gender.toUpperCase(),
      'birthDate': _birthDate!.toIso8601String(),
      'height': _height,
      'occupation': _occupation,
      'education': _education,
      'smoking': _smoking,
      'drinking': _drinking,
      'bio': _bioController.text,
      'interests': _interests,
      'profileImages': _orderedProfileImages(),
      'residence': _residenceController.text,
      'bodyType': _bodyType,
      'marriageIntention': _marriageIntention,
      'childrenPlan': _childrenPlan,
      'income': _incomeController.text,
      'marriageTiming': _marriageTiming,
      'dateCostSharing': _dateCostSharing,
      'importantValue': _importantValue,
      'houseworkSharing': _houseworkSharing,
      'charmPoint': _charmPointController.text,
      'idealPartner': _idealPartnerController.text,
      'holidayActivity': _holidayActivityController.text,
    };

    final notifier = ref.read(profileProvider.notifier);
    final success = _isEditMode
        ? await notifier.updateProfile(profileData)
        : await notifier.createProfile(profileData);

    if (!mounted) return;

    if (success) {
      if (!_isEditMode) {
        await ref.read(authProvider.notifier).updateHasProfile(true);
        if (!mounted) return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.profile} ${l10n.save}!')),
      );

      if (_isEditMode) {
        context.pop();
      } else {
        context.go('/main');
      }
      return;
    }

    final error = ref.read(profileProvider).error ?? l10n.unknownError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.error}: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final isBusy = profileState.isLoading;

    if (_isEditMode && profileState.profile == null && isBusy) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfile),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isEditMode && !_didPrefill && profileState.profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didPrefill) return;
        setState(() => _prefillFromProfile(profileState.profile!));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editProfile : l10n.createProfile),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isBusy,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: ProfileImageUploadWidget(
                      initialImages: _profileImageUrls,
                      mainImageIndex: _mainImageIndex,
                      onMainImageIndexChanged: (index) {
                        setState(() {
                          _mainImageIndex = _coerceMainImageIndex(
                            index,
                            _profileImageUrls.length,
                          );
                        });
                      },
                      onImagesUploaded: (urls) {
                        setState(() {
                          _profileImageUrls = urls;
                          _mainImageIndex = _coerceMainImageIndex(
                            _mainImageIndex,
                            _profileImageUrls.length,
                          );
                        });
                      },
                      maxImages: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: InputDecoration(
                            labelText: l10n.name,
                            hintText: '${l10n.user} 1',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${l10n.name} ${l10n.confirm}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.gender,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'male',
                              icon: const Icon(Icons.male),
                              label: Text(l10n.male),
                            ),
                            ButtonSegment(
                              value: 'female',
                              icon: const Icon(Icons.female),
                              label: Text(l10n.female),
                            ),
                            ButtonSegment(
                              value: 'other',
                              icon: const Icon(Icons.person_outline),
                              label: Text(l10n.other),
                            ),
                          ],
                          selected: {_gender},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _gender = selection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _birthDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.birthDate,
                            hintText: l10n.pleaseSelect,
                            suffixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          onTap: _selectDate,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: '${l10n.height} (${l10n.cm})',
                            hintText: '175',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _height = int.tryParse(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _occupation,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.occupation),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '회사원',
                              child: Text(l10n.occupationOfficeWorker),
                            ),
                            DropdownMenuItem(
                              value: '공무원',
                              child: Text(l10n.occupationPublicServant),
                            ),
                            DropdownMenuItem(
                              value: '자영업',
                              child: Text(l10n.occupationSelfEmployed),
                            ),
                            DropdownMenuItem(
                              value: '전문직 (의사, 변호사 등)',
                              child: Text(l10n.occupationProfessional),
                            ),
                            DropdownMenuItem(
                              value: '개발자/IT',
                              child: Text(l10n.occupationDeveloper),
                            ),
                            DropdownMenuItem(
                              value: '교육/강사',
                              child: Text(l10n.occupationEducation),
                            ),
                            DropdownMenuItem(
                              value: '서비스업',
                              child: Text(l10n.occupationService),
                            ),
                            DropdownMenuItem(
                              value: '예술/디자인',
                              child: Text(l10n.occupationArtDesign),
                            ),
                            DropdownMenuItem(
                              value: '학생',
                              child: Text(l10n.occupationStudent),
                            ),
                            DropdownMenuItem(
                              value: '기타',
                              child: Text(l10n.occupationOther),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _occupation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _education,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.education),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '고등학교 졸업',
                              child: Text(l10n.educationHighSchoolGraduate),
                            ),
                            DropdownMenuItem(
                              value: '전문대 졸업',
                              child: Text(l10n.educationJuniorCollegeGraduate),
                            ),
                            DropdownMenuItem(
                              value: '대학교 졸업',
                              child: Text(l10n.educationUniversityGraduate),
                            ),
                            DropdownMenuItem(
                              value: '대학원 석사',
                              child: Text(l10n.educationMasters),
                            ),
                            DropdownMenuItem(
                              value: '대학원 박사',
                              child: Text(l10n.educationPhd),
                            ),
                            DropdownMenuItem(
                              value: '기타',
                              child: Text(l10n.educationOther),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _education = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _incomeController,
                          decoration: InputDecoration(
                            labelText: l10n.annualIncome,
                            hintText: l10n.annualIncomeHint,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.smoking,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'no', label: Text(l10n.no)),
                            ButtonSegment(value: 'sometimes', label: Text(l10n.sometimes)),
                            ButtonSegment(value: 'yes', label: Text(l10n.yes)),
                          ],
                          selected: {_smoking ?? 'no'},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _smoking = selection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.drinking,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'no', label: Text(l10n.no)),
                            ButtonSegment(value: 'sometimes', label: Text(l10n.sometimes)),
                            ButtonSegment(value: 'yes', label: Text(l10n.yes)),
                          ],
                          selected: {_drinking ?? 'no'},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _drinking = selection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _residenceController,
                          decoration: InputDecoration(
                            labelText: l10n.residence,
                            hintText: l10n.residenceHint,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _bodyType,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.bodyType),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(value: '슬림', child: Text(l10n.bodyTypeSlim)),
                            DropdownMenuItem(value: '보통', child: Text(l10n.bodyTypeAverage)),
                            DropdownMenuItem(
                              value: '글래머러스',
                              child: Text(l10n.bodyTypeGlamorous),
                            ),
                            DropdownMenuItem(value: '근육질', child: Text(l10n.bodyTypeMuscular)),
                            DropdownMenuItem(value: '통통', child: Text(l10n.bodyTypeChubby)),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _bodyType = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _marriageIntention,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.marriageIntention),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '적극적',
                              child: Text(l10n.marriageIntentionActive),
                            ),
                            DropdownMenuItem(
                              value: '있음',
                              child: Text(l10n.marriageIntentionYes),
                            ),
                            DropdownMenuItem(
                              value: '천천히 생각 중',
                              child: Text(l10n.marriageIntentionSlow),
                            ),
                            DropdownMenuItem(
                              value: '미정',
                              child: Text(l10n.marriageIntentionNotSure),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _marriageIntention = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _childrenPlan,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.childrenPlan),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '원함',
                              child: Text(l10n.childrenPlanWant),
                            ),
                            DropdownMenuItem(
                              value: '원하지 않음',
                              child: Text(l10n.childrenPlanNo),
                            ),
                            DropdownMenuItem(
                              value: '상의 후 결정',
                              child: Text(l10n.childrenPlanDiscuss),
                            ),
                            DropdownMenuItem(
                              value: '미정',
                              child: Text(l10n.childrenPlanUndecided),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _childrenPlan = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _marriageTiming,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.marriageTiming),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '6개월 이내',
                              child: Text(l10n.marriageTimingWithin6Months),
                            ),
                            DropdownMenuItem(
                              value: '1년 이내',
                              child: Text(l10n.marriageTimingWithin1Year),
                            ),
                            DropdownMenuItem(
                              value: '2-3년 이내',
                              child: Text(l10n.marriageTimingWithin2to3Years),
                            ),
                            DropdownMenuItem(
                              value: '천천히',
                              child: Text(l10n.marriageTimingSlowly),
                            ),
                            DropdownMenuItem(
                              value: '미정',
                              child: Text(l10n.marriageTimingUndecided),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _marriageTiming = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _dateCostSharing,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.dateCostSharing),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '남성 부담',
                              child: Text(l10n.dateCostSharingManPays),
                            ),
                            DropdownMenuItem(
                              value: '여성 부담',
                              child: Text(l10n.dateCostSharingWomanPays),
                            ),
                            DropdownMenuItem(
                              value: '더치페이',
                              child: Text(l10n.dateCostSharingDutch),
                            ),
                            DropdownMenuItem(
                              value: '번갈아 부담',
                              child: Text(l10n.dateCostSharingAlternate),
                            ),
                            DropdownMenuItem(
                              value: '협의',
                              child: Text(l10n.dateCostSharingDiscuss),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _dateCostSharing = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _importantValue,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.importantValue),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '성격',
                              child: Text(l10n.importantValuePersonality),
                            ),
                            DropdownMenuItem(
                              value: '경제력',
                              child: Text(l10n.importantValueFinancial),
                            ),
                            DropdownMenuItem(
                              value: '외모',
                              child: Text(l10n.importantValueAppearance),
                            ),
                            DropdownMenuItem(
                              value: '가정환경',
                              child: Text(l10n.importantValueFamily),
                            ),
                            DropdownMenuItem(
                              value: '직업',
                              child: Text(l10n.importantValueOccupationEducation),
                            ),
                            DropdownMenuItem(
                              value: '가치관',
                              child: Text(l10n.importantValueValues),
                            ),
                            DropdownMenuItem(
                              value: '종교',
                              child: Text(l10n.importantValueReligion),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _importantValue = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _houseworkSharing,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.houseworkSharing),
                          hint: Text(l10n.pleaseSelect),
                          items: [
                            DropdownMenuItem(
                              value: '평등 분담',
                              child: Text(l10n.houseworkSharingEqual),
                            ),
                            DropdownMenuItem(
                              value: '유연하게',
                              child: Text(l10n.houseworkSharingFlexible),
                            ),
                            DropdownMenuItem(
                              value: '주로 여성',
                              child: Text(l10n.houseworkSharingMostlyWoman),
                            ),
                            DropdownMenuItem(
                              value: '주로 남성',
                              child: Text(l10n.houseworkSharingMostlyMan),
                            ),
                            DropdownMenuItem(
                              value: '협의',
                              child: Text(l10n.houseworkSharingDiscuss),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _houseworkSharing = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _charmPointController,
                          decoration: InputDecoration(
                            labelText: l10n.charmPoint,
                            hintText: l10n.charmPointHint,
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _idealPartnerController,
                          decoration: InputDecoration(
                            labelText: l10n.idealPartner,
                            hintText: l10n.idealPartnerHint,
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _holidayActivityController,
                          decoration: InputDecoration(
                            labelText: l10n.holidayActivity,
                            hintText: l10n.holidayActivityHint,
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: l10n.bio,
                            hintText: l10n.bio,
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          maxLength: 500,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isBusy)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      bottomSheet: Material(
        elevation: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isBusy ? null : _saveProfile,
                child: Text('${l10n.profile} ${l10n.save}'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
