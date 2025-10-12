import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_logger.dart';
import 'package:darkness_dungeon/gameplay/maps/gameplay_maps.dart';

class MapSensor extends GameDecoration with Sensor<Player> {
  final String id;
  bool hasContact = false;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;
  double _contactTime = 0;
  static const double _requiredContactTime =
      0.5; // 500ms delay - evita navegação acidental
  bool _hasNavigated = false; // Previne múltiplas navegações

  MapSensor(
    this.id,
    Vector2 position,
    Vector2 size,
    this.targetMap,
    this.playerPosition,
    this.playerDirection,
  ) : super(position: position, size: size);

  @override
  void onContact(Player component) {
    if (!hasContact && !_hasNavigated) {
      hasContact = true;
      _contactTime = 0; // Reset timer
      AppLogger.debug('MapSensor: Player entered sensor $id');
    }
    super.onContact(component);
  }

  @override
  void onContactExit(Player component) {
    hasContact = false;
    _contactTime = 0; // Reset timer
    AppLogger.debug('MapSensor: Player exited sensor $id');
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (hasContact && !_hasNavigated) {
      _contactTime += dt;
      // Only navigate after required contact time to prevent accidental teleports
      if (_contactTime >= _requiredContactTime) {
        _hasNavigated = true; // Prevent multiple navigation calls
        hasContact = false;
        AppLogger.info(
          'MapSensor: Navigating to $targetMap, position: $playerPosition, direction: $playerDirection',
        );

        // Small delay to ensure smooth transition
        Future.delayed(Duration(milliseconds: 100), () {
          MapNavigator.of(context).toNamed(
            targetMap,
            arguments: MapArguments(playerPosition, playerDirection),
          );
        });
      }
    }
    super.update(dt);
  }

  /// Resets the sensor navigation state
  /// Following Flutter pattern of component state management
  void resetNavigationState() {
    _hasNavigated = false;
    hasContact = false;
    _contactTime = 0;
    AppLogger.debug('MapSensor: Reset navigation state for sensor $id');
  }
}
