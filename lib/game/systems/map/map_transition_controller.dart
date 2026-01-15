// lib/gameplay/core/modules/map/map_transition_controller.dart
import 'dart:async';
import 'package:bonfire/bonfire.dart';

class MapTransitionRequest {
  final String mapId;
  final Vector2 playerPosition;
  final Direction? playerDirection;

  MapTransitionRequest({
    required this.mapId,
    required this.playerPosition,
    this.playerDirection,
  });
}

class MapTransitionController {
  MapTransitionController._();

  static final instance = MapTransitionController._();

  final _transitionController =
      StreamController<MapTransitionRequest>.broadcast();

  Stream<MapTransitionRequest> get onTransitionRequested =>
      _transitionController.stream;

  void requestTransition({
    required String mapId,
    required Vector2 playerPosition,
    Direction? playerDirection,
  }) {
    _transitionController.add(
      MapTransitionRequest(
        mapId: mapId,
        playerPosition: playerPosition,
        playerDirection: playerDirection,
      ),
    );
  }

  void dispose() {
    _transitionController.close();
  }
}
