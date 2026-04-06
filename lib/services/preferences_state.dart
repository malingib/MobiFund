import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState extends ChangeNotifier {
  static const _kThemeMode = 'pref_theme_mode';
  static const _kLocale = 'pref_locale';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('en', 'KE');
  Locale get locale => _locale;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeStr = prefs.getString(_kThemeMode);
    _themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final loc = prefs.getString(_kLocale);
    _locale = _parseLocale(loc) ?? const Locale('en', 'KE');

    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeMode,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, '${locale.languageCode}_${locale.countryCode ?? ''}');
  }

  static Locale? _parseLocale(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final parts = s.split('_');
    if (parts.isEmpty) return null;
    final lang = parts[0].trim();
    final country = parts.length > 1 ? parts[1].trim() : null;
    if (lang.isEmpty) return null;
    return Locale(lang, (country?.isEmpty ?? true) ? null : country);
  }
}

