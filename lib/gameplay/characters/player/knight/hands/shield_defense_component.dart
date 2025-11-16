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

    // Criar sprite do escudo (16x16)
    final sprite = await Sprite.load(_shieldSpritePath);
    _shieldSprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(16, 16),
      anchor: Anchor.center,
    );

    // Inicialmente invisível
    _shieldSprite!.opacity = 0;
    add(_shieldSprite!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isActive && _shieldSprite != null) {
      // Posicionar o escudo na frente do player baseado na direção
      final direction = _player.lastDirection;
      Vector2 offset;

      switch (direction) {
        case Direction.up:
          offset = Vector2(0, -20);
          break;
        case Direction.down:
          offset = Vector2(0, 20);
          break;
        case Direction.left:
          offset = Vector2(-20, 0);
          break;
        case Direction.right:
          offset = Vector2(20, 0);
          break;
        case Direction.upLeft:
          offset = Vector2(-14, -14);
          break;
        case Direction.upRight:
          offset = Vector2(14, -14);
          break;
        case Direction.downLeft:
          offset = Vector2(-14, 14);
          break;
        case Direction.downRight:
          offset = Vector2(14, 14);
          break;
      }

      _shieldSprite!.position = _player.center + offset;
    }
  }

  /// Ativa o modo de defesa
  void activate() {
    _isActive = true;
    if (_shieldSprite != null) {
      _shieldSprite!.opacity = 1;
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
