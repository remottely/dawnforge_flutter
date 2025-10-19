import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class CharacterEmote {
  static const String kExclamationEmoteAssetPath =
      'emotes/exclamation_emote_8.png';
  static const String kQuestionEmoteAssetPath = 'emotes/question_emote_8.png';

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
            textureSize: GameplayConstants.kLargeVectorSize,
          ),
        ),
        target: target,
        loop: false,
        size: GameplayConstants.kSmallVectorSize,
        offset: GameplayConstants.kEmoteOffset,
      ),
    );
  }
}
