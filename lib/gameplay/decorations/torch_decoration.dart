import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

final class _TorchDecorationConfig {
  _TorchDecorationConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<SpriteAnimation> _loadSpriteAnimation() => SpriteAnimation.load(
    'gameplay/decorations/torch_decoration_6.png',
    SpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: _textureSize,
    ),
  );

  static final LightingConfig _lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionExtraLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.torchLighting,
  );
}

class TorchDecorationView extends DDDecoration {
  final bool _isExtinguished;

  TorchDecorationView({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadSpriteAnimation(),
        size: _TorchDecorationConfig._componentSize,
      ) {
    setupLighting(_TorchDecorationConfig._lightingConfig);
  }

  TorchDecorationView.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadSpriteAnimation(),
        size: _TorchDecorationConfig._componentSize,
      );

  @override
  void render(Canvas canvas) {
    if (!_isExtinguished) {
      super.render(canvas);
    }
  }
}
