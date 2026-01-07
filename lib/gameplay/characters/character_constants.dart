import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';

final class CharacterConstants {
  CharacterConstants._();

  static const double kLifeSmall = 80;
  static const double kLifeMedium = 120;
  static const double kLifeLarge = 150;
  static const double kLifeExtraLarge = 200;

  static const double kSpeedSlow = 18 * AppEnvironment.kGameSpeedMultiplier;
  static const double kSpeedMedium = 24 * AppEnvironment.kGameSpeedMultiplier;
  static const double kSpeedFast = 32 * AppEnvironment.kGameSpeedMultiplier;

  static const double kVisionRadiusSuperSmall = 8;
  static const double kVisionRadiusExtraSmall = 16;
  static const double kVisionRadiusSmall = 32;
  static const double kVisionRadiusMedium = 48;
  static const double kVisionRadiusLarge = 64;
  static const double kVisionRadiusExtraLarge = 80;
  static const double kVisionRadiusSuperLarge = 96;

  static const double kDamageSmall = 10;
  static const double kDamageMedium = 20;
  static const double kDamageLarge = 40;
  static const double kDamageExtraLarge = 60;

  static const int kAttackIntervalSmall = 300;
  static const int kAttackIntervalMedium = 800;
  // static const int kAttackIntervalLarge = 1200;
  static const int kAttackIntervalExtraLarge = 1500;
}
