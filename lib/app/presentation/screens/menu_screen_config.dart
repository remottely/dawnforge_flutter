import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

class MenuScreenConfig {
  MenuScreenConfig._();

  static const Duration kCharacterAnimationDuration = Duration(
    milliseconds: 300,
  );
  static const Duration kCharacterAnimationInterval = Duration(seconds: 2);
  static final List<Future<SpriteAnimation>> loadCharacterSpriteAnimations = [
    UISpriteAnimationsConfig.loadKnightPlayerIdleRight6(),
    UISpriteAnimationsConfig.loadGoblinEnemyIdleRight6(),
    UISpriteAnimationsConfig.loadImpEnemyIdleRight4(),
    UISpriteAnimationsConfig.loadDungeonMiniBossEnemyIdleRight4(),
    UISpriteAnimationsConfig.loadDungeonBossEnemyIdleRight4(),
  ];

  static final fLoadKeyboardSprite = Sprite.load(
    'ui/controls/keyboard_tip.png',
  );

  static const String kKevinKoboriUrl = 'https://github.com/kevinkobori';
  static const String kBonfireUrl = 'https://pub.dev/packages/bonfire';
}
