import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:voxel_game/voxel_game.dart';

const _blocks = [
  BlockType('stone', color: 0x808080, hardness: 1.5, tool: 'pickaxe', tier: 1, drop: 'cobblestone'),
  BlockType('cobblestone', color: 0x707070, hardness: 2.0, tool: 'pickaxe'),
  BlockType('dirt', color: 0x74502F, hardness: 0.5, tool: 'shovel'),
  BlockType('grass', color: 0x4C9437, hardness: 0.6, tool: 'shovel', drop: 'dirt'),
  BlockType('planks', color: 0xB08850, hardness: 1.0, tool: 'axe'),
  BlockType.liquid('water', color: 0x3366CC),
  BlockType.liquid('water_flow', color: 0x3366CC, kind: 'water', source: false),
];

/// Level grass at y 20 (the first air cell), no caves, no trees.
VoxelGameSpec _flat({List<MobSpec> mobs = const [], PlayerSpec player = const PlayerSpec(), SkySpec sky = SkySpec.alwaysDay}) =>
    VoxelGameSpec(
      blocks: _blocks,
      world: const WorldGenSpec(
        terrain: TerrainRecipe.flat(20),
        seaLevel: 5,
        caves: CaveSpec.none,
        biomes: [Biome('plains', top: 'grass', under: 'dirt')],
      ),
      items: const [ItemType('wooden_pickaxe', color: 0xB08850, tool: 'pickaxe', tier: 1, stack: 1, durability: 60, damage: 3)],
      player: player,
      mobs: mobs,
      sky: sky,
    );

Future<VoxelGame> _start(VoxelGameSpec spec) async {
  final game = await VoxelGame.startHeadless(spec);
  game.spawner.enabled = false;
  for (var i = 0; i < 600 && !game.ready; i++) {
    game.frame(1 / 60);
    await Future<void>.delayed(Duration.zero);
  }
  expect(game.ready, isTrue, reason: 'the spawn chunk loads and the player stands on it');
  return game;
}

