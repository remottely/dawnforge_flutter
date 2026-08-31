import 'dart:async';
import 'dart:convert';

import 'package:dawnforge/game/systems/localization/gameplay_strings_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameplayLocalizations {
  final Locale locale;

  GameplayLocalizations(this.locale) {
    GameplayStringsLocation.instance.initialize(this);
  }

  late final Map<String, String> _sentences;

  static GameplayLocalizations? of(BuildContext context) {
    return Localizations.of<GameplayLocalizations>(
      context,
      GameplayLocalizations,
    );
  }

  Future<bool> load() async {
    final data = await rootBundle.loadString(
      'assets/l10n/${locale.languageCode}.json',
    );
    final result = json.decode(data) as Map<String, dynamic>;

    _sentences = result.map((String key, dynamic value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String trans(String key) {
    return _sentences[key] ?? '';
  }
}
