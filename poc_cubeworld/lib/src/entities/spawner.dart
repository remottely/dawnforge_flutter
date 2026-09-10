import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import '../core/ivec3.dart';
import '../core/species.dart';
import '../game/game.dart';
import '../player/player.dart';
import '../world/voxel_world.dart';
import 'mob.dart';

/// Keeps a population of creatures around the player: passive by day, hostile
/// at night and underground; despawns what wandered far.
class Spawner {
  Spawner(this.world, this.player, this.main);

  static const int cap = 26;
  static const double minDist = 18.0;
  static const double maxDist = 44.0;

  final VoxelWorld world;
  final Player player;
  final Game main;
  double _timer = 0.0;

  void update(double dt) {
    _timer -= dt;
    if (_timer > 0.0) return;
    _timer = 1.2;
    for (final m in main.mobs) {
      if ((m.position - player.position).length > 96.0) m.removed = true;
    }
    if (main.mobs.length >= cap) return;
    _trySpawn();
  }

  void _trySpawn() {
    final rng = main.random;
    final a = rng.nextDouble() * math.pi * 2;
    final d = minDist + rng.nextDouble() * (maxDist - minDist);
    final x = (player.position.x + math.cos(a) * d).toInt();
    final z = (player.position.z + math.sin(a) * d).toInt();
    if (!world.chunks.containsKey(VoxelWorld.chunkOfXZ(x, z))) return;
    final surface = world.groundHeight(x, z);
    var cave = false;
    var y = surface;
    // Underground spawn when the player is underground.
    final playerSurface = world.surfaceHeight(player.position.x.toInt(), player.position.z.toInt());
    if (player.position.y < playerSurface - 6 && rng.nextDouble() < 0.7) {
      final py = player.position.y.toInt();
      for (var i = 0; i < 12; i++) {
        final ty = py + rng.nextInt(13) - 6;
        if (ty < 2) continue;
        final cell = IVec3(x, ty, z);
        if (!world.isSolid(cell) && !world.isSolid(cell + IVec3.up) && world.isSolid(cell + IVec3.down)) {
          y = ty;
          cave = true;
          break;
        }
      }
      if (!cave) return;
    }
    if (y >= VoxelWorld.sizeY - 3 || y <= 1) return;
    if (world.isLiquid(IVec3(x, y, z)) || world.isLiquid(IVec3(x, y - 1, z))) return;
    final biome = world.biomeAt(x, z);
    final night = main.isNight;
    final candidates = Species.candidates(biome, night, cave, rng);
    if (candidates.isEmpty) return;
    var total = 0.0;
    for (final c in candidates) {
      total += c.weight;
    }
    var pick = rng.nextDouble() * total;
    var chosen = candidates[0];
    for (final c in candidates) {
      pick -= c.weight;
      if (pick <= 0.0) {
        chosen = c;
        break;
      }
    }
    final group = chosen.hostile ? 1 : 1 + rng.nextInt(3);
    for (var i = 0; i < group; i++) {
      final mob = Mob();
      mob.setupMob(world, main, player, chosen);
      mob.position = Vector3(x + 0.5 + rng.nextDouble() * 3.0 - 1.5, y + 0.1, z + 0.5 + rng.nextDouble() * 3.0 - 1.5);
      if (chosen.hostile) mob.scaleToLevel(player.level + rng.nextInt(3) - 1 + (cave ? 2 : 0));
      main.addMob(mob);
    }
  }
}
