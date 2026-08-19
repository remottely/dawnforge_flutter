import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/decorations/decoration_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class SpikeTrapDecorationDef {
  SpikeTrapDecorationDef._();

  static const double kDamageAmount = DecorationConstants.kStatsAmountMedium;
  static const int kPriority = 1;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<SpriteAnimation> loadAnimation() => SpriteAnimation.load(
    'gameplay/decorations/spike_trap_decoration_10.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 10,
      textureSize: _textureSize,
    ),
  );
}
