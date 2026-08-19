// lib/game/features/market/market_decoration.dart
import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/global/global_input_handler.dart';
import 'package:dawnforge/shared/framework/decorations/dd_contact_decoration.dart';

class MarketDecoration extends DDContactDecoration
    with PlayerControllerListener {
  static final Set<String> _spawnedPositions = <String>{};

  static void clearSpawnRegistry() {
    GameLogger.debug(
      '[MarketDecoration] Clearing spawn registry (${_spawnedPositions.length} entries)',
    );
    _spawnedPositions.clear();
  }

  final String? overlayId;
  final FutureOr<void> Function() onOpenMarket;
  final FutureOr<void> Function() onCloseMarket;
  final Sprite? interactionIcon;

  bool _registered = false;
  bool _hasActiveContact = false;

  PlayerController? _playerInput;
  // DDBasePlayerView? _currentPlayer;

  MarketDecoration({
    required super.position,
    required super.size,
    required this.onOpenMarket,
    required this.onCloseMarket,
    this.overlayId,
    this.interactionIcon,
  });
  @override
  void onContact(SimplePlayer component) {
    super.onContact(component);
    if (_hasActiveContact) return;

    _hasActiveContact = true;

    // ✅ MÉTODO ESTÁTICO
    GlobalInputHandler.register(
      id: 'market_$_spawnKey',
      type: InteractionType.market,
      onExecute: () {
        GameLogger.debug('[MarketDecoration] 🛒 Opening market');
        onOpenMarket.call();
      },
    );
  }

  @override
  void onContactExit(SimplePlayer component) {
    super.onContactExit(component);
    _hasActiveContact = false;

    // ✅ MÉTODO ESTÁTICO
    GlobalInputHandler.unregister('market_$_spawnKey');
    GameLogger.debug('[MarketDecoration] Unregistered at $_spawnKey');
    onCloseMarket.call();
  }

  // ❌ REMOVE onJoystickAction (não precisa mais)

  @override
  void onMount() {
    super.onMount();

    final key = _spawnKey;
    if (_spawnedPositions.contains(key)) {
      GameLogger.warning(
        '[MarketDecoration] Duplicate instance detected at $key; removing extra copy.',
      );
      scheduleMicrotask(removeFromParent);
      return;
    }

    _registered = true;
    _spawnedPositions.add(key);
  }

  @override
  void onRemove() {
    _unregisterFromPlayerController();

    // ✅ REMOVE DO GlobalInputHandler (segurança)
    // GlobalInputHandler.instance.unregisterInteractable(this); // error: The method 'unregisterInteractable' isn't defined for the type 'GlobalInputHandler'.
    // Try correcting the name to the name of an existing method, or defining a method named 'unregisterInteractable'.

    // ✅ DESREGISTRA
    if (_hasActiveContact) {
      // ✅ MÉTODO ESTÁTICO
      GlobalInputHandler.unregister('market_$_spawnKey');
    }

    if (_registered) {
      _spawnedPositions.remove(_spawnKey);
    }

    GameLogger.debug(
      '[MarketDecoration] removed at $_spawnKey (registered=$_registered)',
    );

    super.onRemove();
  }

  // @override
  // void onJoystickAction(JoystickActionEvent event) {
  //   if (!_hasActiveContact) return;
  //   if (event.event != ActionEvent.DOWN) return;
  //   if (!InputDef.isInteractionAction(event.id)) return;

  //   final player = _currentPlayer;
  //   if (player == null) {
  //     GameLogger.debug(
  //       '[MarketDecoration] interaction ignored, no player reference at $_spawnKey',
  //     );
  //     return;
  //   }

  //   // ✅ EXECUTA A AÇÃO
  //   GameLogger.debug('[MarketDecoration] 🛒 Opening market at $_spawnKey');
  //   onOpenMarket.call();

  //   // ✅ GlobalInputHandler JÁ CONSUMIU o input, então:
  //   // - DDConsumablePlayerController NÃO vai executar _tryConsumeSelectedItem
  //   // - FarmingBehavior NÃO vai executar ações de farming
  // }

  void _registerToPlayerController() {
    final PlayerController? playerInput =
        gameRef.playerControllers?.firstOrNull;
    if (playerInput == null || _playerInput == playerInput) return;

    _playerInput?.removeObserver(this);
    playerInput.addObserver(this);
    _playerInput = playerInput;
  }

  void _unregisterFromPlayerController() {
    _playerInput?.removeObserver(this);
    _playerInput = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderHint(canvas);
  }

  void _renderHint(Canvas canvas) {
    if (interactionIcon == null) return;

    final hintOffset = Offset(size.x / 2 - 8, -18);
    interactionIcon!.render(
      canvas,
      position: Vector2(hintOffset.dx, hintOffset.dy),
      size: Vector2.all(16),
    );
  }

  String get _spawnKey =>
      '${position.x.toStringAsFixed(3)}|${position.y.toStringAsFixed(3)}';
}
