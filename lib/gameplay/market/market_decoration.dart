import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/market/market_state.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/gameplay/market/widgets/market_dialog.dart';
import 'package:flutter/material.dart';

/// Decoração interativa do market. Quando o jogador encosta, dispara a abertura do dialog/overlay.
class MarketDecoration extends DDContactDecoration {
  static final Set<String> _spawnedPositions = <String>{};

  final String? overlayId;
  final FutureOr<void> Function()? onOpenMarket;
  final Sprite? interactionIcon;
  bool _dialogOpen = false;
  bool _registered = false;
  bool _lockedUntilExit = false;

  MarketDecoration({
    required super.position,
    required super.size,
    Sprite? sprite,
    this.overlayId,
    this.onOpenMarket,
    this.interactionIcon,
  }) : super.withSprite(
          sprite: sprite ??
              Sprite.load(
                'hud/commerce_marketplace_stall_open.png',
              ),
        );

  /// Facilita criação com sprite já carregado.
  MarketDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    this.overlayId,
    this.onOpenMarket,
    this.interactionIcon,
  }) : super.withSprite();

  @override
  void onContact(SimplePlayer component) {
    super.onContact(component);
    final marketAlreadyOpen = MarketState.instance.isOpen.value;
    if (_dialogOpen || _lockedUntilExit || marketAlreadyOpen) {
      debugPrint(
        '[MarketDecoration] onContact ignored (dialogOpen=$_dialogOpen, lockedUntilExit=$_lockedUntilExit, marketAlreadyOpen=$marketAlreadyOpen) at $_spawnKey',
      );
      return;
    }

    _dialogOpen = true;
    _lockedUntilExit = true;
    debugPrint('[MarketDecoration] onContact -> opening market at $_spawnKey');

    // Stop player movement so it doesn't keep walking while dialog is open.
    try {
      component.stopMove();
    } catch (_) {
      // ignore if player implementation differs.
    }

    MarketState.instance.open();
    _openMarket(component);
  }

  @override
  void onContactExit(SimplePlayer component) {
    super.onContactExit(component);
    _dialogOpen = false;
    _lockedUntilExit = false;
    debugPrint('[MarketDecoration] onContactExit -> unlock at $_spawnKey');
    MarketState.instance.close();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Alinha visualmente a banca pela base e adiciona hitbox para bloqueio.
    anchor = Anchor.bottomCenter;
    add(
      RectangleHitbox(
        size: size,
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    final key = _spawnKey;
    if (_spawnedPositions.contains(key)) {
      debugPrint('[MarketDecoration] Duplicate instance detected at $key; removing extra copy.');
      scheduleMicrotask(removeFromParent);
      return;
    }

    _registered = true;
    _spawnedPositions.add(key);
  }

  @override
  void onRemove() {
    if (_registered) {
      _spawnedPositions.remove(_spawnKey);
    }
    debugPrint('[MarketDecoration] removed at $_spawnKey (registered=$_registered)');
    super.onRemove();
  }

  void _openMarket(SimplePlayer component) {
    // Prefer callback if provided (e.g., to push a Flutter dialog).
    if (onOpenMarket != null) {
      debugPrint('[MarketDecoration] opening via onOpenMarket callback');
      onOpenMarket!();
      return;
    }

    // Fallback: use overlay id if provided.
    if (overlayId != null) {
      debugPrint('[MarketDecoration] opening via overlay=$overlayId');
      if (!gameRef.overlays.isActive(overlayId!)) {
        gameRef.overlays.add(overlayId!);
      }
      return;
    }

    // Fallback: abre o dialog Flutter diretamente, usando o modelo do player.
    final model = (component is DDBasePlayerView)
        ? component.controller.model as DDBasePlayerModel?
        : null;

    if (model != null) {
      debugPrint('[MarketDecoration] opening via fallback showDialog');
      showDialog<void>(
        context: gameRef.context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return MarketDialog(
            player: model,
            onClose: () {
              debugPrint('[MarketDecoration] MarketDialog onClose callback');
              _dialogOpen = false;
              MarketState.instance.close();
            },
          );
        },
      ).then((_) {
        debugPrint('[MarketDecoration] MarketDialog closed (Future.then)');
        _dialogOpen = false;
        MarketState.instance.close();
      }).catchError((error, stack) {
        debugPrint('[MarketDecoration] showDialog error: $error');
        _dialogOpen = false;
        MarketState.instance.close();
      });
      return;
    }

    // As último recurso, apenas loga.
    debugPrint('[MarketDecoration] Nenhum handler de abertura do market configurado.');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderHint(canvas);
  }

  void _renderHint(Canvas canvas) {
    // Desenha um pequeno ícone de interação acima do market para guiar o jogador.
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
