import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/barrel_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/torch_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/door_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/door_key_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/life_potion_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/spike_trap_interactable.dart';
import 'package:darkness_dungeon/gameplay/terrain/farmable/farm_tile.dart';

final class GameplayMapConfig {
  GameplayMapConfig._();

  /// Public
  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';

  static const String kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const String kLightingColorPropertyKey = 'lightingColor';
  static const String kBackgroundColorPropertyKey = 'backgroundColor';

  /// Private
  static const String _kCloudyLightingColor = '#d0ffffff';
  static const String _kDarknessLightingColor = '#d0000000';

  static const String _kForestBackgroundColor = '#ff63c74d';
  static const String _kDungeonBackgroundColor = '#ff424242';

  ///
  static Map<String, ObjectBuilder> createEntityBuilder() =>
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

  /// Maps
  static const String kForest1Id = 'forest_1';
  static const String kDungeon1Id = 'dungeon_1';

  static const List<GameplayMapData> kAllMaps = [
    /// forest_1
    const GameplayMapData(
      id: kForest1Id,
      asset: 'tiled/$kForest1Id.json',
      sensorIds: ['sensor_$kDungeon1Id'],
      backgroundMusic: GameplayAudioConfig.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kCloudyLightingColor,
      backgroundColor: _kForestBackgroundColor,
    ),

    /// dungeon_1
    const GameplayMapData(
      id: kDungeon1Id,
      asset: 'tiled/$kDungeon1Id.json',
      sensorIds: ['sensor_$kForest1Id'],
      backgroundMusic: GameplayAudioConfig.kMusicRo1DeathHexBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kDungeonBackgroundColor,
    ),
  ];
}

class LightingConfig {
  LightingConfig._();
}
