# voxel_signals

Circuits and rails for `voxel_core` worlds. You say which block ids are
wires, levers, buttons, lamps, doors or pistons; the network carries power
that fades by one each cell. Rails turn themselves to meet their
neighbours, and carts follow them. Pure Dart.

> **Status: 0.0.0.** The API can still change. Not published yet.

## Features

- `SignalRules`: wires, power sources, toggles, timed buttons and what reacts.
- `SignalNetwork`: power strength per cell (15 down to 0), `use` a switch, `tick` it.
- `SignalReactions`: stock reactions: `swap` (a lamp), `door`, `piston`, `poweredRun`, `trigger`.
- `RailGraph` / `RailVariant`: rails that orient on placement, slopes, and the next cell for a cart.

## Install

`voxel_signals` is at 0.0.0 and not on pub.dev yet. Depend on it by path (or by git):

```yaml
dependencies:
  voxel_signals:
    path: ../packages/voxel_signals
```

Dart SDK `^3.13.0`.

## Usage

1. **Give the network your world.** It needs a `VoxelEditor` (read and write
   blocks), and your world must tell it about every edit:

   ```dart
   @override
   bool setBlock(IVec3 cell, int id) {
     final old = getBlockXYZ(cell.x, cell.y, cell.z);
     // ...write the block...
     signals.touch(cell, old, id);
     return true;
   }
   ```

2. **Declare the circuit blocks.**

   ```dart
   final signals = SignalNetwork(world, SignalRules(
     wireOff: wireOff,
     wireOn: wireOn,
     sources: const {leverOn},
     toggles: const {leverOff: leverOn, leverOn: leverOff},
     reactions: {
       lampOff: SignalReactions.swap(lampOff, lampOn),
       lampOn: SignalReactions.swap(lampOff, lampOn),
     },
   ));
   ```

3. **Tick it every frame** with `signals.tick(dt)`, and call
   `signals.use(cell)` when the player clicks a lever.

4. **Rails:** name each rail shape once, then place rails through the graph.

   ```dart
   final rails = RailGraph({railNs: const RailVariant('rail', 'ns'), railEw: const RailVariant('rail', 'ew') /* ... */});
   rails.place(world, cell, railNs); // turns to meet its neighbours
   final next = rails.nextCell(world, cell, RailGraph.e);
   ```

## Example

```sh
dart run example/voxel_signals_example.dart
```

[`example/voxel_signals_example.dart`](example/voxel_signals_example.dart)
lights a lamp with a lever and a wire, lays a rail line with a curve and rolls
a cart along it.
