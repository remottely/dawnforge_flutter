import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';

class CharacterEmoteController {
  static const kExclamationEmoteAsset =
      'gameplay/characters/emotes/exclamation_emote_8.png';

  static const kQuestionEmoteAsset =
      'gameplay/characters/emotes/question_emote_8.png';

  static AnimatedFollowerGameObject displayEmoteAboveCharacter({
    required String asset,
    required GameComponent target,
  }) {
    return AnimatedFollowerGameObject(
      animation: SpriteAnimation.load(
        asset,
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 8,
          textureSize: GameplayTileConfig.fTileSizeExtraLarge,
        ),
      ),
      target: target,
      loop: false,
      size: GameplayTileConfig.fTileSizeSmall,
      offset: Vector2(0, -3),
    );
  }
}
