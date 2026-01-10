import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/skeleton/skeleton_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_data.dart';
import 'package:darkness_dungeon/gameplay/decorations/barrel/barrel_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/bed/bed_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/chest/chest_decoration_model.dart';
import 'package:darkness_dungeon/gameplay/decorations/chest/chest_decoration_view.dart';
import 'package:darkness_dungeon/gameplay/decorations/door/door_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/door_key/door_key_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/life_potion/life_potion_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/life_potion/life_potion_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/spike_trap/spike_trap_decoration.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_model.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_view.dart';
import 'package:darkness_dungeon/gameplay/farm/components/farm_tile_view.dart';
import 'package:darkness_dungeon/gameplay/market/market_decoration.dart';

final class MapDef {
  MapDef._();

  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';
  static const String kInitialPlayerPositionPropertyKey =
      'initialPlayerPosition';

  static const String kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const String kLightingColorPropertyKey = 'lightingColor';
  static const String kBackgroundColorPropertyKey = 'backgroundColor';

  static const String _kCloudyLightingColor = '#80fdfdfd';
  static const String _kDarknessLightingColor = '#d0101010';
  static const String _kNoneLightingColor = '#00ffffff';

  static const String _kForestBackgroundColor = '#ff63c74d';
  // static const String _kDungeonBackgroundColor = '#ff424242';
  static const String _kLakeBackgroundColor = '#ff000000';
  // static const String _kTempleBackgroundColor = '#ff424242';

  static Map<String, ObjectBuilder> createEntityBuilder() =>
      <String, ObjectBuilder>{
        'market': (p) => MarketDecoration(position: p.position, size: p.size),
        'boss_enemy': (p) => BossEnemyView(position: p.position),
        'mini_boss_enemy': (p) => MiniBossEnemyView(position: p.position),
        'goblin_enemy': (p) => GoblinEnemyView(position: p.position),
        'imp_enemy': (p) => ImpEnemyView(position: p.position),
        'skeleton_enemy': (p) => SkeletonEnemyView(position: p.position),

        'kid_npc': (p) => KidNpcView(position: p.position),
        'wizard_npc': (p) => WizardNpcView(position: p.position),

        'barrel_decoration': (p) => BarrelDecorationView(position: p.position),
        'torch_decoration': (p) => TorchDecorationView.lightingEnabled(
          position: p.position,
          model: TorchDecorationModel(initialIsOn: true),
        ),
        'torch_decoration_empty': (p) => TorchDecorationView.lightingDisabled(
          position: p.position,
          model: TorchDecorationModel(initialIsOn: false),
        ),
        'bed_decoration': (p) =>
            BedDecorationView(position: p.position, size: p.size),
        'door_decoration': (p) =>
            DoorDecorationView(position: p.position, size: p.size),
        'door_key_decoration': (p) =>
            DoorKeyDecorationView(position: p.position),
        'life_potion_decoration': (p) => LifePotionDecorationView(
          position: p.position,
          healAmount: LifePotionDef.kHealAmount,
        ),
        'spike_trap_decoration': (p) =>
            SpikeTrapDecorationView(position: p.position),
        'chest': (p) => ChestDecorationView(
          position: p.position,
          model: ChestDecorationModel(initialIsOpened: false),
        ),

        'farm_tile': (p) => FarmTileView(position: p.position),
      };

  /// Official Maps
  static const String kFarmMapId = 'farm_map';
  static const String kTownMapId = 'town_map';
  static const String kForestMapId = 'forest_map';
  static const String kLakeMapId = 'lake_map';
  static const String kBeachMapId = 'beach_map';
  static const String kCaveMapId = 'cave_map';
  static const String kHomeMapId = 'home_map';

  // /// F Maps
  // static const String kF1Id = 'f_1';

  // /// SV Maps
  // static const String kSVFarmId = 'sv_farm';
  // static const String kSVTownId = 'sv_town';
  // static const String kSVForestId = 'sv_forest';
  // static const String kSVLakeId = 'sv_lake';
  // static const String kSVBeachId = 'sv_beach';
  // static const String kSVCaveId = 'sv_cave';

