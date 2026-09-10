import 'dart:typed_data';

/// The block table. INDEX IS THE SAVE CONTRACT: a chunk stores bytes and a save
/// file stores those bytes, so entries are appended, never reordered or removed.
/// Byte-for-byte the same order as the Godot POC (`src/core/blocks.gd`).
enum BlockShape {
  cube,
  cross,
  liquid,
  torch,
  flower,
  panelZ,
  panelX,
  wallTorch,
  slab,
  fence,
  stairsN,
  stairsE,
  stairsS,
  stairsW,
}

enum ToolType { none, pickaxe, axe, shovel, sword, hoe, shears }

class BlockDef {
  const BlockDef(
    this.id,
    this.name,
    this.r,
    this.g,
    this.b, {
    this.a = 1.0,
    this.shape = BlockShape.cube,
    this.solid = true,
    this.opaque = true,
    this.hardness = 1.0,
    this.tool = ToolType.none,
    this.tier = 0,
    this.drop = '',
    this.light = 0,
  });

  final String id;
  final String name;
  final double r, g, b, a;
  final BlockShape shape;

  /// Stops a body.
  final bool solid;

  /// Occludes faces and stops light.
  final bool opaque;

  /// Seconds by hand; -1 unbreakable.
  final double hardness;
  final ToolType tool;

  /// 0 hand, 1 wood, 2 stone, 3 iron, 4 diamond.
  final int tier;

  /// Item id, "" for itself, "-" for nothing.
  final String drop;

  /// 0..15 emitted light.
  final int light;
}

class Blocks {
  Blocks._();

  static const int air = 0;

