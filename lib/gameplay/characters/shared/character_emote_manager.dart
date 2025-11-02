import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

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
          textureSize: GameplayTileConstants.tileSizeExtraLarge,
        ),
      ),
      target: target,
      loop: false,
      size: GameplayTileConstants.tileSizeSmall,
      offset: Vector2(0, -3),
    );
  }
}
