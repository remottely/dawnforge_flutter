import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';

/// Legacy component - now delegates to [FarmInputHandler].
///
/// This component is maintained for backward compatibility and will be
/// deprecated in the future. All new code should use [FarmInputHandler] directly.
///
/// **Migration Guide:**
/// Replace:
/// ```dart
/// player.add(FarmInteractionComponent(player: player));
/// ```
///
/// With:
/// ```dart
/// player.add(FarmInputHandler(player: player));
/// ```
@Deprecated('Use FarmInputHandler directly instead')
class FarmInteractionComponent extends FarmInputHandler {
  FarmInteractionComponent({required super.player});
}
