import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_scene/scene.dart' hide Spawner;
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/items.dart';
import '../core/ivec3.dart';
import '../core/species.dart';
import '../entities/boat.dart';
import '../entities/item_drop.dart';
import '../entities/mob.dart';
import '../entities/projectile.dart';
import '../entities/remote_player.dart';
import '../entities/spawner.dart';
import '../entities/target.dart';
import '../player/player.dart';
import '../world/voxel_world.dart';
import 'achievements.dart';
import 'game_state.dart';
import 'input.dart';
import 'inventory.dart';
import 'net.dart';
import 'quests.dart';
import 'sfx.dart';
import 'weather.dart';

enum ScreenKind { none, inventory, pause, death, journal }

class Note {
  Note(this.text, this.t);
  final String text;
  double t;
}

class DamageNumber {
  DamageNumber(this.pos, this.text, this.color);
  final Vector3 pos;
  final String text;
  final Vector3 color;
  double age = 0.0;
}

class _Effect {
  _Effect(this.node, this.mat, this.radius, this.color);
  final Node node;
  final UnlitMaterial mat;
  final double radius;
  final Vector3 color;
  double age = 0.0;
}

class _Debris {
  _Debris(this.node, this.vel);
  final Node node;
  final Vector3 vel;
  double age = 0.0;
  double rx = 0, ry = 0, rz = 0;
}

class _Tnt {
  _Tnt(this.node, this.mat, this.at);
  final Node node;
  final UnlitMaterial mat;
  final IVec3 at;
  double age = 0.0;
}

class Loot {
  Loot(this.id, this.bonus);
  final String id;
  final int bonus;
}

/// Orchestrates a play session: world, player, sky and day/night, drops,
/// projectiles, effects, damage numbers, mobs (spawner), HUD state,
/// save/load. Args: `--screenshot=<png>` --frames=N --seed=N --radius=N
/// --class=warrior|ranger|mage|rogue --time=0..1 --fly --fire=primary|secondary
class Game extends ChangeNotifier {
  Game({required this.args, required this.saveDir});

  static const double dayLength = 600.0;
  static const double fixedStep = 1.0 / 60.0;

  final Map<String, String> args;
  final String saveDir;
  final Scene scene = Scene();
  late VoxelWorld world;
  late Player player;
  final Node entities = Node(name: 'Entities');
  final GameInput input = GameInput();
  final QuestLog quests = QuestLog();
  final math.Random random = math.Random();
  double timeOfDay = 0.3;
  bool flyMode = false;
  Mob? boss;
  final Map<IVec3, Inventory> chests = {};
  final Map<IVec3, double> crops = {};
  final Map<IVec3, String> waypoints = {};
  late final Weather weather;
  int journalTab = 0;
  final List<Mob> mobs = [];
  final List<Mob> pets = [];
  final List<ItemDrop> drops = [];
  final List<Projectile> projectiles = [];
  final List<Boat> boats = [];
  final List<RemotePlayer> puppets = [];
  final List<DamageNumber> damageNumbers = [];
  final List<Note> notes = [];
  final List<_Effect> _effects = [];
  final List<_Debris> _debris = [];
  final List<_Tnt> _tnts = [];
  final Set<IVec3> _bossesSpawned = {};
  Spawner? spawner;
  ScreenKind screen = ScreenKind.none;
  String station = '';
  Inventory? chest;
  bool debugVisible = true;
  bool mapVisible = false;
  final ValueNotifier<int> frame = ValueNotifier<int>(0);
  double fps = 0.0;
  double _fpsAcc = 0.0;
  int _fpsCount = 0;
  double _structTimer = 0.0;
  double _autosave = 0.0;
  double _acc = 0.0;
  double _sleepFrom = 0, _sleepTo = 0, _sleepT = -1.0;
  bool started = false;
  bool ready = false;
  Future<void> Function(String path)? screenshotter;
  final List<Completer<void>> _frameWaiters = [];

  /// Look tuning (also settable with --sun= --amb= --tm=).
  static double sunScale = 0.6;
  static double ambientScale = 0.6;

  late final GradientSkySource sky;
  late final SunLight sun;
  Vector3 _ambient = Vector3.zero();
  double _ambientTimer = 99.0;

  String _arg(String prefix, String fallback) => args[prefix] ?? fallback;
  bool _hasArg(String flag) => args.containsKey(flag);

  bool get gameplay => screen == ScreenKind.none && !player.isDead && started;

  Future<void> init() async {
    sunScale = double.tryParse(_arg('--sun=', '')) ?? sunScale;
    ambientScale = double.tryParse(_arg('--amb=', '')) ?? ambientScale;
    _buildEnvironment();
    switch (_arg('--tm=', '')) {
      case 'agx':
        scene.toneMapping = ToneMappingMode.agx;
      case 'neutral':
        scene.toneMapping = ToneMappingMode.pbrNeutral;
      case 'aces':
        scene.toneMapping = ToneMappingMode.aces;
      case 'linear':
        scene.toneMapping = ToneMappingMode.linear;
    }
    scene.add(entities);

    world = VoxelWorld(
      seedValue: int.tryParse(_arg('--seed=', '')) ?? GameState.instance.seedValue,
      loadRadius: int.tryParse(_arg('--radius=', '')) ?? 8,
    );
    scene.add(world.root);
    await world.start();
    timeOfDay = double.tryParse(_arg('--time=', '')) ?? 0.3;

    player = Player();
    player.setupPlayer(world, this, _arg('--class=', GameState.instance.playerClass));
    entities.add(player.node);
    entities.add(player.highlight);
    entities.add(player.crack);
    quests.player = player;
    Achievements.instance.notify = notify;

    final loaded = await _loadGame();
    if (!loaded) {
      final spawn = _findSpawn();
      player.position = spawn;
      player.spawnPoint = spawn.clone();
    }
    flyMode = _hasArg('--fly');
    if (_hasArg('--fp')) player.setFirstPerson(true);
    final fogd = double.tryParse(_arg('--fogd=', ''));
    if (fogd != null) {
      scene.fog.enabled = fogd > 0;
      scene.fog.density = fogd;
    }
    if (_arg('--tp=', '') != '') {
      final parts = _arg('--tp=', '').split(',');
      player.position = Vector3(double.parse(parts[0]), double.parse(parts[1]), double.parse(parts[2]));
    }
    if (_arg('--look=', '') != '') {
      final parts = _arg('--look=', '').split(',');
      player.setLook(double.parse(parts[0]) * math.pi / 180.0, double.parse(parts[1]) * math.pi / 180.0);
    }
    player.syncNode();
    world.updateAround(player.position);

    weather = Weather(() => player.position, world);
    scene.add(weather.node);
    if (_arg('--weather=', '') != '') weather.force(_arg('--weather=', ''));

    final net = Net.instance;
    net.main = this;
    if (net.isClient) net.applyPendingEdits();
    world.onBlockChanged = net.onBlockChanged;
    if (!net.isClient) spawner = Spawner(world, player, this);
    if (net.mode != NetMode.solo) notify(net.isHost ? 'Hosting on port ${Net.port}' : 'Joined the host');

    started = true;
    ready = true;
    if (_arg('--screenshot=', '') != '') {
      unawaited(_runScreenshot(_arg('--screenshot=', ''), int.tryParse(_arg('--frames=', '')) ?? 300));
    } else {
      await input.capture();
    }
    notifyListeners();
  }

