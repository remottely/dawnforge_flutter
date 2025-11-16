import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';

/// Componente visual do escudo durante a defesa
///
/// Mostra um sprite 16x16 na frente do player enquanto está defendendo.
/// O sprite bloqueia ataques e fornece feedback visual da defesa ativa.
class ShieldDefenseComponent extends GameComponent {
  final SimplePlayer _player;
  final String _shieldSpritePath;
  SpriteComponent? _shieldSprite;

  bool _isActive = false;

  ShieldDefenseComponent({
    required SimplePlayer player,
    required String shieldSpritePath,
  }) : _player = player,
       _shieldSpritePath = shieldSpritePath;

  bool get isActive => _isActive;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    try {
      developer.log(
        '[ShieldDefenseComponent] Carregando sprite: $_shieldSpritePath',
      );

      // Criar sprite do escudo (16x16)
      final sprite = await Sprite.load(_shieldSpritePath);

      developer.log(
        '[ShieldDefenseComponent] Sprite carregado com sucesso: ${sprite.srcSize}',
      );

      _shieldSprite = SpriteComponent(
        sprite: sprite,
        size: Vector2(
          16,
          16,
        ), // Aumentando o tamanho para 32x32 para ficar mais visível
        anchor: Anchor.center,
      );

      // Se já foi ativado antes do sprite carregar, começar visível
      _shieldSprite!.opacity = _isActive ? 1 : 0;
      await add(_shieldSprite!);

      developer.log(
        '[ShieldDefenseComponent] Componente criado e adicionado. Opacity: ${_shieldSprite!.opacity}',
      );
    } catch (e) {
      developer.log('[ShieldDefenseComponent] ERRO ao carregar sprite: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isActive && _shieldSprite != null) {
      // Posicionar o escudo na frente do player baseado na direção
      // final direction = _player.lastDirection;
      // Vector2 offset;

      // switch (direction) {
      //   case Direction.up:
      //     offset = Vector2(0, -20);
      //     break;
      //   case Direction.down:
      //     offset = Vector2(0, 20);
      //     break;
      //   case Direction.left:
      //     offset = Vector2(-20, 0);
      //     break;
      //   case Direction.right:
      //     offset = Vector2(20, 0);
      //     break;
      //   case Direction.upLeft:
      //     offset = Vector2(-14, -14);
      //     break;
      //   case Direction.upRight:
      //     offset = Vector2(14, -14);
      //     break;
      //   case Direction.downLeft:
      //     offset = Vector2(-14, 14);
      //     break;
      //   case Direction.downRight:
      //     offset = Vector2(14, 14);
      //     break;
      // }

      // _shieldSprite!.position = _player.center + offset;
      _shieldSprite!.position = _player.center;
    }
  }

  /// Ativa o modo de defesa
  void activate() {
    developer.log(
      '[ShieldDefenseComponent] Ativando defesa. Sprite null? ${_shieldSprite == null}',
    );
    _isActive = true;
    if (_shieldSprite != null) {
      _shieldSprite!.opacity = 1;
      developer.log(
        '[ShieldDefenseComponent] Sprite opacity definida para 1. Posição: ${_shieldSprite!.position}',
      );
    }
  }

  /// Desativa o modo de defesa
  void deactivate() {
    _isActive = false;
    if (_shieldSprite != null) {
      _shieldSprite!.opacity = 0;
    }
  }

  @override
  void onRemove() {
    _shieldSprite?.removeFromParent();
    super.onRemove();
  }
}
