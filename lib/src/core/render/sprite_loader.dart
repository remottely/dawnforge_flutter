import 'dart:ui' show Image;

import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:flame/flame.dart';

/// The one door every pack sprite sheet comes through.
///
/// Flame's shared image cache prefixes every key with `assets/images/`. This
/// project's keys are already whole asset paths — `ContentPaths.resolveRes`
/// turns the pack's `res://data/…` into `assets/generated/<game>/…` — so the
/// prefix has to be empty, and clearing it is a permanent fact about how this
/// project addresses images rather than a step in booting a game.
///
/// It used to be a line in `DawnforgeGame.onLoad`, which made every sheet in
/// the codebase silently depend on the GAME having started first. That held
/// for renderers, which cannot exist without one. It stopped holding the
/// moment an interface widget wanted to draw an item's icon: the inventory
/// panel in a widget test asked for
/// `assets/images/assets/generated/…/t1_item_coal.png` and got told the asset
/// does not exist. Same class of bug either way — a global that one caller
/// happens to configure for all the others.
abstract final class SpriteLoader {
  /// Loads the sheet a data soul's `spritesheet` names, from the pack's own
  /// `res://` path. Cached by Flame, so the second caller for one sheet pays
  /// nothing.
  static Future<Image> loadSheet(String resPath) {
    assert(
      resPath.isNotEmpty,
      '[SpriteLoader] empty spritesheet path — step 03 guarantees every '
      'authored entry has one',
    );
    // Idempotent, and cheap: a string compare per sheet load.
    Flame.images.prefix = '';
    return Flame.images.load(
      ContentPaths.resolveRes(GameConstants.gameName, resPath),
    );
  }
}
