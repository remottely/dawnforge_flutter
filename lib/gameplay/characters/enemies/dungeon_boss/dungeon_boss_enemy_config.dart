import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';

abstract class DungeonBossEnemyConfig {
  static const double attackDamage = 40.0;
  static const double life = 200.0;
  static const double speed = GameplayConstants.kCharacterSpeedSlow;
  static final Vector2 spriteSize = Vector2(
    GameplayConstants.kTileDimensionLarge,
    GameplayConstants.kTileDimensionStandard * 1.7,
  );
  static final Vector2 hitboxSize = Vector2(14, 16);
  static final Vector2 hitboxPosition = Vector2(5, 11);
  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;
  static double get visionRadiusUltraLarge =>
      GameplayConstants.kVisionRadiusUltraLarge;
  static double get visionRadiusLarge => GameplayConstants.kVisionRadiusLarge;
  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));

  /// Creates the sequence of Say objects for the conversation
  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.kidRightDialog('talk_kid_1'),
      GameplayDialogConstants.bossLeftDialog('talk_boss_1'),
      GameplayDialogConstants.playerLeftDialog('talk_player_3'),
      GameplayDialogConstants.bossRightDialog('talk_boss_2'),
    ];
  }
}
