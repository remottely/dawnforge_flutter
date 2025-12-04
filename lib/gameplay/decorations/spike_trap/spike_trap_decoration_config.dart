import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/decorations/decoration_constants.dart';

final class SpikeTrapDecorationConfig {
  SpikeTrapDecorationConfig._();

  static const double kDamageAmount = DecorationConstants.kStatsAmountMedium;
  static const int kPriority = 1;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<SpriteAnimation> loadSpriteAnimation() => SpriteAnimation.load(
    'gameplay/decorations/spike_trap_decoration_10.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: _textureSize,
    ),
  );
}
