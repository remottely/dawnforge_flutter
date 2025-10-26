import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

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
        GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
          amount: 8,
          textureSize: GameplayConstants.fTileSizeExtraLarge,
        ),
      ),
      target: target,
      loop: false,
      size: GameplayConstants.fTileSizeSmall,
      offset: Vector2(0, -3),
    );
  }
}
