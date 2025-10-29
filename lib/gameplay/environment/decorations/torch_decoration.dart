import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/i_dd_game_decoration.dart';

abstract class _TorchDecorationConfig {
  static final _fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final _fComponentSize = _fTextureSize;

  static Future<SpriteAnimation> _loadAnimation() => SpriteAnimation.load(
    'gameplay/environment/decorations/torch_decoration_6.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: _fTextureSize,
    ),
  );

  static final _fLightingConfig = LightingConfig(
    radius: GameplayTileConfig.kTileDimensionExtraLarge,
    blurBorder: GameplayTileConfig.kTileDimensionStandard,
    pulseVariation: 0.1,
    color: CharacterParticlesAnimations.fLightingConfigColor,
  );
}

class TorchDecorationView extends DDGameDecoration {
  final bool _isExtinguished;

  TorchDecorationView({required super.position})
    : _isExtinguished = false,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadAnimation(),
        size: _TorchDecorationConfig._fComponentSize,
      ) {
    _setupLighting();
  }

  TorchDecorationView.empty({required super.position})
    : _isExtinguished = true,
      super.withAnimation(
        animation: _TorchDecorationConfig._loadAnimation(),
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
