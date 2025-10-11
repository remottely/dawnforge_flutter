import 'dart:async';

import 'package:darkness_dungeon/gameplay/core/localization/gameplay_localizations.dart';
import 'package:flutter/material.dart';

class GameplayLocalizationsDelegate
    extends LocalizationsDelegate<GameplayLocalizations> {
  const GameplayLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pt'].contains(locale.languageCode);

  @override
  Future<GameplayLocalizations> load(Locale locale) async {
    GameplayLocalizations localizations = new GameplayLocalizations(locale);
    await localizations.load();
    print("Load ${locale.languageCode}");
    return localizations;
  }

  @override
  bool shouldReload(GameplayLocalizationsDelegate old) => false;

  Locale resolution(Locale? locale, Iterable<Locale> supportedLocales) {
    for (Locale supportedLocale in supportedLocales) {
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
