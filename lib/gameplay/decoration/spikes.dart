import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';
import 'package:darkness_dungeon/gameplay/utils/game_sprite_sheet.dart';

class Spikes extends GameDecoration with Sensor<Knight> {
  final double damageAmount;
  Knight? contactedPlayer;

  Spikes(Vector2 position, {this.damageAmount = 60})
      : super.withAnimation(
          animation: GameSpriteSheet.spikes(),
          position: position,
          size: Vector2(tileSize, tileSize),
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
