import 'dart:ui' as ui show Image;

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/render/animation_creator.dart';
import 'package:dawnforge/src/core/render/sprite_loader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:flame/components.dart';

/// The render binding of one world-object host — the "scene" the factories
/// replaced (study §3.2): a Flame [PositionComponent] that draws the host's
/// sheet and mirrors its simulation state every frame. Render-only: it never
/// mutates the host; the sim never knows it exists.
base class WorldObjectRenderer extends PositionComponent {
  WorldObjectRenderer(this.host) {
    anchor = Anchor.center;
    size = Vector2(
      host.data.frameWidth.toDouble(),
      host.data.frameHeight.toDouble(),
    );
    priority = host.position.y.round(); // top-down painter's order
  }

  final WorldObject host;

  @override
  Future<void> onLoad() async {
    final data = host.data;
    assert(
      data.spritesheetPath.isNotEmpty,
      '[WorldObjectRenderer] ${data.id} has no spritesheet — step 03 '
      'guarantees one for every authored entry',
    );
    final sheet = await SpriteLoader.loadSheet(data.spritesheetPath);
    await addAll(await buildVisuals(sheet));
  }

  /// The child components that draw this host. Base: the first still frame
  /// (a plain prop, a crop at stage 0). Subclasses override for animation.
  Future<List<Component>> buildVisuals(ui.Image sheet) async => [
        SpriteComponent(
          sprite: AnimationCreator.createStill(host.data, sheet),
          size: size,
        ),
      ];

  @override
  void update(double dt) {
    super.update(dt);
    position.setValues(host.position.x, host.position.y);
    priority = host.position.y.round();
  }
}

/// Renderer of an [IActor]: plays `idle`/`walk` off the canonical rows and
/// flips horizontally with the actor's facing.
base class ActorRenderer extends WorldObjectRenderer {
  ActorRenderer(IActor super.host);

  IActor get actor => host as IActor;

  SpriteAnimationGroupComponent<String>? _animations;

  @override
  Future<List<Component>> buildVisuals(ui.Image sheet) async {
    final animations =
        AnimationCreator.createAnimations(actor.actorData, sheet);
    assert(
      animations.containsKey('idle'),
      '[ActorRenderer] ${actor.actorData.id} sheet reserves no idle row',
    );
    _animations = SpriteAnimationGroupComponent<String>(
      animations: animations,
      current: 'idle',
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    return [_animations!];
  }

  @override
  void update(double dt) {
    super.update(dt);
    final animations = _animations;
    if (animations == null) return;

    final wantsWalk =
        actor.movement.isMoving && animations.animations!.containsKey('walk');
    animations.current = wantsWalk ? 'walk' : 'idle';

    final facingLeft = actor.direction.direction == ActorDirection.left;
    animations.scale.x = facingLeft ? -1 : 1;
  }
}
