import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import '../grid/voxel_block_table.dart';
import '../mesh/chunk_mesher.dart';
import 'chunk_streamer.dart';

/// Fills one chunk volume ([ChunkSize.volume] bytes of block ids) for chunk
/// ([cx], [cz]) of [dimension]. Runs on a worker isolate: it must be pure in
/// (seed, position) and touch nothing outside itself.
abstract interface class ChunkGenerator {
  Uint8List generateIn(int cx, int cz, int dimension);
}

/// Builds a [ChunkGenerator] inside a worker isolate. It is sent to the
/// isolate, so it must capture only sendable values: make it in a static or
/// top-level function, never in an instance method whose `this` holds scene
/// objects.
typedef ChunkGeneratorFactory = ChunkGenerator Function();

/// Everything a worker isolate needs to build its own generator and mesher.
class WorkerConfig {
  WorkerConfig({required this.generator, required this.table, this.lighting = true});

  final ChunkGeneratorFactory generator;
  final VoxelBlockTable table;

  /// False skips both light BFS (skylight everywhere): the probe's cost comparison.
  final bool lighting;
}

class _Worker {
  _Worker(this.isolate, this.port);
  final Isolate isolate;
  final SendPort port;
  int pending = 0;
}

/// A fixed pool of isolates running chunk generation and meshing. Requests
/// are answered by futures; each goes to the least busy worker.
class ChunkWorkerPool implements ChunkJobs {
  /// [workers] defaults to [defaultWorkers].
  ChunkWorkerPool(this.config, {int? workers}) : workers = workers ?? defaultWorkers;

  /// One isolate per core, leaving one for the UI and raster threads (VP1.5b:
  /// the 2026-09-11 measurement took radius-16 fill from 2,981 to 1,956 ms going
  /// from 3 isolates to 10 on a 12-core machine).
  static int get defaultWorkers => math.max(1, Platform.numberOfProcessors - 1);

  final WorkerConfig config;
  final int workers;
  final List<_Worker> _workers = [];
  final ReceivePort _inbox = ReceivePort();
  final Map<int, Completer<Object?>> _waiting = {};
  final Map<int, _Worker> _owner = {};
  int _nextId = 1;
  bool _disposed = false;

  Future<void> start() async {
    _inbox.listen(_onReply);
    for (var i = 0; i < workers; i++) {
      final ready = ReceivePort();
      final isolate = await Isolate.spawn(_workerMain, [ready.sendPort, _inbox.sendPort, config],
          debugName: 'chunk-worker-$i');
      final port = await ready.first as SendPort;
      ready.close();
      _workers.add(_Worker(isolate, port));
    }
  }

  void _onReply(Object? message) {
    final list = message as List<Object?>;
    final id = list[0] as int;
    final c = _waiting.remove(id);
    _owner.remove(id)?.pending--;
    c?.complete(list[1]);
  }

  _Worker _pick() {
    _Worker best = _workers.first;
    for (final w in _workers) {
      if (w.pending < best.pending) best = w;
    }
    return best;
  }

  Future<T> _request<T>(List<Object?> body) {
    final id = _nextId++;
    final c = Completer<Object?>();
    _waiting[id] = c;
    final w = _pick();
    w.pending++;
    _owner[id] = w;
    w.port.send([id, ...body]);
    return c.future.then((v) => v as T);
  }

  /// The job carries the dimension it was dispatched for, so a result that
  /// lands after a dimension switch still holds what it was asked for.
  @override
  Future<Uint8List> generate(int cx, int cz, [int dimension = 0]) async {
    final t = await _request<TransferableTypedData>(['gen', cx, cz, dimension]);
    return t.materialize().asUint8List();
  }

  /// [ring] is the chunk and its eight neighbours, in the order
  /// c, nx, px, nz, pz, nxnz, pxnz, nxpz, pxpz; a missing neighbour is null.
  @override
  Future<ChunkMeshResult> mesh(int cx, int cz, List<Uint8List?> ring) async {
    final reply = await _request<List<Object?>>(['mesh', cx, cz, ring]);
    ByteBuffer bytes(int at) => (reply[at] as TransferableTypedData).materialize();
    MeshSurface surface(int at) => MeshSurface(bytes(at).asFloat32List(), bytes(at + 1).asFloat32List(),
        bytes(at + 2).asFloat32List(), bytes(at + 3).asFloat32List(), bytes(at + 4).asInt32List());

    return ChunkMeshResult(surface(0), surface(5), surface(10), surface(15),
        sky: bytes(20).asUint8List(), block: bytes(21).asUint8List(), aoVerts: reply[22] as int, ms: reply[23] as double);
  }

  int get inflight => _waiting.length;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final w in _workers) {
      w.isolate.kill(priority: Isolate.immediate);
    }
    _inbox.close();
    for (final c in _waiting.values) {
      if (!c.isCompleted) c.completeError(StateError('worker pool disposed'));
    }
    _waiting.clear();
  }
}

void _workerMain(List<Object?> args) {
  final ready = args[0] as SendPort;
  final out = args[1] as SendPort;
  final config = args[2] as WorkerConfig;
  final generator = config.generator();
  final mesher = config.table.mesher(lighting: config.lighting);
  final port = ReceivePort();
  ready.send(port.sendPort);
  port.listen((message) {
    final list = message as List<Object?>;
    final id = list[0] as int;
    final kind = list[1] as String;
    if (kind == 'gen') {
      final blocks = generator.generateIn(list[2] as int, list[3] as int, list[4] as int);
      out.send([id, TransferableTypedData.fromList([blocks])]);
    } else if (kind == 'mesh') {
      final ring = (list[4] as List<Object?>).cast<Uint8List?>();
      final r = mesher.build(list[2] as int, list[3] as int, ring[0]!, ring[1], ring[2], ring[3], ring[4], ring[5],
          ring[6], ring[7], ring[8]);
      List<Object?> pack(MeshSurface s) => [
            TransferableTypedData.fromList([s.positions]),
            TransferableTypedData.fromList([s.normals]),
            TransferableTypedData.fromList([s.colors]),
            TransferableTypedData.fromList([s.light]),
            TransferableTypedData.fromList([s.indices]),
          ];
      out.send([
        id,
        [
          ...pack(r.solid), ...pack(r.liquid), ...pack(r.cutout), ...pack(r.glow),
          TransferableTypedData.fromList([r.sky]),
          TransferableTypedData.fromList([r.block]),
          r.aoVerts,
          r.ms,
        ]
      ]);
    }
  });
}
