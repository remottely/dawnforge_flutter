import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

/// Overlay simples para mostrar moedas do jogador.
/// Usa o coinsNotifier do modelo do player para atualizar em tempo real.
class PlayerCoinsOverlay extends StatefulWidget {
  final dynamic player;

  const PlayerCoinsOverlay({super.key, required this.player});

  @override
  State<PlayerCoinsOverlay> createState() => _PlayerCoinsOverlayState();
}

class _PlayerCoinsOverlayState extends State<PlayerCoinsOverlay> {
  DDBasePlayerModel? _model;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _bindToPlayer(widget.player);
  }

  @override
  void didUpdateWidget(PlayerCoinsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player != widget.player) {
      _unbind();
      _bindToPlayer(widget.player);
    }
  }

  @override
  void dispose() {
    _unbind();
    super.dispose();
  }

  void _bindToPlayer(dynamic player) {
    if (player is DDBasePlayerView && player.hasGameRef) {
      final model = player.controller.model;
      _model = model;
      _listener = () {
        if (mounted) setState(() {});
      };
      model.coinsNotifier.addListener(_listener!);
      // Força primeira renderização com valor atual.
      setState(() {});
    }
  }

  void _unbind() {
    final model = _model;
    final listener = _listener;
    if (model != null && listener != null) {
      model.coinsNotifier.removeListener(listener);
    }
    _model = null;
    _listener = null;
  }

  int get _coins => _model?.coins ?? 0;

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 120),
        child: _buildChip(),
      ),
    );
  }

  Widget _buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: Color(0xFFFFD54F),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _coins.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Normal',
            ),
          ),
        ],
      ),
    );
  }
}
