import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_localizations.dart';

final class GameplayStringsLocation {
  GameplayStringsLocation._();

  static final GameplayStringsLocation instance = GameplayStringsLocation._();

  late final GameplayLocalizations _localizations;

  void initialize(GameplayLocalizations localization) {
    _localizations = localization;
  }

  String getString(String key) {
    return _localizations.trans(key);
  }
}
