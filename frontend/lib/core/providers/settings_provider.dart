import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'settings_theme_mode';
const _languageCodeKey = 'settings_language_code';

const Map<String, Locale> _supportedLocales = {
  'ko': Locale('ko', 'KR'),
  'ja': Locale('ja', 'JP'),
  'en': Locale('en', 'US'),
};

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
    default:
      return 'system';
  }
}

Locale _localeFromCode(String? code) {
  return _supportedLocales[code] ?? _supportedLocales['ko']!;
}

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isLoaded;

  const SettingsState({
    required this.themeMode,
    required this.locale,
    this.isLoaded = false,
  });

  factory SettingsState.initial() => const SettingsState(
        themeMode: ThemeMode.system,
        locale: Locale('ko', 'KR'),
        isLoaded: false,
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isLoaded,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = _themeModeFromString(prefs.getString(_themeModeKey));
    final locale = _localeFromCode(prefs.getString(_languageCodeKey));

    state = state.copyWith(
      themeMode: themeMode,
      locale: locale,
      isLoaded: true,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateLocale(String languageCode) async {
    final locale = _localeFromCode(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
