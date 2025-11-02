import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';

class CharacterEmoteManager {
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
        GameplaySpriteAnimationConfig.createStandardData(
          amount: amount,
          textureSize: GameplayTileConfig.tileSizeExtraLarge,
        ),
      ),
      target: target,
      loop: false,
      size: GameplayTileConfig.tileSizeSmall,
      offset: Vector2(0, -3),
    );
  }
}