/// [seconds] of simulation, letting the chunk jobs land between frames.
Future<void> _run(VoxelGame game, double seconds) async {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    game.frame(1 / 60);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('the player stands on the ground, walks forward and jumps', () async {
    final game = await _start(_flat());
    final p = game.player;
    await _run(game, 0.5);
    expect(p.position.y, closeTo(20.0 + 0.001, 0.01));
    expect(p.onFloor, isTrue);
    final start = p.position.clone();
    game.input.hold(VoxelAction.moveForward, true);
    await _run(game, 1.0);
    game.input.hold(VoxelAction.moveForward, false);
    final walked = (p.position - start)..y = 0;
    expect(walked.length, greaterThan(3.0), reason: '4.6 m/s for a second, after the ease-in');
    expect(p.position.z, lessThan(start.z), reason: 'yaw 0 walks toward -z');
    game.input.hold(VoxelAction.jump, true);
    var peak = p.position.y;
    for (var i = 0; i < 30; i++) {
      await _run(game, 1 / 60);
      peak = peak > p.position.y ? peak : p.position.y;
    }
    game.input.hold(VoxelAction.jump, false);
    expect(peak - 20.0, greaterThan(1.2));
  });

  test('a fall of more than four blocks hurts; a creative player never', () async {
    final game = await _start(_flat());
    final p = game.player;
    p.position = Vector3(p.position.x, 32, p.position.z);
    await _run(game, 2.0);
    expect(p.onFloor, isTrue);
    expect(p.hp, lessThan(p.spec.hp), reason: 'twelve blocks: (12 - 4) x 1.2 = 9');
    final creative = await _start(_flat(player: const PlayerSpec(creative: true)));
    creative.player.position.y = 32;
    await _run(creative, 2.0);
    expect(creative.player.hp, creative.player.spec.hp);
  });

  test('mining the block underfoot drops its item, which is picked up', () async {
    final game = await _start(_flat());
    final p = game.player;
    p.pitch = -1.5; // straight down
    game.input.hold(VoxelAction.attack, true);
    await _run(game, 2.0);
    game.input.hold(VoxelAction.attack, false);
    await _run(game, 1.5);
    expect(p.inventory.countOf('dirt'), greaterThanOrEqualTo(1), reason: 'grass drops dirt, and the drop flies to the player');
  });

  test('a held block is placed against the aimed face and used up', () async {
    final game = await _start(_flat(player: const PlayerSpec(startingItems: {'planks': 3})));
    final p = game.player;
    p.pitch = -0.9;
    await _run(game, 0.2);
    final aimed = p.aimedBlock!;
    game.input.tap(VoxelAction.use);
    await _run(game, 0.1);
    expect(game.world.blockNameAt(aimed.block + aimed.normal), 'planks');
    expect(p.inventory.countOf('planks'), 2);
  });

  test('stone needs a pickaxe; with one it breaks into cobblestone', () async {
    final game = await _start(_flat(player: const PlayerSpec(startingItems: {'wooden_pickaxe': 1})));
    final stone = game.blocks[game.blocks.indexOf('stone')];
    expect(game.mining.mineTime(stone, null), -1);
    expect(game.mining.mineTime(stone, game.items['wooden_pickaxe']), closeTo(0.75, 1e-9));
  });

  test('a hunter chases the player and strikes; the player hits back and it drops its loot', () async {
    const zombie = MobSpec('zombie',
        hp: 6, speed: 3.0, brain: [MeleeAttack(damage: 2), Hunt(range: 20), Wander()], drops: [Drop('dirt', 2, 2)]);
    final game = await _start(_flat(mobs: const [zombie], player: const PlayerSpec(startingItems: {'wooden_pickaxe': 1})));
    final p = game.player;
    final m = game.spawnMob('zombie', p.position + Vector3(0, 0, -8));
    await _run(game, 4.0);
    expect(p.hp, lessThan(p.spec.hp), reason: 'it walked eight blocks and bit');
    expect(m.running.whereType<Hunt>(), isNotEmpty);
    // Face it and swing until it falls.
    for (var i = 0; i < 20 && !m.isDead; i++) {
      final to = m.centre() - p.eyePosition;
      p.yaw = -Vector3(0, 0, -1).angleToSigned(Vector3(to.x, 0, to.z).normalized(), Vector3(0, 1, 0));
      p.pitch = 0.0;
      game.input.tap(VoxelAction.attack);
      await _run(game, 0.5);
    }
    expect(m.isDead, isTrue);
    await _run(game, 2.0);
    expect(p.inventory.countOf('dirt'), greaterThanOrEqualTo(2));
    expect(game.mobs, isEmpty, reason: 'a dead mob leaves the world');
  });

  test('a frightened animal runs from what hurt it', () async {
    const sheep = MobSpec('sheep', hp: 8, speed: 2.0, rig: Rig.quadruped(), brain: [FleeWhenHurt(), Wander()]);
    final game = await _start(_flat(mobs: const [sheep]));
    final p = game.player;
    final m = game.spawnMob('sheep', p.position + Vector3(2, 0, 0));
    await _run(game, 0.3);
    m.takeDamage(Damage(1, from: p.position, attacker: p));
    await _run(game, 2.0);
    expect(m.position.distanceTo(p.position), greaterThan(4.0));
  });

  test('a creeper that reaches the player blows a hole in the ground', () async {
    const creeper = MobSpec('creeper', hp: 10, speed: 3.0, brain: [Explode(fuse: 0.8, radius: 2.5, damage: 6), Hunt()]);
    final game = await _start(_flat(mobs: const [creeper]));
    final p = game.player;
    final m = game.spawnMob('creeper', p.position + Vector3(4, 0, 0));
    final hpBefore = p.hp;
    await _run(game, 4.0);
    expect(m.isDead, isTrue);
    expect(p.hp, lessThan(hpBefore));
    final c = IVec3.floor(m.position);
    expect(game.world.getBlock(c + IVec3.down), BlockRegistry.air, reason: 'the grass under it is gone');
  });

  test('at night the spawner fills the dark with what the rules allow', () async {
    const night = MobSpec('ghoul', hp: 4, brain: [Wander()], spawn: SpawnRule.dark(maxAlive: 4));
    const day = MobSpec('cow', hp: 4, brain: [Wander()], spawn: SpawnRule.daylight(maxAlive: 4));
    final game = await _start(_flat(mobs: const [night, day], sky: const SkySpec(startTime: 0.0, cycle: false)));
    game.spawner
      ..enabled = true
      ..minDistance = 6
      ..maxDistance = 14;
    await _run(game, 20.0);
    expect(game.mobs.where((m) => m.spec.id == 'ghoul'), isNotEmpty);
    expect(game.mobs.where((m) => m.spec.id == 'cow'), isEmpty);
  });

  test('water poured on the ground flows and a system runs every step', () async {
    var steps = 0;
    final spec = _flat();
    final withSystem = VoxelGameSpec(
      blocks: spec.blocks,
      world: spec.world,
      sky: spec.sky,
      onTick: (game, dt) => steps++,
    );
    final game = await _start(withSystem);
    final at = IVec3.floor(game.player.position) + const IVec3(3, 0, 3);
    game.world.setBlockNamed(at, 'water');
    await _run(game, 3.0);
    expect(game.world.blockNameAt(at + const IVec3(1, 0, 0)), 'water_flow');
    expect(steps, greaterThan(100));
  });

  test('a saved world comes back: its edits, its player, its bag and its clock', () async {
    final dir = Directory.systemTemp.createTempSync('voxel_saves');
    addTearDown(() => dir.deleteSync(recursive: true));
    final saves = WorldSaves(dir);
    final game = await _start(_flat(player: const PlayerSpec(startingItems: {'planks': 5})));
    final p = game.player;
    final cell = IVec3.floor(p.position) + const IVec3(2, 0, 0);
    game.world.setBlockNamed(cell, 'planks');
    p.inventory.remove('planks', 2);
    game.input.hold(VoxelAction.moveForward, true);
    await _run(game, 0.5);
    game.input.hold(VoxelAction.moveForward, false);
    await _run(game, 0.3);
    p.yaw = 1.25;
    game.timeOfDay = 0.8;
    final where = p.position.clone();
    saves.save(game, 'slot1');
    expect(saves.list(), ['slot1']);

    final back = await VoxelGame.startHeadless(_flat(player: const PlayerSpec(startingItems: {'planks': 5})), save: saves.read('slot1'));
    back.spawner.enabled = false;
    for (var i = 0; i < 600 && !back.ready; i++) {
      back.frame(1 / 60);
      await Future<void>.delayed(Duration.zero);
    }
    expect(back.world.blockNameAt(cell), 'planks');
    expect(back.player.position.distanceTo(where), lessThan(0.05));
    expect(back.player.yaw, 1.25);
    expect(back.player.inventory.countOf('planks'), 3);
    expect(back.timeOfDay, closeTo(0.8, 1e-9));
    saves.delete('slot1');
    expect(saves.list(), isEmpty);
  });

  test('the player is heard: steps by the ground, digging, breaking and placing by material', () async {
    final game = await _start(_flat(player: const PlayerSpec(startingItems: {'planks': 2})));
    final heard = game.sounds as SilentSounds;
    final p = game.player;
    game.input.hold(VoxelAction.moveForward, true);
    await _run(game, 1.0);
    game.input.hold(VoxelAction.moveForward, false);
    expect(heard.played.where((s) => s == 'step_earth').length, greaterThanOrEqualTo(2), reason: 'grass is dug with a shovel: earth');
    p.pitch = -1.5;
    game.input.hold(VoxelAction.attack, true);
    await _run(game, 2.0);
    game.input.hold(VoxelAction.attack, false);
    expect(heard.played, contains('dig'));
    expect(heard.played, contains('break_earth'));
    p.pitch = -0.9;
    await _run(game, 0.2);
    game.input.tap(VoxelAction.use);
    await _run(game, 0.1);
    expect(heard.played, contains('place_wood'), reason: 'planks are cut with an axe: wood');
    expect(game.soundFamily(game.blocks.indexOf('water')), SoundFamily.liquid);
    expect(game.soundFamily(game.blocks.indexOf('stone')), SoundFamily.stone);
  });
}
