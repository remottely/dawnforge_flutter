import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/ui/interface/hotbar_view.dart';
import 'package:dawnforge/src/core/ui/interface/inventory_panel_view.dart';
import 'package:dawnforge/src/core/ui/interface/workstation_panel_view.dart';
import 'package:flutter/widgets.dart';

/// What each of the game's overlay names draws — the ONE table, read by the app
/// shell and by the boot test alike.
///
/// Two copies of this map is how a surface ends up mounted in the app and
/// absent from the test that is supposed to prove it mounts. Flame refuses an
/// overlay name it has no builder for, so the game adding one this map does not
/// carry fails loudly rather than silently drawing nothing.
Map<String, Widget Function(BuildContext, DawnforgeGame)> gameOverlays() =>
    <String, Widget Function(BuildContext, DawnforgeGame)>{
      DawnforgeGame.hotbarOverlay: (context, game) =>
          HotbarView(inventory: game.player.inventory),
      DawnforgeGame.inventoryOverlay: (context, game) => InventoryPanelView(
            inventory: game.player.inventory,
            onClose: game.closeInventory,
            onDropToWorld: game.dropSlotToWorld,
          ),
      DawnforgeGame.workstationOverlay: (context, game) {
        // A bench with no station behind it is not a state this game can be
        // in: the overlay is added by the handler that sets the station and
        // removed by the one that clears it (rule 5).
        final station = game.openStation!;
        return WorkstationPanelView(
          station: station.workstation,
          inventory: game.player.inventory,
          title: station.workstationData.displayName,
          onClose: game.closeWorkstation,
        );
      },
    };
