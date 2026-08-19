import 'dart:async';

import 'package:dawnforge/game/systems/localization/gameplay_localizations.dart';
import 'package:flutter/material.dart';

class GameplayLocalizationsDelegate
    extends LocalizationsDelegate<GameplayLocalizations> {
  static const List<Locale> kSupportedLocales = [Locale('en'), Locale('pt')];

  const GameplayLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return kSupportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<GameplayLocalizations> load(Locale locale) async {
    final GameplayLocalizations localizations = GameplayLocalizations(locale);

    await localizations.load();

    return localizations;
  }

  @override
  bool shouldReload(GameplayLocalizationsDelegate old) => false;

  Locale resolution(Locale? locale, Iterable<Locale> supportedLocales) {
    for (final supportedLocale in supportedLocales) {
      if (locale != null) {
        if (supportedLocale.languageCode == locale.languageCode ||
            supportedLocale.countryCode == locale.countryCode) {
          return supportedLocale;
        }
      }
    }
    return supportedLocales.first;
  }

  static List<Locale> supportedLocales() {
    return [const Locale('en', 'US'), const Locale('pt', 'BR')];
  }
}
