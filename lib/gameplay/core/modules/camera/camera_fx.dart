import 'package:bonfire/bonfire.dart';

final class CameraFx {
  CameraFx._();
  static void _executeLightShake(BonfireGameInterface gameRef) {
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

  static void _executeMediumShake(BonfireGameInterface gameRef) {
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

  /// Public configs
  static void executePrimaryAttackShake(BonfireGameInterface gameRef) =>
      _executeLightShake(gameRef);
  static void executeFireballExplosionShake(BonfireGameInterface gameRef) =>
      _executeMediumShake(gameRef);
}
