import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

import '../core/ivec3.dart';
import '../core/species.dart';
import '../entities/mob.dart';
import '../entities/remote_player.dart';
import 'game.dart';
import 'game_state.dart';

enum NetMode { solo, host, client }

class _Peer {
  _Peer(this.id, this.socket);
  final int id;
  final Socket socket;
  final StringBuffer _buf = StringBuffer();
}

/// Multiplayer probe (stage 15), on TCP newline-delimited JSON instead of
/// ENet. The host runs the whole simulation: mobs, projectile hits, block
/// edits. A client sends requests (block edit, shot) and receives what to
/// draw: player poses, mob puppets, projectile replicas that never damage, and
/// the host's clock.
class Net {
  Net._();
  static final Net instance = Net._();

  static const int port = 7777;

  NetMode mode = NetMode.solo;
  Game? main;
  Uint8List pendingEdits = Uint8List(0);
  final Map<int, RemotePlayer> _puppets = {};
  final Map<int, Mob> _mobPuppets = {};
  double _poseTimer = 0.0;
  double _mobTimer = 0.0;
  double _timeTimer = 0.0;
  bool connected = false;
  bool _applying = false;
  bool _mobPacketSeen = false;
  ServerSocket? _server;
  Socket? _client;
  final Map<int, _Peer> _peers = {};
  int _nextPeer = 2;
  final StringBuffer _clientBuf = StringBuffer();

  /// Set by a hello that arrives before the world exists.
  void Function()? onHelloBeforeWorld;

  bool get isHost => mode == NetMode.host;
  bool get isClient => mode == NetMode.client;

