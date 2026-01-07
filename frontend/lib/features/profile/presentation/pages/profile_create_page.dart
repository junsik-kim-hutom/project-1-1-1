import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/core/models/profile_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:marriage_matching_app/features/auth/providers/auth_provider.dart';
import 'package:marriage_matching_app/features/profile/providers/profile_provider.dart';
import '../widgets/profile_form_section.dart';

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
    final mainIndex =
        _coerceMainImageIndex(_mainImageIndex, _profileImageUrls.length);
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

    final mainIndex =
        _coerceMainImageIndex(_mainImageIndex, _profileImageUrls.length);
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
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_isEditMode && !_didPrefill && profileState.profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didPrefill) return;
        setState(() => _prefillFromProfile(profileState.profile!));
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? l10n.editProfile : l10n.createProfile,
          style:
              AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _isEditMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isBusy,
            child: Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // Photos
                  ProfileFormSection(
                    title: '프로필 사진', // Default to Korean if l10n missing
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
                  const SizedBox(height: 24),

                  // Basic Info
                  ProfileFormSection(
                    title: '기본 정보',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: _inputDecoration(l10n.name, '사용자 1'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${l10n.name} ${l10n.confirm}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(l10n.gender,
                                style: AppTextStyles.labelMedium),
                          ),
                        ),
                        SegmentedButton<String>(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primary.withOpacity(0.1);
                                }
                                return AppColors.surfaceExposed;
                              },
                            ),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primary;
                                }
                                return AppColors.textSecondary;
                              },
                            ),
                          ),
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
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _birthDateController,
                          readOnly: true,
                          decoration: _inputDecoration(l10n.birthDate, '선택해주세요')
                              .copyWith(
                            suffixIcon: const Icon(Icons.calendar_today_rounded,
                                color: AppColors.textSecondary),
                          ),
                          onTap: _selectDate,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _heightController,
                          decoration:
                              _inputDecoration(l10n.height, '175').copyWith(
                            suffixText: 'cm',
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
                  const SizedBox(height: 24),

                  // Job & Education
                  ProfileFormSection(
                    title: '${l10n.occupation} & ${l10n.education}',
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _occupation,
                          isExpanded: true,
                          decoration: _inputDecoration(l10n.occupation, ''),
                          hint: const Text('선택해주세요'),
                          items: _occupationValues.map((val) {
                            return DropdownMenuItem(
                                value: val, child: Text(val));
                          }).toList()
                            ..add(const DropdownMenuItem(
                                value: '기타', child: Text('기타'))),
                          onChanged: (value) =>
                              setState(() => _occupation = value),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _education,
                          isExpanded: true,
                          decoration: _inputDecoration(l10n.education, ''),
                          hint: const Text('선택해주세요'),
                          items: _educationValues
                              .map((val) => DropdownMenuItem(
                                  value: val, child: Text(val)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _education = value),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _incomeController,
                          decoration: _inputDecoration('연수입', '예: 5000만원'),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lifestyle
                  ProfileFormSection(
                    title: '라이프스타일',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.smoking, style: AppTextStyles.labelMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'no', label: Text(l10n.no)),
                            ButtonSegment(
                                value: 'sometimes',
                                label: Text(l10n.sometimes)),
                            ButtonSegment(value: 'yes', label: Text(l10n.yes)),
                          ],
                          selected: {_smoking ?? 'no'},
                          onSelectionChanged: (s) =>
                              setState(() => _smoking = s.first),
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.drinking, style: AppTextStyles.labelMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'no', label: Text(l10n.no)),
                            ButtonSegment(
                                value: 'sometimes',
                                label: Text(l10n.sometimes)),
                            ButtonSegment(value: 'yes', label: Text(l10n.yes)),
                          ],
                          selected: {_drinking ?? 'no'},
                          onSelectionChanged: (s) =>
                              setState(() => _drinking = s.first),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _residenceController,
                          decoration: _inputDecoration('거주지', '예: 서울시 강남구'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _bodyType,
                          isExpanded: true,
                          decoration: _inputDecoration('체형', ''),
                          items: ['슬림', '보통', '글래머러스', '근육질', '통통']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _bodyType = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Values
                  ProfileFormSection(
                    title: '가치관 & 결혼관',
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _marriageIntention,
                          isExpanded: true,
                          decoration: _inputDecoration('결혼 의향', ''),
                          hint: const Text('선택해주세요'),
                          items: ['적극적', '있음', '천천히 생각 중', '미정']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _marriageIntention = value),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _childrenPlan,
                          isExpanded: true,
                          decoration: _inputDecoration('자녀 계획', ''),
                          hint: const Text('선택해주세요'),
                          items: ['원함', '원하지 않음', '상의 후 결정', '미정']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _childrenPlan = value),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _marriageTiming,
                          isExpanded: true,
                          decoration: _inputDecoration('결혼 시기', ''),
                          hint: const Text('선택해주세요'),
                          items: ['6개월 이내', '1년 이내', '2-3년 이내', '천천히', '미정']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _marriageTiming = value),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _dateCostSharing,
                          isExpanded: true,
                          decoration: _inputDecoration('데이트 비용', ''),
                          hint: const Text('선택해주세요'),
                          items: ['남성 부담', '여성 부담', '더치페이', '번갈아 부담', '협의']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _dateCostSharing = value),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _importantValue,
                          isExpanded: true,
                          decoration: _inputDecoration('중요하게 생각하는 가치', ''),
                          hint: const Text('선택해주세요'),
                          items: ['성격', '경제력', '외모', '가정환경', '직업', '가치관', '종교']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _importantValue = value),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _houseworkSharing,
                          isExpanded: true,
                          decoration: _inputDecoration('가사 분담', ''),
                          hint: const Text('선택해주세요'),
                          items: ['평등 분담', '유연하게', '주로 여성', '주로 남성', '협의']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _houseworkSharing = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Introduction
                  ProfileFormSection(
                    title: '자기소개',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _charmPointController,
                          decoration: _inputDecoration(
                              '나의 매력 포인트', '예: 요리를 잘해요, 잘 웃어요'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _idealPartnerController,
                          decoration: _inputDecoration(
                              '이상형', '예: 다정한 사람, 대화가 잘 통하는 사람'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _holidayActivityController,
                          decoration:
                              _inputDecoration('휴일 데이터 선호', '예: 맛집 탐방, 드라이브'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _bioController,
                          decoration:
                              _inputDecoration(l10n.bio, '간단한 자기소개를 입력해주세요.')
                                  .copyWith(
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for FAB
                ],
              ),
            ),
          ),

          // Save Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isBusy ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isBusy
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          l10n.save,
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
    );
  }
}
