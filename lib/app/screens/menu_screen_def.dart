import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

class MenuScreenDef {
  MenuScreenDef._();

  static const Duration kCharacterAnimationDuration = Duration(
    milliseconds: 300,
  );

  static const Duration kCharacterAnimationInterval = Duration(seconds: 2);

  static final List<Future<SpriteAnimation>> characterSpriteAnimations = [
    UISpriteAnimationsDef.loadAnimationFarmerPlayerIdleDown,
    UISpriteAnimationsDef.loadAnimationCutePlayerIdleRight,
    UISpriteAnimationsDef.loadAnimationSunnyPlayerIdleRight,
    UISpriteAnimationsDef.loadAnimationKnightPlayerIdleRight,
    UISpriteAnimationsDef.loadAnimationWizardNpcIdleLeft(),
    UISpriteAnimationsDef.loadAnimationKidNpcIdleLeft(),
    UISpriteAnimationsDef.loadAnimationGoblinEnemyIdleRight(),
    UISpriteAnimationsDef.loadAnimationImpEnemyIdleRight(),
    UISpriteAnimationsDef.loadAnimationMiniBossEnemyIdleRight(),
    UISpriteAnimationsDef.loadAnimationBossEnemyIdleRight(),
  ];

  static final Future<Sprite> keyboardSprite = Sprite.load(
    'ui/input/keyboard_tip.png',
  );

  static const String kKevinKoboriUrl = 'https://github.com/kevinkobori';
  static const String kBonfireUrl = 'https://pub.dev/packages/bonfire';
}
