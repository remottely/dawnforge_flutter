final class AppEnvironment {
  AppEnvironment._();

  static const String _kEnvKey = 'GAME_ENVIRONMENT';
  static const String _kEnvDevelopmentValue = 'DEVELOPMENT';
  static const String _kEnvProductionValue = 'PRODUCTION';

  static const String _kEnvironment = String.fromEnvironment(
    _kEnvKey,
    defaultValue: _kEnvProductionValue,
  );

  static const bool _kIsDevelopment = _kEnvironment == _kEnvDevelopmentValue;
  static const bool _kIsProduction = _kEnvironment == _kEnvProductionValue;

  static const bool kShowCollisionBoxes = _kIsDevelopment;
  static const bool kIsDebugMode = _kIsDevelopment;

  static const bool kPlayBackgroundMusic = false; // _kIsProduction; // TODO(Kevin): NOW - put it back

  static T byEnvironment<T>({required T development, required T production}) {
    switch (_kEnvironment) {
      case _kEnvDevelopmentValue:
        return development;
      case _kEnvProductionValue:
        return production;
      default:
        return production;
    }
  }
}
