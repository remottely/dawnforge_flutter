import 'package:bonfire/bonfire.dart';

final class GameplayCameraEffectsUtils {
  GameplayCameraEffectsUtils._();
  static void lightShake(BonfireGameInterface gameRef) {
    final currentPos = gameRef.camera.viewfinder.position.clone();

    gameRef.camera.viewfinder.position = currentPos + Vector2(1, 0);

    Future.delayed(const Duration(milliseconds: 15), () {
      gameRef.camera.viewfinder.position = currentPos + Vector2(-1, 0);

      Future.delayed(const Duration(milliseconds: 15), () {
        gameRef.camera.viewfinder.position = currentPos + Vector2(1, 0);

        Future.delayed(const Duration(milliseconds: 15), () {
          gameRef.camera.viewfinder.position = currentPos;
        });
      });
    });
  }

  static void mediumShake(BonfireGameInterface gameRef) {
    final currentPos = gameRef.camera.viewfinder.position.clone();

    gameRef.camera.viewfinder.position = currentPos + Vector2(1, 0);

    Future.delayed(const Duration(milliseconds: 20), () {
      gameRef.camera.viewfinder.position = currentPos + Vector2(-1, 0);

      Future.delayed(const Duration(milliseconds: 15), () {
        gameRef.camera.viewfinder.position = currentPos + Vector2(1, 0);

        Future.delayed(const Duration(milliseconds: 15), () {
          gameRef.camera.viewfinder.position = currentPos + Vector2(-1, 0);

          Future.delayed(const Duration(milliseconds: 15), () {
            gameRef.camera.viewfinder.position = currentPos + Vector2(1, 0);

            Future.delayed(const Duration(milliseconds: 15), () {
              gameRef.camera.viewfinder.position = currentPos + Vector2(-1, 0);

              Future.delayed(const Duration(milliseconds: 15), () {
                gameRef.camera.viewfinder.position = currentPos;
              });
            });
          });
        });
      });
    });
  }

  static void primaryAttackShake(BonfireGameInterface gameRef) =>
      lightShake(gameRef);
  static void fireballExplosionShake(BonfireGameInterface gameRef) =>
      mediumShake(gameRef);
}