  static const List<BlockDef> defs = [
    BlockDef('air', 'Air', 0, 0, 0, solid: false, opaque: false, hardness: -1, drop: '-'),
    BlockDef('stone', 'Stone', 0.50, 0.50, 0.52, hardness: 3.0, tool: ToolType.pickaxe, tier: 1, drop: 'cobblestone'),
    BlockDef('dirt', 'Dirt', 0.55, 0.38, 0.24, hardness: 0.8, tool: ToolType.shovel),
    BlockDef('grass', 'Grass Block', 0.36, 0.64, 0.27, hardness: 0.9, tool: ToolType.shovel, drop: 'dirt'),
    BlockDef('sand', 'Sand', 0.87, 0.81, 0.60, hardness: 0.7, tool: ToolType.shovel),
    BlockDef('water', 'Water', 0.20, 0.42, 0.78, a: 0.62, shape: BlockShape.liquid, solid: false, opaque: false, hardness: -1, drop: '-'),
    BlockDef('oak_log', 'Oak Log', 0.43, 0.30, 0.17, hardness: 2.5, tool: ToolType.axe),
    BlockDef('oak_leaves', 'Oak Leaves', 0.25, 0.52, 0.19, hardness: 0.3, drop: '-'),
    BlockDef('gravel', 'Gravel', 0.56, 0.54, 0.51, hardness: 0.8, tool: ToolType.shovel),
    BlockDef('sandstone', 'Sandstone', 0.80, 0.74, 0.52, hardness: 1.5, tool: ToolType.pickaxe, tier: 1),
    BlockDef('snow', 'Snow', 0.94, 0.95, 0.98, hardness: 0.4, tool: ToolType.shovel),
    BlockDef('spruce_log', 'Spruce Log', 0.30, 0.20, 0.12, hardness: 2.5, tool: ToolType.axe),
    BlockDef('spruce_leaves', 'Spruce Leaves', 0.17, 0.37, 0.23, hardness: 0.3, drop: '-'),
    BlockDef('cactus', 'Cactus', 0.29, 0.56, 0.25, hardness: 0.5),
    BlockDef('coal_ore', 'Coal Ore', 0.30, 0.30, 0.31, hardness: 3.5, tool: ToolType.pickaxe, tier: 1, drop: 'coal'),
    BlockDef('iron_ore', 'Iron Ore', 0.66, 0.54, 0.46, hardness: 4.0, tool: ToolType.pickaxe, tier: 2, drop: 'raw_iron'),
    BlockDef('gold_ore', 'Gold Ore', 0.78, 0.66, 0.30, hardness: 4.0, tool: ToolType.pickaxe, tier: 3, drop: 'raw_gold'),
    BlockDef('diamond_ore', 'Diamond Ore', 0.50, 0.85, 0.85, hardness: 5.0, tool: ToolType.pickaxe, tier: 3, drop: 'diamond'),
    BlockDef('bedrock', 'Bedrock', 0.22, 0.22, 0.24, hardness: -1, drop: '-'),
    BlockDef('oak_planks', 'Oak Planks', 0.72, 0.56, 0.33, hardness: 2.0, tool: ToolType.axe),
    BlockDef('cobblestone', 'Cobblestone', 0.44, 0.44, 0.45, hardness: 3.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('lamp', 'Lamp', 0.98, 0.88, 0.50, hardness: 0.5, light: 15),
    BlockDef('crafting_table', 'Crafting Table', 0.62, 0.44, 0.24, hardness: 2.5, tool: ToolType.axe),
    BlockDef('glass', 'Glass', 0.80, 0.92, 0.97, a: 0.35, opaque: false, hardness: 0.4, drop: '-'),
    BlockDef('bricks', 'Bricks', 0.66, 0.31, 0.26, hardness: 3.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('stone_bricks', 'Stone Bricks', 0.47, 0.47, 0.50, hardness: 3.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('mossy_stone_bricks', 'Mossy Stone Bricks', 0.40, 0.50, 0.40, hardness: 3.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('tall_grass', 'Tall Grass', 0.40, 0.68, 0.28, shape: BlockShape.cross, solid: false, opaque: false, hardness: 0.0, drop: '-'),
    BlockDef('flower_red', 'Red Flower', 0.88, 0.24, 0.24, shape: BlockShape.flower, solid: false, opaque: false, hardness: 0.0),
    BlockDef('flower_yellow', 'Yellow Flower', 0.94, 0.84, 0.26, shape: BlockShape.flower, solid: false, opaque: false, hardness: 0.0),
    BlockDef('lava', 'Lava', 0.98, 0.45, 0.10, a: 0.92, shape: BlockShape.liquid, solid: false, opaque: false, hardness: -1, drop: '-', light: 13),
    BlockDef('clay', 'Clay', 0.62, 0.64, 0.70, hardness: 0.8, tool: ToolType.shovel),
    BlockDef('torch', 'Torch', 0.98, 0.78, 0.35, shape: BlockShape.torch, solid: false, opaque: false, hardness: 0.0, light: 13),
    BlockDef('chest', 'Chest', 0.58, 0.40, 0.20, hardness: 2.5, tool: ToolType.axe),
    BlockDef('furnace', 'Furnace', 0.38, 0.38, 0.41, hardness: 3.5, tool: ToolType.pickaxe, tier: 1),
    BlockDef('wool', 'Wool', 0.93, 0.93, 0.92, hardness: 0.8),
    BlockDef('spruce_planks', 'Spruce Planks', 0.50, 0.36, 0.22, hardness: 2.0, tool: ToolType.axe),
    BlockDef('dead_bush', 'Dead Bush', 0.55, 0.42, 0.24, shape: BlockShape.cross, solid: false, opaque: false, hardness: 0.0, drop: 'stick'),
    BlockDef('mushroom', 'Mushroom', 0.75, 0.35, 0.30, shape: BlockShape.flower, solid: false, opaque: false, hardness: 0.0, light: 2),
    BlockDef('gold_block', 'Gold Block', 0.95, 0.80, 0.30, hardness: 4.0, tool: ToolType.pickaxe, tier: 3),
    BlockDef('iron_block', 'Iron Block', 0.82, 0.82, 0.84, hardness: 4.0, tool: ToolType.pickaxe, tier: 2),
    BlockDef('diamond_block', 'Diamond Block', 0.45, 0.90, 0.88, hardness: 5.0, tool: ToolType.pickaxe, tier: 3),
    BlockDef('ice', 'Ice', 0.70, 0.85, 0.98, a: 0.75, opaque: false, hardness: 0.5, tool: ToolType.pickaxe, drop: '-'),
    BlockDef('dark_stone', 'Dark Stone', 0.33, 0.33, 0.37, hardness: 4.0, tool: ToolType.pickaxe, tier: 1, drop: 'cobblestone'),
    BlockDef('bone_block', 'Bone Block', 0.88, 0.86, 0.76, hardness: 2.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('bed', 'Bed', 0.85, 0.25, 0.30, hardness: 0.5),
    BlockDef('wheat_0', 'Wheat Sprout', 0.45, 0.70, 0.30, shape: BlockShape.cross, solid: false, opaque: false, hardness: 0.0, drop: 'wheat_seeds'),
    BlockDef('wheat_1', 'Young Wheat', 0.60, 0.72, 0.30, shape: BlockShape.cross, solid: false, opaque: false, hardness: 0.0, drop: 'wheat_seeds'),
    BlockDef('wheat_2', 'Wheat', 0.85, 0.75, 0.30, shape: BlockShape.cross, solid: false, opaque: false, hardness: 0.0, drop: 'wheat'),
    BlockDef('farmland', 'Farmland', 0.40, 0.27, 0.16, hardness: 0.8, tool: ToolType.shovel, drop: 'dirt'),
    BlockDef('spawner', 'Monster Spawner', 0.20, 0.12, 0.28, hardness: 5.0, tool: ToolType.pickaxe, tier: 1, drop: 'magic_dust', light: 4),
    BlockDef('tnt', 'TNT', 0.85, 0.20, 0.15, hardness: 0.0),
    BlockDef('ladder', 'Ladder', 0.60, 0.45, 0.25, shape: BlockShape.cross, solid: false, opaque: false, hardness: 0.4, tool: ToolType.axe),
    BlockDef('door_z', 'Door', 0.62, 0.45, 0.25, shape: BlockShape.panelZ, opaque: false, hardness: 1.0, tool: ToolType.axe, drop: 'door'),
    BlockDef('door_x', 'Door', 0.62, 0.45, 0.25, shape: BlockShape.panelX, opaque: false, hardness: 1.0, tool: ToolType.axe, drop: 'door'),
    BlockDef('door_z_open', 'Open Door', 0.62, 0.45, 0.25, shape: BlockShape.panelX, solid: false, opaque: false, hardness: 1.0, tool: ToolType.axe, drop: 'door'),
    BlockDef('door_x_open', 'Open Door', 0.62, 0.45, 0.25, shape: BlockShape.panelZ, solid: false, opaque: false, hardness: 1.0, tool: ToolType.axe, drop: 'door'),
    BlockDef('wall_torch', 'Wall Torch', 0.98, 0.78, 0.35, shape: BlockShape.wallTorch, solid: false, opaque: false, hardness: 0.0, drop: 'torch', light: 13),
    BlockDef('enchanting_table', 'Enchanting Table', 0.38, 0.18, 0.55, hardness: 3.0, tool: ToolType.pickaxe, tier: 1, light: 7),
    BlockDef('brewing_stand', 'Brewing Stand', 0.30, 0.22, 0.30, hardness: 2.0, tool: ToolType.pickaxe, light: 3),
    BlockDef('waypoint', 'Waypoint', 0.35, 0.75, 0.95, hardness: 3.0, tool: ToolType.pickaxe, tier: 1, light: 10),
    BlockDef('oak_slab', 'Oak Slab', 0.72, 0.56, 0.33, shape: BlockShape.slab, opaque: false, hardness: 2.0, tool: ToolType.axe),
    BlockDef('stone_slab', 'Stone Slab', 0.50, 0.50, 0.52, shape: BlockShape.slab, opaque: false, hardness: 2.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('cobblestone_slab', 'Cobblestone Slab', 0.44, 0.44, 0.45, shape: BlockShape.slab, opaque: false, hardness: 2.0, tool: ToolType.pickaxe, tier: 1),
    BlockDef('oak_fence', 'Oak Fence', 0.43, 0.30, 0.17, shape: BlockShape.fence, opaque: false, hardness: 2.0, tool: ToolType.axe),
    BlockDef('oak_stairs_n', 'Oak Stairs', 0.72, 0.56, 0.33, shape: BlockShape.stairsN, opaque: false, hardness: 2.0, tool: ToolType.axe, drop: 'oak_stairs'),
    BlockDef('oak_stairs_e', 'Oak Stairs', 0.72, 0.56, 0.33, shape: BlockShape.stairsE, opaque: false, hardness: 2.0, tool: ToolType.axe, drop: 'oak_stairs'),
    BlockDef('oak_stairs_s', 'Oak Stairs', 0.72, 0.56, 0.33, shape: BlockShape.stairsS, opaque: false, hardness: 2.0, tool: ToolType.axe, drop: 'oak_stairs'),
    BlockDef('oak_stairs_w', 'Oak Stairs', 0.72, 0.56, 0.33, shape: BlockShape.stairsW, opaque: false, hardness: 2.0, tool: ToolType.axe, drop: 'oak_stairs'),
    BlockDef('stone_stairs_n', 'Stone Stairs', 0.50, 0.50, 0.52, shape: BlockShape.stairsN, opaque: false, hardness: 2.0, tool: ToolType.pickaxe, tier: 1, drop: 'stone_stairs'),
    BlockDef('stone_stairs_e', 'Stone Stairs', 0.50, 0.50, 0.52, shape: BlockShape.stairsE, opaque: false, hardness: 2.0, tool: ToolType.pickaxe, tier: 1, drop: 'stone_stairs'),
    BlockDef('stone_stairs_s', 'Stone Stairs', 0.50, 0.50, 0.52, shape: BlockShape.stairsS, opaque: false, hardness: 2.0, tool: ToolType.pickaxe, tier: 1, drop: 'stone_stairs'),
    BlockDef('stone_stairs_w', 'Stone Stairs', 0.50, 0.50, 0.52, shape: BlockShape.stairsW, opaque: false, hardness: 2.0, tool: ToolType.pickaxe, tier: 1, drop: 'stone_stairs'),
  ];

  static final Map<String, int> _indexById = {
    for (var i = 0; i < defs.length; i++) defs[i].id: i,
  };

  static int get count => defs.length;

  static int indexOf(String id) {
    final i = _indexById[id];
    if (i == null) throw ArgumentError('unknown block: $id');
    return i;
  }

  static bool has(String id) => _indexById.containsKey(id);
  static BlockDef def(int index) => defs[index];
  static String idOf(int index) => defs[index].id;
  static String displayName(int index) => defs[index].name;
  static bool isSolid(int index) => defs[index].solid;
  static bool isLiquid(int index) => defs[index].shape == BlockShape.liquid;
  static bool isOpaque(int index) => defs[index].opaque;
  static BlockShape shapeOf(int index) => defs[index].shape;
  static bool isPlant(int index) =>
      defs[index].shape == BlockShape.cross || defs[index].shape == BlockShape.flower;

  /// A block another block may be placed INTO: air, plants, liquids.
  static bool isReplaceable(int index) {
    final sh = defs[index].shape;
    return index == air || sh == BlockShape.cross || sh == BlockShape.flower || sh == BlockShape.liquid;
  }

  static double hardness(int index) => defs[index].hardness;
  static ToolType toolOf(int index) => defs[index].tool;
  static int minTier(int index) => defs[index].tier;

  /// The item dropped when broken: "" means nothing.
  static String dropOf(int index) {
    final drop = defs[index].drop;
    if (drop == '-') return '';
    if (drop == '') return defs[index].id;
    return drop;
  }

  static int lightOf(int index) => defs[index].light;

  static bool isStairs(int index) {
    final sh = defs[index].shape;
    return sh.index >= BlockShape.stairsN.index && sh.index <= BlockShape.stairsW.index;
  }

  /// The orientation of a stairs block whose HIGH step sits at the back, along
  /// [forwardX]/[forwardZ] (the direction the placer looks). [index] is any of
  /// the four orientations of one stairs.
  static int stairsFacing(int index, double forwardX, double forwardZ) {
    if (!isStairs(index)) throw ArgumentError('not a stairs block: ${idOf(index)}');
    final id = idOf(index);
    final base = id.substring(0, id.length - 2);
    final String suffix;
    if (forwardX.abs() > forwardZ.abs()) {
      suffix = forwardX > 0 ? '_e' : '_w';
    } else {
      suffix = forwardZ > 0 ? '_s' : '_n';
    }
    return indexOf(base + suffix);
  }

  // --- tables handed to the mesher isolate ------------------------------------

  static Float32List palette() {
    final out = Float32List(defs.length * 4);
    for (var i = 0; i < defs.length; i++) {
      out[i * 4] = defs[i].r;
      out[i * 4 + 1] = defs[i].g;
      out[i * 4 + 2] = defs[i].b;
      out[i * 4 + 3] = defs[i].a;
    }
    return out;
  }

  static Uint8List shapes() =>
      Uint8List.fromList([for (final d in defs) d.shape.index]);

  static Uint8List opaqueTable() =>
      Uint8List.fromList([for (final d in defs) d.opaque ? 1 : 0]);

  static Uint8List emission() =>
      Uint8List.fromList([for (final d in defs) d.light]);

  /// Every block id the generator needs, resolved once so the generator never
  /// spells a byte.
  static Map<String, int> generatorIds() => {
        for (final id in const [
          'stone', 'dirt', 'grass', 'sand', 'water', 'oak_log', 'oak_leaves', 'gravel',
          'sandstone', 'snow', 'spruce_log', 'spruce_leaves', 'cactus', 'coal_ore', 'iron_ore',
          'gold_ore', 'diamond_ore', 'bedrock', 'tall_grass', 'flower_red', 'flower_yellow', 'lava',
          'clay', 'dead_bush', 'mushroom', 'ice', 'dark_stone', 'mossy_stone_bricks', 'stone_bricks',
          'chest', 'lamp', 'bone_block', 'oak_planks', 'ladder', 'spawner', 'glass',
          'crafting_table', 'furnace',
        ])
          id: indexOf(id),
      };
}
