import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/environment_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';

class Spikes extends GameDecoration with Sensor<Knight> {
  final double damageAmount;
  Knight? contactedPlayer;

  Spikes(Vector2 position, {this.damageAmount = 60})
    : super.withAnimation(
        animation: EnvironmentSpriteSheet.spikes(),
        position: position,
        size: Vector2(
          GameplayConstants.kCurrentTileSize,
          GameplayConstants.kCurrentTileSize,
        ),
      );

  @override
  void onContact(Knight collision) {
    contactedPlayer = collision;
  }

  @override
  void update(double dt) {
    if (isAnimationLastFrame) {
      contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, damageAmount, 0);
    }
    super.update(dt);
  }

  @override
  int get priority => LayerPriority.getComponentPriority(1);

  @override
  void onContactExit(Knight component) {
    contactedPlayer = null;
  }
}
