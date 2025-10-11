import 'package:darkness_dungeon/gameplay/core/localization/gameplay_localizations.dart';

class GameplayStringsLocation {
  static final GameplayStringsLocation _singleton =
      new GameplayStringsLocation._internal();

  static late GameplayLocalizations _myLocalizations;

  static void configure(GameplayLocalizations location) {
    _myLocalizations = location;
  }

  factory GameplayStringsLocation() {
    return _singleton;
  }

  GameplayStringsLocation._internal();

  String getString(String key) {
    return _myLocalizations.trans(key);
  }
}

String getString(String key) {
  return GameplayStringsLocation().getString(key);
}
