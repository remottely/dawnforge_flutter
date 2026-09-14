import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/items.dart';
import '../core/ivec3.dart';
import '../game/inventory.dart';
import '../game/net.dart';
import '../game/sfx.dart';
import '../player/player.dart';
import '../ui/hud.dart';
import '../world/voxel_world.dart';
import 'target.dart';
import 'voxel_body.dart';
import 'voxel_mesh_builder.dart';

/// An item lying in the world: bobs, spins, is pulled to a near player and
/// picked up. Stage 21b: the host owns every drop. A [replica] (client side)
/// only falls and spins; the host also pulls a drop to a peer's puppet and
/// hands the item over through the network.
class ItemDrop extends VoxelBody {
  String itemId = '';
  int count = 1;
  int bonus = 0;
  double _age = 0.0;
  final Node _visual = Node();
  late Player _player;
  double _pickupDelay = 0.6;
  bool replica = false;
  int netId = 0;

  void setupDrop(VoxelWorld w, String id, int n, Player player, [double delay = 0.6]) {
    setup(w, 0.15, 0.3);
    itemId = id;
    count = n;
    _player = player;
    _pickupDelay = delay;
    if (Items.isBlock(id)) {
      _visual.add(VoxelMeshBuilder.blockCube(VoxelMeshBuilder.blockColor(Items.blockOf(id)), 0.3));
    } else {
      final v = <IVec3, Vector3>{};
      VoxelMeshBuilder.box(v, const IVec3(0, 0, 0), const IVec3(2, 2, 2), VoxelMeshBuilder.itemColor(id), 0.08);
      _visual.add(VoxelMeshBuilder.meshNode(v, 0.09, Vector3(1.5, 1.5, 1.5)));
    }
    _visual.position = Vector3(0, 0.2, 0);
    node.add(_visual);
  }

  /// The local player or, on the host, a peer's puppet, whichever is nearest
  /// within 3 m. RemotePlayer is reached through [Target] so this file never
  /// names it: ItemDrop -> RemotePlayer -> Player would close an import cycle.
  Target? _nearestBody() {
    Target? best = _player.isDead ? null : _player;
    var bestD = best == null ? double.infinity : (_player.position - position).length;
    if (Net.instance.isHost) {
      for (final b in Net.instance.puppetBodies()) {
        final d = (b.position - position).length;
        if (d < bestD) {
          bestD = d;
          best = b;
        }
      }
    }
    return bestD < 3.0 ? best : null;
  }

  void update(double dt) {
    // Stage 24: a restored drop waits for its chunk (unloaded reads as air).
    if (!world.isLoaded(IVec3.floor(position))) return;
    _age += dt;
    if (_age > 300.0) {
      removed = true;
      return;
    }
    applyGravity(dt);
    velocity.x = lerpd(velocity.x, 0.0, dt * 4.0);
    velocity.z = lerpd(velocity.z, 0.0, dt * 4.0);
    if (!replica && _age > _pickupDelay) {
      final body = _nearestBody();
      if (body != null) {
        final toPlayer = (body.position + Vector3(0, 0.9, 0)) - centre();
        final d = toPlayer.length;
        if (d < 1.0) {
          _pickUpBy(body);
          return;
        }
        if (d < 3.0) {
          velocity += toPlayer.normalized() * dt * 40.0;
          if (velocity.length > 9.0) velocity = velocity.normalized() * 9.0;
        }
      }
    }
    move(dt);
    syncNode();
    _visual.rotation = Quaternion.axisAngle(Vector3(0, 1, 0), _age * 2.0);
    _visual.position = Vector3(0, 0.2 + math.sin(_age * 3.0) * 0.06, 0);
  }

  /// Stage 24: what the save keeps of a drop.
  Map<String, Object> toJson() => {
        'item': itemId,
        'count': count,
        'bonus': bonus,
        'pos': [position.x, position.y, position.z],
      };

  void _pickUpBy(Target body) {
    if (identical(body, _player)) {
      _pickUp();
      return;
    }
    // A puppet: the peer's own inventory takes it (assumed to fit; the drop is
    // gone either way).
    Net.instance.givePeer(body.peerId, itemId, count, bonus);
    removed = true;
  }

  void _pickUp() {
    if (bonus > 0) {
      if (_player.inventory.addStack(ItemStack(itemId, 1, bonus: bonus))) {
        _player.notify('+ ${Hud.itemLabel(itemId, bonus)}');
        Sfx.play('pickup', -8.0);
        removed = true;
      }
      return;
    }
    final left = _player.pickUp(itemId, count);
    if (left <= 0) {
      removed = true;
    } else {
      count = left;
      _age = 0.0;
      _pickupDelay = 2.0;
    }
  }

  static bool isBlockDrop(String id) => Items.isBlock(id) && Blocks.has(id);
}
