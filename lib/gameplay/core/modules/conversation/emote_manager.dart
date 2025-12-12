import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

class EmoteManager {
  static const String kExclamationEmoteAsset =
      'gameplay/characters/emotes/exclamation_emote_8.png';
  static const String kQuestionEmoteAsset =
      'gameplay/characters/emotes/question_emote_8.png';

  static AnimatedFollowerGameObject displayEmoteAboveCharacter({
    required String asset,
    required int amount,
    required GameComponent target,
  }) {
    return AnimatedFollowerGameObject(
      animation: SpriteAnimation.load(
        asset,
        SpriteAnimationConfig.createStandardData(
          amount: amount,
          textureSize: TileConstants.tileSizeExtraLarge,
        ),
      ),
      target: target,
      loop: false,
      size: TileConstants.tileSizeSmall,
      offset: Vector2(0, -3),
    );
  }

  static final Vector2 _emoteTextureSize = TileConstants.tileSizeExtraLarge;

  static Future<SpriteAnimation> _loadAnimationEmoteDecoration() =>
      SpriteAnimation.load(
        EmoteManager.kExclamationEmoteAsset,
        SpriteAnimationConfig.createStandardData(
          amount: 8,
          textureSize: _emoteTextureSize,
        ),
      );

  static AnimatedGameObject getDecorationAnimatedObject(Vector2 size) =>
      AnimatedGameObject(
        animation: EmoteManager._loadAnimationEmoteDecoration(),
        size: size,
        position: Vector2(size.x / 2, -size.y + 4),
        loop: false,
      );
}
