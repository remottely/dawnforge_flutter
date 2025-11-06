import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/pickaxe/knight_pickaxe_config.dart';

enum KnightPickaxeAttackPhase { windUp, strike, recover }

class KnightPickaxeModel {
  bool isAttacking = false;
  bool facingRight = true;
  double elapsedSeconds = 0;
  Duration attackDuration = KnightPickaxeConfig.defaultAttackDuration;
  KnightPickaxeAttackPhase currentPhase = KnightPickaxeAttackPhase.windUp;
  double currentRotationAngle = 0;

  Vector2 staticOffset = KnightPickaxeConfig.defaultStaticOffset;
  Vector2 rightOffset = KnightPickaxeConfig.defaultRightOffset;
  Vector2 leftOffset = KnightPickaxeConfig.defaultLeftOffset;

  Vector2 get directionOffset => facingRight ? rightOffset : leftOffset;

  void resetAnimationState() {
    isAttacking = false;
    elapsedSeconds = 0;
    currentPhase = KnightPickaxeAttackPhase.windUp;
    currentRotationAngle = 0;
  }

  void updateAttackDuration(Duration newDuration) {
    attackDuration = newDuration;
  }

  double get attackDurationSeconds => attackDuration.inMilliseconds / 1000.0;
}
