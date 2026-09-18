// A Minecraft-like in one declaration: `flutter run -d macos`.
import 'package:voxel_game/voxel_game.dart';

void main() => runVoxelGame(game, title: 'Voxel game', saveSlot: 'world1');

const game = VoxelGameSpec(
  seed: 2024,
  blocks: [
    BlockType('stone', color: 0x7F7F84, hardness: 1.5, tool: 'pickaxe', tier: 1, drop: 'cobblestone'),
    BlockType('cobblestone', color: 0x6E6E70, hardness: 2.0, tool: 'pickaxe'),
    BlockType('dirt', color: 0x8A5E3B, hardness: 0.5, tool: 'shovel'),
    BlockType('grass', color: 0x5C9E3A, hardness: 0.6, tool: 'shovel', drop: 'dirt'),
    BlockType('sand', color: 0xDCCB8A, hardness: 0.5, tool: 'shovel'),
    BlockType('snow', color: 0xF2F6FA, hardness: 0.3, tool: 'shovel'),
    BlockType('log', color: 0x6B4F2A, hardness: 2.0, tool: 'axe'),
    BlockType('leaves', color: 0x3F8A2E, hardness: 0.2, opaque: false),
    BlockType('planks', color: 0xB08850, hardness: 2.0, tool: 'axe'),
    BlockType('crafting_table', color: 0x9C6B3C, hardness: 2.5, tool: 'axe'),
    BlockType('coal_ore', color: 0x3A3A3E, hardness: 3.0, tool: 'pickaxe', tier: 1, drop: 'coal'),
    BlockType('torch', color: 0xFFD070, shape: BlockShape.torch, solid: false, hardness: 0, light: 14),
    BlockType('flower', color: 0xE04040, shape: BlockShape.flower, solid: false, hardness: 0),
    BlockType('wire', color: 0x701010, shape: BlockShape.wire, solid: false, hardness: 0),
    BlockType('wire_lit', color: 0xFF3020, shape: BlockShape.wire, solid: false, hardness: 0, light: 3, drop: 'wire'),
    BlockType('lever', color: 0x806040, shape: BlockShape.torch, solid: false, hardness: 0),
    BlockType('lever_on', color: 0xC0A070, shape: BlockShape.torch, solid: false, hardness: 0, drop: 'lever'),
    BlockType('lamp', color: 0x6A4A2A, hardness: 0.3),
    BlockType('lamp_lit', color: 0xFFD890, hardness: 0.3, light: 15, drop: 'lamp'),
    BlockType.liquid('water', color: 0x3366CC),
    BlockType.liquid('water_flow', color: 0x3366CC, kind: 'water', source: false),
  ],
  items: [
    ItemType('coal', color: 0x202020),
    ItemType('wooden_pickaxe', color: 0xB08850, tool: 'pickaxe', tier: 1, stack: 1, durability: 60, damage: 2),
    ItemType('stone_sword', color: 0x8C8C90, tool: 'sword', tier: 2, stack: 1, durability: 130, damage: 5),
    ItemType('wool', color: 0xEEEEEE),
    ItemType('bone', color: 0xE8E4D0),
  ],
  recipes: [
    Recipe('planks', 4, {'log': 1}),
    Recipe('torch', 4, {'coal': 1, 'planks': 1}),
    Recipe('crafting_table', 1, {'planks': 4}),
    Recipe('wooden_pickaxe', 1, {'planks': 5}, station: 'crafting_table'),
    Recipe('stone_sword', 1, {'cobblestone': 2, 'planks': 1}, station: 'crafting_table'),
  ],
  world: WorldGenSpec(
    bedrock: 'stone',
    biomes: [
      Biome('tundra', top: 'snow', under: 'dirt', climate: Climate.cold, trees: [TreeSpec.spruce(log: 'log', leaves: 'leaves')], treeChance: 30),
      Biome('desert', top: 'sand', climate: Climate.hotDry),
      Biome('forest', top: 'grass', under: 'dirt', climate: Climate.wet, trees: [TreeSpec.oak(log: 'log', leaves: 'leaves')], treeChance: 90),
      Biome('plains', top: 'grass', under: 'dirt', trees: [TreeSpec.oak(log: 'log', leaves: 'leaves')], treeChance: 12, plants: [Plant('flower', perMille: 30)]),
    ],
    beach: Biome('beach', top: 'sand'),
    ores: [Ore('coal_ore', share: 0.11)],
    structures: [StructureSpec('tower', build: tower, biomes: ['plains', 'forest'], radius: 3)],
  ),
  signals: SignalSpec(wire: ('wire', 'wire_lit'), levers: {'lever': 'lever_on'}, lamps: {'lamp': 'lamp_lit'}),
  player: PlayerSpec(startingItems: {'wooden_pickaxe': 1, 'stone_sword': 1, 'planks': 32, 'torch': 16, 'lever': 4, 'wire': 32, 'lamp': 4}),
  mobs: [
    MobSpec('sheep', hp: 8, speed: 2.0, halfWidth: 0.45, height: 1.2, rig: Rig.quadruped(body: 0xEEEEEE, head: 0xD8C8B0),
        brain: [FleeWhenHurt(), LookAtPlayer(), Wander()], drops: [Drop('wool', 1, 2)], spawn: SpawnRule.daylight(biomes: ['plains', 'forest'])),
    MobSpec('chicken', hp: 4, speed: 1.8, halfWidth: 0.25, height: 0.7, rig: Rig.bird(),
        brain: [FleeWhenHurt(), Wander()], spawn: SpawnRule.daylight(group: (1, 3))),
    MobSpec('zombie', hp: 20, speed: 2.6, rig: Rig.humanoid(skin: 0x5E9A5A, shirt: 0x3A6A9A, armsForward: true, redEyes: true),
        brain: [MeleeAttack(damage: 3), Hunt(range: 18), Wander()], drops: [Drop('bone', 0, 2)], spawn: SpawnRule.dark()),
    MobSpec('skeleton', hp: 16, speed: 2.4, rig: Rig.humanoid(skin: 0xE0E0D8, shirt: 0xC8C8C0, pants: 0xB0B0A8, redEyes: true),
        brain: [RangedAttack(projectile: ProjectileSpec.arrow), Hunt(range: 20), Wander()], drops: [Drop('bone', 1, 3)], spawn: SpawnRule.dark(weight: 6)),
    MobSpec('creeper', hp: 14, speed: 2.8, halfWidth: 0.35, height: 1.6, rig: Rig.humanoid(skin: 0x4CAF50, shirt: 0x4CAF50, pants: 0x357A38),
        brain: [Explode(), Hunt(range: 14), Wander()], spawn: SpawnRule.dark(weight: 5)),
    MobSpec('slime', hp: 8, speed: 2.2, halfWidth: 0.4, height: 0.8, rig: Rig.blob(), gait: Gait.hop,
        brain: [MeleeAttack(damage: 2), Hunt(range: 12), Wander()], spawn: SpawnRule.dark(weight: 4)),
  ],
);

/// A cobblestone tower with a door, a torch on top.
void tower(StructureSite s) {
  s.level(-2, -2, 2, 2, 'cobblestone', clearTo: 12);
  final top = 7 + s.roll(1) % 4;
  s.fill(-2, 0, -2, 2, top, 2, 'cobblestone', hollow: true);
  s.fill(0, 1, 2, 0, 2, 2, 'air');
  s.put(0, top + 1, 0, 'torch');
}
