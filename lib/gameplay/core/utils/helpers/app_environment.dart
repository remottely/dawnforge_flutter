class AppEnvironment {
  static const _kEnvKey = 'GAME_ENVIRONMENT';
  static const _kEnvDevelopmentValue = 'DEVELOPMENT';
  static const _kEnvProductionValue = 'PRODUCTION';

  static const _kEnvironment = String.fromEnvironment(
    _kEnvKey,
    defaultValue: _kEnvDevelopmentValue,
  );

  static const _kIsDevelopment = _kEnvironment == _kEnvDevelopmentValue;
  static const _kIsProduction = _kEnvironment == _kEnvProductionValue;

  static const kShowCollisionBoxes = _kIsDevelopment;
  static const kIsDebugMode = _kIsDevelopment;

  static const kPlayBackgroundMusic = _kIsProduction;

  static T byEnvironment<T>({required T development, required T production}) {
    switch (_kEnvironment) {
      case _kEnvDevelopmentValue:
        return development;
      case _kEnvProductionValue:
        return production;
      default:
        return development;
    }
  }
}
