/// A Minecraft-like in a few lines: declare blocks, world generation, the
/// player and mobs in a [VoxelGameSpec] and run it. The kit over voxel_core,
/// voxel_scene, voxel_worldgen and voxel_content, which it re-exports, so a
/// game imports this one library.
library;

export 'package:voxel_content/voxel_content.dart';
export 'package:voxel_core/voxel_core.dart' show BlockShape, IVec3;
export 'package:voxel_worldgen/voxel_worldgen.dart'
    show
        Biome,
        CaveSpec,
        Climate,
        Ore,
        Plant,
        StructureSite,
        StructureSpec,
        TerrainRecipe,
        TreeShape,
        TreeSpec,
        WorldGenSpec;

export 'src/camera/view_camera.dart';
export 'src/core/voxel_game.dart';
export 'src/entities/game_entity.dart';
export 'src/entities/item_pickup.dart';
export 'src/entities/projectile.dart';
export 'src/entities/target.dart';
export 'src/input/input_map.dart';
export 'src/input/voxel_action.dart';
export 'src/loop/fixed_step_loop.dart';
export 'src/mobs/behaviors.dart';
export 'src/mobs/mob.dart';
export 'src/mobs/mob_spec.dart';
export 'src/mobs/rig.dart';
export 'src/mobs/spawner.dart';
export 'src/player/character_motor.dart';
export 'src/player/player_entity.dart';
export 'src/player/player_spec.dart';
export 'src/spec/sky_spec.dart';
export 'src/spec/voxel_game_spec.dart';
export 'src/world/game_world.dart';
export 'src/ui/default_hud.dart';
export 'src/ui/voxel_game_widget.dart';
