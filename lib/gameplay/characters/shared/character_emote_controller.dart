import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

class CharacterEmoteController {
  static const kExclamationEmoteAssetPath =
      'gameplay/characters/emotes/exclamation_emote_8.png';

  static const kQuestionEmoteAssetPath =
      'gameplay/characters/emotes/question_emote_8.png';

  static final Vector2 _kEmoteOffset = Vector2(0, -3);

  static void displayEmoteAboveCharacter({
    required BonfireGameInterface gameRef,
    required GameComponent target,
    required String assetPath,
  }) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          assetPath,
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 8,
            textureSize: GameplayConstants.kTileSizeExtraLarge,
          ),
        ),
        target: target,
        loop: false,
        size: GameplayConstants.kTileSizeSmall,
        offset: _kEmoteOffset,
      ),
    );
  }
}
