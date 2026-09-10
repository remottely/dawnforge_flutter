import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'chunk_mesher.dart';
import 'terrain_generator.dart';

/// Everything a worker isolate needs to build its own generator and mesher.
class WorkerConfig {
  WorkerConfig({
    required this.seed,
    required this.ids,
    required this.palette,
    required this.shapes,
    required this.opaque,
    required this.emission,
  });
  final int seed;
  final Map<String, int> ids;
  final Float32List palette;
  final Uint8List shapes;
  final Uint8List opaque;
  final Uint8List emission;
}

class _Worker {
  _Worker(this.isolate, this.port);
  final Isolate isolate;
  final SendPort port;
  int pending = 0;
}

/// A fixed pool of isolates running terrain generation and meshing (the
/// Godot POC's C# on WorkerThreadPool). Requests are answered by futures.
class ChunkWorkerPool {
  ChunkWorkerPool(this.config, {this.workers = 3});

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

  Future<Uint8List> generate(int cx, int cz) async {
    final t = await _request<TransferableTypedData>(['gen', cx, cz]);
    return t.materialize().asUint8List();
  }

  Future<ChunkMeshResult> mesh(int cx, int cz, List<Uint8List?> ring) async {
    final reply = await _request<List<Object?>>(['mesh', cx, cz, ring]);
    MeshSurface surface(int at) {
      final p = (reply[at] as TransferableTypedData).materialize().asFloat32List();
      final n = (reply[at + 1] as TransferableTypedData).materialize().asFloat32List();
      final c = (reply[at + 2] as TransferableTypedData).materialize().asFloat32List();
      final i = (reply[at + 3] as TransferableTypedData).materialize().asInt32List();
      return MeshSurface(p, n, c, i);
    }

    return ChunkMeshResult(surface(0), surface(4), surface(8));
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
  final generator = TerrainGenerator(ids: config.ids, seed: config.seed);
  final mesher = ChunkMesher(
    palette: config.palette,
    shape: config.shapes,
    opaque: config.opaque,
    emission: config.emission,
  );
  final port = ReceivePort();
  ready.send(port.sendPort);
  port.listen((message) {
    final list = message as List<Object?>;
    final id = list[0] as int;
    final kind = list[1] as String;
    if (kind == 'gen') {
      final blocks = generator.generate(list[2] as int, list[3] as int);
      out.send([id, TransferableTypedData.fromList([blocks])]);
    } else if (kind == 'mesh') {
      final ring = (list[4] as List<Object?>).cast<Uint8List?>();
      final r = mesher.build(list[2] as int, list[3] as int, ring[0]!, ring[1], ring[2], ring[3], ring[4], ring[5],
          ring[6], ring[7], ring[8]);
      List<Object?> pack(MeshSurface s) => [
            TransferableTypedData.fromList([s.positions]),
            TransferableTypedData.fromList([s.normals]),
            TransferableTypedData.fromList([s.colors]),
            TransferableTypedData.fromList([s.indices]),
          ];
      out.send([id, [...pack(r.solid), ...pack(r.liquid), ...pack(r.cutout)]]);
    }
  });
}