  // /// Final maps
  // static const String kFarmId = 'farm';
  // static const String kLakeId = 'lake';
  // static const String kTownId = 'town';
  // static const String kBeachId = 'beach';
  // static const String kForestId = 'forest';
  // static const String kCaveId = 'cave';

  // /// Test maps
  // static const String kFarmTestId = 'farm_test';
  // static const String kConversationTestId = 'conversation_test';
  // static const String kCombatTestId = 'combat_test';
  // static const String kBossTestId = 'boss_test';
  // // static const String kMineTestId = 'mine_test';
  // // static const String kFishingTestId = 'fishing_test';

  // static const String kLake1Id = 'lake_1';
  // static const String kForest1Id = 'forest_1';
  // static const String kDungeon1Id = 'dungeon_1';
  // static const String kTemple1Id = 'temple_1';

  static const List<MapData> kAllMaps = [
    // /// TEST MAP
    // MapData(
    //   id: kF1Id,
    //   asset: 'tiled/f/maps/$kF1Id.json',
    //   sensorIds: [
    //     'sensor_$kSVForestId',
    //     'sensor_$kSVTownId',
    //     'sensor_$kSVLakeId',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kDarknessLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    /// Official Maps
    MapData(
      id: kFarmMapId,
      asset: 'tiled/maps/$kFarmMapId.json',
      sensorIds: [
        'sensor_$kForestMapId',
        'sensor_$kTownMapId',
        'sensor_$kLakeMapId',
        'sensor_$kHomeMapId',
      ],
      backgroundMusic: AudioDef.bgMusicFarm,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '40,22',
    ),

    MapData(
      id: kForestMapId,
      asset: 'tiled/maps/$kForestMapId.json',
      sensorIds: ['sensor_$kFarmMapId', 'sensor_$kCaveMapId'],
      backgroundMusic: AudioDef.bgMusicForest,
      lightingColor: _kCloudyLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '40,22',
    ),

    MapData(
      id: kTownMapId,
      asset: 'tiled/maps/$kTownMapId.json',
      sensorIds: [
        'sensor_$kFarmMapId',
        'sensor_$kCaveMapId',
        'sensor_$kBeachMapId',
      ],
      backgroundMusic: AudioDef.bgMusicTown,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '40,22',
    ),

    MapData(
      id: kLakeMapId,
      asset: 'tiled/maps/$kLakeMapId.json',
      sensorIds: ['sensor_$kFarmMapId', 'sensor_$kBeachMapId'],
      backgroundMusic: AudioDef.bgMusicLake,
      lightingColor: _kCloudyLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '40,22',
    ),

    MapData(
      id: kBeachMapId,
      asset: 'tiled/maps/$kBeachMapId.json',
      sensorIds: ['sensor_$kTownMapId', 'sensor_$kLakeMapId'],
      backgroundMusic: AudioDef.bgMusicBeach,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '40,22',
    ),

    MapData(
      id: kCaveMapId,
      asset: 'tiled/maps/$kCaveMapId.json',
      sensorIds: ['sensor_$kForestMapId', 'sensor_$kTownMapId'],
      backgroundMusic: AudioDef.bgMusicCave,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '40,22',
    ),

    MapData(
      id: kHomeMapId,
      asset: 'tiled/maps/$kHomeMapId.json',
      sensorIds: ['sensor_$kFarmMapId'],
      backgroundMusic: AudioDef.bgMusicFarm,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
      initialPlayerPosition: '5,5',
    ),

    // /// SV MAPS
    // MapData(
    //   id: kSVFarmId,
    //   asset: 'tiled/sv/maps/$kSVFarmId.json',
    //   sensorIds: [
    //     'sensor_$kSVForestId',
    //     'sensor_$kSVTownId',
    //     'sensor_$kSVLakeId',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '52,20',
    // ),

    // MapData(
    //   id: kSVTownId,
    //   asset: 'tiled/sv/maps/$kSVTownId.json',
    //   sensorIds: [
    //     'sensor_$kSVFarmId',
    //     'sensor_$kSVForestId',
    //     'sensor_$kSVBeachId',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicTown,
    //   lightingColor: _kCloudyLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // /// NEW MAPS
    // const MapData(
    //   id: kFarmId,
    //   asset: 'tiled/maps/$kFarmId.json',
    //   sensorIds: [
    //     'sensor_$kForestId',
    //     'sensor_$kTownId',
    //     'sensor_$kLakeId',
    //     'sensor_$kDungeon1Id',
    //     'sensor_$kForest1Id',
    //     'sensor_$kLake1Id',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kForestId,
    //   asset: 'tiled/maps/$kForestId.json',
    //   sensorIds: ['sensor_$kCaveId', 'sensor_$kTownId', 'sensor_$kFarmId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kTownId,
    //   asset: 'tiled/maps/$kTownId.json',
    //   sensorIds: [
    //     'sensor_$kFarmId',
    //     'sensor_$kForestId',
    //     'sensor_$kBeachId',
    //     'sensor_$kLakeId',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kLakeId,
    //   asset: 'tiled/maps/$kLakeId.json',
    //   sensorIds: ['sensor_$kFarmId', 'sensor_$kTownId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kBeachId,
    //   asset: 'tiled/maps/$kBeachId.json',
    //   sensorIds: ['sensor_$kTownId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kCaveId,
    //   asset: 'tiled/maps/$kCaveId.json',
    //   sensorIds: ['sensor_$kForestId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // /// OLD MAPS FOR TESTING
    // const MapData(
    //   id: kFarmTestId,
    //   asset: 'tiled/$kFarmTestId.json',
    //   sensorIds: [
    //     'sensor_$kBossTestId',
    //     'sensor_$kConversationTestId',
    //     'sensor_$kLake1Id',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kNoneLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kConversationTestId,
    //   asset: 'tiled/$kConversationTestId.json',
    //   sensorIds: ['sensor_$kFarmTestId', 'sensor_$kCombatTestId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kCloudyLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kCombatTestId,
    //   asset: 'tiled/$kCombatTestId.json',
    //   sensorIds: ['sensor_$kConversationTestId', 'sensor_$kBossTestId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kDarknessLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kBossTestId,
    //   asset: 'tiled/$kBossTestId.json',
    //   sensorIds: ['sensor_$kCombatTestId', 'sensor_$kFarmTestId'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kDarknessLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kLake1Id,
    //   asset: 'tiled/$kLake1Id.json',
    //   sensorIds: [
    //     'sensor_$kForest1Id',
    //     'sensor_$kDungeon1Id',
    //     'sensor_$kFarmTestId',
    //   ],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kDarknessLightingColor,
    //   backgroundColor: _kLakeBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kForest1Id,
    //   asset: 'tiled/$kForest1Id.json',
    //   sensorIds: ['sensor_$kDungeon1Id'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kCloudyLightingColor,
    //   backgroundColor: _kForestBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kDungeon1Id,
    //   asset: 'tiled/$kDungeon1Id.json',
    //   sensorIds: ['sensor_$kForest1Id', 'sensor_$kTemple1Id'],
    //   backgroundMusic: AudioDef.bGMusicFarm,
    //   lightingColor: _kDarknessLightingColor,
    //   backgroundColor: _kDungeonBackgroundColor,
    //   initialPlayerPosition: '10,10',
    // ),

    // const MapData(
    //   id: kTemple1Id,
    //   asset: 'tiled/$kTemple1Id.json',
    //   sensorIds: ['sensor_$kLake1Id'],
    //   backgroundMusic: AudioDef.bGMusicFarm, // TODO(Kevin): Change music
    //   lightingColor: _kNoneLightingColor, // TODO(Kevin): Change color
    //   backgroundColor: _kTempleBackgroundColor, // TODO(Kevin): Change color
    //   initialPlayerPosition: '10,10',
    // ),
  ];
}
