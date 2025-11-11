import 'package:bonfire/bonfire.dart';

class KnightHandItemView extends GameDecoration {
  KnightHandItemView({
    required super.sprite,
    required super.position,
    required super.size,
    required int Function() priorityResolver,
  }) : _priorityResolver = priorityResolver,
       super.withSprite(
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
