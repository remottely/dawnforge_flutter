import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/farm/components/farm_tile_component.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile.dart' as model;

/// View de um tile de fazenda que integra com o FarmManager
/// Este componente é criado pelo Tiled map e gerencia a visualização
class FarmTileView extends GameDecoration {
  final int tileX;
  final int tileY;
  FarmTileComponent? _visualComponent;

  FarmTileView({required Vector2 position})
    : tileX = (position.x / 16).floor(),
      tileY = (position.y / 16).floor(),
      super(position: position, size: TileConstants.tileSizeStandard) {
    // Inicializar tile no FarmManager se não existir
    final existingTile = FarmManager.instance.getTile(tileX, tileY);
    if (existingTile == null) {
      final newTile = model.FarmTile(x: tileX, y: tileY);
      FarmManager.instance.setTile(newTile);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    developer.log('[FarmTileView] Loading tile at ($tileX, $tileY)');

    // Criar componente visual como filho (posição relativa)
    final tile = FarmManager.instance.getTile(tileX, tileY)!;
    _visualComponent = FarmTileComponent(
      farmTile: tile,
      position: Vector2.zero(), // Posição relativa ao pai
    );

    // Adicionar como filho (renderiza junto com este componente)
    add(_visualComponent!);

    developer.log(
      '[FarmTileView] ✓ Visual component added at ($tileX, $tileY)',
    );
  }

  /// Verifica se o player está sobrepondo este tile
  bool isPlayerOnTile(Player player) {
    return player.rectCollision.overlaps(rectCollision);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Atualizar componente visual com estado atual do tile
    final currentTile = FarmManager.instance.getTile(tileX, tileY);
    if (currentTile != null && _visualComponent != null) {
      // Log apenas se o estado mudou
      if (currentTile.soilState != _visualComponent!.farmTile.soilState ||
          currentTile.crop?.cropId != _visualComponent!.farmTile.crop?.cropId) {
        // developer.log(
        //   '[FarmTileView] Tile ($tileX, $tileY) changed! Old: ${_visualComponent!.farmTile.soilState}, New: ${currentTile.soilState}',
        // );
      }
      _visualComponent!.updateTile(currentTile);
    }
  }

  // onRemove não precisa mais - o filho é removido automaticamente

  @override
  int get priority => 20;
}
