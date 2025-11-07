import 'package:bonfire/bonfire.dart';

class KnightHandItemView extends GameDecoration {
  KnightHandItemView({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required int Function() priorityResolver,
  }) : _priorityResolver = priorityResolver,
       super.withSprite(
         sprite: sprite,
         position: position,
         size: size,
         //  angle: (45 * pi) / 180,
       ) {
    anchor = Anchor.bottomCenter;
  }

  final int Function() _priorityResolver;

  @override
  int get priority => _priorityResolver();

  Future<void> updateSprite(String spritePath) async {
    sprite = await Sprite.load(spritePath);
  }
}