  Future<bool> host() async {
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    } catch (e) {
      debugPrint('[net] could not open port $port: $e');
      return false;
    }
    mode = NetMode.host;
    _server!.listen((socket) {
      final peer = _Peer(_nextPeer++, socket);
      _peers[peer.id] = peer;
      debugPrint('[net] peer ${peer.id} joined');
      socket.setOption(SocketOption.tcpNoDelay, true);
      unawaited(socket.done.then((_) {}, onError: (Object e) => debugPrint('[net] peer ${peer.id} socket closed: $e')));
      utf8.decoder.bind(socket).listen((chunk) => _feed(peer._buf, chunk, (m) => _onHostMessage(peer.id, m)),
          onDone: () => _onPeerLeft(peer.id), onError: (Object e) => _onPeerLeft(peer.id));
      _onPeerJoined(peer.id);
    });
    return true;
  }

  Future<bool> join(String ip) async {
    try {
      _client = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[net] join failed: $e');
      return false;
    }
    mode = NetMode.client;
    _client!.setOption(SocketOption.tcpNoDelay, true);
    unawaited(_client!.done.then((_) {}, onError: (Object e) => debugPrint('[net] socket closed: $e')));
    GameState.instance.worldName = 'client_${DateTime.now().millisecondsSinceEpoch % 100000}';
    GameState.instance.freshWorld = true;
    utf8.decoder.bind(_client!).listen((chunk) => _feed(_clientBuf, chunk, _onClientMessage), onDone: () {
      debugPrint('[net] server disconnected');
      main?.notify('Host left');
    }, onError: (Object e) => debugPrint('[net] $e'));
    return true;
  }

  void _feed(StringBuffer buf, String chunk, void Function(Map<String, dynamic>) handle) {
    buf.write(chunk);
    final s = buf.toString();
    final last = s.lastIndexOf('\n');
    if (last < 0) return;
    buf.clear();
    buf.write(s.substring(last + 1));
    for (final line in s.substring(0, last).split('\n')) {
      if (line.isEmpty) continue;
      try {
        handle(jsonDecode(line) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[net] bad message: $e');
      }
    }
  }

  void _sendTo(Socket s, Map<String, Object?> m) {
    try {
      s.write('${jsonEncode(m)}\n');
    } catch (e) {
      debugPrint('[net] send failed: $e');
    }
  }

  void _broadcast(Map<String, Object?> m) {
    for (final p in _peers.values) {
      _sendTo(p.socket, m);
    }
  }

  void _toHost(Map<String, Object?> m) {
    final c = _client;
    if (c != null) _sendTo(c, m);
  }

  static List<double> _v(Vector3 v) => [v.x, v.y, v.z];
  static Vector3 _vec(dynamic l) {
    final a = (l as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    return Vector3(a[0], a[1], a[2]);
  }

  void _onPeerJoined(int id) {
    final m = main;
    if (m == null) return;
    m.saveGame();
    final bytes = m.world.editsToBytes();
    _sendTo(_peers[id]!.socket, {'t': 'hello', 'seed': m.world.seedValue, 'time': m.timeOfDay, 'edits': base64Encode(bytes)});
  }

  void _onPeerLeft(int id) {
    _peers.remove(id);
    final p = _puppets.remove(id);
    if (p != null) p.removed = true;
  }

  void _onHostMessage(int sender, Map<String, dynamic> msg) {
    final m = main;
    if (m == null) return;
    switch (msg['t']) {
      case 'block_req':
        m.world.setBlock(IVec3(msg['x'] as int, msg['y'] as int, msg['z'] as int), msg['id'] as int);
      case 'pose':
        _onPose(sender, msg);
      case 'fire':
        final owner = _puppets[sender] ?? m.player;
        m.spawnProjectile(_vec(msg['from']), _vec(msg['vel']), (msg['dmg'] as num).toDouble(), owner, msg['kind'] as String,
            (msg['radius'] as num).toDouble(), (msg['kb'] as num).toDouble());
      case 'melee':
        final attacker = _puppets[sender] ?? m.player;
        m.meleeStrike(_vec(msg['dir']), (msg['dmg'] as num).toDouble(), (msg['follow'] as num).toDouble(), attacker);
    }
  }

  void _onClientMessage(Map<String, dynamic> msg) {
    switch (msg['t']) {
      case 'hello':
        GameState.instance.seedValue = msg['seed'] as int;
        pendingEdits = base64Decode(msg['edits'] as String);
        connected = true;
        debugPrint('[net] hello from host: seed ${msg['seed']}, ${pendingEdits.length} edit bytes');
        final m = main;
        if (m == null) {
          onHelloBeforeWorld?.call();
        } else {
          m.timeOfDay = (msg['time'] as num).toDouble();
          if (m.world.seedValue != msg['seed']) {
            m.world.setWorldSeed(msg['seed'] as int).then((_) {
              m.world.reset();
              m.world.updateAround(m.player.position);
              applyPendingEdits();
            });
          } else {
            applyPendingEdits();
          }
        }
      case 'block':
        final m = main;
        if (m == null) return;
        final b = IVec3(msg['x'] as int, msg['y'] as int, msg['z'] as int);
        if (m.world.getBlock(b) == msg['id']) return;
        _applying = true;
        m.world.setBlock(b, msg['id'] as int);
        _applying = false;
      case 'pose':
        _onPose(1, msg);
      case 'time':
        main?.timeOfDay = (msg['v'] as num).toDouble();
      case 'mobs':
        _onMobs(msg);
      case 'replica':
        main?.spawnReplica(_vec(msg['from']), _vec(msg['vel']), msg['kind'] as String, (msg['radius'] as num).toDouble());
      case 'hurt':
        main?.player.takeDamage((msg['amount'] as num).toDouble(), msg['source'] as String,
            msg['from'] == null ? null : _vec(msg['from']));
      case 'dmg':
        main?.spawnDamageNumber(_vec(msg['at']), (msg['amount'] as num).toDouble(), _vec(msg['color']));
    }
  }

  /// Called by the game once its world exists (client side).
  void applyPendingEdits() {
    final m = main;
    if (m == null || pendingEdits.isEmpty) return;
    m.world.loadEditsFromBytes(pendingEdits);
    m.world.refresh();
    pendingEdits = Uint8List(0);
  }

  // --- blocks ------------------------------------------------------------------

  void onBlockChanged(IVec3 b, int old, int id) {
    if (_applying) return;
    if (mode == NetMode.host) {
      _broadcast({'t': 'block', 'x': b.x, 'y': b.y, 'z': b.z, 'id': id});
    } else if (mode == NetMode.client) {
      _toHost({'t': 'block_req', 'x': b.x, 'y': b.y, 'z': b.z, 'id': id});
    }
  }

  // --- players -------------------------------------------------------------------

  void process(double dt) {
    final m = main;
    if (mode == NetMode.solo || m == null) return;
    _poseTimer += dt;
    if (_poseTimer >= 0.05) {
      _poseTimer = 0.0;
      final p = m.player;
      final pose = {'t': 'pose', 'pos': _v(p.position), 'yaw': p.model.yaw, 'held': p.heldItem(), 'cls': p.playerClass};
      if (mode == NetMode.host) {
        _broadcast(pose);
      } else {
        _toHost(pose);
      }
    }
    if (mode == NetMode.host) {
      _mobTimer += dt;
      if (_mobTimer >= 0.1) {
        _mobTimer = 0.0;
        _broadcastMobs();
      }
      _timeTimer += dt;
      if (_timeTimer >= 2.0) {
        _timeTimer = 0.0;
        _broadcast({'t': 'time', 'v': m.timeOfDay});
      }
    }
  }

  void _onPose(int id, Map<String, dynamic> msg) {
    final m = main;
    if (m == null) return;
    var puppet = _puppets[id];
    if (puppet == null) {
      puppet = RemotePlayer()..peerId = id;
      puppet.setupPuppet(msg['cls'] as String, 'Player $id');
      _puppets[id] = puppet;
      m.addPuppet(puppet);
    }
    puppet.setPose(_vec(msg['pos']), (msg['yaw'] as num).toDouble(), msg['held'] as String);
  }

  // --- mobs: host simulates, clients draw puppets -----------------------------------

  void _broadcastMobs() {
    final m = main!;
    final rows = <List<Object>>[];
    for (final mob in m.mobs) {
      if (mob.puppet || mob.state == MobState.dead) continue;
      rows.add([mob.instanceId, mob.species.id, mob.position.x, mob.position.y, mob.position.z, mob.modelYaw(), mob.hp, mob.maxHp, mob.mobLevel]);
    }
    _broadcast({'t': 'mobs', 'time': m.timeOfDay, 'rows': rows});
  }

  void _onMobs(Map<String, dynamic> msg) {
    final m = main;
    if (m == null) return;
    final rows = msg['rows'] as List<dynamic>;
    if (!_mobPacketSeen) {
      _mobPacketSeen = true;
      debugPrint('[net] first mob packet: ${rows.length} mobs, host time ${msg['time']}');
    }
    m.timeOfDay = (msg['time'] as num).toDouble();
    final seen = <int>{};
    for (final r in rows) {
      final row = r as List<dynamic>;
      final key = row[0] as int;
      seen.add(key);
      var mob = _mobPuppets[key];
      if (mob == null) {
        mob = Mob();
        mob.setupMob(m.world, m, m.player, Species.def(row[1] as String));
        mob.puppet = true;
        mob.position = Vector3((row[2] as num).toDouble(), (row[3] as num).toDouble(), (row[4] as num).toDouble());
        mob.scaleToLevel((row[8] as num).toInt());
        _mobPuppets[key] = mob;
        m.addMob(mob);
      }
      mob.setPuppetState(Vector3((row[2] as num).toDouble(), (row[3] as num).toDouble(), (row[4] as num).toDouble()),
          (row[5] as num).toDouble(), (row[6] as num).toDouble(), (row[7] as num).toDouble());
    }
    for (final key in _mobPuppets.keys.toList()) {
      if (!seen.contains(key)) _mobPuppets.remove(key)!.removed = true;
    }
  }

  // --- projectiles: host owns the hit, everyone sees a replica ------------------------

  void requestFire(Vector3 from, Vector3 vel, double dmg, String kind, double radius, double kb) =>
      _toHost({'t': 'fire', 'from': _v(from), 'vel': _v(vel), 'dmg': dmg, 'kind': kind, 'radius': radius, 'kb': kb});

  void broadcastReplica(Vector3 from, Vector3 vel, String kind, double radius) {
    if (mode == NetMode.host) _broadcast({'t': 'replica', 'from': _v(from), 'vel': _v(vel), 'kind': kind, 'radius': radius});
  }

  // --- melee: the host runs the reach check for a client's swing ----------------------

  void requestMelee(Vector3 dir, double dmg, double followUp) =>
      _toHost({'t': 'melee', 'dir': _v(dir), 'dmg': dmg, 'follow': followUp});

  // --- damage: the host decides, the peer's own body applies it -----------------------

  void hurtPeer(int id, double amount, String source, Vector3? from) {
    final p = _peers[id];
    if (mode == NetMode.host && p != null) {
      _sendTo(p.socket, {'t': 'hurt', 'amount': amount, 'source': source, 'from': from == null ? null : _v(from)});
    }
  }

  void broadcastDamageNumber(Vector3 at, double amount, Vector3 color) {
    if (mode == NetMode.host) _broadcast({'t': 'dmg', 'at': _v(at), 'amount': amount, 'color': _v(color)});
  }

  List<RemotePlayer> puppetBodies() => _puppets.values.toList();

  List<(int, Vector3)> puppetPositions() => [for (final e in _puppets.entries) (e.key, e.value.position)];

  void shutdown() {
    _server?.close();
    _client?.close();
    for (final p in _peers.values) {
      p.socket.close();
    }
    _peers.clear();
    mode = NetMode.solo;
  }
}
