import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/barrel_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/torch_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/door_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/door_key_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/life_potion_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/spike_trap_interactable.dart';
import 'package:darkness_dungeon/gameplay/terrain/farmable/farm_tile.dart';

enum MapId { map1, dungeon1 }

final class GameplayMapConfig {
  GameplayMapConfig._();

  /// Map keys
  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';

  static const String kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const String kLightingColorPropertyKey = 'lightingColor';
  static const String kBackgroundColorPropertyKey = 'backgroundColor';

  ///
  static Map<String, ObjectBuilder> get entityBuilders =>
      <String, ObjectBuilder>{
        /// Enemies
        'dungeon_boss_enemy': (p) => DungeonBossEnemyView(p.position),
        'dungeon_mini_boss_enemy': (p) => DungeonMiniBossEnemyView(p.position),
        'goblin_enemy': (p) => GoblinEnemyView(p.position),
        'imp_enemy': (p) => ImpEnemyView(p.position),

        /// NPCs
        'kid_npc': (p) => KidNpcView(p.position),
        'wizard_npc': (p) => WizardNpcView(p.position),

        /// Decorations
        'barrel_decoration': (p) => BarrelDecorationView(position: p.position),
        'torch_decoration': (p) => TorchDecorationView(position: p.position),
        'torch_decoration_empty': (p) =>
            TorchDecorationView.empty(position: p.position),

        /// Interactables
        'door_interactable': (p) =>
            DoorInteractableView(position: p.position, size: p.size),
        'door_key_interactable': (p) =>
            DoorKeyInteractableView(position: p.position),
        'life_potion_interactable': (p) => LifePotionDecorationView(
          position: p.position,
          healAmount: LifePotionConfig.kHealAmount,
        ),
        'spike_trap_interactable': (p) =>
            SpikeTrapInteractableView(position: p.position),

        /// Farmable
        'farm_tile': (p) => FarmTileView(p.position),
      };

  ///
  static const List<GameplayMapData> kAllMaps = [
    /// map_1
    const GameplayMapData(
      id: MapId.map1,
      asset: 'tiled/map_1.json',
      sensorIds: ['sensor_dungeon_1'],
      backgroundMusic: 'music/music_ro1_letters_background.mp3',
      lightingColor: '#d0ffffff',
      backgroundColor: '#ff63c74d',
    ),

    /// dungeon_1
    const GameplayMapData(
      id: MapId.dungeon1,
      asset: 'tiled/dungeon_1.json',
      sensorIds: ['sensor_map_1'],
      backgroundMusic: 'music/music_ro1_death_hex_background.mp3',
      lightingColor: '#d0000000',
      backgroundColor: '#ff424242',
    ),
  ];
}
