import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';
import 'package:flutter/services.dart';

/// Componente que gerencia interação do player com farm tiles
/// Teclas: H (Arar), J (Regar), K (Plantar), R (Colher), N (Debug: avançar dia)
class FarmInteractionComponent extends GameComponent
    with KeyboardEventListener {
  final Player player;

  FarmInteractionComponent({required this.player});

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    // Buscar FarmTileView que está em contato com o player
    final farmTile = _getFarmTileInContact();
    if (farmTile == null) {
      developer.log('[FarmInteraction] ❌ No farm tile in contact with player');
      return false;
    }

    final x = farmTile.tileX;
    final y = farmTile.tileY;

    developer.log('[FarmInteraction] 🎯 Interacting with tile ($x, $y)');

    // H = Arar (Hoe)
    if (event.logicalKey == LogicalKeyboardKey.keyH) {
      final success = FarmManager.instance.tillSoil(x, y);
      if (success) {
        developer.log('[FarmInteraction] ✅ Tilled soil at ($x, $y)');
        _showFloatingText('Terra Arada!');
      } else {
        developer.log('[FarmInteraction] ❌ Cannot till at ($x, $y)');
      }
      return true;
    }

    // J = Regar (Water)
    if (event.logicalKey == LogicalKeyboardKey.keyJ) {
      final success = FarmManager.instance.waterTile(x, y);
      if (success) {
        developer.log('[FarmInteraction] ✅ Watered tile at ($x, $y)');
        _showFloatingText('Regado!');
      } else {
        developer.log('[FarmInteraction] ❌ Cannot water at ($x, $y)');
      }
      return true;
    }

    // K = Plantar (Seed/Plant) - Exemplo com carrot
    if (event.logicalKey == LogicalKeyboardKey.keyK) {
      // TODO: Integrar com inventário para escolher seed
      final success = FarmManager.instance.plantSeed(x, y, 'carrot');
      if (success) {
        developer.log('[FarmInteraction] ✅ Planted seed at ($x, $y)');
        _showFloatingText('Plantado!');
      } else {
        developer.log('[FarmInteraction] ❌ Cannot plant at ($x, $y)');
      }
      return true;
    }

    // R = Colher (Reap/Harvest)
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      final crop = FarmManager.instance.harvestCrop(x, y);
      if (crop != null) {
        developer.log('[FarmInteraction] ✅ Harvested ${crop.name} at ($x, $y)');
        _showFloatingText('Colhido ${crop.yieldAmount}x ${crop.name}!');
        // TODO: Adicionar itens ao inventário
      } else {
        developer.log('[FarmInteraction] ❌ Cannot harvest at ($x, $y)');
      }
      return true;
    }

    // N = Debug: Avançar 1 dia
    if (event.logicalKey == LogicalKeyboardKey.keyN) {
      FarmManager.instance.advanceDay();
      developer.log('[FarmInteraction] 🌙 DEBUG: Advanced 1 day manually');
      _showFloatingText('Dia avançado!');
      return true;
    }

    return false;
  }

  /// Busca o FarmTileView que está em contato direto com o player
  FarmTileView? _getFarmTileInContact() {
    // Buscar todos os FarmTileView no jogo
    final allFarmTiles = gameRef.query<FarmTileView>();

    // Verificar qual está sobrepondo o player
    for (final farmTile in allFarmTiles) {
      if (farmTile.isPlayerOnTile(player)) {
        return farmTile;
      }
    }

    return null;
  }

  void _showFloatingText(String text) {
    // TODO: Implementar floating text visual
    // Por enquanto só loga
    developer.log('[FarmInteraction] $text');
  }
}
