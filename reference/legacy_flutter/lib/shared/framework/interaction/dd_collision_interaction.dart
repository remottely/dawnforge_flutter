import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';

class DDCollisionInteraction extends GameDecoration
    with Movement, BlockMovementCollision {
  DDCollisionInteraction({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        size: size,
        position: Vector2.zero(),
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    // Não renderiza nada em produção
    if (kDebugMode && gameRef.showCollisionArea) {
      super.render(canvas);
    }
  }
}
