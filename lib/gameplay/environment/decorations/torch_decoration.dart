import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/framework/dd_game_decoration.dart';

final class _TorchDecorationConfig {
  _TorchDecorationConfig._();

  static final Vector2 _fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final Vector2 _fComponentSize = _fTextureSize;

  static Future<SpriteAnimation> _loadSpriteAnimation() => SpriteAnimation.load(
    'gameplay/environment/decorations/torch_decoration_6.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: _fTextureSize,
    ),
  );

  static final LightingConfig _fLightingConfig = LightingConfig(
    radius: GameplayTileConfig.kTileDimensionExtraLarge,
    blurBorder: GameplayTileConfig.kTileDimensionStandard,
    pulseVariation: 0.1,
    color: CharacterFxParticlesAnimationsConfig.fLightingConfigColor,
  );
}

class TorchDecorationView extends DDGameDecoration {
  final bool _isExtinguished;

  TorchDecorationView({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadSpriteAnimation(),
        size: _TorchDecorationConfig._fComponentSize,
      ) {
    _setupLighting();
  }

  TorchDecorationView.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadSpriteAnimation(),
        size: _TorchDecorationConfig._fComponentSize,
      ) {
    _setupLighting();
  }

  @override
  void render(Canvas canvas) {
    if (!_isExtinguished) {
      super.render(canvas);
    }
  }

  void _setupLighting() {
    setupLighting(_TorchDecorationConfig._fLightingConfig);
  }
}
