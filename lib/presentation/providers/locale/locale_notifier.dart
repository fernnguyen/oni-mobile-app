import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/locale/app_locale.dart';

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  static const String _localePrefsKey = 'selected_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final languageCode = prefs.getString(_localePrefsKey);

    if (languageCode != null) {
      if (languageCode == 'en') {
        return const Locale('en', 'US');
      } else if (languageCode == 'vi') {
        return const Locale('vi', 'VN');
      }
    }

    return AppLocale.defaultLocale;
  }

  void changeLocale(String languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localePrefsKey, languageCode);

    if (languageCode == 'en') {
      state = const Locale('en', 'US');
    } else {
      state = const Locale('vi', 'VN');
    }
  }
}
