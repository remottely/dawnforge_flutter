import 'package:bonfire/bonfire.dart';

final class HitboxUtils {
  HitboxUtils._();

  static RectangleHitbox createExpandHitbox(Vector2 componentSize) =>
      RectangleHitbox(size: componentSize);

  static RectangleHitbox createCenterHitbox({
    required Vector2 componentSize,
    required double hitboxStartPositionX,
    required double hitboxStartPositionY,
  }) => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      componentSize.x - (2 * hitboxStartPositionX),
      componentSize.y - (2 * hitboxStartPositionY),
    ),
  );

  static RectangleHitbox createBottomHitbox({
    required Vector2 componentSize,
    required double hitboxStartPositionX,
    required double hitboxStartPositionY,
  }) => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      componentSize.x - (2 * hitboxStartPositionX),
      componentSize.y - hitboxStartPositionY,
    ),
  );

  /// Cria um hitbox customizado usando offsets de cada lado
  ///
  /// [componentSize] - Tamanho total do componente
  /// [left] - Offset desde a esquerda (0.0 = borda esquerda)
  /// [top] - Offset desde o topo (0.0 = borda superior)
  /// [right] - Offset desde a direita (0.0 = borda direita)
  /// [bottom] - Offset desde a parte inferior (0.0 = borda inferior)
  ///
  /// Exemplo:
  /// ```dart
  /// // Hitbox que deixa 4px de margem em todos os lados
  /// createCustomHitbox(
  ///   componentSize: Vector2(16, 16),
  ///   left: 4.0,
  ///   top: 4.0,
  ///   right: 4.0,
  ///   bottom: 4.0,
  /// );
  /// // Resultado: hitbox de 8x8 começando em (4, 4)
  /// ```
  static RectangleHitbox createCustomHitbox({
    required Vector2 componentSize,
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) {
    return RectangleHitbox(
      position: Vector2(left, top),
      size: Vector2(
        componentSize.x - left - right,
        componentSize.y - top - bottom,
      ),
    );
  }
}
