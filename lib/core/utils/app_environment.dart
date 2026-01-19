final class AppEnvironment {
  AppEnvironment._();

  static const String _kEnvKey = 'GAME_ENVIRONMENT';
  static const String _kEnvDevelopmentValue = 'DEVELOPMENT';
  static const String _kEnvStagingValue = 'STAGING';
  static const String _kEnvProductionValue = 'PRODUCTION';

  static const String _kEnvironment = String.fromEnvironment(
    _kEnvKey,
    defaultValue: _kEnvProductionValue,
  );

  static const bool _kIsDevelopment = _kEnvironment == _kEnvDevelopmentValue;
  static const bool _kIsStaging = _kEnvironment == _kEnvStagingValue;
  static const bool _kIsProduction = _kEnvironment == _kEnvProductionValue;

  /// GENERAL
  static const bool kIsDebugMode = _kIsDevelopment;
  static const bool kIsDevToolsMode = _kIsDevelopment || _kIsStaging;

  /// DEV
  static const bool kShowCollisionArea = kIsDebugMode;
  static const double kGameSpeedMultiplier = _kIsStaging
      ? 1.0
      : 1.0; // TODO(Kevin): NOW - put it back: kIsDebugMode
  // static const double kGameSpeedMultiplier = kIsDevToolsMode ? 4.0 : 1.0;

  /// STG

  /// PRD
  static const bool kPlayBackgroundMusic = _kIsProduction;
}
