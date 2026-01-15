import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/game/tile_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

class EmoteManager {
  static const String kExclamationEmoteAsset =
      'gameplay/characters/emotes/exclamation_emote_8.png';
  static const String kQuestionEmoteAsset =
      'gameplay/characters/emotes/question_emote_8.png';

  static const int kExclamationEmoteAmount = 8;
  static const int kQuestionEmoteAmount = 8;

  static final Vector2 _emoteTextureSize = TileConstants.tileSizeExtraLarge;

  static Future<SpriteAnimation> loadExclamationEmote() =>
      _loadAnimationEmoteDecoration(
        asset: kExclamationEmoteAsset,
        amount: kExclamationEmoteAmount,
      );

  static Future<SpriteAnimation> loadQuestionEmote() =>
      _loadAnimationEmoteDecoration(
        asset: kQuestionEmoteAsset,
        amount: kQuestionEmoteAmount,
      );

  static Future<SpriteAnimation> _loadAnimationEmoteDecoration({
    required String asset,
    required int amount,
  }) => SpriteAnimation.load(
    asset,
    SpriteAnimationConfigHelper.createStandardData(
      amount: amount,
      textureSize: _emoteTextureSize,
    ),
  );

  static AnimatedFollowerGameObject displayEmoteAboveCharacter({
    required FutureOr<SpriteAnimation> animation,
    required GameComponent target,
  }) {
    return AnimatedFollowerGameObject(
      animation: animation,
      target: target,
      loop: false,
      size: TileConstants.tileSizeSmall,
      offset: Vector2(0, -3),
    );
  }

  static AnimatedGameObject displayEmoteAboveDecoration(Vector2 size) =>
      AnimatedGameObject(
        animation: loadExclamationEmote(),
        size: size,
        position: Vector2(size.x / 2, -size.y + 4),
        loop: false,
      );
}