  Vector3 _findSpawn() {
    for (var ring = 0; ring < 40; ring++) {
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi * 2 / 8.0;
        final x = (math.cos(a) * ring * 12).toInt() + 8;
        final z = (math.sin(a) * ring * 12).toInt() + 8;
        final h = world.surfaceHeight(x, z);
        final biome = world.biomeAt(x, z);
        if (h > 48 && biome != 0 && biome != 6) return Vector3(x + 0.5, h + 1.5, z + 0.5);
      }
    }
    return Vector3(8.5, 80, 8.5);
  }

  void _buildEnvironment() {
    sky = GradientSkySource(sunSharpness: 600.0);
    scene.skybox = Skybox(sky);
    sun = SunLight(
      sky,
      castsShadow: !_hasArg('--noshadow'),
      cacheStaticShadows: _arg('--shadowcache=', '1') != '0',
      shadowMaxDistance: 110.0,
      shadowMapResolution: 2048,
      shadowCascadeCount: 4,
      shadowSoftness: 0.04,
      shadowDepthBias: 0.02,
      shadowNormalBias: 0.06,
      shadowCasterFaces: _arg('--casterfaces=', 'back') == 'front' ? ShadowCasterFaces.front : ShadowCasterFaces.back,
      shadowAmbientStrength: 0.0,
    );
    scene.sunLight = sun;
    scene.toneMapping = ToneMappingMode.aces;
    scene.exposure = 1.0;
    scene.fog
      ..enabled = true
      ..mode = FogMode.exponential
      ..density = 0.003
      ..skyColorInfluence = 1.0
      ..maxOpacity = 0.9;
    _updateSky();
  }

  static Vector3 _mix(Vector3 a, Vector3 b, double t) => a + (b - a) * t;

  void _updateSky() {
    final angle = (timeOfDay - 0.25) * math.pi * 2; // 0.25 = sunrise, 0.5 = noon
    final sunDir = Vector3(math.cos(angle) * 0.6, math.sin(angle), -0.5).normalized();
    final elevation = sunDir.y;
    final day = (elevation * 3.0 + 0.15).clamp(0.0, 1.0);
    final dusk = (1.0 - elevation.abs() * 5.0).clamp(0.0, 1.0);
    final sunColor = _mix(Vector3(1.0, 0.95, 0.85), Vector3(1.0, 0.55, 0.3), dusk);
    final dark = ready ? weather.darken() : 0.0;
    final bolt = ready ? weather.flash : 0.0;
    final overcast = Vector3(0.45, 0.48, 0.55);
    final topDay = Vector3(0.20, 0.42, 0.85);
    final horDay = Vector3(0.62, 0.78, 0.92);
    final topNight = Vector3(0.02, 0.03, 0.08);
    final horNight = Vector3(0.06, 0.08, 0.15);
    final horDusk = Vector3(0.95, 0.55, 0.30);
    var top = _mix(topNight, topDay, day);
    var hor = _mix(_mix(horNight, horDay, day), horDusk, dusk * 0.8);
    if (dark > 0.0 || bolt > 0.0) {
      final grey = overcast * (0.15 + 0.85 * day);
      top = _mix(_mix(top, grey, dark), Vector3(1, 1, 1), bolt * 0.8);
      hor = _mix(_mix(hor, overcast * (0.2 + 0.8 * day), dark), Vector3(1, 1, 1), bolt * 0.8);
    }
    sky.zenithColor = top;
    sky.horizonColor = hor;
    sky.groundColor = hor * 0.9;
    if (elevation > 0.0) {
      sky.sunDirection = sunDir;
      sun.color = sunColor;
      sun.intensity = (3.0 * 0.85 * day * (1.0 - dark) + 0.02 + bolt * 1.5) * sunScale;
      sky.sunColor = sunColor * (2.5 * day + 0.4);
    } else {
      sky.sunDirection = -sunDir;
      sun.color = Vector3(0.55, 0.65, 0.95);
      sun.intensity = (3.0 * 0.18 * (1.0 - day) + 0.02) * sunScale;
      sky.sunColor = Vector3(0.5, 0.6, 0.9) * 0.9;
    }
    final ambientEnergy = (0.10 + 0.30 * day) * (1.0 - dark * 0.5) + bolt * 0.6;
    final ambientColor = _mix(Vector3(0.35, 0.40, 0.60), Vector3(0.80, 0.84, 0.92), day);
    final radiance = ambientColor * (ambientEnergy * 1.25 * ambientScale);
    if ((radiance - _ambient).length > 0.02 && _ambientTimer > 0.5) {
      _ambient = radiance;
      _ambientTimer = 0.0;
      scene.environment = EnvironmentMap.constantDiffuse(radiance);
    }
    scene.fog.color = hor;
    if (ready) scene.fog.density = 0.003 + 0.012 * dark;
  }

  String timeLabel() {
    final h = (timeOfDay * 24.0).toInt();
    final m = ((timeOfDay * 24.0) % 1.0 * 60.0).toInt();
    const biomeNames = ['Ocean', 'Beach', 'Plains', 'Forest', 'Desert', 'Snow', 'Mountains', 'Swamp'];
    final b = world.biomeAt(player.position.x.toInt(), player.position.z.toInt());
    final clock = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}   ${biomeNames[b]}${isNight ? '   (night)' : ''}';
    return weather.kind == WeatherKind.clear ? clock : '$clock   ${weather.label}';
  }

  bool get isNight => timeOfDay < 0.22 || timeOfDay > 0.78;

  String debugText() =>
      'FPS ${fps.round()}  chunks ${world.loadedChunkCount}  queue ${world.pendingCount}  faces ${world.facesEmitted}  mobs ${mobs.length}\n'
      'pos ${player.position.x.toStringAsFixed(1)} ${player.position.y.toStringAsFixed(1)} ${player.position.z.toStringAsFixed(1)}  seed ${world.seedValue}   [F1] hide';

  void notify(String text) {
    notes.add(Note(text, 3.0));
    if (notes.length > 5) notes.removeRange(0, notes.length - 5);
  }

  // --- the frame -----------------------------------------------------------------

  /// Called once per rendered frame by the view; runs the fixed-step simulation.
  void onFrame(double dt) {
    if (!ready) return;
    _fpsAcc += dt;
    _fpsCount++;
    if (_fpsAcc >= 0.5) {
      fps = _fpsCount / _fpsAcc;
      _fpsAcc = 0.0;
      _fpsCount = 0;
    }
    _acc += math.min(dt, 0.1);
    var steps = 0;
    while (_acc >= fixedStep && steps < 4) {
      _tick(fixedStep);
      _acc -= fixedStep;
      steps++;
    }
    if (steps == 0) input.endTick();
    world.update();
    _ambientTimer += dt;
    _updateSky();
    frame.value++;
    if (_frameWaiters.isNotEmpty) {
      final waiters = List.of(_frameWaiters);
      _frameWaiters.clear();
      for (final w in waiters) {
        w.complete();
      }
    }
  }

  Future<void> nextFrame() {
    final c = Completer<void>();
    _frameWaiters.add(c);
    return c.future;
  }

  void _handleGlobalKeys() {
    if (input.justPressed(GameAction.debugHud)) debugVisible = !debugVisible;
    if (input.justPressed(GameAction.map)) mapVisible = !mapVisible;
    if (input.justPressed(GameAction.screenshot)) {
      final dir = Directory('$saveDir/../../screenshots');
      dir.createSync(recursive: true);
      final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch ~/ 1000}.png';
      screenshotter?.call(path).then((_) => notify('Screenshot saved: $path'));
    }
    if (input.justPressed(GameAction.fly)) {
      flyMode = !flyMode;
      notify('Fly mode ${flyMode ? 'ON (Space up, Ctrl down)' : 'OFF'}');
    }
    if (input.justPressed(GameAction.pause)) {
      if (screen != ScreenKind.none) {
        if (screen != ScreenKind.death) closeScreen();
      } else {
        openScreen(ScreenKind.pause);
      }
    } else if (input.justPressed(GameAction.journal) && !player.isDead) {
      if (screen != ScreenKind.none) {
        closeScreen();
      } else {
        openJournal(0);
      }
    } else if (input.justPressed(GameAction.inventory) && !player.isDead) {
      if (screen != ScreenKind.none) {
        closeScreen();
      } else {
        openStation('', IVec3.zero);
      }
    }
    if (input.captureLost && screen == ScreenKind.none && !player.isDead) {
      input.captureLost = false;
      openScreen(ScreenKind.pause);
    }
  }

  void _tick(double dt) {
    _handleGlobalKeys();
    timeOfDay = (timeOfDay + dt / dayLength) % 1.0;
    if (_sleepT >= 0.0) {
      _sleepT += dt;
      final t = (_sleepT / 2.2).clamp(0.0, 1.0);
      final e = t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;
      timeOfDay = (_sleepFrom + (_sleepTo - _sleepFrom) * e) % 1.0;
      if (t >= 1.0) {
        timeOfDay = 0.26;
        _sleepT = -1.0;
      }
    }
    GameState.instance.playTime += dt;
    final play = gameplay;
    player.physicsProcess(dt, input, play);
    for (final m in mobs) {
      m.update(dt);
    }
    for (final m in pets) {
      m.update(dt);
    }
    for (final d in drops) {
      d.update(dt);
    }
    for (final p in projectiles) {
      p.update(dt);
    }
    for (final b in boats) {
      b.update(dt);
    }
    for (final p in puppets) {
      p.update(dt);
    }
    weather.process(dt);
    _tickVisuals(dt);
    spawner?.update(dt);
    Net.instance.process(dt);
    _prune();

    for (final n in notes) {
      n.t -= dt;
    }
    notes.removeWhere((n) => n.t <= 0.0);

    _structTimer += dt;
    if (_structTimer > 1.0) {
      _structTimer = 0.0;
      _checkStructures();
      _growCrops();
      _tickSpawners();
      _trackBoss();
      if (weather.isWet) {
        _growCrops();
        final surface = world.surfaceHeight(player.position.x.toInt(), player.position.z.toInt());
        if (player.effects.has('burning') && player.position.y >= surface - 1) {
          player.effects.clear('burning');
        }
      }
      if (player.position.y < 20.0) Achievements.instance.unlock('deep');
      final b = boss;
      if (b != null && (b.removed || b.state == MobState.dead)) boss = null;
    }
    _autosave += dt;
    if (_autosave > 60.0) {
      _autosave = 0.0;
      saveGame();
    }
    input.endTick();
  }

  void _tickVisuals(double dt) {
    for (final e in _effects) {
      e.age += dt;
      final t = (e.age / 0.35).clamp(0.0, 1.0);
      final eased = 1 - math.pow(1 - t, 3).toDouble();
      final s = 1.0 + (e.radius * 2.0 - 1.0) * eased;
      e.node.scale = Vector3(s, s, s);
      e.mat.baseColorFactor = Vector4(e.color.x, e.color.y, e.color.z, 0.55 * (1 - t));
    }
    for (final d in _debris) {
      d.age += dt;
      d.node.position = d.node.position + d.vel * dt;
      d.vel.y -= 9.8 * dt;
      d.rx += 0.1 * dt * 60;
      d.ry += 0.13 * dt * 60;
      d.rz += 0.07 * dt * 60;
      d.node.rotation = Quaternion.euler(d.ry, d.rx, d.rz);
    }
    for (final t in _tnts) {
      t.age += dt;
      final phase = (t.age / 0.4) % 2.0;
      final white = phase < 1.0 ? phase : 2.0 - phase;
      final c = Blocks.def(Blocks.indexOf('tnt'));
      t.mat.baseColorFactor = Vector4(c.r + (1 - c.r) * white, c.g + (1 - c.g) * white, c.b + (1 - c.b) * white, 1);
      if (t.age >= 3.2) {
        entities.remove(t.node);
        explode(t.at.centre, 3.5, 18.0, null);
      }
    }
    _tnts.removeWhere((t) => t.age >= 3.2);
    for (final n in damageNumbers) {
      n.age += dt;
    }
    damageNumbers.removeWhere((n) => n.age >= 0.9);
  }

  void _prune() {
    void pruneList<T>(List<T> list, bool Function(T) gone, Node Function(T) nodeOf) {
      for (final e in list) {
        if (gone(e)) entities.remove(nodeOf(e));
      }
      list.removeWhere(gone);
    }

    pruneList<Mob>(mobs, (m) => m.removed, (m) => m.node);
    pruneList<Mob>(pets, (m) => m.removed, (m) => m.node);
    pruneList<ItemDrop>(drops, (d) => d.removed, (d) => d.node);
    pruneList<Projectile>(projectiles, (p) => p.removed, (p) => p.node);
    pruneList<Boat>(boats, (b) => b.removed, (b) => b.node);
    pruneList<RemotePlayer>(puppets, (p) => p.removed, (p) => p.node);
    pruneList<_Effect>(_effects, (e) => e.age >= 0.35, (e) => e.node);
    pruneList<_Debris>(_debris, (d) => d.age >= 0.6, (d) => d.node);
  }

  // --- screens ------------------------------------------------------------------------

  void openStation(String st, IVec3 at) {
    station = st;
    chest = st == 'chest' ? chestInventory(at) : null;
    openScreen(ScreenKind.inventory);
  }

  void openScreen(ScreenKind kind) {
    screen = kind;
    input.releaseKeys();
    unawaited(input.release());
    notifyListeners();
  }

  void closeScreen() {
    screen = ScreenKind.none;
    chest = null;
    if (!player.isDead) unawaited(input.capture());
    notifyListeners();
  }

  void onPlayerDied() => openScreen(ScreenKind.death);

  void openJournal(int tab) {
    journalTab = tab;
    openScreen(ScreenKind.journal);
  }

  /// Waypoints sorted by label, as the journal lists them.
  List<MapEntry<IVec3, String>> waypointList() {
    final out = waypoints.entries.toList();
    out.sort((a, b) => a.value.compareTo(b.value));
    return out;
  }

  /// Travel to a waypoint block: free when standing beside any waypoint, 10
  /// mana from anywhere.
  bool travelToWaypoint(IVec3 to) {
    final label = waypoints[to];
    if (label == null) return false;
    var near = false;
    for (final k in waypoints.keys) {
      if ((k.toVector3() - player.position).length < 6.0) near = true;
    }
    if (!near) {
      if (player.mana < 10.0) {
        notify('Need 10 mana to travel from afar');
        return false;
      }
      player.mana -= 10.0;
    }
    spawnEffect(player.centre(), Vector3(0.35, 0.75, 0.95), 1.5);
    player.position = to.toVector3() + Vector3(0.5, 1.05, 0.5);
    player.velocity = Vector3.zero();
    player.syncNode();
    world.updateAround(player.position);
    spawnEffect(player.centre(), Vector3(0.35, 0.75, 0.95), 1.5);
    Sfx.play('quest', -6.0, 1.4);
    notify('Travelled to $label');
    Achievements.instance.unlock('traveler');
    return true;
  }

  /// A chest's contents, created on first open. A chest that came with a
  /// structure is filled with loot decided by its position, so it is the same
  /// loot for everyone.
  Inventory chestInventory(IVec3 at) {
    final existing = chests[at];
    if (existing != null) return existing;
    final inv = Inventory();
    chests[at] = inv;
    if (!GameState.instance.placedChests.contains(at.key)) {
      final rng = math.Random(at.hashCode ^ world.seedValue);
      const loot = [
        ['iron_ingot', 1, 4], ['coal', 3, 8], ['arrow', 4, 12], ['apple', 1, 4], ['magic_dust', 1, 3],
        ['gold_ingot', 0, 2], ['diamond', 0, 1], ['string', 1, 4], ['health_potion', 0, 1], ['bread', 1, 3],
        ['gem_shard', 0, 2], ['leather', 1, 3], ['torch', 2, 6], ['glider', 0, 1],
      ];
      final picks = 3 + rng.nextInt(4);
      for (var i = 0; i < picks; i++) {
        final pick = loot[rng.nextInt(loot.length)];
        final lo = pick[1] as int, hi = pick[2] as int;
        final n = lo + rng.nextInt(hi - lo + 1);
        if (n > 0) inv.add(pick[0] as String, n);
      }
      if (rng.nextDouble() < 0.45) {
        final w = randomLootWeapon(rng);
        inv.addStack(ItemStack(w.id, 1, bonus: w.bonus));
      }
    }
    return inv;
  }

  void _checkStructures() {
    final here = VoxelWorld.chunkOf(IVec3.floor(player.position));
    for (final s in world.structuresNear(here)) {
      final key = IVec3(s.x, s.y, s.z);
      if (s.type == 4) {
        if (!_bossesSpawned.contains(key) && key.distanceTo(player.position) < 40.0) {
          _bossesSpawned.add(key);
          for (var i = 0; i < 4; i++) {
            final v = Mob();
            v.setupMob(world, this, player, Species.def('villager'));
            v.position = Vector3(s.x + random.nextDouble() * 12 - 6, world.groundHeight(s.x, s.z) + 0.5, s.z + random.nextDouble() * 12 - 6);
            addMob(v);
          }
          notify('You found a village! Trade with F (gold for goods)');
        }
        continue;
      }
      if (s.type != 1) continue;
      if (_bossesSpawned.contains(key)) continue;
      final bossRoom = Vector3(s.x + 24.0, s.y + 1.0, s.z.toDouble());
      if ((player.position - bossRoom).length < 14.0) {
        _bossesSpawned.add(key);
        final mob = Mob();
        mob.setupMob(world, this, player, Species.def('troll'));
        mob.position = bossRoom + Vector3(-2, 0, 2);
        mob.scaleToLevel(player.level + 2);
        addMob(mob);
        boss = mob;
        notify('A Cave Troll guards the treasure!');
      }
    }
  }

  // --- spawning helpers used by the player, mobs and projectiles ----------------------

  void addMob(Mob mob) {
    mobs.add(mob);
    mob.syncNode();
    entities.add(mob.node);
  }

  void addPuppet(RemotePlayer p) {
    puppets.add(p);
    entities.add(p.node);
  }

  void spawnDrop(Vector3 at, String id, int count, [Vector3? vel, double delay = 0.6]) {
    final drop = ItemDrop();
    drop.setupDrop(world, id, count, player, delay);
    drop.position = at.clone();
    drop.velocity = vel ?? Vector3(random.nextDouble() * 3 - 1.5, 3.0, random.nextDouble() * 3 - 1.5);
    drop.syncNode();
    drops.add(drop);
    entities.add(drop.node);
  }

  void spawnLootDrop(Vector3 at, ItemStack stack) {
    final drop = ItemDrop();
    drop.setupDrop(world, stack.id, 1, player);
    drop.bonus = stack.bonus;
    drop.position = at.clone();
    drop.velocity = Vector3(random.nextDouble() * 3 - 1.5, 3.0, random.nextDouble() * 3 - 1.5);
    drop.syncNode();
    drops.add(drop);
    entities.add(drop.node);
  }

  bool _hasOpaqueSide(IVec3 b) {
    for (final side in IVec3.sides) {
      if (Blocks.isOpaque(world.getBlock(b + side))) return true;
    }
    return false;
  }

  void spawnBoat(Vector3 at, double heading) {
    final b = Boat();
    b.setupBoat(world, this, at, heading);
    boats.add(b);
    entities.add(b.node);
  }

  /// Enchanting: one level and two magic dust buy a random +1..+3 on the held weapon or tool.
  void enchantHeld() {
    final item = player.heldItem();
    if (item == '' || (Items.kind(item) != ItemKind.weapon && Items.kind(item) != ItemKind.tool)) {
      notify('Hold a weapon or tool to enchant it');
      return;
    }
    if (player.level < 2) {
      notify('Need level 2 to enchant');
      return;
    }
    if (player.inventory.countOf('magic_dust') < 2) {
      notify('Need 2 Magic Dust');
      return;
    }
    player.inventory.remove('magic_dust', 2);
    player.level -= 1;
    final bonus = player.inventory.bonusAt(player.selectedSlot) + 1 + random.nextInt(3);
    player.inventory.slots[player.selectedSlot]!.bonus = bonus;
    player.inventory.emitChanged();
    spawnEffect(player.centre() + Vector3(0, 0.8, 0), Vector3(0.7, 0.4, 1.0), 2.0);
    Sfx.play('bolt', -6.0);
    notify('${Items.displayName(item)} is now +$bonus');
  }

  void spawnProjectile(Vector3 from, Vector3 vel, double dmg, Object? owner, String kind,
      [double radius = 0.1, double knockback = 5.0]) {
    final net = Net.instance;
    if (net.isClient && identical(owner, player)) {
      // The host owns the hit; what flies here is only a picture of the shot.
      spawnReplica(from, vel, kind, radius);
      net.requestFire(from, vel, dmg, kind, radius, knockback);
      return;
    }
    final p = Projectile();
    p.setupProjectile(world, this, from, vel, dmg, owner, kind, radius, knockback);
    projectiles.add(p);
    entities.add(p.node);
    net.broadcastReplica(from, vel, kind, radius);
  }

  void meleeStrike(Vector3 dir, double dmg, double followUp, Target attacker) {
    // A swing is a segment of meleeReach from the attacker's own centre along
    // its facing; the nearest mob body on it takes the hit. Runs on whoever
    // owns the simulation, never on a camera cache.
    final net = Net.instance;
    if (net.isClient && identical(attacker, player)) {
      net.requestMelee(dir, dmg, followUp);
      return;
    }
    final origin = attacker.centre();
    if (net.isHost && !identical(attacker, player) && attacker is RemotePlayer) {
      debugPrint('[net] melee strike resolved for peer ${attacker.peerId}');
    }
    Mob? best;
    var bestD = double.infinity;
    for (final m in mobs) {
      final d = m.rayDistance(origin, dir, 0.15);
      if (d >= 0.0 && d < Player.meleeReach && d < bestD) {
        bestD = d;
        best = m;
      }
    }
    if (best == null) return;
    Sfx.play('hit', -4.0);
    best.takeDamage(dmg, attacker.position, 6.0, attacker);
    spawnDamageNumber(best.centre(), dmg, Vector3(1, 0.95, 0.6));
    if (followUp > 0.0) {
      best.takeDamage(followUp, attacker.position, 2.0, attacker);
      spawnDamageNumber(best.centre() + Vector3(0, 0.3, 0), followUp, Vector3(1, 0.6, 0.3));
    }
  }

  List<Target> targets() {
    final out = <Target>[player];
    if (Net.instance.isHost) out.addAll(Net.instance.puppetBodies());
    return out;
  }

  void spawnReplica(Vector3 from, Vector3 vel, String kind, double radius) {
    final p = Projectile()..replica = true;
    p.setupProjectile(world, this, from, vel, 0.0, player, kind, radius, 0.0);
    projectiles.add(p);
    entities.add(p.node);
  }

  void spawnDamageNumber(Vector3 at, double amount, Vector3 color) {
    Net.instance.broadcastDamageNumber(at, amount, color);
    damageNumbers.add(DamageNumber(
        at + Vector3(random.nextDouble() * 0.6 - 0.3, 0.3, random.nextDouble() * 0.6 - 0.3), amount.round().toString(), color));
  }

  void spawnEffect(Vector3 at, Vector3 color, double radius) {
    final mat = UnlitMaterial()
      ..baseColorFactor = Vector4(color.x, color.y, color.z, 0.55)
      ..alphaMode = AlphaMode.blend;
    final node = Node(mesh: Mesh(SphereGeometry(radius: 0.5), mat))
      ..position = at.clone()
      ..castsShadows = false;
    entities.add(node);
    _effects.add(_Effect(node, mat, radius, color));
  }

  void spawnDebris(Vector3 at, Vector3 color) {
    for (var i = 0; i < 6; i++) {
      final size = 0.08 + random.nextDouble() * 0.08;
      final f = 0.8 + random.nextDouble() * 0.3;
      final mat = PhysicallyBasedMaterial()
        ..baseColorFactor = Vector4(color.x * f, color.y * f, color.z * f, 1)
        ..roughnessFactor = 1.0
        ..metallicFactor = 0.0;
      final node = Node(mesh: Mesh(CuboidGeometry(Vector3(size, size, size)), mat))
        ..position = at + Vector3(random.nextDouble() * 0.6 - 0.3, random.nextDouble() * 0.6 - 0.2, random.nextDouble() * 0.6 - 0.3)
        ..castsShadows = false;
      entities.add(node);
      _debris.add(_Debris(node, Vector3(random.nextDouble() * 4 - 2, 2 + random.nextDouble() * 2, random.nextDouble() * 4 - 2)));
    }
  }

  void trade(Mob villager) {
    const offers = [
      ['gold_ingot', 1, 'iron_ingot', 3], ['gold_ingot', 1, 'arrow', 12], ['gold_ingot', 1, 'bread', 4],
      ['gold_ingot', 2, 'magic_dust', 3], ['gold_ingot', 3, 'health_potion', 1], ['raw_gold', 2, 'gold_ingot', 1],
      ['leather', 4, 'leather_armor', 1], ['wool', 6, 'glider', 1], ['diamond', 1, 'crystal_staff', 1], ['gem_shard', 3, 'diamond', 1],
    ];
    final rng = math.Random(IVec3.floor(villager.position).hashCode ^ world.seedValue);
    final offer = offers[rng.nextInt(offers.length)];
    final give = offer[0] as String, giveN = offer[1] as int, get = offer[2] as String, getN = offer[3] as int;
    if (player.inventory.countOf(give) >= giveN) {
      player.inventory.remove(give, giveN);
      player.inventory.add(get, getN);
      notify('Traded $giveN ${Items.displayName(give)} for $getN ${Items.displayName(get)}');
      Sfx.play('pickup');
    } else {
      notify('Villager wants $giveN ${Items.displayName(give)} for $getN ${Items.displayName(get)}');
    }
  }

  void _tickSpawners() {
    final here = VoxelWorld.chunkOf(IVec3.floor(player.position));
    for (final s in world.structuresNear(here)) {
      if (s.type != 1) continue;
      for (var room = 0; room < 2; room++) {
        final pos = IVec3(s.x + room * 12, s.y + 1, s.z + 2);
        final id = world.getBlock(pos);
        if (id == Blocks.air || Blocks.idOf(id) != 'spawner') continue;
        if (pos.distanceTo(player.position) > 13.0) continue;
        var near = 0;
        for (final m in mobs) {
          if (pos.distanceTo(m.position) < 12.0) near++;
        }
        if (near >= 5 || random.nextDouble() < 0.4) continue;
        final pick = const ['zombie', 'skeleton', 'spider', 'cave_slime'][random.nextInt(4)];
        final mob = Mob();
        mob.setupMob(world, this, player, Species.def(pick));
        mob.position = pos.toVector3() + Vector3(random.nextDouble() * 4 - 2, 0.1, -1 - random.nextDouble() * 2);
        mob.scaleToLevel(player.level + 1);
        addMob(mob);
        spawnEffect(mob.centre(), Vector3(0.6, 0.2, 0.9), 1.2);
      }
    }
  }

  void _trackBoss() {
    final b = boss;
    if (b != null && !b.removed && b.state != MobState.dead && (b.position - player.position).length < 40.0) return;
    boss = null;
    for (final mob in mobs) {
      if (mob.isBoss && (mob.position - player.position).length < 30.0) {
        boss = mob;
        notify('A ${mob.species.name} approaches!');
        return;
      }
    }
  }

  /// Blows a hole: blocks inside the radius go (bedrock and chests stay), a
  /// third drop items, and every body nearby takes damage falling off with
  /// distance.
  void explode(Vector3 at, double radius, double damage, Object? source) {
    Sfx.play('bolt', 2.0, 0.5);
    spawnEffect(at, Vector3(1, 0.6, 0.2), radius * 1.6);
    final r = radius.ceil();
    final centre = IVec3.floor(at);
    final chained = <IVec3>[];
    for (var dx = -r; dx <= r; dx++) {
      for (var dy = -r; dy <= r; dy++) {
        for (var dz = -r; dz <= r; dz++) {
          final p = centre + IVec3(dx, dy, dz);
          if (math.sqrt(dx * dx + dy * dy + dz * dz) > radius + random.nextDouble() * 0.5) continue;
          final id = world.getBlock(p);
          if (id == Blocks.air || Blocks.hardness(id) < 0.0 || Blocks.idOf(id) == 'chest') continue;
          if (Blocks.idOf(id) == 'tnt') {
            world.setBlock(p, Blocks.air);
            chained.add(p);
            continue;
          }
          world.setBlock(p, Blocks.air);
          if (random.nextDouble() < 0.3 && Blocks.dropOf(id) != '') spawnDrop(p.centre, Blocks.dropOf(id), 1);
        }
      }
    }
    for (final m in List.of(mobs)) {
      if (identical(m, source)) continue;
      final d = (m.centre() - at).length;
      if (d < radius * 2.0) {
        final dmg = damage * (1.0 - d / (radius * 2.0));
        m.takeDamage(dmg, at, 8.0, source);
        spawnDamageNumber(m.centre(), dmg, Vector3(1, 0.5, 0.2));
      }
    }
    final pd = (player.centre() - at).length;
    if (pd < radius * 2.0) player.takeDamage(damage * (1.0 - pd / (radius * 2.0)), 'explosion', at);
    for (final p in chained) {
      Future<void>.delayed(Duration.zero, () => explode(p.centre, radius, damage, source));
    }
  }

  void igniteTnt(IVec3 at) {
    world.setBlock(at, Blocks.air);
    final c = Blocks.def(Blocks.indexOf('tnt'));
    final mat = UnlitMaterial()..baseColorFactor = Vector4(c.r, c.g, c.b, 1);
    final node = Node(mesh: Mesh(CuboidGeometry(Vector3(1, 1, 1)), mat))..position = at.centre;
    entities.add(node);
    _tnts.add(_Tnt(node, mat, at));
    Sfx.play('dig', -6.0, 1.5);
  }

  /// A weapon with a random bonus (Cube World style loot): rarity from the bonus size.
  Loot randomLootWeapon(math.Random rng, [int minBonus = 1]) {
    const pool = ['stone_sword', 'iron_sword', 'iron_dagger', 'bow', 'longbow', 'staff', 'diamond_sword', 'crystal_staff'];
    final id = pool[rng.nextInt(pool.length)];
    final bonus = minBonus + rng.nextInt(6 - minBonus + 1);
    return Loot(id, bonus);
  }

  void _growCrops() {
    final now = GameState.instance.playTime;
    for (final pos in crops.keys.toList()) {
      final id = world.getBlock(pos);
      final name = id != Blocks.air ? Blocks.idOf(id) : '';
      if (!name.startsWith('wheat_')) {
        crops.remove(pos);
        continue;
      }
      final stage = int.parse(name.substring(6));
      if (stage >= 2) {
        crops.remove(pos);
        continue;
      }
      final lit = world.groundHeight(pos.x, pos.z) <= pos.y + 1;
      final need = lit ? 45.0 : 90.0;
      if (now - crops[pos]! > need) {
        world.setBlock(pos, Blocks.indexOf('wheat_${stage + 1}'));
        crops[pos] = now;
      }
    }
  }

  void plantCrop(IVec3 pos) => crops[pos] = GameState.instance.playTime;

  /// Sand and gravel above a removed block fall until they land.
  void _settleFalling(IVec3 above) {
    final id = world.getBlock(above);
    if (id == Blocks.air) return;
    final name = Blocks.idOf(id);
    if (name != 'sand' && name != 'gravel') return;
    var target = above;
    while (target.y > 1 && Blocks.isReplaceable(world.getBlock(target + IVec3.down))) {
      target = target + IVec3.down;
    }
    if (target != above) {
      world.setBlock(above, Blocks.air);
      world.setBlock(target, id);
      _settleFalling(above + IVec3.up);
    }
  }

  void sleepInBed(IVec3 at) {
    player.spawnPoint = at.toVector3() + Vector3(0.5, 1.2, 0.5);
    if (isNight) {
      player.position = at.toVector3() + Vector3(0.5, 1.0, 0.5);
      player.startSleep();
      _sleepFrom = timeOfDay;
      _sleepTo = timeOfDay > 0.5 ? 1.26 : 0.26;
      _sleepT = 0.0;
      notify('You sleep until morning. Spawn point set.');
      Achievements.instance.unlock('sleeper');
      for (final m in mobs) {
        if (m.species.hostile && (m.position - player.position).length < 30.0) m.removed = true;
      }
    } else {
      notify('Spawn point set. You can only sleep at night.');
    }
    saveGame();
  }

  void onBlockBroken(IVec3 b, int id) {
    Achievements.instance.unlock('first_block');
    if (Blocks.idOf(id) == 'waypoint') waypoints.remove(b);
    GameState.instance.blocksMined += 1;
    _settleFalling(b + IVec3.up);
    for (final side in IVec3.sides) {
      final n = b + side;
      final nid = Blocks.idOf(world.getBlock(n));
      if (nid == 'wall_torch' && !_hasOpaqueSide(n)) {
        world.setBlock(n, Blocks.air);
        spawnDrop(n.toVector3() + Vector3(0.5, 0.4, 0.5), 'torch', 1);
      }
    }
    if (Blocks.idOf(id).startsWith('door_')) {
      for (final other in [b + IVec3.up, b + IVec3.down]) {
        if (Blocks.idOf(world.getBlock(other)).startsWith('door_')) world.setBlock(other, Blocks.air);
      }
    }
    final c = Blocks.def(id);
    spawnDebris(b.centre, Vector3(c.r, c.g, c.b));
    Sfx.play('break', -6.0);
    if (Blocks.idOf(id) == 'chest' && chests.containsKey(b)) {
      final inv = chests.remove(b)!;
      for (final s in inv.slots) {
        if (s != null) spawnDrop(b.centre, s.id, s.count);
      }
    }
  }

  void onBlockPlaced(IVec3 b, int id) {
    if (GameState.instance.blocksPlaced >= 99) Achievements.instance.unlock('builder');
    if (Blocks.idOf(id) == 'waypoint') {
      waypoints[b] = 'Waypoint ${waypoints.length + 1}';
      notify('${waypoints[b]} set. Right click it to travel (J lists them)');
    }
    GameState.instance.blocksPlaced += 1;
    Sfx.play('place', -8.0);
    if (Blocks.idOf(id) == 'chest') GameState.instance.placedChests.add(b.key);
  }

  // --- persistence -------------------------------------------------------------------

  Future<void> saveGame() async {
    try {
      await Directory(saveDir).create(recursive: true);
      await world.saveEdits('$saveDir/blocks.bin');
      final data = {
        'player': player.toJson(),
        'time': timeOfDay,
        'seed': world.seedValue,
        'crops': {for (final e in crops.entries) e.key.key: e.value},
        'stats': GameState.instance.toJson(),
        'chests': {for (final e in chests.entries) e.key.key: e.value.toJson()},
        'bosses': [for (final k in _bossesSpawned) k.key],
        'quests': quests.toJson(),
        'waypoints': {for (final e in waypoints.entries) e.key.key: e.value},
      };
      await File('$saveDir/player.json').writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('[save] failed: $e');
    }
  }

  Future<bool> _loadGame() async {
    final f = File('$saveDir/player.json');
    if (_hasArg('--new') || GameState.instance.freshWorld || !await f.exists()) return false;
    final data = jsonDecode(await f.readAsString());
    if (data is! Map<String, dynamic>) return false;
    await world.loadEdits('$saveDir/blocks.bin');
    timeOfDay = (data['time'] as num?)?.toDouble() ?? 0.3;
    GameState.instance.fromJson((data['stats'] as Map<String, dynamic>?) ?? {});
    player.fromJson(data['player'] as Map<String, dynamic>);
    quests.fromJson((data['quests'] as Map<String, dynamic>?) ?? {});
    for (final e in ((data['crops'] as Map<String, dynamic>?) ?? {}).entries) {
      final k = IVec3.parse(e.key);
      if (k != null) crops[k] = (e.value as num).toDouble();
    }
    for (final e in ((data['chests'] as Map<String, dynamic>?) ?? {}).entries) {
      final k = IVec3.parse(e.key);
      if (k == null) continue;
      final inv = Inventory();
      inv.fromJson(e.value as List<dynamic>);
      chests[k] = inv;
    }
    for (final e in ((data['waypoints'] as Map<String, dynamic>?) ?? {}).entries) {
      final k = IVec3.parse(e.key);
      if (k != null) waypoints[k] = e.value.toString();
    }
    for (final k in (data['bosses'] as List<dynamic>? ?? const [])) {
      final p = IVec3.parse(k.toString());
      if (p != null) _bossesSpawned.add(p);
    }
    return true;
  }

  // --- the screenshot probe --------------------------------------------------------------

  Future<void> _runScreenshot(String path, int frames) async {
    final t0 = DateTime.now();
    for (var i = 0; i < frames; i++) {
      await nextFrame();
      if (i % 40 == 0 && _hasArg('--trace')) {
        debugPrint('[trace] f$i pos ${player.position} vel ${player.velocity} floor ${player.onFloor}');
      }
      if (i > 10 && world.isIdle) break;
    }
    debugPrint('[probe] window filled: ${world.loadedChunkCount} chunks, ${world.facesEmitted} faces in ${DateTime.now().difference(t0).inMilliseconds} ms');
    final net = Net.instance;
    if (net.mode != NetMode.solo) debugPrint('[probe] net mode ${net.mode} puppets ${net.puppetPositions()}');
    debugPrint('[probe] camera at ${player.cameraPosition} distance ${player.camDistance.toStringAsFixed(2)} yaw ${player.yaw.toStringAsFixed(2)} pitch ${player.pitch.toStringAsFixed(2)}');
    debugPrint('[probe] player at ${player.position} structures near: ${world.structuresNear(VoxelWorld.chunkOf(IVec3.floor(player.position)))}');
    if (_hasArg('--map')) mapVisible = true;
    if (_arg('--journal=', '') != '') openJournal(int.tryParse(_arg('--journal=', '')) ?? 0);
    if (_hasArg('--open-inventory')) openStation('crafting_table', IVec3.zero);
    final fire = _arg('--fire=', '');
    if (_hasArg('--stage16')) {
      final b = IVec3.floor(player.position) + const IVec3(0, 0, -3);
      world.setBlock(b + const IVec3(-1, 0, 0), Blocks.indexOf('oak_planks'));
      world.setBlock(b + const IVec3(-1, 1, 0), Blocks.indexOf('oak_planks'));
      world.setBlock(b + const IVec3(1, 0, 0), Blocks.indexOf('oak_planks'));
      world.setBlock(b + const IVec3(1, 1, 0), Blocks.indexOf('oak_planks'));
      world.setBlock(b, Blocks.indexOf('door_z'));
      world.setBlock(b + IVec3.up, Blocks.indexOf('door_z'));
      world.setBlock(b + const IVec3(2, 1, 0), Blocks.indexOf('wall_torch'));
      world.setBlock(b + const IVec3(3, 0, 0), Blocks.indexOf('enchanting_table'));
      spawnBoat(b.toVector3() + Vector3(-3.5, 0.6, 2.5), 0.4);
    }
    Mob? dummy;
    if (_hasArg('--strike') && !net.isClient) {
      dummy = Mob();
      dummy.setupMob(world, this, player, Species.def('zombie'));
      final ahead = player.aimDirection().clone()..y = 0;
      dummy.position = player.position + ahead.normalized() * 2.2;
      addMob(dummy);
    }
    final elite = _hasArg('--stage18') ? _probeStage18() : null;
    final settle = int.tryParse(_arg('--settle=', '')) ?? 30;
    for (var i = 0; i < settle; i++) {
      await nextFrame();
      if (elite != null && i == 5) player.probeDodge();
      if (elite != null && i == 6) {
        debugPrint('[probe] stage18: dodging ${player.isDodging()}, invulnerable ${player.invulnerable}, from ${player.position}');
      }
      if (fire != '' && i % 6 == 0 && i >= 6) player.probeFire(fire == 'secondary');
      if (dummy != null && i == 12) {
        debugPrint('[probe] strike: zombie hp ${dummy.hp.toStringAsFixed(1)} before, ray ${dummy.rayDistance(player.centre(), player.aimDirection(), 0.15).toStringAsFixed(2)} m from the player\'s centre');
        player.probeStrike();
      }
    }
    if (dummy != null) debugPrint('[probe] strike: zombie hp ${dummy.hp.toStringAsFixed(1)} after');
    if (elite != null) {
      final ach = Achievements.instance;
      debugPrint('[probe] stage18: effects ${player.effects.rows.keys.toList()}');
      debugPrint('[probe] stage18: elite \'${elite.displayName()}\' hp ${elite.maxHp.toStringAsFixed(0)} '
          'speed x${elite.speedMult.toStringAsFixed(1)}, talents ${player.talents}, points left ${player.talentPoints}');
      debugPrint('[probe] stage18: weather ${weather.label} intensity ${weather.intensity.toStringAsFixed(2)} '
          'darken ${weather.darken().toStringAsFixed(2)}');
      debugPrint('[probe] stage18: waypoints ${waypoints.length}, player at ${player.position}, '
          'achievements ${ach.count}: ${ach.unlocked.toList()}');
    }
    if (_hasArg('--wait-peer')) {
      final t1 = DateTime.now();
      while (net.puppetPositions().isEmpty && DateTime.now().difference(t1).inMilliseconds < 40000) {
        await nextFrame();
      }
      if (net.puppetPositions().isNotEmpty) {
        final z = Mob();
        z.setupMob(world, this, player, Species.def('zombie'));
        z.position = net.puppetPositions()[0].$2 + Vector3(2.5, 0, 0);
        addMob(z);
        for (var i = 0; i < 90; i++) {
          await nextFrame();
        }
        debugPrint('[probe] zombie beside the puppet: hp ${z.hp.toStringAsFixed(1)} after the peer\'s swing');
      }
      if (_hasArg('--strike') && net.isClient) {
        for (var i = 0; i < 30; i++) {
          await nextFrame();
        }
        debugPrint('[probe] strike sent to the host, aim ${player.aimDirection()}');
        player.probeStrike();
        for (var i = 0; i < 60; i++) {
          await nextFrame();
        }
      }
      var hunting = 0;
      for (final m in mobs) {
        if (m.huntsPuppet()) hunting++;
      }
      debugPrint('[probe] net mode ${net.mode} puppets ${net.puppetPositions()}, mobs hunting a puppet: $hunting');
    }
    await nextFrame();
    await nextFrame();
    debugPrint('[probe] fps ${fps.toStringAsFixed(0)} mobs ${mobs.length} drops ${drops.length} projectiles ${projectiles.length}');
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    debugPrint('[probe] view ${view.physicalSize.width / view.devicePixelRatio}x${view.physicalSize.height / view.devicePixelRatio} logical @${view.devicePixelRatio}x');
    final shot = screenshotter;
    if (shot != null) {
      await shot(path);
      debugPrint('[probe] screenshot saved to $path');
    } else {
      debugPrint('[probe] no screenshotter, nothing captured');
    }
    exit(0);
  }

  /// --stage18: poison plus a potion, an elite spider, a talent, two waypoints
  /// and a hop between them.
  Mob _probeStage18() {
    player.applyEffect('poison', 8.0);
    player.drink('speed', 30.0);
    final ahead = player.aimDirection().clone()..y = 0;
    final elite = Mob();
    elite.setupMob(world, this, player, Species.def('spider'));
    elite.position = player.position + ahead.normalized() * 3.0;
    elite.scaleToLevel(3);
    elite.setAffix('Venomous');
    addMob(elite);
    player.talentPoints = 2;
    player.learnTalent('might');
    final base = IVec3.floor(player.position);
    final a = base + const IVec3(3, 0, 0);
    final b = base + const IVec3(0, 0, 6);
    for (final w in [a, b]) {
      world.setBlock(w, Blocks.indexOf('waypoint'));
      onBlockPlaced(w, Blocks.indexOf('waypoint'));
    }
    travelToWaypoint(b);
    return elite;
  }

  void shutdown() {
    world.dispose();
    input.dispose();
  }
}
