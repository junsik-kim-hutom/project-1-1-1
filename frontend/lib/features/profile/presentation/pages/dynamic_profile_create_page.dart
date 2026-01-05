import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';

class DynamicProfileCreatePage extends ConsumerStatefulWidget {
  const DynamicProfileCreatePage({super.key});

  @override
  ConsumerState<DynamicProfileCreatePage> createState() =>
      _DynamicProfileCreatePageState();
}

class _DynamicProfileCreatePageState
    extends ConsumerState<DynamicProfileCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // 기본 필드
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String _gender = 'male';
  DateTime? _birthDate;

  // 동적 필드 값 저장
  final Map<String, dynamic> _fieldValues = {};

  // Mock 데이터 - 실제로는 API에서 가져옴
  List<Map<String, dynamic>> _profileFields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileFields();
  }

  Future<void> _loadProfileFields() async {
    // TODO: API에서 프로필 필드 가져오기
    // final response = await apiClient.dio.get('/api/profile-fields/active');

    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    setState(() {
      _profileFields = _getMockFields();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getMockFields() {
    return [
      {
        'id': '1',
        'fieldKey': 'residence',
        'fieldType': 'text',
        'category': 'basic',
        'label': {'ko': '거주지', 'ja': '居住地', 'en': 'Residence'},
        'placeholder': {'ko': '예: 서울시 강남구', 'ja': '', 'en': ''},
        'isRequired': true,
      },
      {
        'id': '2',
        'fieldKey': 'body_type',
        'fieldType': 'select',
        'category': 'basic',
        'label': {'ko': '몸매', 'ja': '体型', 'en': 'Body Type'},
        'options': {
          'ko': ['슬림', '보통', '글래머러스', '근육질', '통통']
        },
        'isRequired': false,
      },
      {
        'id': '3',
        'fieldKey': 'smoking',
        'fieldType': 'select',
        'category': 'lifestyle',
        'label': {'ko': '흡연 여부', 'ja': '喫煙', 'en': 'Smoking'},
        'options': {
          'ko': ['비흡연', '흡연', '가끔 흡연']
        },
        'isRequired': true,
      },
      {
        'id': '4',
        'fieldKey': 'drinking',
        'fieldType': 'select',
        'category': 'lifestyle',
        'label': {'ko': '음주 여부', 'ja': '飲酒', 'en': 'Drinking'},
        'options': {
          'ko': ['마시지 않음', '가끔 마심', '자주 마심']
        },
        'isRequired': true,
      },
      {
        'id': '5',
        'fieldKey': 'marriage_intention',
        'fieldType': 'select',
        'category': 'family',
        'label': {'ko': '결혼 의향', 'ja': '結婚意向', 'en': 'Marriage Intention'},
        'options': {
          'ko': ['1년 이내', '2-3년 이내', '좋은 사람 만나면', '아직 모름']
        },
        'isRequired': true,
      },
      {
        'id': '6',
        'fieldKey': 'personality',
        'fieldType': 'multi_select',
        'category': 'personality',
        'label': {'ko': '성격', 'ja': '性格', 'en': 'Personality'},
        'options': {
          'ko': ['외향적', '내향적', '활발함', '차분함', '유머러스', '진지함']
        },
        'isRequired': false,
      },
    ];
  }

  Widget _buildDynamicField(Map<String, dynamic> field) {
    final fieldType = field['fieldType'] as String;
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final baseLabel = _pickLocalizedString(
      field['label'] as Map<String, dynamic>,
      localeCode,
    );
    final isRequired = field['isRequired'] as bool;

    switch (fieldType) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            labelText: baseLabel + (isRequired ? ' *' : ''),
            hintText: (field['placeholder'] as Map?) != null
                ? _pickLocalizedString(
                    (field['placeholder'] as Map).cast<String, dynamic>(),
                    localeCode,
                  )
                : null,
          ),
          validator: isRequired
              ? (value) => (value?.isEmpty ?? true)
                  ? l10n.pleaseEnterField(baseLabel)
                  : null
              : null,
          onChanged: (value) {
            _fieldValues[field['fieldKey']] = value;
          },
        );

      case 'select':
        final options =
            _pickLocalizedList(field['options'] as Map<String, dynamic>, localeCode);
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: baseLabel + (isRequired ? ' *' : ''),
          ),
          items: options
              .cast<String>()
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          validator: isRequired
              ? (value) =>
                  value == null ? l10n.pleaseSelectField(baseLabel) : null
              : null,
          onChanged: (value) {
            _fieldValues[field['fieldKey']] = value;
          },
        );

      case 'multi_select':
        final options =
            _pickLocalizedList(field['options'] as Map<String, dynamic>, localeCode);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baseLabel + (isRequired ? ' *' : ''),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final selected = (_fieldValues[field['fieldKey']] as List?)
                        ?.contains(option) ??
                    false;
                return FilterChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (isSelected) {
                    setState(() {
                      if (_fieldValues[field['fieldKey']] == null) {
                        _fieldValues[field['fieldKey']] = [];
                      }
                      final list =
                          _fieldValues[field['fieldKey']] as List<dynamic>;
                      if (isSelected) {
                        list.add(option);
                      } else {
                        list.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _pickLocalizedString(Map<String, dynamic> map, String localeCode) {
    final value = map[localeCode] ?? map['en'] ?? map['ko'];
    if (value is String && value.isNotEmpty) return value;
    for (final v in map.values) {
      if (v is String && v.isNotEmpty) return v;
    }
    return '';
  }

  List<dynamic> _pickLocalizedList(Map<String, dynamic> map, String localeCode) {
    final value = map[localeCode] ?? map['en'] ?? map['ko'];
    if (value is List) return value;
    for (final v in map.values) {
      if (v is List) return v;
    }
    return const [];
  }

  List<Widget> _buildFieldsByCategory(String category) {
    final categoryFields =
        _profileFields.where((f) => f['category'] == category).toList();

    if (categoryFields.isEmpty) {
      return [];
    }

    return [
      const SizedBox(height: 24),
      Text(
        _getCategoryTitle(category),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const Divider(),
      const SizedBox(height: 8),
      ...categoryFields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDynamicField(field),
        );
      }),
    ];
  }

  String _getCategoryTitle(String category) {
    const categoryTitles = {
      'basic': '기본 정보',
      'lifestyle': '라이프스타일',
      'family': '결혼 & 가족',
      'work': '직업 & 경제',
      'personality': '성격 & 가치관',
      'preferences': '선호사항',
    };
    return categoryTitles[category] ?? category;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: API로 프로필 저장
      // TODO: Send data to API
      // Data: _nameController.text, _gender, _birthDate, _fieldValues

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 저장 완료!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 작성'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 기본 필드
                  Text(
                    '필수 정보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름 *',
                      hintText: '홍길동',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '이름을 입력해주세요' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: '성별 *'),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('남성')),
                      DropdownMenuItem(value: 'female', child: Text('여성')),
                      DropdownMenuItem(value: 'other', child: Text('기타')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('생년월일 *'),
                    subtitle: Text(_birthDate != null
                        ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                        : '선택해주세요'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1990),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _birthDate = picked;
                        });
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: '자기소개',
                      hintText: '자신을 소개해주세요',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),

                  // 동적 필드 (카테고리별)
                  ..._buildFieldsByCategory('basic'),
                  ..._buildFieldsByCategory('lifestyle'),
                  ..._buildFieldsByCategory('family'),
                  ..._buildFieldsByCategory('work'),
                  ..._buildFieldsByCategory('personality'),
                  ..._buildFieldsByCategory('preferences'),

                  const SizedBox(height: 32),

                  // 저장 버튼
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('프로필 저장'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
