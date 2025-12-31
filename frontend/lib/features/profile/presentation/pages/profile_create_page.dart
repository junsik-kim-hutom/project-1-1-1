import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';

class ProfileCreatePage extends ConsumerStatefulWidget {
  const ProfileCreatePage({super.key});

  @override
  ConsumerState<ProfileCreatePage> createState() => _ProfileCreatePageState();
}

class _ProfileCreatePageState extends ConsumerState<ProfileCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String _gender = 'male';
  DateTime? _birthDate;
  int? _height;
  String? _occupation;
  String? _education;
  String? _smoking = 'no';
  String? _drinking = 'no';
  final List<String> _interests = [];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
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
      });
    }
  }

  void _saveProfile() {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      // TODO: Save profile to API
      // Mock usage to silence warnings
      debugPrint('Profile: $_height, $_occupation, $_education, $_interests');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.profile} ${l10n.save}!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createProfile),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
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

            // Gender
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: InputDecoration(labelText: l10n.gender),
              items: [
                DropdownMenuItem(value: 'male', child: Text(l10n.male)),
                DropdownMenuItem(value: 'female', child: Text(l10n.female)),
                DropdownMenuItem(value: 'other', child: Text(l10n.other)),
              ],
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Birth Date
            ListTile(
              title: Text(l10n.birthDate),
              subtitle: Text(_birthDate != null
                  ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                  : l10n.confirm),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),

            // Height
            TextFormField(
              decoration: InputDecoration(
                labelText: '${l10n.height} (cm)',
                hintText: '175',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _height = int.tryParse(value);
              },
            ),
            const SizedBox(height: 16),

            // Occupation
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.occupation,
                hintText: l10n.developer,
              ),
              onChanged: (value) {
                _occupation = value;
              },
            ),
            const SizedBox(height: 16),

            // Education
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.education,
                hintText: l10n.education,
              ),
              onChanged: (value) {
                _education = value;
              },
            ),
            const SizedBox(height: 16),

            // Smoking
            DropdownButtonFormField<String>(
              initialValue: _smoking,
              decoration: InputDecoration(labelText: l10n.smoking),
              items: [
                DropdownMenuItem(value: 'yes', child: Text(l10n.yes)),
                DropdownMenuItem(value: 'no', child: Text(l10n.no)),
                DropdownMenuItem(value: 'sometimes', child: Text(l10n.sometimes)),
              ],
              onChanged: (value) {
                setState(() {
                  _smoking = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Drinking
            DropdownButtonFormField<String>(
              initialValue: _drinking,
              decoration: InputDecoration(labelText: l10n.drinking),
              items: [
                DropdownMenuItem(value: 'yes', child: Text(l10n.yes)),
                DropdownMenuItem(value: 'no', child: Text(l10n.no)),
                DropdownMenuItem(value: 'sometimes', child: Text(l10n.sometimes)),
              ],
              onChanged: (value) {
                setState(() {
                  _drinking = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: l10n.bio,
                hintText: l10n.bio,
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('${l10n.profile} ${l10n.save}'),
            ),
          ],
        ),
      ),
    );
  }
}
