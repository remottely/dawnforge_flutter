import 'package:darkness_dungeon/gameplay/core/localization/gameplay_localizations.dart';

class GameplayStringsLocation {
  // Private static instance for singleton pattern
  static GameplayStringsLocation? _instance;
  static final GameplayStringsLocation instance = _instance ??=
      GameplayStringsLocation._internal();

  // Private constructor for singletonƒ
  GameplayStringsLocation._internal();

  static late GameplayLocalizations _localizations;

  static void initialize(GameplayLocalizations localization) {
    _localizations = localization;
  }

  String getString(String key) {
    return _localizations.trans(key);
  }
}
