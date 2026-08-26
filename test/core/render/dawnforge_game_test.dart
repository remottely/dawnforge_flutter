import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP3 slice gate in test form: the game boots from the REAL bundled assets,
/// spawns a player from the registry, and input moves it through the fixed
/// step. (The visual half of the gate — 60fps on device — is a hand-run.)
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  testWidgets('boots content, spawns the player, input moves it',
      (tester) async {
    final game = DawnforgeGame();
    // Image decode is real async, which the fake-async test zone blocks —
    // boot the game inside runAsync so sprite sheets actually load.
    await tester.runAsync(() async {
      await tester.pumpWidget(GameWidget<DawnforgeGame>(game: game));
      for (var i = 0; i < 40 && game.simObjects.length < 6; i++) {
        await tester.pump(const Duration(milliseconds: 25));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    });

    // Content booted from the generated assets.
    expect(locator<ActorRegistry>().count, greaterThan(0));
    expect(locator<LocalizationSystem>().isLoaded, isTrue);
    expect(game.simObjects.length, 6); // 5 props + the player
    expect(game.player.actorData.id, 't1_actor_creature_boar');

    // Feed a "D held" state straight into the input SSOT (a raw key event
    // needs a focused widget tree; the helper is the contract, so it is the
    // seam) and run the sim for half a second of frames.
    locator<InputHelper>().handleKeyEvent(
      const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyD,
        logicalKey: LogicalKeyboardKey.keyD,
        timeStamp: Duration.zero,
      ),
    );
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(game.player.position.x, greaterThan(0));
    expect(game.player.movement.isMoving, isTrue);
  });
}
