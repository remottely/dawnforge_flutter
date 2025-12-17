import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_data.dart';
import 'package:darkness_dungeon/gameplay/decorations/barrel/barrel_decoration.dart';
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

final class MapDef {
  MapDef._();

  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';

  static const String kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const String kLightingColorPropertyKey = 'lightingColor';
  static const String kBackgroundColorPropertyKey = 'backgroundColor';

  static const String _kCloudyLightingColor = '#d0ffffff';
  static const String _kDarknessLightingColor = '#f0000000';
  static const String _kNoneLightingColor = '#00ffffff';

  static const String _kForestBackgroundColor = '#ff63c74d';
  static const String _kDungeonBackgroundColor = '#ff424242';
  static const String _kLakeBackgroundColor = '#ff000000';
  static const String _kTempleBackgroundColor = '#ff424242';

  static Map<String, ObjectBuilder> createEntityBuilder() =>
      <String, ObjectBuilder>{
        'boss_enemy': (p) => BossEnemyView(position: p.position),
        'mini_boss_enemy': (p) => MiniBossEnemyView(position: p.position),
        'goblin_enemy': (p) => GoblinEnemyView(position: p.position),
        'imp_enemy': (p) => ImpEnemyView(position: p.position),

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

  /// Final maps
  static const String kFarmId = 'farm';
  static const String kLakeId = 'lake';
  static const String kTownId = 'town';
  static const String kBeachId = 'beach';
  static const String kForestId = 'forest';
  static const String kCaveId = 'cave';

  /// Test maps
  static const String kFarmTestId = 'farm_test';
  static const String kConversationTestId = 'conversation_test';
  static const String kCombatTestId = 'combat_test';
  static const String kBossTestId = 'boss_test';
  // static const String kMineTestId = 'mine_test';
  // static const String kFishingTestId = 'fishing_test';

  static const String kLake1Id = 'lake_1';
  static const String kForest1Id = 'forest_1';
  static const String kDungeon1Id = 'dungeon_1';
  static const String kTemple1Id = 'temple_1';

  static const List<MapData> kAllMaps = [
    /// NEW MAPS
    const MapData(
      id: kFarmId,
      asset: 'tiled/maps/$kFarmId.json',
      // sensorIds: ['sensor_$kLakeId', 'sensor_$kTownId'],
      sensorIds: [],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kLakeId,
      asset: 'tiled/maps/$kLakeId.json',
      // sensorIds: ['sensor_$kLakeId', 'sensor_$kTownId'],
      sensorIds: [],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kTownId,
      asset: 'tiled/maps/$kTownId.json',
      // sensorIds: ['sensor_$kLakeId', 'sensor_$kTownId'],
      sensorIds: [],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    /// OLD MAPS FOR TESTING
    const MapData(
      id: kFarmTestId,
      asset: 'tiled/$kFarmTestId.json',
      sensorIds: [
        'sensor_$kBossTestId',
        'sensor_$kConversationTestId',
        'sensor_$kLake1Id',
      ],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kNoneLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kConversationTestId,
      asset: 'tiled/$kConversationTestId.json',
      sensorIds: ['sensor_$kFarmTestId', 'sensor_$kCombatTestId'],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kCloudyLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kCombatTestId,
      asset: 'tiled/$kCombatTestId.json',
      sensorIds: ['sensor_$kConversationTestId', 'sensor_$kBossTestId'],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kBossTestId,
      asset: 'tiled/$kBossTestId.json',
      sensorIds: ['sensor_$kCombatTestId', 'sensor_$kFarmTestId'],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kLake1Id,
      asset: 'tiled/$kLake1Id.json',
      sensorIds: [
        'sensor_$kForest1Id',
        'sensor_$kDungeon1Id',
        'sensor_$kFarmTestId',
      ],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kLakeBackgroundColor,
    ),

    const MapData(
      id: kForest1Id,
      asset: 'tiled/$kForest1Id.json',
      sensorIds: ['sensor_$kDungeon1Id'],
      backgroundMusic: AudioDef.kMusicRo1LettersBackgroundAsset,
      lightingColor: _kCloudyLightingColor,
      backgroundColor: _kForestBackgroundColor,
    ),

    const MapData(
      id: kDungeon1Id,
      asset: 'tiled/$kDungeon1Id.json',
      sensorIds: ['sensor_$kForest1Id', 'sensor_$kTemple1Id'],
      backgroundMusic: AudioDef.kMusicRo1DeathHexBackgroundAsset,
      lightingColor: _kDarknessLightingColor,
      backgroundColor: _kDungeonBackgroundColor,
    ),

    const MapData(
      id: kTemple1Id,
      asset: 'tiled/$kTemple1Id.json',
      sensorIds: ['sensor_$kLake1Id'],
      backgroundMusic: AudioDef
          .kMusicRo1DeathHexBackgroundAsset, // TODO(Kevin): Change music
      lightingColor: _kNoneLightingColor, // TODO(Kevin): Change color
      backgroundColor: _kTempleBackgroundColor, // TODO(Kevin): Change color
    ),
  ];
}
