import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

final class FarmActionConfig {
  static execute({required DDBasePlayerView player}) {
    // Compute the world position in front of the player where the digger acts
    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(12, 0),
      player.lastDirection,
    );

    final startPos =
        player.rectCollision.center.toVector2() +
        Vector2(attackOffset.x, attackOffset.y);

    // Define a small detection rect around the impact point
    final hitRect = Rect.fromCenter(
      center: Offset(startPos.x, startPos.y),
      width: 16,
      height: 16,
    );

    // Query for farm tile views that overlap the impact area and pick the closest one
    FarmTileView? bestTarget;
    double bestDistSq = double.infinity;

    for (final view in player.gameRef.query<FarmTileView>()) {
      final compRect = view.rectCollision;
      if (!compRect.overlaps(hitRect)) continue;

      final dx = compRect.center.dx - startPos.x;
      final dy = compRect.center.dy - startPos.y;
      final distSq = dx * dx + dy * dy;

      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        bestTarget = view;
      }
    }

    if (bestTarget != null) {
      switch (player.model.equipment) {
        case WeaponType.digger:
          FarmManager.instance.tillSoil(bestTarget.tileX, bestTarget.tileY);
          return;
        case WeaponType.wateringCan:
          FarmManager.instance.waterTile(bestTarget.tileX, bestTarget.tileY);
          return;
        case WeaponType.seed:
          FarmManager.instance.plantSeed(
            bestTarget.tileX,
            bestTarget.tileY,
            'carrot',
          ); // TODO(Kevin): remove 'carrot' dependency
          return;
        default:
          // Valid target to till soil
          return;
      }
    }
  }
}
