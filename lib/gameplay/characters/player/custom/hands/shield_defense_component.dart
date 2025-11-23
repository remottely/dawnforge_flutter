import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

/// Componente visual do escudo durante a defesa
///
/// Mostra uma animação 16x16 na frente do player enquanto está defendendo.
/// A animação bloqueia ataques e fornece feedback visual da defesa ativa.
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
      developer.log('[ShieldDefenseComponent] Carregando animação de defesa');

      // Criar animação do escudo (16x16) diretamente
      final loadShieldDefenseRight12 = await SpriteAnimation.load(
        'gameplay/characters/player/shield_defense_right_12.png',
        SpriteAnimationConfig.createStandardData(
          amount: 12,
          textureSize: TileConstants.tileSizeSuperLarge,
        ),
      );

      developer.log('[ShieldDefenseComponent] Animação carregada com sucesso');

      _shieldAnimation = SpriteAnimationComponent(
        animation: loadShieldDefenseRight12,
        size: TileConstants.tileSizeStandard,
        anchor: Anchor.center,
      );

      // Definir prioridade alta para renderizar na frente do player
      _shieldAnimation!.priority = 1000;

      // Se já foi ativado antes da animação carregar, começar visível
      _shieldAnimation!.opacity = _isActive ? 1 : 0;

      // Adicionar diretamente ao gameRef ao invés de como filho deste componente
      _player.gameRef.add(_shieldAnimation!);

      developer.log(
        '[ShieldDefenseComponent] Componente criado. Opacity: ${_shieldAnimation!.opacity}, IsActive: $_isActive',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[ShieldDefenseComponent] ERRO ao carregar animação: $e\n$stackTrace',
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isActive && _shieldAnimation != null) {
      // Posicionar o escudo na frente do player
      _shieldAnimation!.position = _player.center;
    }
  }

  /// Ativa o modo de defesa
  void activate() {
    developer.log(
      '[ShieldDefenseComponent] Ativando defesa. Animação null? ${_shieldAnimation == null}',
    );
    _isActive = true;
    if (_shieldAnimation != null) {
      _shieldAnimation!.opacity = 1;
      developer.log(
        '[ShieldDefenseComponent] Animação opacity = 1. Posição: ${_shieldAnimation!.position}',
      );
    }
  }

  /// Desativa o modo de defesa
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
