import 'package:bonfire/bonfire.dart';

class KnightHandItemView extends GameDecoration {
  KnightHandItemView({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required int priorityValue,
  }) : _priorityValue = priorityValue,
       super.withSprite(sprite: sprite, position: position, size: size) {
    anchor = Anchor.bottomCenter;
  }

  final int _priorityValue;

  @override
  int get priority => LayerPriority.getComponentPriority(_priorityValue);

  Future<void> updateSprite(String spritePath) async {
    sprite = await Sprite.load(spritePath);
  }
}
