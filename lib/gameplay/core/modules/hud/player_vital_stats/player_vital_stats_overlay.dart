import 'package:dawnforge/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_state.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

class PlayerVitalStatsOverlay extends StatefulWidget {
  final dynamic player;

  const PlayerVitalStatsOverlay({super.key, required this.player});

  @override
  State<PlayerVitalStatsOverlay> createState() =>
      _PlayerVitalStatsOverlayState();
}

class _PlayerVitalStatsOverlayState extends State<PlayerVitalStatsOverlay> {
  DemoPlayer? _cachedPlayer;

  @override
  void initState() {
    super.initState();
    _updateCachedPlayer();
    // Initialize player stats immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePlayerStats();
    });
  }

  @override
  void didUpdateWidget(PlayerVitalStatsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when player changes
    if (oldWidget.player != widget.player) {
      _updateCachedPlayer();
      _updatePlayerStats();
    }
  }

  void _updateCachedPlayer() {
    final player = widget.player;
    if (player is DemoPlayer && player.hasGameRef) {
      _cachedPlayer = player;
    }
  }

  void _updatePlayerStats() {
    if (_cachedPlayer != null && mounted) {
      setState(() {});
    }
  }

  double get _currentLife => _cachedPlayer?.life ?? 0.0;
  double get _maxLife => _cachedPlayer?.maxLife ?? 100.0;
  double get _currentStamina {
    final player = _cachedPlayer;
    if (player != null) {
      try {
        return player.controller.model.stamina;
      } catch (e) {
        // Silenciosamente retorna 0 se houver erro
      }
    }
    return 0.0;
  }

  // bool get _hasAnyKey =>
  //     getIt<InventoryManager>().hasItem(DoorKeyDecorationDef.kItemId);

  // bool get _hasKeySelected {
  //   final selectedIndex =
  //       getIt<EquipmentManager>().currentMainHandSlotIndex;
  //   final slot = getIt<InventoryManager>().getSlotByIndex(selectedIndex);
  //   if (slot == null || slot.item == null) return false;
  //   return slot.item!.id == DoorKeyDecorationDef.kItemId && slot.quantity > 0;
  // }

  @override
  Widget build(BuildContext context) {
    // Force rebuild periodically to update player stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _updatePlayerStats();
          }
        });
      }
    });

    return ValueListenableBuilder<bool>(
      valueListenable: PlayerVitalStatsState.instance.isVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();
        return child!;
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthBar(),
              const SizedBox(width: 8),
              _buildStaminaBar(),
              // const SizedBox(width: 12),
              // _buildKeyIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthBar() {
    final percentage = _maxLife > 0
        ? (_currentLife / _maxLife).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'HP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Normal',
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 18,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF455A64),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: percentage,
                alignment: Alignment.bottomCenter,
                child: Container(color: _getHealthBarColor(percentage)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaminaBar() {
    final maxStamina = 100.0;
    final percentage = (_currentStamina / maxStamina).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Normal',
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 18,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF455A64),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: percentage,
                alignment: Alignment.bottomCenter,
                child: Container(color: Colors.yellow),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildKeyIndicator() {
  //   final hasKeySelected = _hasKeySelected;
  //   final hasAnyKey = _hasAnyKey;
  //   final keyColor = hasKeySelected
  //       ? Colors.yellow
  //       : (hasAnyKey ? Colors.white : Colors.grey);

  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(
  //         Icons.vpn_key,
  //         color: keyColor,
  //         size: 16,
  //       ),
  //       const SizedBox(width: 4),
  //       Text(
  //         hasAnyKey ? 'KEY' : '-',
  //         style: TextStyle(
  //           color: keyColor,
  //           fontSize: 12,
  //           fontFamily: 'Normal',
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Color _getHealthBarColor(double percentage) {
    if (percentage > 2.0 / 3.0) {
      return Colors.green;
    } else if (percentage > 1.0 / 3.0) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
