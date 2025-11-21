import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_data.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/barrel_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_model.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_view.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/door_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/door_key_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/life_potion_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/spike_trap_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_model.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_view.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';

final class MapConfig {
  MapConfig._();

  /// Public
  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';

  static const String kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const String kLightingColorPropertyKey = 'lightingColor';
  static const String kBackgroundColorPropertyKey = 'backgroundColor';

  /// Private
  static const String _kCloudyLightingColor = '#d0ffffff';
  static const String _kDarknessLightingColor = '#f0000000';
  static const String _kNoneLightingColor = '#00ffffff';

  static const String _kForestBackgroundColor = '#ff63c74d';
  static const String _kDungeonBackgroundColor = '#ff424242';
  static const String _kLakeBackgroundColor = '#ff000000';
  static const String _kTempleBackgroundColor = '#ff424242';

  ///
  static Map<String, ObjectBuilder> createEntityBuilder() =>
      <String, ObjectBuilder>{
        /// Enemies
        'boss_enemy': (p) => BossEnemyView(position: p.position),
        'mini_boss_enemy': (p) => MiniBossEnemyView(position: p.position),
        'goblin_enemy': (p) => GoblinEnemyView(position: p.position),
        'imp_enemy': (p) => ImpEnemyView(position: p.position),

        /// NPCs
        'kid_npc': (p) => KidNpcView(position: p.position),
        'wizard_npc': (p) => WizardNpcView(position: p.position),

        /// Decorations

        /// Interactables
        'barrel_decoration': (p) => BarrelDecorationView(position: p.position),
        'torch_decoration': (p) => TorchDecorationView.lightingEnabled(
          position: p.position,
          model: TorchDecorationModel(initialIsOn: true),
        ),
        'torch_decoration_empty': (p) => TorchDecorationView.lightingDisabled(
          position: p.position,
          model: TorchDecorationModel(initialIsOn: false),
        ),
        'door_interactable': (p) =>
            DoorDecorationView(position: p.position, size: p.size),
        'door_key_interactable': (p) =>
            DoorKeyDecorationView(position: p.position),
        'life_potion_interactable': (p) => LifePotionDecorationView(
          position: p.position,
          healAmount: LifePotionConfig.kHealAmount,
        ),
        'spike_trap_interactable': (p) =>
            SpikeTrapDecorationView(position: p.position),
        'chest': (p) => ChestDecorationView(
          position: p.position,
          model: ChestDecorationModel(initialIsOpened: false),
        ),

        /// Farmable
        'farm_tile': (p) => FarmTileView(position: p.position),
      };

  /// Maps
  static const String kLake1Id = 'lake_1';
  static const String kForest1Id = 'forest_1';
  static const String kDungeon1Id = 'dungeon_1';
  static const String kTemple1Id = 'temple_1';

  static const List<MapData> kAllMaps = [
    /// lake_1
    const MapData(
      id: kLake1Id,
      asset: 'tiled/$kLake1Id.json',
      sensorIds: ['sensor_$kForest1Id', 'sensor_$kDungeon1Id'],
      backgroundMusic: AudioConfig.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    /// forest_1
    const MapData(
      id: kForest1Id,
      asset: 'tiled/$kForest1Id.json',
      sensorIds: ['sensor_$kDungeon1Id'],
      backgroundMusic: AudioConfig.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kCloudyLightingColor,
      backgroundColor: _kForestBackgroundColor,
    ),

    /// dungeon_1
    const MapData(
      id: kDungeon1Id,
      asset: 'tiled/$kDungeon1Id.json',
      sensorIds: ['sensor_$kForest1Id', 'sensor_$kTemple1Id'],
      backgroundMusic: AudioConfig.kMusicRo1DeathHexBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kDungeonBackgroundColor,
    ),

    /// temple_1
    const MapData(
      id: kTemple1Id,
      asset: 'tiled/$kTemple1Id.json',
      sensorIds: ['sensor_$kLake1Id'],
      backgroundMusic: AudioConfig
          .kMusicRo1DeathHexBackgroundAsset, // TODO(Kevin): Change music
      lightingColor: _kNoneLightingColor, // TODO(Kevin): Change color
      backgroundColor: _kTempleBackgroundColor, // TODO(Kevin): Change color
    ),
  ];
}

class LightingConfig {
  LightingConfig._();
}
