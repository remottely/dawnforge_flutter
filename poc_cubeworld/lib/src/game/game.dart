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
import '../entities/voxel_body.dart';
import '../player/player.dart';
import '../world/terrain_generator.dart';
import '../world/voxel_world.dart';
import 'achievements.dart';
import 'game_state.dart';
import 'input.dart';
import 'inventory.dart';
import 'loot.dart';
import 'net.dart';
import 'quests.dart';
import 'sfx.dart';
import 'settings.dart';
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

class _Stage21a {
  _Stage21a(this.at, this.kind, this.origin);
  final Vector3 at;
  final int kind;
  final IVec3 origin;
}

class _Stage20 {
  _Stage20(this.horse, this.wool);
  final Mob horse;
  final int wool;
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
  Game({required this.args, required String saveDir})
      : saveRoot = Directory(saveDir).parent.parent.path,
        saveDir = args.containsKey('--slot=') ? '${Directory(saveDir).parent.path}/${args['--slot=']}' : saveDir;

  static const double dayLength = 600.0;
  static const double fixedStep = 1.0 / 60.0;

  final Map<String, String> args;

  /// `worlds/<name>`, or `worlds/<slot>` with `--slot=` (stage 24).
  final String saveDir;

  /// Godot's `user://`: the folder holding `worlds/`, `settings.cfg` and the
  /// stage 24 probe flag.
  final String saveRoot;

  /// Stage 24: every chunk the player ever stood in (the world map's explored
  /// area, saved), the structures the player came close to (kind per origin,
  /// the map's icons), and the verify half of the `--stage24` probe, signalled
  /// across the reload by `probe24.flag`.
  final Set<ChunkPos> visitedChunks = {};
  final Map<IVec3, int> discoveredStructures = {};
  bool _stage24Verify = false;
  String get _probe24Flag => '$saveRoot/probe24.flag';

  /// Set by the view: throws this session away and builds a fresh one with the
  /// same arguments (Godot's `reload_current_scene`).
  void Function()? reloader;
  bool worldMapVisible = false;
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

  /// Stage 23: plates pressed and not yet left, so one press lights one fuse.
  final Set<IVec3> _platesFired = {};
  Spawner? spawner;
  ScreenKind screen = ScreenKind.none;
  String station = '';
  Inventory? chest;
  IVec3 chestPos = IVec3.zero;
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

  /// Where the probe wants the camera on the captured frame, when it must not
  /// drift (a body is swept out of terrain every tick).
  Vector3 Function()? _pinCameraTo;

  /// A probe's per-tick hook, called right after the simulation step (Godot's
  /// `await physics_frame`, which a per-frame await here would undercount).
  void Function()? _probeTick;
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
    final flag = File(_probe24Flag);
    _stage24Verify = flag.existsSync();
    if (_stage24Verify) flag.deleteSync(); // one verify boot, whatever happens next

