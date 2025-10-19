import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class DecorationSpriteAnimations {
  static Future<SpriteAnimation> doorDecorationOpening14() =>
      SpriteAnimation.load(
        'gameplay/environment/decorations/door_decoration_opening_14.png',
        SpriteAnimationData.sequenced(
          amount: 14,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: GameplayConstants.kTileVector2Default,
        ),
      );

  static Future<SpriteAnimation> spikeTrapDecoration10() =>
      SpriteAnimation.load(
        'gameplay/environment/decorations/spike_trap_decoration_10.png',
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: GameplayConstants.kTileVector2Default,
        ),
      );

  static Future<SpriteAnimation> torchDecoration6() => SpriteAnimation.load(
    'gameplay/environment/decorations/torch_decoration_6.png',
    SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplayConstants.kTileVector2Default,
    ),
  );
}
