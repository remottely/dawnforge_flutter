import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class DecorationSpriteAnimations {
  static Future<SpriteAnimation> doorDecorationOpening14() =>
      SpriteAnimation.load(
        'gameplay/environment/decorations/door_decoration_opening_14.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: 14,
          textureSize: GameplayConstants.kTileVector2Standard,
        ),
      );

  static Future<SpriteAnimation> spikeTrapDecoration10() =>
      SpriteAnimation.load(
        'gameplay/environment/decorations/spike_trap_decoration_10.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: 10,
          textureSize: GameplayConstants.kTileVector2Standard,
        ),
      );

  static Future<SpriteAnimation> torchDecoration6() => SpriteAnimation.load(
    'gameplay/environment/decorations/torch_decoration_6.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: 6,
      textureSize: GameplayConstants.kTileVector2Standard,
    ),
  );
}
