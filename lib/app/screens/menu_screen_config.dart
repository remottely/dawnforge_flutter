// import 'package:bonfire/bonfire.dart';
// import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_config.dart';

// class MenuScreenConfig {
//   MenuScreenConfig._();

//   static const Duration kCharacterAnimationDuration = Duration(
//     milliseconds: 300,
//   );
//   static const Duration kCharacterAnimationInterval = Duration(seconds: 2);
//   static final List<Future<SpriteAnimation>> characterSpriteAnimations = [
//     UISpriteAnimationsConfig.loadAnimationKnightPlayerIdleRight(), // TODO(Kevin): delete this line
//     UISpriteAnimationsConfig.loadAnimationCutePlayerIdleRight(),
//     UISpriteAnimationsConfig.loadAnimationGoblinEnemyIdleRight(),
//     UISpriteAnimationsConfig.loadAnimationImpEnemyIdleRight(),
//     UISpriteAnimationsConfig.loadAnimationMiniBossEnemyIdleRight(),
//     UISpriteAnimationsConfig.loadAnimationBossEnemyIdleRight(),
//   ];

//   static final Future<Sprite> keyboardSprite = Sprite.load(
//     'ui/input/keyboard_tip.png',
//   );

//   static const String kKevinKoboriUrl = 'https://github.com/kevinkobori';
//   static const String kBonfireUrl = 'https://pub.dev/packages/bonfire';
// }

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_config.dart';

class MenuScreenConfig {
  MenuScreenConfig._();

  static const Duration kCharacterAnimationDuration = Duration(
    milliseconds: 300,
  );

  static const Duration kCharacterAnimationInterval = Duration(seconds: 2);

  static final List<Future<SpriteAnimation>> characterSpriteAnimations = [
    UISpriteAnimationsConfig.loadAnimationCutePlayerIdleRight(),
    UISpriteAnimationsConfig.loadAnimationSunnyPlayerIdleRight(),
    UISpriteAnimationsConfig.loadAnimationKnightPlayerIdleRight(),
    UISpriteAnimationsConfig.loadAnimationGoblinEnemyIdleRight(),
    UISpriteAnimationsConfig.loadAnimationImpEnemyIdleRight(),
    UISpriteAnimationsConfig.loadAnimationMiniBossEnemyIdleRight(),
    UISpriteAnimationsConfig.loadAnimationBossEnemyIdleRight(),
  ];

  static final Future<Sprite> keyboardSprite = Sprite.load(
    'ui/input/keyboard_tip.png',
  );

  static const String kKevinKoboriUrl = 'https://github.com/kevinkobori';
  static const String kBonfireUrl = 'https://pub.dev/packages/bonfire';
}
