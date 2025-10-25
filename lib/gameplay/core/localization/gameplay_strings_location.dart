import 'package:darkness_dungeon/gameplay/core/localization/gameplay_localizations.dart';

class GameplayStringsLocation {
  GameplayStringsLocation._internal();

  static final GameplayStringsLocation _instance =
      GameplayStringsLocation._internal();

  static GameplayStringsLocation get instance => _instance;

  late final GameplayLocalizations _localizations;

  void initialize(GameplayLocalizations localization) {
    _localizations = localization;
  }

  String getString(String key) {
    return _localizations.trans(key);
  }
}
