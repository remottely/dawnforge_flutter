// import 'dart:async';

// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
// import 'package:dawnforge/gameplay/market/market_decoration_def.dart';
// import 'package:dawnforge/gameplay/market/market_state.dart';
// import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
// import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
// import 'package:flutter/material.dart';
// import 'package:dawnforge/shared/framework/decorations/dd_contact_decoration.dart';

// class MarketDecoration extends DDContactDecoration with PlayerControllerListener {
//   static final Set<String> _spawnedPositions = <String>{};

//   /// Clear cached spawn registry (e.g., when rebuilding the game after death/restart).
//   static void clearSpawnRegistry() {
//     debugPrint(
//       '[MarketDecoration] Clearing spawn registry (${_spawnedPositions.length} entries)',
//     );
//     _spawnedPositions.clear();
//   }

//   final String? overlayId;
//   final FutureOr<void> Function()? onOpenMarket;
//   final Sprite? interactionIcon;
//   bool _dialogOpen = false;
//   bool _registered = false;
//   bool _hasActiveContact = false;
//   PlayerController? _registeredController;
//   DDBasePlayerView? _currentPlayer;

//   MarketDecoration({
//     required super.position,
//     // required super.size,
//     this.overlayId,
//     this.onOpenMarket,
//     this.interactionIcon,
//   }) : super.withSprite(
//          sprite: MarketDecorationDef.loadSprite(),
//          size: MarketDecorationDef.componentSize,
//        ) {
//     anchor = Anchor.bottomLeft;
//   }

//   @override
//   Future<void> onLoad() {
//     add(MarketDecorationDef.createHitbox());
//     return super.onLoad();
//   }

//   @override
//   void onContact(SimplePlayer component) {
//     super.onContact(component);
//     if (_hasActiveContact) return;
//     _hasActiveContact = true;
//     _currentPlayer = component is DDBasePlayerView ? component : _currentPlayer;
//     _registerToPlayerController();

//     debugPrint(
//       '[MarketDecoration] onContact -> waiting interaction at $_spawnKey',
//     );
//   }

//   @override
//   void onContactExit(SimplePlayer component) {
//     super.onContactExit(component);
//     _hasActiveContact = false;
//     _dialogOpen = false;
//     _currentPlayer = null;
//     _unregisterFromPlayerController();
//     debugPrint('[MarketDecoration] onContactExit -> unlock at $_spawnKey');
//     _closeMarket();
//   }

//   @override
//   void onCollisionStart(
//     Set<Vector2> intersectionPoints,
//     PositionComponent other,
//   ) {
//     if (other is SimplePlayer) {
//       _onPlayerContact(other);
//     }
//     super.onCollisionStart(intersectionPoints, other);
//   }

//   @override
//   void onCollisionEnd(PositionComponent other) {
//     if (other is SimplePlayer) {
//       _onPlayerContactExit(other);
//     }
//     super.onCollisionEnd(other);
//   }

//   void _onPlayerContact(SimplePlayer component) {
//     if (_hasActiveContact) return;
//     _hasActiveContact = true;
//     _currentPlayer = component is DDBasePlayerView ? component : _currentPlayer;
//     _registerToPlayerController();

//     debugPrint(
//       '[MarketDecoration] onContact -> waiting interaction at $_spawnKey',
//     );
//   }

//   void _onPlayerContactExit(SimplePlayer component) {
//     _hasActiveContact = false;
//     _dialogOpen = false;
//     _currentPlayer = null;
//     _unregisterFromPlayerController();
//     debugPrint('[MarketDecoration] onContactExit -> unlock at $_spawnKey');
//     _closeMarket();
//   }

//   @override
//   void onMount() {
//     super.onMount();
//     MarketState.instance.isOpen.addListener(_syncDialogState);
//     final key = _spawnKey;
//     if (_spawnedPositions.contains(key)) {
//       debugPrint(
//         '[MarketDecoration] Duplicate instance detected at $key; removing extra copy.',
//       );
//       scheduleMicrotask(removeFromParent);
//       return;
//     }

//     _registered = true;
//     _spawnedPositions.add(key);
//   }

//   @override
//   void onRemove() {
//     MarketState.instance.isOpen.removeListener(_syncDialogState);
//     _unregisterFromPlayerController();
//     if (_registered) {
//       _spawnedPositions.remove(_spawnKey);
//     }
//     debugPrint(
//       '[MarketDecoration] removed at $_spawnKey (registered=$_registered)',
//     );
//     super.onRemove();
//   }

//   void _openMarket(SimplePlayer component) {
//     // Prefer callback if provided (e.g., to push a Flutter dialog).
//     if (onOpenMarket != null) {
//       debugPrint('[MarketDecoration] opening via onOpenMarket callback');
//       onOpenMarket!();
//       return;
//     }

//     // Fallback: use overlay id if provided.
//     if (overlayId != null) {
//       debugPrint('[MarketDecoration] opening via overlay=$overlayId');
//       if (!gameRef.overlays.isActive(overlayId!)) {
//         gameRef.overlays.add(overlayId!);
//       }
//       return;
//     }

//     // Fallback: abre via estado global para ser renderizado no HUD central.
//     final model = (component is DDBasePlayerView)
//         ? component.controller.model as DDBasePlayerModel?
//         : null;

//     if (model != null) {
//       debugPrint('[MarketDecoration] opening via MarketState.openWithPlayer');
//       MarketState.instance.openWithPlayer(model);
//       return;
//     }
//   }

//   @override
//   void onJoystickAction(JoystickActionEvent event) {
//     if (!_hasActiveContact) return;
//     if (event.event != ActionEvent.DOWN) return;
//     if (!InputDef.isInteractionAction(event.id)) return;
//     if (_dialogOpen) {
//       debugPrint(
//         '[MarketDecoration] interaction ignored, dialog already open at $_spawnKey',
//       );
//       return;
//     }

//     final player = _currentPlayer;
//     if (player == null) {
//       debugPrint(
//         '[MarketDecoration] interaction ignored, no player reference at $_spawnKey',
//       );
//       return;
//     }

//     _dialogOpen = true;
//     _openMarket(player);
//   }

//   @override
//   void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
//     if (!_dialogOpen) return;
//     if (event.directional == JoystickMoveDirectional.IDLE) return;
//     debugPrint(
//       '[MarketDecoration] movement detected -> closing market at $_spawnKey',
//     );
//     _closeMarket();
//   }

//   void _closeMarket() {
//     MarketState.instance.close();
//     _dialogOpen = false;
//   }

//   void _syncDialogState() {
//     _dialogOpen = MarketState.instance.isOpen.value;
//   }

//   void _registerToPlayerController() {
//     final controller = gameRef.playerControllers?.firstOrNull;
//     if (controller == null || _registeredController == controller) return;

//     _registeredController?.removeObserver(this);
//     controller.addObserver(this);
//     _registeredController = controller;
//   }

//   void _unregisterFromPlayerController() {
//     _registeredController?.removeObserver(this);
//     _registeredController = null;
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     _renderHint(canvas);
//   }

//   void _renderHint(Canvas canvas) {
//     // Desenha um pequeno ícone de interação acima do market para guiar o jogador.
//     if (interactionIcon == null) return;

//     final hintOffset = Offset(size.x / 2 - 8, -18);
//     interactionIcon!.render(
//       canvas,
//       position: Vector2(hintOffset.dx, hintOffset.dy),
//       size: Vector2.all(16),
//     );
//   }

//   String get _spawnKey =>
//       '${position.x.toStringAsFixed(3)}|${position.y.toStringAsFixed(3)}';
// }
