import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/game/tile_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

class ShieldDefenseComponent extends GameComponent {
  final SimplePlayer _player;
  SpriteAnimationComponent? _shieldAnimation;

  bool _isActive = false;

  ShieldDefenseComponent({required SimplePlayer player}) : _player = player;

  bool get isActive => _isActive;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    try {
      GameLogger.info('[ShieldDefenseComponent] Carregando animação de defesa');

      final loadAnimationRight = await SpriteAnimation.load(
        'gameplay/characters/player/shield_defense_right_12.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 12,
          textureSize: TileConstants.tileSizeSuperLarge,
        ),
      );

      GameLogger.info(
        '[ShieldDefenseComponent] Animação carregada com sucesso',
      );

      _shieldAnimation = SpriteAnimationComponent(
        animation: loadAnimationRight,
        size: TileConstants.tileSizeStandard,
        anchor: Anchor.center,
      );

      _shieldAnimation!.priority = 1000;

      _shieldAnimation!.opacity = _isActive ? 1 : 0;

      _player.gameRef.add(_shieldAnimation!);

      GameLogger.info(
        '[ShieldDefenseComponent] Componente criado. Opacity: ${_shieldAnimation!.opacity}, IsActive: $_isActive',
      );
    } catch (e, stackTrace) {
      GameLogger.error(
        '[ShieldDefenseComponent] ERRO ao carregar animação: $e\n$stackTrace',
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isActive && _shieldAnimation != null) {
      _shieldAnimation!.position = _player.center;
    }
  }

  void activate() {
    GameLogger.info(
      '[ShieldDefenseComponent] Ativando defesa. Animação null? ${_shieldAnimation == null}',
    );
    _isActive = true;
    if (_shieldAnimation != null) {
      _shieldAnimation!.opacity = 1;
      GameLogger.info(
        '[ShieldDefenseComponent] Animação opacity = 1. Posição: ${_shieldAnimation!.position}',
      );
    }
  }

  void deactivate() {
    _isActive = false;
    if (_shieldAnimation != null) {
      _shieldAnimation!.opacity = 0;
    }
  }

  @override
  void onRemove() {
    _shieldAnimation?.removeFromParent();
    super.onRemove();
  }
}
