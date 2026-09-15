import 'dart:ui' as ui show Image;

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_crop.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/domain/farming/crop_rules.dart';
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

/// Renderer of a [PropCrop]: the still frame of the stage it is AT, off a
/// sheet laid out as variant blocks of `realStageCount` rows each (the
/// spec's `setup_crop_atlas`). Which block is a visual-only choice, the
/// spec's "random from all rows": derived from the host's position so two
/// palms side by side differ and the same palm looks the same every boot.
///
/// Until this class every crop drew row 0 — a PLANTED seedling — whatever
/// stage it was at, because the base renderer knows no stage.
base class CropRenderer extends WorldObjectRenderer {
  CropRenderer(PropCrop super.host);

  PropCrop get crop => host as PropCrop;

  @override
  Future<List<Component>> buildVisuals(ui.Image sheet) async {
    final data = crop.cropData;
    final rows = sheet.height ~/ data.frameHeight;
    final stageCount = data.realStageCount;
    assert(
      rows >= stageCount,
      '[CropRenderer] ${data.id}: the sheet has $rows rows for $stageCount '
      'stages — step 02 cut fewer frames than the crop has stages',
    );
    final blocks = rows ~/ stageCount;
    final block = (host.position.x.round() * 31 + host.position.y.round() * 17)
            .abs() %
        blocks;
    return [
      SpriteComponent(
        sprite: AnimationCreator.createStill(
          data,
          sheet,
          rowIndex: CropRules.calculateTargetFrame(
            block,
            stageCount,
            data.currentStage,
          ),
        ),
        size: size,
      ),
    ];
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