    world = VoxelWorld(
      seedValue: int.tryParse(_arg('--seed=', '')) ?? GameState.instance.seedValue,
      // A probe run keeps radius 8 so its chunk counts never depend on this
      // machine's settings.cfg.
      loadRadius: int.tryParse(_arg('--radius=', '')) ?? (_arg('--screenshot=', '') != '' ? 8 : Settings.instance.renderRadius),
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
    weather.setEnabled(Settings.instance.weather);
    if (_arg('--weather=', '') != '') weather.force(_arg('--weather=', ''));

    final net = Net.instance;
    net.main = this;
    net.rejectOne = _hasArg('--reject-one') && net.isHost;
    if (net.isClient) net.applyPendingEdits();
    world.onBlockChanged = net.onBlockChanged;
    world.flowEnabled = !net.isClient;
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
    if (input.justPressed(GameAction.map)) cycleMap(); // stage 24: minimap, then the world map, then off
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
    // Stage 23: the pressure plates (Godot's `Main._physics_process`). Host / solo
    // only: a client sees the `igniteTnt` block edit arrive.
    if (!Net.instance.isClient) {
      _checkPlateUnder(player);
      for (final m in List.of(mobs)) {
        _checkPlateUnder(m);
      }
      for (final m in List.of(pets)) {
        _checkPlateUnder(m);
      }
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
    // Stage 25: the tick's flow edits leave as one `blocks` message.
    Net.instance.beginBlockBatch();
    world.tickFlow(dt);
    Net.instance.endBlockBatch();
    _probeTick?.call();
    Net.instance.process(dt);
    _prune();

    for (final n in notes) {
      n.t -= dt;
    }
    notes.removeWhere((n) => n.t <= 0.0);

    _structTimer += dt;
    if (_structTimer > 1.0) {
      _structTimer = 0.0;
      visitedChunks.add(VoxelWorld.chunkOf(IVec3.floor(player.position)));
      _checkStructures();
      // Stage 25: growth is a host block edit; it reaches clients as one.
      if (!Net.instance.isClient) _growCrops();
      _tickSpawners();
      _tickRuinGhosts();
      _trackBoss();
      if (weather.isWet) {
        if (!Net.instance.isClient) _growCrops();
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
    for (final d in drops) {
      if (d.removed) Net.instance.onDropGone(d);
    }
    pruneList<ItemDrop>(drops, (d) => d.removed, (d) => d.node);
    pruneList<Projectile>(projectiles, (p) => p.removed, (p) => p.node);
    for (final b in boats) {
      if (b.removed) Net.instance.onBoatGone(b);
    }
    pruneList<Boat>(boats, (b) => b.removed, (b) => b.node);
    pruneList<RemotePlayer>(puppets, (p) => p.removed, (p) => p.node);
    pruneList<_Effect>(_effects, (e) => e.age >= 0.35, (e) => e.node);
    pruneList<_Debris>(_debris, (d) => d.age >= 0.6, (d) => d.node);
  }

  // --- screens ------------------------------------------------------------------------

  void openStation(String st, IVec3 at) {
    station = st;
    chestPos = at;
    chest = st != 'chest' ? null : (Net.instance.isClient ? Net.instance.openChest(at) : chestInventory(at));
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
      // Stage 23: the table of the structure the chest belongs to (`LootTables`).
      final rng = math.Random(at.hashCode ^ world.seedValue);
      final table = LootTables.tableNear(world, at);
      for (final stack in LootTables.roll(table, rng)) {
        inv.add(stack.id, stack.count);
      }
      if ((table == 'dungeon' || table == 'temple') && rng.nextDouble() < 0.45) {
        final w = randomLootWeapon(rng);
        inv.addStack(ItemStack(w.id, 1, bonus: w.bonus));
      }
    }
    return inv;
  }

  /// Kinds 5..8 of `structuresNear` (ruin, well, mine, temple), announced once each.
  static const Map<int, String> minorStructureFound = {
    5: 'You found an old ruin!',
    6: 'You found a well!',
    7: 'You found an abandoned mine!',
    8: 'You found a desert temple!',
  };

  void _checkStructures() {
    final here = VoxelWorld.chunkOf(IVec3.floor(player.position));
    for (final s in world.structuresNear(here)) {
      final key = IVec3(s.x, s.y, s.z);
      // Stage 24: any structure within 48 m is discovered (the map draws it
      // from now on).
      if (s.type >= 1 && s.type <= 8 && !discoveredStructures.containsKey(key) && key.distanceTo(player.position) < 48.0) {
        discoveredStructures[key] = s.type;
      }
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
      final found = minorStructureFound[s.type];
      if (found != null) {
        if (!_bossesSpawned.contains(key) && key.distanceTo(player.position) < 24.0) {
          _bossesSpawned.add(key);
          notify(found);
        }
        // Stage 23: the Mummy King wakes the first time someone steps into the
        // temple chamber. Its own key is the chamber's, lifted by
        // templeBossKeyY so it never collides with the announcement key above
        // (both live in `_bossesSpawned` and the save).
        if (s.type == TerrainGenerator.structTemple) {
          final bkey = IVec3(s.x, s.y + templeBossKeyY, s.z);
          final chamber = Vector3(s.x + 0.5, s.y + 1.0, s.z + 0.5);
          if (!_bossesSpawned.contains(bkey) && (player.position - chamber).length < 6.0) {
            _bossesSpawned.add(bkey);
            spawnTempleBoss(chamber);
          }
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

  static const int templeBossKeyY = 1000;

  /// Stage 23: the Mummy King, between the two chests at the back of the
  /// chamber whose floor centre is [chamber] (the cell above the pressure plate).
  Mob spawnTempleBoss(Vector3 chamber) {
    final mob = Mob();
    mob.setupMob(world, this, player, Species.def('mummy_king'));
    mob.position = chamber + Vector3(0, 0.05, -1.0);
    mob.scaleToLevel(player.level + 2);
    addMob(mob);
    boss = mob;
    notify('The Mummy King stirs!');
    Sfx.play('thunder', -8.0, 1.6);
    return mob;
  }

  /// Stage 23: a pressure plate fires when any body's feet are in its cell. It
  /// lights the TNT right under it (the temple trap); a plate over nothing just
  /// clicks.
  void _checkPlateUnder(VoxelBody body) {
    final cell = IVec3(body.position.x.floor(), (body.position.y + 0.05).floor(), body.position.z.floor());
    final id = world.getBlock(cell);
    if (id == Blocks.air || Blocks.idOf(id) != 'pressure_plate') {
      _platesFired.remove(cell); // the body left (or the plate is gone): it may fire again
      return;
    }
    if (_platesFired.contains(cell) || !body.overlapsBlock(cell)) return;
    _platesFired.add(cell);
    Sfx.play('click', 0.0, 0.6);
    final below = world.getBlock(cell + IVec3.down);
    if (below != Blocks.air && Blocks.idOf(below) == 'tnt') {
      igniteTnt(cell + IVec3.down);
      notify('Click... the floor rumbles!');
    }
  }

  int platesFired() => _platesFired.length;

  /// Stage 23: ghosts haunt ruins at night — up to two per ruin within 40 m, one
  /// every few seconds.
  void _tickRuinGhosts() {
    final sp = spawner;
    if (!isNight || Net.instance.isClient || sp == null) return;
    final here = VoxelWorld.chunkOf(IVec3.floor(player.position));
    for (final s in world.structuresNear(here)) {
      if (s.type != TerrainGenerator.structRuin) continue;
      final at = Vector3(s.x.toDouble(), s.y.toDouble(), s.z.toDouble());
      if ((player.position - at).length > 40.0 || random.nextDouble() > 0.35) continue;
      var near = 0;
      for (final m in mobs) {
        if (m.species.id == 'ghost' && (m.position - at).length < 24.0) near += 1;
      }
      if (near >= 2) continue;
      final x = s.x + random.nextInt(9) - 4;
      final z = s.z + random.nextInt(9) - 4;
      final ghost = sp.forceSpawn('ghost', Vector3(x + 0.5, world.groundHeight(x, z) + 0.5, z + 0.5));
      spawnEffect(ghost.centre(), Vector3(0.7, 0.8, 1.0), 1.5);
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

  ItemDrop? spawnDrop(Vector3 at, String id, int count, [Vector3? vel, double delay = 0.6]) {
    // The host owns drops (stage 21b); a client asks for one instead.
    if (Net.instance.isClient) {
      Net.instance.requestDrop(at, id, count, vel ?? Vector3.zero());
      return null;
    }
    final drop = ItemDrop();
    drop.setupDrop(world, id, count, player, delay);
    drop.position = at.clone();
    drop.velocity = vel ?? Vector3(random.nextDouble() * 3 - 1.5, 3.0, random.nextDouble() * 3 - 1.5);
    drop.syncNode();
    drops.add(drop);
    entities.add(drop.node);
    Net.instance.onDropSpawned(drop);
    return drop;
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
    Net.instance.onDropSpawned(drop);
  }

  bool _hasOpaqueSide(IVec3 b) {
    for (final side in IVec3.sides) {
      if (Blocks.isOpaque(world.getBlock(b + side))) return true;
    }
    return false;
  }

  void spawnBoat(Vector3 at, double heading) {
    // The host owns boats (stage 25); a client asks for one instead.
    if (Net.instance.isClient) {
      Net.instance.requestBoat(at, heading);
      return;
    }
    final b = Boat();
    b.setupBoat(world, this, at, heading);
    boats.add(b);
    entities.add(b.node);
    Net.instance.onBoatSpawned(b);
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
      final candidates = <IVec3>[];
      if (s.type == 1) {
        for (var room = 0; room < 2; room++) {
          candidates.add(IVec3(s.x + room * 12, s.y + 1, s.z + 2));
        }
      } else if (s.type == TerrainGenerator.structMine) {
        // The mine corridor runs +x from the shaft, 20-30 long; the spawner
        // sits on its centre line.
        for (var x = s.x + 17; x < s.x + 31; x++) {
          candidates.add(IVec3(x, TerrainGenerator.mineFloorY + 1, s.z));
        }
      }
      for (final pos in candidates) {
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

  /// Stage 23: TNT blocks lit and not yet exploded.
  int litTntCount() => _tnts.length;

  /// Probes only: put every lit TNT back unexploded, so a trap can be shown
  /// after it fired.
  void probeDefuseTnt() {
    for (final t in _tnts) {
      entities.remove(t.node);
      world.setBlock(t.at, Blocks.indexOf('tnt'));
    }
    _tnts.clear();
    _platesFired.clear();
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
        // Stage 24: boats, tamed mobs (the mount by its index), dropped items,
        // the explored map.
        ...entityData(),
      };
      await File('$saveDir/player.json').writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('[save] failed: $e');
    }
  }

  /// Stage 24: the save keys Godot added — `boats`, `pets`, `mount`, `drops`,
  /// `visited`, `structures`.
  Map<String, Object> entityData() {
    final petData = <Map<String, Object>>[];
    var mountIndex = -1;
    for (final m in pets) {
      if (m.puppet || !m.tamed || m.isDead || m.removed) continue;
      if (identical(m, player.mount)) mountIndex = petData.length;
      petData.add(m.toJson());
    }
    return {
      'boats': [for (final b in boats) if (!b.removed && !b.replica) b.toJson()],
      'pets': petData,
      'mount': mountIndex,
      'drops': [for (final d in drops) if (!d.replica && !d.removed) d.toJson()],
      'visited': encodeVisited(visitedChunks),
      'structures': encodeStructures(discoveredStructures),
    };
  }

  static List<String> encodeVisited(Set<ChunkPos> chunks) => [for (final c in chunks) '${c.x},${c.z}'];

  static Set<ChunkPos> decodeVisited(List<dynamic> keys) {
    final out = <ChunkPos>{};
    for (final k in keys) {
      final parts = k.toString().split(',');
      out.add((x: int.parse(parts[0]), z: int.parse(parts[1])));
    }
    return out;
  }

  static Map<String, int> encodeStructures(Map<IVec3, int> found) => {for (final e in found.entries) e.key.key: e.value};

  static Map<IVec3, int> decodeStructures(Map<String, dynamic> data) {
    final out = <IVec3, int>{};
    for (final e in data.entries) {
      final k = IVec3.parse(e.key);
      if (k != null) out[k] = (e.value as num).toInt();
    }
    return out;
  }

  Future<bool> _loadGame() async {
    final f = File('$saveDir/player.json');
    if ((_hasArg('--new') || GameState.instance.freshWorld) && !_stage24Verify) return false;
    if (!await f.exists()) return false;
    final data = jsonDecode(await f.readAsString());
    if (data is! Map<String, dynamic>) return false;
    // The seed is the world: a save made under another seed wins over the
    // menu's default (an explicit --seed= still overrides, for the probes).
    final savedSeed = (data['seed'] as num?)?.toInt();
    if (_arg('--seed=', '') == '' && savedSeed != null && savedSeed != world.seedValue) {
      await world.setWorldSeed(savedSeed);
    }
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
    // Stage 24: the entities and the explored map.
    visitedChunks.addAll(decodeVisited(data['visited'] as List<dynamic>? ?? const []));
    discoveredStructures.addAll(decodeStructures(data['structures'] as Map<String, dynamic>? ?? const {}));
    for (final b in (data['boats'] as List<dynamic>? ?? const [])) {
      final bd = b as Map<String, dynamic>;
      final p = (bd['pos'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
      spawnBoat(Vector3(p[0], p[1], p[2]), (bd['yaw'] as num?)?.toDouble() ?? 0.0);
    }
    final restored = <Mob>[];
    for (final pd in (data['pets'] as List<dynamic>? ?? const [])) {
      final d = pd as Map<String, dynamic>;
      if (!Species.defs.containsKey(d['species'].toString())) continue;
      final m = Mob();
      m.setupMob(world, this, player, Species.def(d['species'].toString()));
      m.fromJson(d);
      if (m.tamed) {
        pets.add(m);
        entities.add(m.node);
      } else {
        addMob(m);
      }
      restored.add(m);
    }
    final mountIndex = (data['mount'] as num?)?.toInt() ?? -1;
    if (mountIndex >= 0 && mountIndex < restored.length && restored[mountIndex].isMount && restored[mountIndex].tamed) {
      player.mountHorse(restored[mountIndex]);
    }
    for (final dd in (data['drops'] as List<dynamic>? ?? const [])) {
      final d = dd as Map<String, dynamic>;
      final p = (d['pos'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
      final drop = ItemDrop();
      drop.setupDrop(world, d['item'].toString(), (d['count'] as num?)?.toInt() ?? 1, player);
      drop.position = Vector3(p[0], p[1], p[2]);
      drop.bonus = (d['bonus'] as num?)?.toInt() ?? 0;
      drop.syncNode();
      drops.add(drop);
      entities.add(drop.node);
      Net.instance.onDropSpawned(drop);
    }
    return true;
  }

  // --- the screenshot probe --------------------------------------------------------------

  Future<void> _runScreenshot(String path, int frames) async {
    final stage21a = _hasArg('--stage21a')
        ? _probeStage21aTeleport()
        // The temple: seed 42's nearest is past 24 chunks.
        : (_hasArg('--stage23') ? _probeStage21aTeleport(48) : null);
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
    if (stage21a != null) {
      // The chunks are in now: stand exactly where the probe chose, with a
      // pocket of air behind the player for the orbit camera (the mine's
      // corridor is its own pocket).
      final at = stage21a.at;
      if (stage21a.kind != TerrainGenerator.structMine) {
        for (var dx = -2; dx < 3; dx++) {
          for (var dz = -3; dz < 8; dz++) {
            for (var dy = 0; dy < 6; dy++) {
              world.setBlock(IVec3(at.x.floor() + dx, at.y.floor() + dy, at.z.floor() + dz), Blocks.air);
            }
          }
        }
      }
      player.position = at.clone();
      player.velocity = Vector3.zero();
      player.syncNode();
    }
    if (_hasArg('--stage21a')) {
      final counts = <int, int>{};
      final seen = <IVec3>{};
      for (final pos in world.chunks.keys) {
        for (final st in world.structuresNear(pos)) {
          final key = IVec3(st.x, st.y, st.z);
          if (!seen.add(key)) continue;
          counts[st.type] = (counts[st.type] ?? 0) + 1;
        }
      }
      debugPrint('[probe] stage21a: structures by kind $counts');
    }
    if (_hasArg('--map')) mapVisible = true;
    if (_hasArg('--open-map')) {
      mapVisible = true;
      worldMapVisible = true;
    }
    if (_hasArg('--open-settings')) openScreen(ScreenKind.pause);
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
    // --stage19: a row of slabs, three fences in a line, and two stairs three
    // blocks ahead.
    final stage19FacesBefore = world.facesEmitted;
    var stage19Placed = 0;
    if (_hasArg('--stage19')) {
      // The player looks north (-Z); the row sits one block below eye level,
      // shifted right so the block on the left of the spawn does not hide it.
      final b = IVec3.floor(player.position) + const IVec3(3, -1, -3);
      final stairs = Blocks.stairsFacing(Blocks.indexOf('oak_stairs_n'), 0, -1);
      final stoneStairs = Blocks.stairsFacing(Blocks.indexOf('stone_stairs_n'), 0, -1);
      final row = [
        b + const IVec3(-3, 0, 0), b + const IVec3(-2, 0, 0), b + const IVec3(-1, 0, 0), b,
        b + const IVec3(1, 0, 0), b + const IVec3(2, 0, 0), b + const IVec3(3, 0, 0),
      ];
      final ids = [
        Blocks.indexOf('oak_slab'), Blocks.indexOf('stone_slab'), Blocks.indexOf('oak_fence'),
        Blocks.indexOf('oak_fence'), Blocks.indexOf('oak_fence'), stairs, stoneStairs,
      ];
      for (var i = 0; i < row.length; i++) {
        for (var dz = -1; dz < 3; dz++) {
          for (var dy = 0; dy < 4; dy++) {
            world.setBlock(row[i] + IVec3(0, dy, dz), Blocks.air); // clear the view
          }
        }
        // Contrasts with every block in the row.
        world.setBlock(row[i] + IVec3.down, Blocks.indexOf('dark_stone'));
        if (world.setBlock(row[i], ids[i])) stage19Placed += 1;
      }
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
    final stage20 = _hasArg('--stage20') ? _probeStage20() : null;
    var rideFrom = Vector3.zero();
    final settle = int.tryParse(_arg('--settle=', '')) ?? 30;
    for (var i = 0; i < settle; i++) {
      await nextFrame();
      // --ride (with --stage20): hold W and sprint for ten frames and measure
      // how far the horse went.
      if (stage20 != null && _hasArg('--ride') && i == 3) {
        rideFrom = stage20.horse.position.clone();
        input.probeHold(GameAction.moveForward, true);
        input.probeHold(GameAction.sprint, true);
      }
      if (stage20 != null && _hasArg('--ride') && i == 13) {
        input.probeHold(GameAction.moveForward, false);
        input.probeHold(GameAction.sprint, false);
        debugPrint('[probe] stage20: rode ${(stage20.horse.position - rideFrom).length.toStringAsFixed(2)} m in ten '
            'frames, horse velocity ${stage20.horse.velocity}, rider at ${player.position}');
      }
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
    if (_hasArg('--stage19')) {
      debugPrint('[probe] stage19: placed $stage19Placed blocks, faces before/after '
          '$stage19FacesBefore/${world.facesEmitted}');
    }
    if (stage20 != null) {
      debugPrint('[probe] stage20: wool in inventory ${player.inventory.countOf('wool')} (dropped ${stage20.wool})');
      debugPrint('[probe] stage20: capture mounted ${player.isMounted()} at ${player.position} '
          '(horse at ${stage20.horse.position}), bobber out ${player.bobber != null} '
          'landed ${player.bobber?.landed ?? false}');
    }
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
    // --stage21b (with --wait-peer): drops, chests, weather and mounts across the
    // wire. The host pre-fills a chest, forces a storm, mounts a horse and drops
    // an item beside the client's puppet; the client reports what reached it and
    // reads the host's chest.
    const chestAt = IVec3(7, 77, 7);
    if (_hasArg('--stage21b') && net.isHost && net.puppetPositions().isNotEmpty) {
      final chestInv = chestInventory(chestAt);
      chestInv.fromJson(const []);
      chestInv.add('apple', 3);
      weather.force('storm');
      // A flat 7x7 stone pad 4 m east so the horse stands where the client's
      // camera can see it.
      final pad = IVec3.floor(player.position + Vector3(4.0, 0.0, 0.0));
      for (var dx = -3; dx < 4; dx++) {
        for (var dz = -3; dz < 4; dz++) {
          world.setBlock(pad + IVec3(dx, -1, dz), Blocks.indexOf('stone'));
          for (var dy = 0; dy < 6; dy++) {
            world.setBlock(pad + IVec3(dx, dy, dz), Blocks.air);
          }
        }
      }
      final horse = Mob();
      horse.setupMob(world, this, player, Species.def('horse'));
      horse.position = pad.toVector3() + Vector3(0.5, 0.5, 0.5);
      addMob(horse);
      horse.tame(player);
      player.mountHorse(horse);
      debugPrint('[probe] stage21b: host forced weather ${weather.label}, chest $chestAt holds '
          '${chestInv.toJson().first}, riding ${player.isMounted()} (riddenBy ${horse.riddenBy})');
      // One metre east of the puppet, on a block laid there so the drop cannot
      // fall into a hole.
      final ppos = net.puppetPositions().first.$2;
      final under = IVec3(ppos.x.floor() + 1, ppos.y.floor() - 1, ppos.z.floor());
      world.setBlock(under, Blocks.indexOf('stone'));
      world.setBlock(under + IVec3.up, Blocks.air);
      spawnDrop(ppos + Vector3(1.0, 0.4, 0.0), 'iron_ingot', 2, Vector3(0, 0.5, 0));
      // A spider bites the puppet once through the simulation: the poison must
      // reach the peer.
      final spider = Mob();
      spider.setupMob(world, this, player, Species.def('spider'));
      spider.position = ppos + Vector3(-2.0, 0.5, 0.0);
      addMob(spider);
      spider.hurtTarget(net.puppetBodies().first, 1.0);
      debugPrint('[probe] stage21b: spider bit the puppet (effect ${spider.species.effect})');
      final t2 = DateTime.now();
      while (net.lastGive == null && DateTime.now().difference(t2).inMilliseconds < 15000) {
        await nextFrame();
      }
      final give = net.lastGive;
      debugPrint('[probe] stage21b: client picked up ${give == null ? 'nothing' : '${give.$2} x${give.$3}'}');
      final t3 = DateTime.now();
      while (net.puppetPositions().isNotEmpty && DateTime.now().difference(t3).inMilliseconds < 12000) {
        await nextFrame();
      }
      debugPrint('[probe] stage21b: host rider at ${player.position}, horse at ${horse.position} '
          '(ridden ${horse.ridden} by ${horse.riddenBy})');
    }
    if (_hasArg('--stage21b') && net.isClient) {
      final t2 = DateTime.now();
      while (DateTime.now().difference(t2).inMilliseconds < 3000) {
        await nextFrame();
      }
      debugPrint('[probe] stage21b: client weather ${weather.label} (forced ${weather.forced}), '
          'iron_ingot in bag ${player.inventory.countOf('iron_ingot')}, drop replicas '
          '${net.dropReplicas.length}, effects ${player.effects.rows.keys.toList()}');
      final view = net.openChest(chestAt);
      final t3 = DateTime.now();
      while (view.countOf('apple') == 0 && DateTime.now().difference(t3).inMilliseconds < 5000) {
        await nextFrame();
      }
      debugPrint('[probe] stage21b: chest $chestAt from the host holds ${view.toJson().take(2).toList()}');
      net.closeChest(chestAt);
      var mounted = 0;
      for (final b in net.puppetBodies()) {
        if (b.mountedOn != null) mounted++;
      }
      debugPrint('[probe] stage21b: host puppets riding a horse puppet: $mounted');
      // Frame the host puppet for the capture: hover 3.5 m south of it in first
      // person, looking north.
      if (net.puppetBodies().isNotEmpty) {
        flyMode = true;
        player.setFirstPerson(true);
        player.setLook(0.0, -0.3);
        for (var i = 0; i < 20; i++) {
          player.position = net.puppetBodies().first.position + Vector3(0, 0.8, 3.5);
          player.velocity = Vector3.zero();
          player.syncNode();
          await nextFrame();
        }
        debugPrint('[probe] stage21b: capture from ${player.position}, '
            'host puppet at ${net.puppetBodies().first.position}');
        // The body keeps being swept out of whatever it stands in, so pin the
        // camera again on the frame that is actually captured.
        _pinCameraTo = () => net.puppetBodies().first.position + Vector3(0, 0.8, 3.5);
      }
    }
    if (_hasArg('--stage25') && net.isHost && net.puppetPositions().isNotEmpty) await _probeStage25Host();
    if (_hasArg('--stage25') && net.isClient) await _probeStage25Client();
    if (_hasArg('--stage22')) await _probeStage22();
    if (_hasArg('--stage23')) await _probeStage23(stage21a);
    if (_hasArg('--stage24')) {
      // The setup half saved and asked for a fresh session; the verify half
      // prints the rest and captures.
      if (await _probeStage24()) return;
    }
    await nextFrame();
    await nextFrame();
    debugPrint('[probe] fps ${fps.toStringAsFixed(0)} mobs ${mobs.length} drops ${drops.length} projectiles ${projectiles.length}');
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    debugPrint('[probe] view ${view.physicalSize.width / view.devicePixelRatio}x${view.physicalSize.height / view.devicePixelRatio} logical @${view.devicePixelRatio}x');
    final pin = _pinCameraTo;
    if (pin != null) {
      player.position = pin();
      player.velocity = Vector3.zero();
      player.syncNode();
      await nextFrame();
    }
    final shot = screenshotter;
    if (shot != null) {
      await shot(path);
      debugPrint('[probe] screenshot saved to $path');
    } else {
      debugPrint('[probe] no screenshotter, nothing captured');
    }
    exit(0);
  }

  /// --stage22: sub-block collision and liquid flow on a stone pad beside
  /// spawn. Three walks along +x (onto a slab, up a stairs onto a block, into a
  /// fence with a jump), then a water source that spreads and drains, then lava
  /// meeting water. The camera ends above the pad.
  Future<void> _probeStage22() async {
    final x0 = player.position.x.floor() + 3;
    final z0 = player.position.z.floor();
    // The pad's stone row sits at the HIGHEST ground of its footprint, so no
    // lake or river can share its level (Godot's first draft exposed a shore
    // and flooded the walks); the walk floor is y0 + 1. The footprint is
    // 16 x 20: every puddle the probe pours stays on the pad.
    var y0 = 0;
    for (var x = x0 - 3; x < x0 + 13; x++) {
      for (var z = z0 - 4; z < z0 + 16; z++) {
        y0 = math.max(y0, world.groundHeight(x, z));
      }
    }
    final lo = IVec3(x0 - 3, y0 + 1, z0 - 4);
    final hi = IVec3(x0 + 12, y0 + 4, z0 + 15); // the counted volume: the pad footprint, 4 high
    final stone = Blocks.indexOf('stone');
    for (var x = lo.x; x <= hi.x; x++) {
      for (var z = lo.z; z <= hi.z; z++) {
        world.setBlock(IVec3(x, y0, z), stone);
        for (var y = y0 + 1; y < y0 + 7; y++) {
          world.setBlock(IVec3(x, y, z), Blocks.air);
        }
      }
    }
    final stairs = Blocks.stairsFacing(Blocks.indexOf('oak_stairs_n'), 1, 0);
    world.setBlock(IVec3(x0 + 2, y0 + 1, z0), Blocks.indexOf('oak_slab'));
    world.setBlock(IVec3(x0 + 5, y0 + 1, z0), stairs);
    world.setBlock(IVec3(x0 + 6, y0 + 1, z0), Blocks.indexOf('oak_planks'));
    world.setBlock(IVec3(x0 + 9, y0 + 1, z0), Blocks.indexOf('oak_fence'));
    final start = Vector3(x0 + 0.5, y0 + 1.1, z0 + 0.5);
    debugPrint('[probe] stage22 site x0=$x0 y0=$y0 z0=$z0 (walk floor y=${y0 + 1})');
    final slab = await _stage22Walk(start, x0 + 2.2, 90, false);
    debugPrint('[probe] stage22 slab top y=${slab.y.toStringAsFixed(3)} (expect ${(y0 + 1.5).toStringAsFixed(1)}) '
        'at x=${slab.x.toStringAsFixed(2)} on_floor=${slab.floor}');
    final stair = await _stage22Walk(start, x0 + 6.3, 150, false);
    debugPrint('[probe] stage22 stairs top y=${stair.y.toStringAsFixed(3)} (expect ${y0 + 2}) '
        'at x=${stair.x.toStringAsFixed(2)} max_vy=${stair.maxVy.toStringAsFixed(2)}');
    final fence = await _stage22Walk(start, x0 + 20.0, 220, true, x0 + 8.5);
    debugPrint('[probe] stage22 fence blocked x=${fence.x.toStringAsFixed(3)} (post face ${(x0 + 9.375).toStringAsFixed(3)}) '
        'max y=${fence.maxY.toStringAsFixed(3)} fence cleared=${fence.maxX > x0 + 9.7}');
    player.probeWalk(Vector3.zero());
    player.position = Vector3(x0 - 2.5, y0 + 1.1, z0 - 3.5);
    player.velocity = Vector3.zero();
    player.syncNode();
    // Liquids: a source in mid-air spreads over the pad, drains when scooped,
    // then lava meets water.
    final source = IVec3(x0 + 2, y0 + 3, z0 + 6);
    world.setBlock(source, Blocks.indexOf('water'));
    await _stage22Settle(2.0);
    final water = _stage22Count(lo, hi);
    debugPrint('[probe] stage22 water cells=${water.water} (expect >20 and <=60) max dist=${water.dist} '
        'flow updates=${world.flowUpdates}');
    world.setBlock(source, Blocks.air);
    await _stage22Settle(3.0);
    final drained = _stage22Count(lo, hi);
    debugPrint('[probe] stage22 water after drain=${drained.water} (expect 0) queue=${world.flowPending}');
    world.setBlock(IVec3(x0 + 8, y0 + 2, z0 + 8), Blocks.indexOf('lava'));
    world.setBlock(IVec3(x0 + 8, y0 + 2, z0 + 10), Blocks.indexOf('water'));
    await _stage22Settle(3.0);
    final mixed = _stage22Count(lo, hi);
    debugPrint('[probe] stage22 lava cells=${mixed.lava} water cells=${mixed.water}');
    debugPrint('[probe] stage22 obsidian/cobblestone=${mixed.hard} (expect >=1)');
    // A second water source keeps a puddle for the capture, then the camera
    // hovers over the pad.
    world.setBlock(source, Blocks.indexOf('water'));
    await _stage22Settle(1.5);
    flyMode = true;
    player.setFirstPerson(true);
    final eye = Vector3(x0 + 5.0, y0 + 8.0, z0 - 6.0);
    final target = Vector3(x0 + 4.5, y0 + 1.0, z0 + 5.0);
    final dir = target - eye;
    player.setLook(math.atan2(-dir.x, -dir.z), math.atan2(dir.y, math.sqrt(dir.x * dir.x + dir.z * dir.z)));
    for (var i = 0; i < 30; i++) {
      player.position = eye.clone();
      player.velocity = Vector3.zero();
      player.syncNode();
      await nextFrame();
    }
    _pinCameraTo = () => eye.clone();
    debugPrint('[probe] stage22 capture from $eye toward $target');
  }

  /// Walk +x from [start] until [stopX], for [ticks] simulation ticks; with
  /// [jump] the player jumps once, the moment a wall past [jumpAfterX] stops
  /// it. Reports where it ended and the highest it got.
  Future<({double x, double y, bool floor, double maxX, double maxY, double maxVy})> _stage22Walk(
      Vector3 start, double stopX, int ticks, bool jump, [double jumpAfterX = 0.0]) {
    player.position = start.clone();
    player.velocity = Vector3.zero();
    player.probeWalk(Vector3(1, 0, 0));
    var maxY = start.y, maxX = start.x, maxVy = 0.0;
    var jumped = false;
    var i = 0;
    final done = Completer<({double x, double y, bool floor, double maxX, double maxY, double maxVy})>();
    _probeTick = () {
      final p = player.position;
      maxY = math.max(maxY, p.y);
      maxX = math.max(maxX, p.x);
      maxVy = math.max(maxVy, player.velocity.y);
      if (_hasArg('--trace') && i % 5 == 0) {
        debugPrint('[trace] walk f$i pos $p vel ${player.velocity} floor ${player.onFloor} wall ${player.hitWall} water ${player.inWater}');
      }
      if (p.x >= stopX) player.probeWalk(Vector3.zero());
      if (jump && !jumped && player.hitWall && player.onFloor && p.x > jumpAfterX) {
        jumped = true;
        player.velocity.y = Player.jumpVelocity;
      }
      i += 1;
      if (i >= ticks) {
        _probeTick = null;
        player.probeWalk(Vector3.zero());
        done.complete((x: p.x, y: p.y, floor: player.onFloor, maxX: maxX, maxY: maxY, maxVy: maxVy));
      }
    };
    return done.future;
  }

  Future<void> _stage22Settle(double seconds) async {
    final t0 = DateTime.now();
    while (DateTime.now().difference(t0).inMilliseconds < (seconds * 1000).round()) {
      await nextFrame();
    }
  }

  /// Liquid and hardened cells inside the volume, and the farthest flow
  /// distance seen.
  ({int water, int lava, int hard, int dist}) _stage22Count(IVec3 lo, IVec3 hi) {
    var water = 0, lava = 0, hard = 0, dist = 0;
    final cobble = Blocks.indexOf('cobblestone');
    for (var x = lo.x; x <= hi.x; x++) {
      for (var y = lo.y; y <= hi.y; y++) {
        for (var z = lo.z; z <= hi.z; z++) {
          final b = IVec3(x, y, z);
          final id = world.getBlock(b);
          final kind = Blocks.liquidKind(id);
          if (kind != '') {
            if (kind == 'water') {
              water += 1;
            } else {
              lava += 1;
            }
            dist = math.max(dist, world.flowDistOf(b));
          } else if (id == cobble || (Blocks.has('obsidian') && id == Blocks.indexOf('obsidian'))) {
            hard += 1;
          }
        }
      }
    }
    return (water: water, lava: lava, hard: hard, dist: dist);
  }

  // --- stage 25: host-owned drops, boats and bobbers, bag overflow, chest gating,
  // batched flow, predicted block edits. Host + client twins with --wait-peer;
  // the host takes --reject-one.

  /// The probe site, in the same world cells as Godot's: a 7x7 stone pad (the
  /// host fishes from its north-west corner), a walled 5x5 water basin north
  /// of it (the boat) and an empty walled 5x5 pool 10 m east (one source in
  /// its centre floods it: 24 flow cells, and nothing runs downhill).
  ({IVec3 pad, IVec3 basin, IVec3 pool, IVec3 crop, IVec3 editA, IVec3 editB}) _stage25Site() {
    final pad = IVec3.floor(Vector3(8.5, 50.0, 8.5) + Vector3(4.0, 0.0, 0.0));
    return (
      pad: pad,
      basin: pad + const IVec3(0, 0, -8),
      pool: pad + const IVec3(10, 0, 0),
      crop: const IVec3(5, 50, 8),
      editA: const IVec3(8, 45, 8),
      editB: const IVec3(9, 45, 8),
    );
  }

  Future<void> _waitMs(int ms, [bool Function()? until]) async {
    final t = DateTime.now();
    while (DateTime.now().difference(t).inMilliseconds < ms && !(until?.call() ?? false)) {
      await nextFrame();
    }
  }

  Future<void> _probeStage25Host() async {
    final net = Net.instance;
    final site = _stage25Site();
    final stone = Blocks.indexOf('stone');
    for (var dx = -3; dx < 4; dx++) {
      for (var dz = -3; dz < 4; dz++) {
        world.setBlock(site.pad + IVec3(dx, -1, dz), stone);
        for (var dy = 0; dy < 6; dy++) {
          world.setBlock(site.pad + IVec3(dx, dy, dz), Blocks.air);
        }
        final wall = dx.abs() == 3 || dz.abs() == 3;
        for (final at in [site.basin, site.pool]) {
          world.setBlock(at + IVec3(dx, -1, dz), stone);
          world.setBlock(at + IVec3(dx, 0, dz),
              wall ? stone : (at == site.basin ? Blocks.indexOf('water') : Blocks.air));
          for (var dy = 1; dy < 5; dy++) {
            world.setBlock(at + IVec3(dx, dy, dz), Blocks.air);
          }
        }
      }
    }
    // The host fishes from the pad's north-west corner, rod in hand, at the basin's centre cell.
    player.position = site.pad.toVector3() + Vector3(-2.0, 0.0, -2.0);
    player.velocity = Vector3.zero();
    player.syncNode();
    player.inventory.setSlot(player.selectedSlot, ItemStack('fishing_rod', 1));
    player.setLook(0.0, -0.4);
    spawnBoat(site.basin.toVector3() + Vector3(0.5, 0.9, 0.5), 0.0);
    // A crop planted long enough ago to grow on the next pass: growth is a host block edit.
    world.setBlock(site.crop + IVec3.down, Blocks.indexOf('farmland'));
    world.setBlock(site.crop, Blocks.indexOf('wheat_0'));
    crops[site.crop] = GameState.instance.playTime - 200.0;
    _growCrops();
    debugPrint('[probe] stage25 host: crop at ${site.crop} grew to ${Blocks.idOf(world.getBlock(site.crop))} through setBlock');
    // A water source in the empty pool's centre: the flow tick's cells leave batched.
    world.setBlock(site.pool, Blocks.indexOf('water'));
    player.castFishing(site.basin);
    // A drop for the capture: on the basin's south wall, out of the host's pull
    // range and in the client's camera frame.
    spawnDrop(site.basin.toVector3() + Vector3(1.5, 1.5, 3.5), 'apple', 1, Vector3(0, 0.5, 0));
    // The client fills its bag and declares it. Godot waits a flat 1.5 s; the
    // Flutter client can still be filling its window then, so the host also
    // waits (up to 15 s) for the declared bag to show room for exactly one.
    final peer = net.puppetPositions().first.$1;
    await _waitMs(1500);
    await _waitMs(15000, () => net.declaredBag(peer)?.roomFor('iron_ingot', 3) == 1);
    final ppos = net.puppetPositions().first.$2;
    final under = IVec3(ppos.x.floor() + 1, ppos.y.floor() - 1, ppos.z.floor());
    world.setBlock(under, stone);
    world.setBlock(under + IVec3.up, Blocks.air);
    spawnDrop(ppos + Vector3(1.0, 0.4, 0.0), 'iron_ingot', 3, Vector3(0, 0.5, 0));
    final t1 = DateTime.now();
    await _waitMs(22000, () =>
        (net.stats['give_rest_spawned'] as int) > 0 &&
        (net.stats['chest_accepted'] as int) > 0 &&
        (net.stats['rejected_seq'] as int) >= 0 &&
        net.stats['boat_boarded'] == true &&
        net.boatDrivers.isEmpty &&
        DateTime.now().difference(t1).inMilliseconds > 6000);
    final boat = boats.firstWhere((b) => !b.replica);
    final s = net.stats;
    debugPrint('[probe] stage25 host: drop poses sent=${s['drop_pose_rpcs']}');
    debugPrint('[probe] stage25 host: give rest spawned=${s['give_rest_spawned']}');
    debugPrint('[probe] stage25 host: chest edit rejected(not open)=${s['chest_rejected']} accepted=${s['chest_accepted']}');
    debugPrint('[probe] stage25 host: boat spawned net_id=${boat.netId} client aboard=${s['boat_boarded']}');
    debugPrint('[probe] stage25 host: flow batch rpcs=${s['flow_batch_rpcs']} cells=${s['flow_batch_cells']}');
    debugPrint('[probe] stage25 host: rejected client edit seq=${s['rejected_seq']}');
    debugPrint('[probe] stage25 host: bobber out=${player.bobber != null} at ${player.bobber?.position}, boat at ${boat.position}');
    await _waitMs(20000, () => net.puppetPositions().isEmpty);
  }

  Future<void> _probeStage25Client() async {
    final net = Net.instance;
    final site = _stage25Site();
    player.probeFillBag('iron_ingot');
    bool restSeen() => net.liveDropReplicas().any((d) => d.itemId == 'iron_ingot' && d.count == 2);
    // The host's 3-stack is pulled in and split. Godot waits a flat 4.5 s; here
    // at least that, and on until the rest shows (the host may start later).
    final t0 = DateTime.now();
    await _waitMs(12000, () => DateTime.now().difference(t0).inMilliseconds > 4500 && restSeen());
    debugPrint('[probe] stage25 client: bag got=${net.stats['bag_got']} rest dropped seen=${restSeen()}');
    // Chests: an edit without the chest open here is refused; the same edit after opening lands.
    const chestAt = IVec3(7, 77, 7);
    net.chestSlotChanged(chestAt, 1, ItemStack('stone', 1), true);
    final view = net.openChest(chestAt);
    await _waitMs(4000, () => (net.stats['chest_states'] as int) > 0);
    net.chestSlotChanged(chestAt, 1, ItemStack('stone', 1), true);
    await _waitMs(4000, () => view.countOf('stone') > 0);
    var filled = 0;
    for (var i = 0; i < Inventory.size; i++) {
      if (!view.isEmptySlot(i)) filled++;
    }
    debugPrint('[probe] stage25 client: chest state slots=$filled (${view.toJson().take(2).toList()})');
    net.closeChest(chestAt);
    // Boats: board the host's replica, row forward for three seconds, measure how far it went.
    await _waitMs(4000, () => net.boatReplicas().isNotEmpty);
    if (net.boatReplicas().isNotEmpty) {
      final b = net.boatReplicas().first;
      player.boardBoat(b);
      final from = b.position.clone();
      player.probeWalk(Vector3(0, 0, -1));
      await _waitMs(3000);
      player.probeWalk(Vector3.zero());
      final moved = (b.position - from).length;
      debugPrint('[probe] stage25 client: aboard boat net_id=${b.netId} moved=${moved.toStringAsFixed(2)} (from $from to ${b.position})');
      player.leaveBoat();
    } else {
      debugPrint('[probe] stage25 client: aboard boat net_id=0 moved=-1 (no replica arrived)');
    }
    // Predicted edits: the host refuses the first (--reject-one), so it rolls back; the second stands.
    final wasA = world.getBlock(site.editA);
    world.setBlock(site.editA, Blocks.indexOf('oak_planks'));
    world.setBlock(site.editB, Blocks.indexOf('oak_planks'));
    await _waitMs(5000, () => net.prediction.pending.isEmpty);
    debugPrint('[probe] stage25 client: predicted=${net.stats['predicted']} rollbacks=${net.stats['rollbacks']} '
        '(cell a back to ${Blocks.idOf(wasA)}: ${world.getBlock(site.editA) == wasA}, cell b ${Blocks.idOf(world.getBlock(site.editB))})');
    var delta = 0.0;
    final where = <String>[];
    for (final d in net.liveDropReplicas()) {
      delta = math.max(delta, d.netPoseDelta());
      where.add('${d.itemId} x${d.count} at ${d.position}');
    }
    debugPrint('[probe] stage25 client: replica drop delta to host pose=${delta.toStringAsFixed(3)} '
        '(replicas ${net.liveDropReplicas().length}: ${where.join(', ')})');
    debugPrint('[probe] stage25 client: flow cells seen=${net.stats['flow_cells_seen']}');
    debugPrint('[probe] stage25 client: bobber replica of host seen=${net.stats['bobber_seen']} (live ${net.bobberReplicaCount()})');
    debugPrint('[probe] stage25 client: crop at ${site.crop} reads ${Blocks.idOf(world.getBlock(site.crop))}');
    // Frame the host puppet fishing over the basin, the capture's drop in the foreground.
    if (net.puppetBodies().isNotEmpty) {
      flyMode = true;
      player.setFirstPerson(true);
      final hostAt = net.puppetBodies().first.position.clone();
      final eye = hostAt + Vector3(3.5, 2.5, 2.5);
      final to = (hostAt + Vector3(0.5, 0.8, -4.0)) - eye;
      player.setLook(math.atan2(-to.x, -to.z), math.asin(to.y / to.length));
      for (var i = 0; i < 20; i++) {
        player.position = eye.clone();
        player.velocity = Vector3.zero();
        player.syncNode();
        await nextFrame();
      }
      debugPrint('[probe] stage25 client: capture from ${player.position}, host puppet at $hostAt');
      _pinCameraTo = () => eye.clone();
    }
  }

  // --- stage 23: temple boss + trap, loot tables, second abilities, three mobs, durability ---

  /// Waits [n] simulation ticks (Godot's `await physics_frame` n times).
  Future<void> _ticks(int n) {
    final done = Completer<void>();
    var left = n;
    _probeTick = () {
      left -= 1;
      if (left <= 0) {
        _probeTick = null;
        done.complete();
      }
    };
    return done.future;
  }

  /// The chamber floor centre (the pressure plate cell) of the temple found by
  /// `_probeStage21aTeleport`, or of a 5x5x3 sandstone chamber built beside the
  /// player when no temple was in reach.
  ({IVec3 plate, String path}) _stage23Chamber(_Stage21a? found) {
    if (found != null && found.kind == TerrainGenerator.structTemple) {
      final o = found.origin;
      // The generator's chamber floor is at the structure's y; confirm by
      // finding the plate.
      for (var dy = -2; dy < 4; dy++) {
        final cell = IVec3(o.x, o.y + dy, o.z);
        final id = world.getBlock(cell);
        if (id != Blocks.air && Blocks.idOf(id) == 'pressure_plate') return (plate: cell, path: 'temple');
      }
      debugPrint('[probe] stage23 temple at $o has no plate in its floor column');
    }
    final base = IVec3.floor(player.position) + const IVec3(6, 0, 0);
    final y0 = world.groundHeight(base.x, base.z);
    final sand = Blocks.indexOf('sandstone');
    for (var dx = -2; dx < 3; dx++) {
      for (var dz = -2; dz < 3; dz++) {
        for (var dy = -1; dy < 5; dy++) {
          final edge = dx.abs() == 2 || dz.abs() == 2 || dy == -1 || dy == 4;
          world.setBlock(IVec3(base.x + dx, y0 + dy, base.z + dz), edge ? sand : Blocks.air);
        }
      }
    }
    final plate = IVec3(base.x, y0, base.z);
    world.setBlock(plate, Blocks.indexOf('pressure_plate'));
    world.setBlock(plate + IVec3.down, Blocks.indexOf('tnt'));
    world.setBlock(plate + const IVec3(0, 4, 0), Blocks.indexOf('lamp'));
    world.setBlock(plate + const IVec3(-1, 1, -1), Blocks.indexOf('chest'));
    world.setBlock(plate + const IVec3(1, 1, -1), Blocks.indexOf('chest'));
    world.setBlock(plate + const IVec3(0, 1, 2), Blocks.air); // the south doorway
    world.setBlock(plate + const IVec3(0, 2, 2), Blocks.air);
    return (plate: plate, path: 'built');
  }

  void _probePlace(Vector3 at) {
    player.position = at.clone();
    player.velocity = Vector3.zero();
    player.syncNode();
  }

  Future<void> _probeStage23(_Stage21a? found) async {
    final chamber = _stage23Chamber(found);
    final plate = chamber.plate;
    var path = chamber.path;
    final stand = Vector3(plate.x + 0.5, plate.y + 1.05, plate.z + 1.5);
    // 1. The boss wakes when the player enters the chamber: the same check the
    // game runs each second.
    flyMode = false;
    _probePlace(stand);
    player.setLook(0.0, -0.05);
    world.updateAround(stand);
    boss = null;
    if (path == 'temple') _checkStructures();
    var b = boss;
    if (b == null) {
      b = spawnTempleBoss(plate.toVector3() + Vector3(0.5, 1.0, 0.5));
      path += '+direct';
    }
    final theBoss = b;
    theBoss.stun(120.0, false); // held still for the capture: it would step on its own plate otherwise
    debugPrint('[probe] stage23 temple boss=${theBoss.displayName()} hp=${theBoss.maxHp.toInt()} '
        '(path $path, plate $plate, player ${player.position})');
    // 2. The trap: the player on the plate lights the TNT under it (one tick).
    _probePlace(plate.toVector3() + Vector3(0.5, 0.55, 0.5));
    await _ticks(3);
    final below = world.getBlock(plate + IVec3.down);
    debugPrint('[probe] stage23 plate trap: tnt lit=${litTntCount() > 0} (plates fired ${platesFired()}, '
        'block under the plate now ${below != Blocks.air ? Blocks.idOf(below) : 'air'})');
    probeDefuseTnt(); // keep the chamber whole for the capture
    _probePlace(stand);
    // 3. Loot tables, seeded so the line is stable.
    for (final table in const ['temple', 'mine', 'ruin', 'well']) {
      final parts = [for (final st in LootTables.roll(table, math.Random(23))) '${st.id} x${st.count}'];
      debugPrint('[probe] stage23 loot $table=${parts.join(', ')}');
    }
    // 4..6 happen on a flat pad 12 m east of the chamber, out of the boss's reach.
    final pad = IVec3(plate.x + 12, 0, plate.z);
    var py = 0;
    for (var dx = -6; dx < 7; dx++) {
      for (var dz = -6; dz < 7; dz++) {
        py = math.max(py, world.groundHeight(pad.x + dx, pad.z + dz));
      }
    }
    for (var dx = -6; dx < 7; dx++) {
      for (var dz = -6; dz < 7; dz++) {
        world.setBlock(IVec3(pad.x + dx, py, pad.z + dz), Blocks.indexOf('stone'));
        for (var dy = 1; dy < 6; dy++) {
          world.setBlock(IVec3(pad.x + dx, py + dy, pad.z + dz), Blocks.air);
        }
      }
    }
    final padStand = Vector3(pad.x + 0.5, py + 1.05, pad.z + 0.5);
    _probePlace(padStand);
    player.setLook(0.0, 0.0); // north (-z)
    player.inventory.add('arrow', 64);
    for (final cls in const ['warrior', 'ranger', 'mage', 'rogue']) {
      player.probeSetClass(cls);
      _probePlace(padStand);
      final zs = <Mob>[];
      for (var i = 0; i < 3; i++) {
        final z = Mob();
        z.setupMob(world, this, player, Species.def('zombie'));
        z.position = padStand + Vector3(i - 1.0, 0.0, -2.0);
        addMob(z);
        zs.add(z);
      }
      await _ticks(1);
      final before = player.mana;
      player.probeAbility2();
      final after = player.mana;
      await _ticks(20);
      var hits = 0;
      for (final z in zs) {
        if (z.removed || z.isDead) {
          hits += 1;
          continue;
        }
        final hit = switch (cls) {
          'warrior' => z.stunned > 0.0,
          'ranger' => z.hp < z.maxHp,
          'mage' => z.slowed > 0.0,
          _ => z.blinded > 0.0 && z.state != MobState.chase && z.state != MobState.attack,
        };
        if (hit) hits += 1;
      }
      debugPrint('[probe] stage23 ability2 $cls=${player.classDef.ability2} mana ${before.round()}->${after.round()} hits=$hits');
      for (final z in zs) {
        z.removed = true;
      }
      await _ticks(1);
    }
    // 5. The three new mobs, force-spawned; the ghost starts inside a stone block.
    final sp = spawner!;
    final bat = sp.forceSpawn('bat', padStand + Vector3(-3, 1.5, -3));
    final bear = sp.forceSpawn('bear', padStand + Vector3(3, 0, -3));
    final wall = IVec3(pad.x + 4, py + 1, pad.z + 3);
    for (var dx = -1; dx < 2; dx++) {
      for (var dy = 0; dy < 3; dy++) {
        for (var dz = -1; dz < 2; dz++) {
          world.setBlock(wall + IVec3(dx, dy, dz), Blocks.indexOf('stone'));
        }
      }
    }
    final ghost = sp.forceSpawn('ghost', wall.toVector3() + Vector3(0.5, 0.2, 0.5));
    final ghostFrom = ghost.position.clone();
    await _ticks(60);
    int alive(Mob m) => !m.removed && !m.isDead ? 1 : 0;
    final moved = ghost.removed ? 0.0 : (ghost.position - ghostFrom).length;
    debugPrint('[probe] stage23 spawned bat=${alive(bat)} bear=${alive(bear)} ghost=${alive(ghost)}; '
        'ghost passes blocks=${moved > 0.3} (moved ${moved.toStringAsFixed(2)} m from inside stone, noclip ${!ghost.removed && ghost.noclip})');
    for (final m in [bat, bear, ghost]) {
      m.removed = true;
    }
    // 6. Durability: an iron sword swung five times at a zombie, then forced to
    // its last use.
    player.probeSetClass('warrior');
    _probePlace(padStand);
    player.inventory.add('iron_sword', 1);
    player.selectedSlot = player.inventory.find('iron_sword');
    final dummy = Mob();
    dummy.setupMob(world, this, player, Species.def('zombie'));
    dummy.position = padStand + Vector3(0, 0, -2.0);
    dummy.scaleToLevel(30); // outlives six iron-sword swings
    addMob(dummy);
    dummy.stun(30.0, false);
    await _ticks(1);
    final maxDur = Items.durabilityOf('iron_sword');
    for (var i = 0; i < 5; i++) {
      player.probeStrike();
      await _ticks(1);
    }
    final worn = player.inventory.durAt(player.selectedSlot);
    final broke = player.heldItem() != 'iron_sword';
    player.inventory.slots[player.selectedSlot]!.dur = 1;
    player.probeStrike();
    await _ticks(1);
    final forced = player.heldItem() == '';
    debugPrint('[probe] stage23 durability: sword $maxDur->$worn broke=$broke; forced break=$forced '
        '(zombie hp ${dummy.hp.toStringAsFixed(0)}/${dummy.maxHp.toStringAsFixed(0)})');
    dummy.removed = true;
    // The capture: first person in the south corridor, the Mummy King three
    // metres ahead.
    final door = Vector3(plate.x + 0.5, plate.y + 1.05, plate.z + 2.5);
    player.probeSetClass('warrior');
    _probePlace(door);
    player.setFirstPerson(true);
    player.setLook(0.0, 0.05);
    world.updateAround(door);
    for (var i = 0; i < 20; i++) {
      _probePlace(door);
      await nextFrame();
    }
    _pinCameraTo = () => door.clone();
    final gone = theBoss.removed || theBoss.isDead;
    debugPrint('[probe] stage23 capture from ${player.position}, boss at ${theBoss.position} '
        '(${gone ? 'gone' : 'alive'}, hp ${theBoss.hp.toStringAsFixed(0)})');
  }

  /// --stage21a: stand at the nearest ruin / well / mine / temple (`--kind=5..8`
  /// picks one kind) so the capture shows it. The mine puts the player inside
  /// the corridor, the temple outside its south entrance; `--fp` switches to
  /// first person for the tight corridor.
  _Stage21a? _probeStage21aTeleport([int radius = 24]) {
    final want = int.tryParse(_arg('--kind=', '')) ?? 0;
    final wantBiome = int.tryParse(_arg('--biome=', '')) ?? -1;
    final here = VoxelWorld.chunkOf(IVec3.floor(player.position));
    StructureAt? best;
    var bestD = double.infinity;
    for (var dz = -radius; dz <= radius; dz += 4) {
      for (var dx = -radius; dx <= radius; dx += 4) {
        for (final st in world.structuresNear((x: here.x + dx, z: here.z + dz))) {
          if (st.type < 5 || (want != 0 && st.type != want)) continue;
          if (wantBiome >= 0 && world.biomeAt(st.x, st.z) != wantBiome) continue;
          final d = math.sqrt(math.pow(st.x - player.position.x, 2) + math.pow(st.z - player.position.z, 2));
          if (d < bestD) {
            bestD = d;
            best = st;
          }
        }
      }
    }
    if (best == null) {
      debugPrint('[probe] stage21a: no ruin / well / mine / temple within $radius chunks');
      return null;
    }
    var at = Vector3(best.x + 0.5, best.y + 1.1, best.z + 0.5);
    switch (best.type) {
      case TerrainGenerator.structRuin:
        at += Vector3(0, 0, 8);
      case TerrainGenerator.structWell:
        at += Vector3(0, 0, 5);
      case TerrainGenerator.structMine:
        // The lit beam is at +10.
        at = Vector3(best.x + 7.5, TerrainGenerator.mineFloorY + 1.1, best.z + 0.5);
      case TerrainGenerator.structTemple:
        at += Vector3(0, 0, 9);
    }
    player.position = at.clone();
    player.velocity = Vector3.zero();
    player.spawnPoint = at.clone();
    player.setFirstPerson(_hasArg('--fp'));
    player.syncNode();
    world.updateAround(at);
    debugPrint('[probe] stage21a: teleported to kind ${best.type} at (${best.x}, ${best.y}, ${best.z}), '
        'standing at $at (${bestD.round()} m from spawn)');
    return _Stage21a(at, best.type, IVec3(best.x, best.y, best.z));
  }

  /// --stage20: a tamed horse is mounted and left, a sheep is sheared, a line
  /// is cast at a fresh water block and the bite forced, a bucket scoops the
  /// water and pours it back. The player is left on the horse with the line out
  /// so the capture shows both.
  _Stage20 _probeStage20() {
    final ahead = player.aimDirection().clone()..y = 0;
    ahead.normalize();
    final right = ahead.cross(Vector3(0, 1, 0));
    // A flat grass stage around the player so the camera, the horse and the
    // water are all in view.
    final base = IVec3.floor(player.position);
    final floorY = base.y - 1;
    for (var dx = -7; dx < 8; dx++) {
      for (var dz = -9; dz < 8; dz++) {
        world.setBlock(IVec3(base.x + dx, floorY, base.z + dz), Blocks.indexOf('grass'));
        for (var dy = 1; dy < 7; dy++) {
          world.setBlock(IVec3(base.x + dx, floorY + dy, base.z + dz), Blocks.air);
        }
      }
    }
    final horse = Mob();
    horse.setupMob(world, this, player, Species.def('horse'));
    horse.position = player.position + ahead * 3.0;
    addMob(horse);
    horse.tame(player);
    player.mountHorse(horse);
    debugPrint('[probe] stage20: riding horse ${player.isMounted()} (tamed ${horse.tamed}, ridden ${horse.ridden})');
    player.dismount();
    debugPrint('[probe] stage20: dismounted, riding ${player.isMounted()}, horse ridden ${horse.ridden}');
    final sheep = Mob();
    sheep.setupMob(world, this, player, Species.def('sheep'));
    sheep.position = player.position + ahead * 2.0 - right * 2.0;
    addMob(sheep);
    final wool = player.shearMob(sheep);
    debugPrint('[probe] stage20: sheared the sheep, $wool wool dropped, sheared ${sheep.sheared}');
    final wc = IVec3.floor(player.position + ahead * 2.0 + right * 2.0) + IVec3.down;
    world.setBlock(wc + IVec3.up, Blocks.air);
    world.setBlock(wc, Blocks.indexOf('water'));
    player.inventory.add('fishing_rod', 1);
    player.selectedSlot = player.inventory.find('fishing_rod');
    player.castFishing(wc);
    player.bobber!.forceBite();
    final got = player.catchFish();
    debugPrint('[probe] stage20: cast at $wc, bite forced, caught $got '
        '(now ${player.inventory.countOf(got)} in the bag), xp ${player.xp}, '
        'achievements ${Achievements.instance.unlocked.toList()}');
    player.inventory.add('bucket', 1);
    player.selectedSlot = player.inventory.find('bucket');
    final scooped = player.scoopLiquid(wc);
    debugPrint('[probe] stage20: scooped $scooped, held ${player.heldItem()}, '
        'block there ${Blocks.idOf(world.getBlock(wc))}');
    final poured = player.pourLiquid(wc);
    debugPrint('[probe] stage20: poured $poured, held ${player.heldItem()}, '
        'block there ${Blocks.idOf(world.getBlock(wc))}');
    player.selectedSlot = player.inventory.find('fishing_rod');
    player.castFishing(wc);
    player.mountHorse(horse);
    return _Stage20(horse, wool);
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

  // --- stage 24: persistence of entities, map markers, quests tab, settings, bed respawn ---

  /// M: the minimap, then the world map on top of it, then both off.
  void cycleMap() {
    if (worldMapVisible) {
      worldMapVisible = false;
      mapVisible = false;
    } else if (mapVisible) {
      worldMapVisible = true;
    } else {
      mapVisible = true;
    }
  }

  /// The settings screen's live hook: the streaming window follows the slider
  /// at once.
  void applyRenderDistance(int radius) {
    radius = radius.clamp(4, 10);
    Settings.instance.renderRadius = radius;
    world.loadRadius = radius;
    world.unloadRadius = radius + 2;
    world.refresh();
    world.updateAround(player.position);
    world.trimWindow();
  }

  /// The tamed mounts alive right now (brown dots on both maps).
  List<Mob> tamedMounts() => [for (final m in pets) if (m.tamed && m.isMount && !m.isDead && !m.removed) m];

  /// What the maps draw, for the probe: waypoints, discovered structures, tamed
  /// mounts.
  ({int waypoints, int structures, int mounts}) markerCounts() =>
      (waypoints: waypoints.length, structures: discoveredStructures.length, mounts: tamedMounts().length);

  String _stage24Line(String tag) {
    final tamed = pets.where((m) => m.tamed && !m.isDead && !m.removed).length;
    final dropCount = drops.where((d) => !d.removed).length;
    return '[probe] stage24 $tag: boats=${boats.length} tamed=$tamed drops=$dropCount mounted=${player.isMounted()} '
        'waypoints=${waypoints.length} visited=${visitedChunks.length}';
  }

  /// --stage24, first boot: a boat, a ridden horse, a tamed wolf, two drops, a
  /// waypoint and three visited chunks, saved to the slot, then the session is
  /// rebuilt with `probe24.flag` set so the second boot loads that save and
  /// verifies it. Returns true when the reload was requested.
  Future<bool> _probeStage24() async {
    if (_stage24Verify) {
      await _probeStage24Verify();
      return false;
    }
    final ahead = player.aimDirection().clone()..y = 0;
    ahead.normalize();
    final right = ahead.cross(Vector3(0, 1, 0));
    // A flat stone pad so nothing restored falls into a hole before its chunk is in.
    final floorY = player.position.y.floor() - 1;
    final base = IVec3.floor(player.position);
    for (var dx = -8; dx < 9; dx++) {
      for (var dz = -8; dz < 9; dz++) {
        world.setBlock(IVec3(base.x + dx, floorY, base.z + dz), Blocks.indexOf('stone'));
        for (var dy = 1; dy < 7; dy++) {
          world.setBlock(IVec3(base.x + dx, floorY + dy, base.z + dz), Blocks.air);
        }
      }
    }
    player.velocity = Vector3.zero();
    spawnBoat(player.position + ahead * 4.0 + Vector3(0, 0.1, 0), 0.4);
    final horse = Mob();
    horse.setupMob(world, this, player, Species.def('horse'));
    horse.position = player.position + right * 2.0;
    addMob(horse);
    horse.tame(player);
    player.mountHorse(horse);
    final wolf = Mob();
    wolf.setupMob(world, this, player, Species.def('wolf'));
    wolf.position = player.position - right * 3.0;
    addMob(wolf);
    wolf.tame(player);
    // Two drops 5 m out, past the 3 m pull, with a delay so nothing picks them
    // up before the save.
    spawnDrop(player.position + ahead * 5.0 + right * 3.0 + Vector3(0, 0.4, 0), 'apple', 3, Vector3(0, 0.1, 0), 600.0);
    spawnDrop(player.position - ahead * 5.0 - right * 3.0 + Vector3(0, 0.4, 0), 'coal', 2, Vector3(0, 0.1, 0), 600.0);
    // The waypoint 14 blocks off the pad, on the ground there, so its label
    // clears the others on the map.
    final wp = IVec3(base.x - 14, world.groundHeight(base.x - 14, base.z + 14), base.z + 14);
    world.setBlock(wp, Blocks.indexOf('waypoint'));
    onBlockPlaced(wp, Blocks.indexOf('waypoint'));
    final here = VoxelWorld.chunkOf(base);
    visitedChunks.addAll([here, (x: here.x + 1, z: here.z), (x: here.x, z: here.z + 1)]);
    _checkStructures(); // the once-a-second discovery pass, run now so the save carries the ruin nearby
    await _ticks(5); // the drops land, the horse settles under the rider
    debugPrint(_stage24Line('pre-save'));
    await saveGame();
    File(_probe24Flag).writeAsStringSync('verify');
    debugPrint('[probe] stage24 saved to $saveDir, reloading the scene');
    reloader!();
    return true;
  }

  /// --stage24, second boot (`probe24.flag` was set): the save was loaded by
  /// [init]; this half counts what came back, then walks the map markers, the
  /// quests tab, the settings and the bed.
  Future<void> _probeStage24Verify() async {
    // The restored bodies wait for their chunks; give the physics a few ticks
    // once the window is in.
    await _ticks(8);
    debugPrint(_stage24Line('post-load'));
    final saved = jsonDecode(File('$saveDir/player.json').readAsStringSync()) as Map<String, dynamic>;
    Vector3? savedHorse;
    for (final pd in (saved['pets'] as List<dynamic>? ?? const [])) {
      final d = pd as Map<String, dynamic>;
      if (d['species'] == 'horse') {
        final p = (d['pos'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
        savedHorse = Vector3(p[0], p[1], p[2]);
      }
    }
    final horseNow = player.mount?.position;
    final delta = savedHorse != null && horseNow != null ? (savedHorse - horseNow).length : double.infinity;
    debugPrint('[probe] stage24 horse pos delta=${delta.toStringAsFixed(2)}');
    // Markers: what the maps draw (the discovery pass runs once a second in play).
    _checkStructures();
    mapVisible = true;
    worldMapVisible = true;
    final mc = markerCounts();
    debugPrint('[probe] stage24 markers: waypoints=${mc.waypoints} structures=${mc.structures} mounts=${mc.mounts}');
    // The quests tab.
    openJournal(JournalTabs.quests);
    await nextFrame();
    debugPrint('[probe] stage24 quests tab entries=${JournalTabs.questEntries(quests).length} '
        'active=${quests.current?.title ?? 'none'} (tab ${JournalTabs.names[journalTab]})');
    closeScreen();
    // Settings: render distance 8 -> 6 (meshed chunks), weather off, and the file.
    final before = world.meshCount;
    applyRenderDistance(6);
    for (var i = 0; i < 200; i++) {
      await nextFrame();
      if (i > 5 && world.isIdle) break;
    }
    debugPrint('[probe] stage24 settings: radius 8->6 chunks loaded before=$before after=${world.meshCount}');
    weather.force('storm');
    Settings.instance.weather = false;
    weather.setEnabled(false);
    await nextFrame();
    debugPrint('[probe] stage24 settings: weather off -> ${weather.label}');
    Settings.instance.path = '$saveRoot/settings_probe24.cfg'; // never this machine's own settings.cfg
    final written = Settings.instance.save() && File(Settings.instance.path).existsSync();
    debugPrint('[probe] stage24 settings: settings.cfg written=$written (${Settings.instance.path})');
    Settings.instance.weather = true;
    weather.setEnabled(true);
    // Bed respawn: sleep sets the spawn point (daytime: only that), death sends
    // the player back to it.
    if (player.mount != null) player.dismount();
    final bed = IVec3.floor(player.position) + const IVec3(4, 0, 0);
    world.setBlock(bed, Blocks.indexOf('bed'));
    sleepInBed(bed);
    final spawn = player.spawnPoint.clone();
    player.position = player.position + Vector3(0, 0, -6.0);
    player.velocity = Vector3.zero();
    player.takeDamage(9999.0, 'fall');
    await nextFrame();
    final died = player.isDead;
    player.respawn();
    closeScreen();
    String v3(Vector3 v) => '(${v.x.toStringAsFixed(1)},${v.y.toStringAsFixed(1)},${v.z.toStringAsFixed(1)})';
    debugPrint('[probe] stage24 respawn at bed: spawn=${v3(spawn)} died=$died -> pos=${v3(player.position)} '
        'delta=${(spawn - player.position).length.toStringAsFixed(2)}');
  }

  void shutdown() {
    world.dispose();
    input.dispose();
  }
}
