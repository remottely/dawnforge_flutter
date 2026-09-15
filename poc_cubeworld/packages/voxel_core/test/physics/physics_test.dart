import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:voxel_core/voxel_core.dart';

const int _stone = 1;
const int _water = 2;
const int _slab = 3;
const int _glass = 4;

final _table = VoxelBlockTable(const [
  VoxelBlockDef(shape: BlockShape.cube, solid: false, opaque: false, r: 0, g: 0, b: 0, a: 0),
  VoxelBlockDef(shape: BlockShape.cube, solid: true, opaque: true, r: 0.5, g: 0.5, b: 0.5),
  VoxelBlockDef(
      shape: BlockShape.liquid, solid: false, opaque: false, r: 0.2, g: 0.4, b: 0.8, a: 0.6, liquidKind: 0, liquidSource: true),
  VoxelBlockDef(shape: BlockShape.slab, solid: true, opaque: false, r: 0.7, g: 0.5, b: 0.3),
  VoxelBlockDef(shape: BlockShape.cube, solid: true, opaque: false, r: 0.9, g: 0.9, b: 1.0, a: 0.3),
]);

/// A sparse world: stone floor filling y 0..9 everywhere, plus placed cells.
class _World implements VoxelQuery {
  final Map<IVec3, int> cells = {};

  @override
  VoxelBlockTable get table => _table;

  @override
  int getBlockXYZ(int x, int y, int z) => cells[IVec3(x, y, z)] ?? (y >= 0 && y < 10 ? _stone : 0);
}

void main() {
  late _World world;
  late VoxelBody body;

  setUp(() {
    world = _World();
    body = VoxelBody()..setup(world, 0.3, 1.8);
  });

  void run(double seconds, void Function() eachTick) {
    for (var t = 0.0; t < seconds; t += 1 / 60) {
      eachTick();
      body.applyGravity(1 / 60);
      body.move(1 / 60);
    }
  }

  test('a falling body lands flush on the floor', () {
    body.position = Vector3(4.5, 14.0, 4.5);
    run(1.5, () {});
    expect(body.onFloor, isTrue);
    expect(body.position.y, closeTo(10.0 + VoxelBody.skin, 1e-6));
  });

  test('walking into a wall stops at the face, minus the half width and skin', () {
    world.cells[const IVec3(7, 10, 4)] = _stone;
    world.cells[const IVec3(7, 11, 4)] = _stone;
    body.position = Vector3(4.5, 10.001, 4.5);
    run(1.0, () => body.velocity.x = 4.0);
    expect(body.hitWall, isTrue);
    expect(body.position.x, closeTo(7.0 - 0.3 - VoxelBody.skin, 1e-6));
  });

  test('a slab is stepped onto; a full-height wall is not', () {
    world.cells[const IVec3(6, 10, 4)] = _slab;
    body.position = Vector3(4.5, 10.001, 4.5);
    var stepped = false;
    run(1.0, () {
      body.velocity.x = 3.0;
      if (body.tryStepUp()) stepped = true;
    });
    expect(stepped, isTrue);
    expect(body.position.y, greaterThan(10.4));

    world.cells[const IVec3(9, 11, 4)] = _stone;
    world.cells[const IVec3(9, 12, 4)] = _stone;
    world.cells[const IVec3(9, 13, 4)] = _stone;
    final wall = VoxelBody()
      ..setup(world, 0.3, 1.8)
      ..position = Vector3(8.5, 10.001, 4.5);
    for (var tick = 0; tick < 20 && !wall.hitWall; tick++) {
      wall.velocity.x = 3.0;
      wall.move(1 / 60);
    }
    expect(wall.hitWall, isTrue);
    // Without gravity the sweep never lands, so stand the body on the floor.
    wall.onFloor = true;
    expect(wall.tryStepUp(), isFalse, reason: 'both lifts overlap the wall');
    expect(wall.position.y, closeTo(10.001, 1e-6), reason: 'vector_math stores float32');
  });

  test('fluid sensing reports the liquid kind at feet and head', () {
    world.cells[const IVec3(4, 10, 4)] = _water;
    body.position = Vector3(4.5, 10.001, 4.5);
    body.move(0);
    expect(body.inWater, isTrue);
    expect(body.headInWater, isFalse);
    expect(body.feetLiquid, 0);
    expect(body.headLiquid, VoxelBlockDef.noLiquid);
  });

  test('a noclip body moves through stone', () {
    body
      ..noclip = true
      ..position = Vector3(4.5, 5.0, 4.5)
      ..velocity = Vector3(10, 0, 0);
    body.move(0.5);
    expect(body.position.x, closeTo(9.5, 1e-9));
  });

  test('the solid ray hits the floor from above through the top face; glass is solid, water is not', () {
    world.cells[const IVec3(2, 12, 2)] = _water;
    final hit = VoxelRaycast.solid(world, Vector3(2.5, 15.5, 2.5), Vector3(0, -1, 0), 10)!;
    expect(hit.block, const IVec3(2, 9, 2));
    expect(hit.normal, IVec3.up);
    expect(hit.distance, closeTo(5.5, 1e-9));

    world.cells[const IVec3(5, 12, 2)] = _glass;
    expect(VoxelRaycast.solid(world, Vector3(2.5, 12.5, 2.5), Vector3(1, 0, 0), 10)!.block, const IVec3(5, 12, 2));
    expect(VoxelRaycast.solid(world, Vector3(2.5, 15.5, 2.5), Vector3(0, 1, 0), 10), isNull);
  });

  test('the liquid ray finds water and stops at the first solid', () {
    world.cells[const IVec3(2, 10, 2)] = _water;
    expect(VoxelRaycast.liquid(world, Vector3(2.5, 13.5, 2.5), Vector3(0, -1, 0), 10), const IVec3(2, 10, 2));
    expect(VoxelRaycast.liquid(world, Vector3(6.5, 13.5, 6.5), Vector3(0, -1, 0), 10), isNull);
  });
}
