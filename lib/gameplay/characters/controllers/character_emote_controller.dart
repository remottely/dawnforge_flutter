import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class CharacterEmoteController {
  static const String kExclamationEmoteAssetPath =
      'gameplay/characters/emotes/exclamation_emote_8.png';
  static const String kQuestionEmoteAssetPath =
      'gameplay/characters/emotes/question_emote_8.png';
  static Vector2 get kEmoteOffset => Vector2(0, -3);

  static displayEmoteAboveCharacter({
    required BonfireGameInterface gameRef,
    required GameComponent target,
    required String assetPath,
  }) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          assetPath,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplayConstants.kTileVector2ExtraLarge,
          ),
        ),
        target: target,
        loop: false,
        size: GameplayConstants.kTileVector2Small,
        offset: kEmoteOffset,
      ),
    );
  }
}
