import 'dart:math' as math;

import 'package:flutter_scene/scene.dart' hide Spawner;
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import 'package:voxel_core/voxel_core.dart';
import '../core/species.dart';
import '../game/achievements.dart';
import '../game/game.dart';
import '../game/game_state.dart';
import '../game/inventory.dart';
import '../game/loot.dart';
import '../game/sfx.dart';
import '../player/player.dart';
import '../world/voxel_world.dart';
import 'player_model.dart';
import 'remote_player.dart';
import 'target.dart';
import 'scene_body.dart';
import '../game/pathfinder.dart';
import 'voxel_mesh_builder.dart';

enum MobState { idle, wander, chase, attack, flee, dead }

/// A creature: voxel model by body type, a small state machine, health bar,
/// drops and XP.
class Mob extends SceneBody {
  late SpeciesDef species;
  double hp = 1;
  double maxHp = 1;
  MobState state = MobState.idle;
  late Game main;
  late Player player;
  double _timer = 0.0;
  Vector3 _dir = Vector3.zero();
  double _attackCd = 0.0;
  final Map<String, Part> _parts = {};
  double _phase = 0.0;
  double hurt = 0.0;
  bool barVisible = false;
  bool _angry = false;
  double _age = 0.0;
  double _hopCd = 0.0;
  bool tamed = false;

  /// Stage 33: the playground exhibit that placed this creature ('' for none):
  /// the spawner never despawns or counts it, and the save does not keep it.
  String exhibit = '';
  bool puppet = false;
  double _puppetYaw = 0.0;
  Mob? _petTarget;
  Target? _target;
  int mobLevel = 1;
  double _fuse = 0.0;
  String affix = '';
  double affixScale = 1.0;
  /// Stage 20: a mount carries its rider's input instead of thinking; a sheep
  /// regrows its wool.
  bool ridden = false;

  /// Peer id of the rider (stage 21b), 0 when free.
  int riddenBy = 0;

  /// On a puppet: the host's instance id of this mob.
  int netId = 0;
  Vector3 rideInput = Vector3.zero();
  bool rideSprint = false;
  bool rideJump = false;
  bool sheared = false;
  double _regrow = 0.0;
  double speedMult = 1.0;
  double damageMult = 1.0;
  double _modelYaw = 0.0;
  double _modelScale = 1.0;
  double _squash = 1.0;
  double _shakeX = 0.0;
  double _deathTimer = -1.0;

  /// Stage 23: crowd control from the second abilities, and the flying / ghost
  /// behaviours.
  double stunned = 0.0; // Shield Bash: no thinking, no walking
  double slowed = 0.0; // Frost Nova: half speed
  double blinded = 0.0; // Smoke Bomb: lost its target and cannot aggro
  double _flap = 0.0;
  PhysicallyBasedMaterial? _tint;
  final int instanceId = _nextId++;

  // Stage 32: combat feel and the classic daylight rule.
  double _freeze = 0.0; // hit-stop: the pose holds for 60 ms
  double _flash = 0.0; // the white hit tint, 100 ms
  double _burnTimer = 0.0;
  double _stagger = 0.0; // knockback window: the steering lets the shove carry
  bool burning = false; // a zombie / skeleton under the noon sky, out of water
  double _breath = 1.0;
  double _toppleX = 0.0; // the death: the body tips over on its local X
  double _toppleY = 0.0;
  PhysicallyBasedMaterial? _fade; // the death fade
  static const double knockbackSpeed = 4.0;
  static const double knockbackUp = 3.0;
  static const double staggerSeconds = 0.3;
  static const double hitStop = 0.06;
  static const double hitFlash = 0.1;
  static const List<String> burnsInDaylightIds = ['zombie', 'skeleton', 'dark_skeleton'];
  static const double headTurnRange = 6.0;
  static const double toppleSeconds = 0.4;
  static const double fadeSeconds = 0.3;

  /// Stage 32, probe only: drops rolled in place of the species' own (Godot's
  /// probe duplicates the species dictionary; a Dart `SpeciesDef` is const).
  Map<String, List<int>>? probeDrops;

  /// Stage 32: what a melee hit adds to the victim's velocity: [knockback] away
  /// from [from] on the ground plane (at least [knockbackSpeed]; a projectile's
  /// or an explosion's extra is above that) and [knockbackUp] up.
  static Vector3 knockbackVelocity(Vector3 victim, Vector3 from, double knockback) {
    final push = victim - from;
    push.y = 0.0;
    if (push.length2 > 0) push.normalize();
    return push * math.max(knockback, knockbackSpeed) + Vector3(0, knockbackUp, 0);
  }

  /// Stage 32: the daylight rule. A zombie, skeleton or wither skeleton whose
  /// head cell reads full sky while the day factor is at least 0.9 burns, unless
  /// it is in water or tamed (the underworld has no sky, so nothing burns there).
  static bool burnsInDaylight(String speciesId, {required bool inLiquid, required bool tamed, required int headSky, required double dayFactor}) =>
      burnsInDaylightIds.contains(speciesId) && !inLiquid && !tamed && headSky >= 15 && dayFactor >= 0.9;

  /// Stage 32: which hurt voice a species uses: flying, undead, large (1.5 m or
  /// a boss) or small.
  String hurtGroup() {
    if (species.flying) return 'flying';
    if (burnsInDaylightIds.contains(species.id) || species.ghost || species.id == 'mummy_king') return 'undead';
    if (height >= 1.5 || isBoss) return 'large';
    return 'small';
  }

  bool isFrozen() => _freeze > 0.0;
  bool isFlashing() => _flash > 0.0;
  static int _nextId = 1;

  /// Stage 26: a trader's three offers and the spot it wanders around (a
  /// villager keeps to its village); null home for everything else.
  List<TradeOffer> trades = [];
  Vector3? home;

  static const List<TradeOffer> tradePool = [
    TradeOffer('wheat', 3, 'gold_ingot', 1), TradeOffer('gold_ingot', 1, 'bread', 4),
    TradeOffer('gold_ingot', 1, 'iron_ingot', 3), TradeOffer('gold_ingot', 1, 'arrow', 12),
    TradeOffer('gold_ingot', 2, 'magic_dust', 3), TradeOffer('gold_ingot', 2, 'health_potion', 1),
    TradeOffer('gold_ingot', 5, 'iron_pickaxe', 1), TradeOffer('raw_gold', 2, 'gold_ingot', 1),
    TradeOffer('leather', 4, 'leather_armor', 1), TradeOffer('wool', 6, 'glider', 1),
    TradeOffer('diamond', 1, 'crystal_staff', 1), TradeOffer('gem_shard', 3, 'diamond', 1),
    TradeOffer('gold_ingot', 2, 'speed_potion', 1), TradeOffer('melon_slice', 6, 'gold_ingot', 1),
    TradeOffer('gold_ingot', 3, 'shears', 1),
  ];
  static const double homeRadius = 16.0;

  /// Stage 31: a walker chases and heads home along an A* path ([Pathfinder]),
  /// replanned every [pathPeriod] seconds or when the next waypoint got blocked;
  /// after [pathFails] partial paths in a row it falls back to the straight chase
  /// for [pathDirectSeconds]. Fliers and puppets never path.
  /// [pathfindingEnabled] is the probe's off switch for the no-path control.
  static bool pathfindingEnabled = true;
  static const double pathPeriod = 0.6;
  static const int pathFails = 3;
  static const double pathDirectSeconds = 3.0;
  static const double pathReach = 0.35;
  List<Vector3> _path = const [];
  int _pathI = 0;
  double _pathTimer = 0.0;
  int _pathFail = 0;
  double _pathDirectUntil = -1.0;
  int pathReplans = 0; // for the probe

  /// Stage 26: Godot's `setup_mob` sets `home` and rolls the offers for a
  /// trader; here the position arrives after `setupMob`, so the spawner calls
  /// this once the mob stands at [bornAt]. The offers are decided by that spot
  /// and the world seed (Dart's Random, so not Godot's three for the same spot).
  void makeTrader(Vector3 bornAt) {
    home = bornAt.clone();
    trades = rollTrades(math.Random(traderSeed(IVec3.floor(bornAt), world.seedValue)));
  }

  /// A spatial hash that is the same in every process (`IVec3.hashCode` is
  /// Dart's per-run seeded `Object.hash`, so the same villager would roll
  /// other offers after a restart or on another peer): the loot seed.
  static int traderSeed(IVec3 at, int seed) => LootTables.seedFor(at, seed);

  /// Three distinct offers from the pool.
  static List<TradeOffer> rollTrades(math.Random rng) {
    final pool = List<TradeOffer>.of(tradePool);
    return [for (var i = 0; i < 3; i++) pool.removeAt(rng.nextInt(pool.length))];
  }

  /// Stage 26: the trade at row [i] of [trades], when [bag] holds what it asks
  /// and has room for what it gives. True when the items changed hands.
  /// The two children of a split, beside where this mob fell.
  List<Mob> spawnSplit() {
    final sp = main.spawner!;
    final at = centre();
    return [
      for (var i = 0; i < 2; i++)
        sp.forceSpawn(species.splits, at + Vector3(i == 0 ? 0.6 : -0.6, 0.2, 0))
          ..velocity = Vector3(i == 0 ? 3.0 : -3.0, 5.0, main.random.nextDouble() * 4.0 - 2.0)
          ..mobLevel = mobLevel,
    ];
  }

  bool tradeWith(Inventory bag, int i) {
    if (i < 0 || i >= trades.length) throw RangeError.index(i, trades, 'offer');
    final o = trades[i];
    if (bag.countOf(o.take) < o.takeCount) return false;
    if (bag.roomFor(o.give, o.giveCount) < o.giveCount) return false;
    bag.remove(o.take, o.takeCount);
    bag.add(o.give, o.giveCount);
    Sfx.play('pickup');
    return true;
  }

  /// Elite affixes (stage 18): a prefix on the name, a coloured aura, and one
  /// twist each.
  static const Map<String, AffixDef> affixes = {
    'Swift': AffixDef(speed: 1.5, r: 0.45, g: 0.85, b: 0.95),
    'Sturdy': AffixDef(hp: 2.0, r: 0.70, g: 0.70, b: 0.75),
    'Venomous': AffixDef(effect: 'poison', r: 0.35, g: 0.80, b: 0.30),
    'Burning': AffixDef(effect: 'burning', r: 1.00, g: 0.55, b: 0.15),
    'Chilling': AffixDef(effect: 'slow', r: 0.50, g: 0.60, b: 0.95),
    'Giant': AffixDef(scale: 1.4, hp: 1.6, damage: 1.3, r: 0.95, g: 0.80, b: 0.30),
  };

  bool get isBoss => species.boss;
  bool get isMount => species.mount;
  bool get isDead => state == MobState.dead;

  void scaleToLevel(int lvl) {
    mobLevel = math.max(lvl, 1);
    final f = 1.0 + (mobLevel - 1) * 0.18;
    maxHp = species.hp * f;
    hp = maxHp;
  }

  void tame(Player by) {
    tamed = true;
    _angry = false;
    state = MobState.idle;
    main.mobs.remove(this);
    main.pets.add(this);
    maxHp += 10.0;
    hp = maxHp;
    barVisible = true;
    if (isMount) {
      by.notify('${species.name} is tamed! [F] to ride it');
    } else {
      by.notify('${species.name} is now your companion!');
      Achievements.instance.unlock('tamer');
    }
  }

  void _petThink(double dt, double dist, Vector3 toPlayer) {
    // A mount never fights: it trots after its owner while they are near, and
    // waits otherwise.
    if (isMount) {
      if (dist > 20.0 || dist < 2.5) {
        _dir = Vector3.zero();
      } else if (dist > 4.0) {
        _dir = toPlayer.normalized();
      }
      return;
    }
    // Fight what the player fights, otherwise heel.
    final pt = _petTarget;
    if (pt != null && (pt.removed || pt.state == MobState.dead)) _petTarget = null;
    if (_petTarget == null) {
      var best = 12.0;
      for (final mob in main.mobs) {
        if (mob.species.hostile && mob.state == MobState.chase) {
          final d = (mob.position - position).length;
          if (d < best) {
            best = d;
            _petTarget = mob;
          }
        }
      }
    }
    final target = _petTarget;
    if (target != null) {
      final toT = target.position - position;
      toT.y = 0.0;
      if (toT.length < 1.6 + halfWidth) {
        _dir = Vector3.zero();
        _face(toT);
        if (_attackCd <= 0.0) {
          _attackCd = 1.0;
          target.takeDamage(species.damage + 2, position, 4.0, this);
          main.spawnDamageNumber(target.centre(), species.damage + 2, Vector3(0.6, 0.8, 1.0));
        }
      } else {
        _dir = toT.normalized();
      }
      return;
    }
    if (dist > 4.0) {
      _dir = toPlayer.normalized();
    } else if (dist < 2.0) {
      _dir = Vector3.zero();
    }
    if (dist > 30.0) position = player.position + Vector3(1, 0.5, 1);
  }

  void setupMob(VoxelWorld w, Game m, Player p, SpeciesDef sp) {
    species = sp;
    setup(w, sp.halfWidth, sp.height);
    main = m;
    player = p;
    maxHp = sp.hp;
    hp = maxHp;
    GameState.instance.seen.add(sp.id);
    _buildModel();
    if (sp.ghost) {
      noclip = true;
      _setTint(ghostTint);
    }
  }

  /// Stage 23: a tint over the whole model (a stun, a ghost's transparency);
  /// alpha 1 clears it.
  static final Vector4 ghostTint = Vector4(0.85, 0.92, 1.0, 0.45);

  void _setTint(Vector4 color) {
    if (color.a >= 1.0) {
      if (!species.ghost) {
        _tint = null;
      } else {
        color = ghostTint; // a ghost never turns solid
      }
    } else {
      _tint ??= PhysicallyBasedMaterial()
        ..roughnessFactor = 0.9
        ..metallicFactor = 0.0
        ..alphaMode = AlphaMode.blend;
    }
    _tint?.baseColorFactor = color;
    if (_flash <= 0.0) _applyOverride(_tint ?? VoxelMeshBuilder.material());
  }

  void _applyOverride(Material material) {
    for (final part in _parts.values) {
      for (final child in part.node.children) {
        final mesh = child.mesh;
        if (mesh == null) continue;
        for (final prim in mesh.primitives) {
          prim.material = material;
        }
        refreshMeshMaterials(child); // stage 32: a material swap reaches the render item only this way
      }
    }
  }

  /// Shield Bash: the mob stands frozen for [seconds], coloured yellow ([tint]
  /// off for a probe hold).
  void stun(double seconds, [bool tint = true]) {
    stunned = math.max(stunned, seconds);
    _dir = Vector3.zero();
    if (tint) _setTint(Vector4(1.0, 0.9, 0.3, 0.8));
  }

  void slow(double seconds) => slowed = math.max(slowed, seconds);

  /// Smoke Bomb: forgets its target and cannot pick one up for [seconds].
  void loseTarget(double seconds) {
    blinded = math.max(blinded, seconds);
    _angry = false;
    _target = null;
    if (state == MobState.chase || state == MobState.attack) {
      state = MobState.idle;
      _timer = seconds;
    }
  }

  /// Turn this mob into an elite: the affix scales it, tints its bar and hangs
  /// an aura light on it.
  void setAffix(String name) {
    final a = affixes[name];
    if (a == null) throw ArgumentError('unknown affix $name');
    affix = name;
    speedMult = a.speed;
    damageMult = a.damage;
    maxHp *= a.hp;
    hp = maxHp;
    affixScale = a.scale;
    final aura = PointLight(color: a.color, intensity: 6.0, range: 4.0);
    final auraNode = Node(name: 'Aura')..position = Vector3(0, height * 0.5, 0);
    auraNode.addComponent(PointLightComponent(aura));
    node.add(auraNode);
    barVisible = true;
  }

  /// The bar colour: blue for a pet, the affix colour for an elite, red else.
  Vector3 barColor() {
    if (tamed) return Vector3(0.3, 0.6, 1.0);
    final a = affixes[affix];
    return a != null ? a.color : Vector3(0.85, 0.25, 0.25);
  }

  String displayName() {
    final base = species.hostile ? '${species.name} Lv $mobLevel' : species.name;
    return affix != '' ? '$affix $base' : base;
  }

  double damageDealt() => species.damage * (1.0 + (mobLevel - 1) * 0.12) * damageMult;

  /// Damage a body and pass on whatever the affix or the species inflicts.
  void hurtTarget(Target t, double amount) {
    t.takeDamage(amount, species.id, position);
    var eff = affixes[affix]?.effect ?? '';
    if (eff == '') eff = species.effect;
    if (eff == '') return;
    if (t is Player) {
      t.applyEffect(eff, 6.0);
    } else if (t is RemotePlayer) {
      // A puppet forwards both to its peer (stage 21b: the effect too).
      t.applyEffect(eff, 6.0);
    }
  }

  /// Puppet: what the host says about taming and riding, so a client can find a
  /// tamed mount and sit the rider's puppet on it.
  void setPuppetFlags(bool isTamed, int rider) {
    riddenBy = rider;
    ridden = rider != 0;
    if (isTamed && !tamed) {
      tamed = true;
      main.mobs.remove(this);
      if (!main.pets.contains(this)) main.pets.add(this);
      barVisible = true;
    }
  }

  Part _part(Map<IVec3, Vector3> voxels, Vector3 at, double s) {
    final pivot = VoxelMeshBuilder.meshNode({}, 1.0);
    pivot.add(VoxelMeshBuilder.meshNode(voxels, s));
    node.add(pivot);
    return Part(pivot, at);
  }

  void _buildModel() {
    final colors = species.colors;
    final body = species.body;
    final s = body == 'humanoid' ? 0.055 * (height / 1.75) : 0.06;
    final dark = Vector3(0.05, 0.05, 0.05);
    switch (body) {
      case 'quadruped':
        final w = halfWidth;
        final bodyLen = (height * 14).toInt();
        final bodyH = (height * 7).toInt();
        final bodyW = (w * 22).toInt();
        final legH = (height * 6).toInt();
        var v = <IVec3, Vector3>{};
        VoxelMeshBuilder.box(v, IVec3(-bodyW ~/ 2, 0, -bodyLen ~/ 2), IVec3(bodyW ~/ 2, bodyH, bodyLen ~/ 2), colors[0]);
        _parts['body'] = _part(v, Vector3(0, legH * s, 0), s);
        v = {};
        final hs = (bodyW * 0.7).toInt();
        VoxelMeshBuilder.box(v, IVec3(-hs ~/ 2, -hs ~/ 2, -hs), IVec3(hs ~/ 2, hs ~/ 2, 0), colors.length > 1 ? colors[1] : colors[0]);
        v[IVec3(-hs ~/ 2 + 1, 0, -hs)] = dark;
        v[IVec3(hs ~/ 2 - 1, 0, -hs)] = dark;
        _parts['head'] = _part(v, Vector3(0, (legH + bodyH * 0.8) * s, -bodyLen / 2 * s), s);
        for (var i = 0; i < 4; i++) {
          v = {};
          VoxelMeshBuilder.box(v, IVec3(-1, -legH, -1), const IVec3(1, 0, 1), colors.length > 1 ? colors[1] : colors[0] * 0.8);
          final lx = (bodyW / 2 - 1.5) * s * (i % 2 == 0 ? 1 : -1);
          final lz = (bodyLen / 2 - 2) * s * (i < 2 ? 1 : -1);
          _parts['leg$i'] = _part(v, Vector3(lx, legH * s, lz), s);
        }
      case 'humanoid':
        final skin = colors[0];
        final shirt = colors[1];
        final pants = colors[2];
        final k = height / 1.75;
        var v = <IVec3, Vector3>{};
        VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -1, 1), pants);
        _parts['leg0'] = _part(v, Vector3(-0.11 * k, 0.66 * k, 0), s);
        _parts['leg1'] = _part(v, Vector3(0.11 * k, 0.66 * k, 0), s);
        v = {};
        VoxelMeshBuilder.box(v, const IVec3(-4, 0, -2), const IVec3(3, 11, 1), shirt);
        _parts['body'] = _part(v, Vector3(0, 0.66 * k, 0), s);
        v = {};
        VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -1, 1), skin);
        _parts['arm0'] = _part(v, Vector3(-0.33 * k, 1.30 * k, 0), s);
        _parts['arm1'] = _part(v, Vector3(0.33 * k, 1.30 * k, 0), s);
        v = {};
        VoxelMeshBuilder.box(v, const IVec3(-4, 0, -4), const IVec3(3, 7, 3), skin, 0.04);
        final eye = species.hostile ? Vector3(0.9, 0.1, 0.1) : dark;
        v[const IVec3(-3, 4, -4)] = eye;
        v[const IVec3(2, 4, -4)] = eye;
        _parts['head'] = _part(v, Vector3(0, 1.32 * k, 0), s);
        _parts['arm0']!.rx = -1.4;
        _parts['arm1']!.rx = -1.4;
      case 'blob':
        final v = <IVec3, Vector3>{};
        final r = (halfWidth * 16).toInt();
        final h = (height * 14).toInt();
        VoxelMeshBuilder.box(v, IVec3(-r, 0, -r), IVec3(r, h, r), colors[0], 0.08);
        for (var x = -r; x <= r; x++) {
          for (var z = -r; z <= r; z++) {
            if (x.abs() == r || z.abs() == r) v.remove(IVec3(x, h, z));
            if (x.abs() == r && z.abs() == r) v.remove(IVec3(x, 0, z));
          }
        }
        v[IVec3(-r ~/ 2, h * 2 ~/ 3, -r)] = dark;
        v[IVec3(r ~/ 2, h * 2 ~/ 3, -r)] = dark;
        _parts['body'] = _part(v, Vector3.zero(), s);
      case 'spider':
        var v = <IVec3, Vector3>{};
        VoxelMeshBuilder.box(v, const IVec3(-4, 0, -3), const IVec3(4, 4, 5), colors[0], 0.06);
        VoxelMeshBuilder.box(v, const IVec3(-3, 0, -7), const IVec3(3, 3, -3), colors[0] * 0.9, 0.06);
        v[const IVec3(-2, 3, -7)] = colors[1];
        v[const IVec3(2, 3, -7)] = colors[1];
        v[const IVec3(-1, 2, -7)] = colors[1];
        v[const IVec3(1, 2, -7)] = colors[1];
        _parts['body'] = _part(v, Vector3(0, 0.35, 0), s);
        for (var i = 0; i < 8; i++) {
          v = {};
          final side = i % 2 == 0 ? 1 : -1;
          VoxelMeshBuilder.box(v, const IVec3(0, 0, 0), const IVec3(5, 0, 0), colors[0]);
          VoxelMeshBuilder.box(v, const IVec3(5, -5, 0), const IVec3(5, 0, 0), colors[0]);
          final leg = _part(v, Vector3(side * 0.25, 0.42, (i ~/ 2 - 1.5) * 0.18), s);
          leg.sx = side.toDouble();
          leg.ry = (i ~/ 2 - 1.5) * 0.3 * side;
          _parts['leg$i'] = leg;
        }
      case 'bird':
        var v = <IVec3, Vector3>{};
        VoxelMeshBuilder.box(v, const IVec3(-2, 0, -3), const IVec3(2, 4, 3), colors[0]);
        _parts['body'] = _part(v, Vector3(0, 0.25, 0), s);
        v = {};
        VoxelMeshBuilder.box(v, const IVec3(-1, 0, -2), const IVec3(1, 3, 1), colors[0]);
        VoxelMeshBuilder.box(v, const IVec3(0, 1, -3), const IVec3(0, 1, -3), Vector3(0.95, 0.7, 0.2));
        VoxelMeshBuilder.box(v, const IVec3(0, 3, -1), const IVec3(0, 4, -1), colors[1]);
        _parts['head'] = _part(v, Vector3(0, 0.5, -0.18), s);
        for (var i = 0; i < 2; i++) {
          v = {};
          VoxelMeshBuilder.box(v, const IVec3(0, -4, 0), const IVec3(0, 0, 0), Vector3(0.95, 0.7, 0.2));
          _parts['leg$i'] = _part(v, Vector3((i - 0.5) * 0.12, 0.25, 0), s);
        }
    }
    for (final p in _parts.values) {
      p.apply();
    }
  }

  void takeDamage(double amount, Vector3 from, double knockback, Object? attacker) {
    if (state == MobState.dead) return;
    hp -= amount;
    hurt = 0.25;
    barVisible = true;
    final push = position - from;
    push.y = 0.0;
    if (push.length2 > 0) push.normalize();
    // Stage 32: every hit shoves the victim 4 m/s away and 3 m/s up, holds its
    // pose for 60 ms and tints it white for 100 ms; the hurt voice is the
    // species group's.
    velocity += knockbackVelocity(position, from, knockback);
    _freeze = hitStop;
    _flash = hitFlash;
    _stagger = staggerSeconds;
    _applyOverride(PlayerModel.flashMaterial());
    Sfx.play('hurt_${hurtGroup()}', -8.0);
    if (species.trader) {
      hp = maxHp;
      return;
    }
    if ((attacker is Player || attacker is RemotePlayer) && (species.hostile || species.neutral)) {
      _angry = true;
      state = MobState.chase;
    } else if (!species.hostile) {
      state = MobState.flee;
      _timer = 4.0;
      _dir = push;
    }
    if (hp <= 0.0) _die();
  }

  void _die() {
    state = MobState.dead;
    final st = GameState.instance;
    st.mobsKilled += 1;
    st.kills[species.id] = (st.kills[species.id] ?? 0) + 1;
    final ach = Achievements.instance;
    if (species.hostile) {
      ach.unlock('first_kill');
      if (st.mobsKilled >= 50) ach.unlock('slayer');
    }
    if (isBoss) ach.unlock('boss');
    if (species.id == 'underworld_lord') main.onUnderworldLordDied(position); // stage 29: the fortress core opens
    if (affix != '') {
      ach.unlock('elite');
      main.spawnDrop(centre(), 'gem_shard', 1 + main.random.nextInt(2));
      main.spawnDrop(centre(), 'magic_dust', 1);
    }
    player.gainXp((species.xp * (1.0 + (mobLevel - 1) * 0.15) * (affix != '' ? 2.5 : 1.0)).toInt());
    main.quests.onKill(species.id);
    for (final e in (probeDrops ?? species.drops).entries) {
      final n = e.value[0] + main.random.nextInt(e.value[1] - e.value[0] + 1);
      if (n > 0) main.spawnDrop(centre(), e.key, n);
    }
    if (isBoss) {
      main.spawnDrop(centre(), 'diamond', 1);
      final loot = main.randomLootWeapon(main.random, 4);
      main.spawnLootDrop(centre(), ItemStack(loot.id, 1, bonus: loot.bonus));
    }
    // Stage 26: a slime that dies leaves two small slimes hopping away from
    // where it fell.
    // Godot adds them at once; here a death usually happens inside a loop over
    // `Game.mobs`, so the children wait in `Game.pendingSplits` for the end of
    // the tick.
    if (species.splits != '' && main.spawner != null) main.pendingSplits.add(this);
    main.spawnEffect(centre(), Vector3(0.9, 0.3, 0.3), 1.0);
    // Stage 32: the body topples 90 degrees over 0.4 s, fades over 0.3 s, then
    // goes; the drops above already fell at t=0.
    _deathTimer = 0.0;
    _flash = 0.0;
    barVisible = false;
    _fade = PhysicallyBasedMaterial()
      ..roughnessFactor = 0.9
      ..metallicFactor = 0.0
      ..alphaMode = AlphaMode.blend
      ..baseColorFactor = species.ghost ? ghostTint.clone() : Vector4(1, 1, 1, 1);
    _applyOverride(_fade!);
  }

  /// Stage 32: the classic rule, checked twice a second from the cell at the
  /// head: 0.5 HP per half second, orange, embers.
  void _burnTick(double dt) {
    _burnTimer -= dt;
    if (_burnTimer > 0.0) return;
    _burnTimer = 0.5;
    final was = burning;
    burning = false;
    if (burnsInDaylightIds.contains(species.id) && !inLiquid && !tamed) {
      final head = IVec3(position.x.floor(), (position.y + height - 0.15).floor(), position.z.floor());
      burning = burnsInDaylight(species.id, inLiquid: inLiquid, tamed: tamed, headSky: world.lightAt(head).sky, dayFactor: main.dayFactor);
    }
    if (burning) {
      if (!was) _setTint(Vector4(1.0, 0.55, 0.15, 0.85));
      hp -= 0.5;
      hurt = 0.25;
      main.spawnDebris(centre() + Vector3(0, height * 0.3, 0), Vector3(1.0, 0.5, 0.1), 1, 0.6);
      if (hp <= 0.0) _die();
    } else if (was && stunned <= 0.0) {
      _setTint(Vector4(1, 1, 1, 1));
    }
  }

  /// Stage 32: the hit-stop, the stagger and the flash run down; the flash gives
  /// the tint back when it ends.
  void _tickFeel(double dt) {
    _freeze = math.max(_freeze - dt, 0.0);
    _stagger = math.max(_stagger - dt, 0.0);
    if (_flash > 0.0) {
      _flash -= dt;
      if (_flash <= 0.0) {
        _flash = 0.0;
        _applyOverride(_tint ?? VoxelMeshBuilder.material());
      }
    }
  }

  void update(double dt) {
    if (state == MobState.dead) {
      // Stage 32: topple (linear, Godot's EASE_IN on a linear transition), then fade.
      _deathTimer += dt;
      final t = (_deathTimer / toppleSeconds).clamp(0.0, 1.0);
      _toppleX = -math.pi / 2 * t;
      _toppleY = height * 0.5 * t;
      final f = ((_deathTimer - toppleSeconds) / fadeSeconds).clamp(0.0, 1.0);
      final fade = _fade;
      if (fade != null) fade.baseColorFactor = Vector4(fade.baseColorFactor.x, fade.baseColorFactor.y, fade.baseColorFactor.z, (species.ghost ? ghostTint.w : 1.0) * (1.0 - f));
      _applyModel();
      if (_deathTimer >= toppleSeconds + fadeSeconds) removed = true;
      return;
    }
    if (puppet) {
      _modelYaw = lerpAngle(_modelYaw, _puppetYaw, dt * 10.0);
      hurt = math.max(hurt - dt, 0.0);
      _tickFeel(dt);
      _applyModel();
      return;
    }
    // Stage 24: a restored mob waits for its chunk; an unloaded chunk reads as
    // air and it would fall.
    if (!world.isLoaded(IVec3.floor(position))) return;
    _age += dt;
    _attackCd = math.max(_attackCd - dt, 0.0);
    _hopCd = math.max(_hopCd - dt, 0.0);
    hurt = math.max(hurt - dt, 0.0);
    _tickFeel(dt);
    _burnTick(dt);
    if (state == MobState.dead) return; // burnt to death this tick
    _timer -= dt;
    _pathTimer -= dt;
    if (sheared) {
      _regrow -= dt;
      if (_regrow <= 0.0) {
        sheared = false;
        _parts['body']?..sx = 1.0
          ..sy = 1.0
          ..sz = 1.0;
      }
    }
    if (ridden) {
      _rideTick(dt);
      return;
    }
    slowed = math.max(slowed - dt, 0.0);
    blinded = math.max(blinded - dt, 0.0);
    if (stunned > 0.0) {
      stunned -= dt;
      if (stunned <= 0.0) _setTint(Vector4(1, 1, 1, 1));
      _dir = Vector3.zero();
      _moveAndAnimate(dt);
      return;
    }
    _target = _nearestTarget();
    final target = _target!;
    final dist = (position - target.position).length;
    final toPlayer = target.position - position;
    if (!species.flying) toPlayer.y = 0.0;
    final aggro = species.hostile && blinded <= 0.0 ? 18.0 : 0.0;
    final ranged = species.ranged;
    final reach = 1.9 + halfWidth;

    if (tamed) {
      _petThink(dt, dist, toPlayer);
    } else {
      _stateThink(dist, toPlayer, aggro, ranged, reach);
    }
    if (state == MobState.dead || removed) return;
    _moveAndAnimate(dt);
  }

  /// Ridden: the rider's wish drives the body at the species speed, sprint
  /// x1.4, jump on the floor.
  void _rideTick(double dt) {
    final speed = species.speed * (rideSprint ? 1.4 : 1.0);
    if (inLiquid && rideInput.length > 0.1) velocity.y = 3.0;
    applyGravity(dt);
    if (rideJump && onFloor) velocity.y = 9.0;
    rideJump = false;
    velocity.x = lerpd(velocity.x, rideInput.x * speed, dt * 8.0);
    velocity.z = lerpd(velocity.z, rideInput.z * speed, dt * 8.0);
    move(dt);
    if (hitWall && onFloor && rideInput.length > 0.1) tryStepUp();
    _dir = rideInput;
    _face(rideInput);
    _animate(dt);
    syncNode();
  }

  /// Shears take 1..3 wool; the body shrinks until it regrows two minutes later.
  int shear() {
    if (species.id != 'sheep' || sheared) {
      throw StateError('only an unsheared sheep can be sheared');
    }
    sheared = true;
    _regrow = 120.0;
    _parts['body']?..sx = 0.85
      ..sy = 0.7
      ..sz = 0.85;
    return 1 + main.random.nextInt(3);
  }

  Target _nearestTarget() {
    Target best = player;
    var bestD = double.infinity;
    for (final t in main.targets()) {
      final d = (t.position - position).length2;
      if (d < bestD && !t.isDead) {
        bestD = d;
        best = t;
      }
    }
    return best;
  }

  bool huntsPuppet() => _target is! Player && state == MobState.chase;

  void _stateThink(double dist, Vector3 toPlayer, double aggro, bool ranged, double reach) {
    final target = _target!;
    final targetDead = target.isDead;
    final rng = main.random;
    switch (state) {
      case MobState.idle:
        _dir = Vector3.zero();
        if (_timer <= 0.0) {
          state = MobState.wander;
          _timer = 1.5 + rng.nextDouble() * 2.5;
          final a = rng.nextDouble() * math.pi * 2;
          _dir = Vector3(math.cos(a), 0, math.sin(a));
        }
        if ((species.hostile || _angry) && dist < aggro && !targetDead) state = MobState.chase;
      case MobState.wander:
        if (_timer <= 0.0) {
          state = MobState.idle;
          _timer = 1.0 + rng.nextDouble() * 4.0;
        }
        final h = home;
        if (h != null) {
          final away = position - h;
          away.y = 0.0;
          // Stage 26: a villager turns back to its village.
          if (away.length > homeRadius) _dir = _steer(-away, h);
        }
        if ((species.hostile || _angry) && dist < aggro && !targetDead) state = MobState.chase;
      case MobState.chase:
        if (targetDead || dist > aggro * 2.2) {
          state = MobState.idle;
          _angry = false;
        }
        _dir = _steer(toPlayer, target.position);
        if (ranged) {
          if (dist < 6.0) {
            _dir = -_dir;
          } else if (dist < 13.0) {
            _dir = Vector3.zero();
          }
          if (dist < 16.0 && _attackCd <= 0.0) {
            _attackCd = 2.2;
            _face(toPlayer);
            main.spawnProjectile(centre() + Vector3(0, 0.3, 0), (target.centre() - centre()).normalized() * 24.0,
                species.damage, this, species.body == 'humanoid' ? 'arrow' : 'frost');
          }
        } else if (dist < reach) {
          state = MobState.attack;
        }
      case MobState.attack:
        _dir = Vector3.zero();
        _face(toPlayer);
        if (species.explodes) {
          _fuse += 0.016;
          _modelScale = 1.0 + _fuse * 0.5;
          if (_fuse > 1.1) {
            main.explode(centre(), 3.0, 9.0 + mobLevel, this);
            removed = true;
          }
          return;
        }
        if (dist > reach + 0.4) {
          state = MobState.chase;
        } else if (_attackCd <= 0.0) {
          _attackCd = 1.3;
          _parts['arm0']?.rx = -2.4;
          hurtTarget(target, damageDealt());
          Sfx.play('hit', -4.0);
        }
      case MobState.flee:
        if (_timer <= 0.0) state = MobState.idle;
        if (dist < 12.0 && toPlayer.length2 > 0) _dir = -toPlayer.normalized();
      case MobState.dead:
        break;
    }
  }

  /// Stage 31: the horizontal direction to walk toward [goal]: the next waypoint
  /// of an A* path for a walker, the straight line for a flier, a puppet, or a
  /// walker whose paths keep failing.
  Vector3 _steer(Vector3 direct, Vector3 goal) {
    final flat = Vector3(direct.x, 0, direct.z);
    Vector3 norm(Vector3 v) => v.length2 > 0 ? v.normalized() : Vector3.zero();
    if (!pathfindingEnabled || species.flying || puppet || _age < _pathDirectUntil) return norm(flat);
    final from = IVec3(position.x.floor(), (position.y + 0.05).floor(), position.z.floor());
    final to = IVec3(goal.x.floor(), (goal.y + 0.05).floor(), goal.z.floor());
    final blocked = _pathI < _path.length && world.isSolid(IVec3.floor(_path[_pathI]));
    if (_pathTimer <= 0.0 || blocked || _path.isEmpty) {
      _path = Pathfinder.find(world, from, to);
      _pathI = 0;
      _pathTimer = pathPeriod;
      pathReplans += 1;
      final last = _path.isEmpty ? to : IVec3.floor(_path.last);
      if (_path.isEmpty || (last != to && ((last.x - to.x).abs() + (last.z - to.z).abs() > 1 || (last.y - to.y).abs() > 1))) {
        _pathFail += 1;
        if (_pathFail >= pathFails) {
          _pathFail = 0;
          _pathDirectUntil = _age + pathDirectSeconds;
          _path = const [];
          return norm(flat);
        }
      } else {
        _pathFail = 0;
      }
    }
    while (_pathI < _path.length) {
      final wp = _path[_pathI];
      final dx = wp.x - position.x, dz = wp.z - position.z;
      if (dx * dx + dz * dz < pathReach * pathReach && (wp.y - position.y).abs() < 1.1) {
        _pathI += 1;
      } else {
        break;
      }
    }
    if (_pathI >= _path.length) return norm(flat);
    final next = _path[_pathI] - position;
    next.y = 0.0;
    return norm(next);
  }

  /// Stage 31, for the probe's trace: the waypoint being walked to and the path length.
  (int, int) get pathProgress => (_pathI, _path.length);

  void _moveAndAnimate(double dt) {
    var speed = species.speed * speedMult;
    if (state == MobState.wander) speed *= 0.5;
    if (slowed > 0.0) speed *= 0.5;
    // Stage 29: soul sand under the feet.
    if (onFloor) speed *= Blocks.speedMult(world.getBlockXYZ(position.x.floor(), (position.y - 0.05).floor(), position.z.floor()));
    if (species.flying) {
      _fly(dt, speed);
      return;
    }
    final hops = species.hops;
    if (inLiquid) {
      if (_dir.length > 0.1) velocity.y = 3.0;
      applyGravity(dt);
    } else {
      applyGravity(dt);
    }
    if (hops) {
      if (onFloor && _dir.length > 0.1 && _hopCd <= 0.0) {
        velocity.y = 7.0;
        _hopCd = state != MobState.chase ? 0.9 : 0.5;
      }
      velocity.x = lerpd(velocity.x, !onFloor ? _dir.x * speed : 0.0, dt * 3.0);
      velocity.z = lerpd(velocity.z, !onFloor ? _dir.z * speed : 0.0, dt * 3.0);
    } else if (_stagger <= 0.0) {
      // Stage 32: a shoved body carries for 0.3 s before it steers again.
      velocity.x = lerpd(velocity.x, _dir.x * speed, dt * 8.0);
      velocity.z = lerpd(velocity.z, _dir.z * speed, dt * 8.0);
    }
    move(dt);
    if (hitWall && onFloor && _dir.length > 0.1) {
      if (!tryStepUp()) velocity.y = 8.0;
    }
    if (_dir.length > 0.1) _face(_dir);
    _animate(dt);
    if (position.y < -5.0) removed = true;
    syncNode();
  }

  /// Stage 23: a flier ignores gravity. Wandering it flutters on a random 3D
  /// heading that changes every few tenths of a second (the bat's erratic
  /// path); chasing it steers straight at the target's centre. A ghost is a slow
  /// flier with `noclip`, so the walls are nothing to it.
  void _fly(double dt, double speed) {
    _flap -= dt;
    final target = _target;
    if (state == MobState.chase && target != null) {
      final to = target.centre() - centre();
      _dir = to.length2 > 0 ? to.normalized() : Vector3.zero();
    } else if (tamed) {
      // Stage 26: a tamed parrot hovers over its owner's shoulder.
      final toPerch = player.centre() + Vector3(0, 1.2, 0) - centre();
      _dir = toPerch.length > 1.2 ? toPerch.normalized() : Vector3.zero();
    } else if (state == MobState.wander || state == MobState.idle) {
      if (_flap <= 0.0) {
        final rng = main.random;
        _flap = 0.2 + rng.nextDouble() * 0.4;
        _dir = Vector3(rng.nextDouble() * 2 - 1, rng.nextDouble() * 1.2 - 0.6, rng.nextDouble() * 2 - 1).normalized();
        // Stay near the ground it hunts over: a wanderer far above a solid cell
        // dives back.
        if (!world.isSolid(IVec3.floor(position + Vector3(0, -3, 0)))) _dir.y = -0.7;
      }
      if (_dir.length > 0.1) state = MobState.wander;
    }
    final bob = math.sin(_age * 9.0) * 0.8;
    velocity.x = lerpd(velocity.x, _dir.x * speed, dt * 6.0);
    velocity.z = lerpd(velocity.z, _dir.z * speed, dt * 6.0);
    velocity.y = lerpd(velocity.y, _dir.y * speed + bob, dt * 6.0);
    move(dt);
    if (hitWall && _flap > 0.1) _flap = 0.0; // bounce off a wall into a new heading next tick
    final flat = Vector3(_dir.x, 0, _dir.z);
    if (flat.length > 0.1) _face(flat);
    _animate(dt);
    if (position.y < -5.0) removed = true;
    syncNode();
  }

  void _face(Vector3 dir) {
    if (dir.length < 0.01) return;
    _modelYaw = lerpAngle(_modelYaw, math.atan2(-dir.x, -dir.z), 0.2);
  }

  void _animate(double dt) {
    if (_freeze > 0.0) {
      _applyModel(); // stage 32: hit-stop, the pose holds (the body still moves)
      return;
    }
    final sp = math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z);
    _phase += dt * sp * 2.2;
    // Stage 32: idle life. Every body breathes (2% on the height); a passive
    // mob's head turns toward the player within 6 m.
    if (species.body != 'blob' && !species.explodes) _breath = 1.0 + 0.02 * math.sin(_age * 2.4);
    final head = _parts['head'];
    if (head != null && !species.hostile) {
      final to = player.centre() - centre();
      var want = 0.0;
      if (math.sqrt(to.x * to.x + to.z * to.z) < headTurnRange) {
        want = math.atan2(-to.x, -to.z) - _modelYaw;
        want = (want + math.pi) % (math.pi * 2) - math.pi;
        want = want.clamp(-1.2, 1.2);
      }
      head.ry = lerpAngle(head.ry, want, dt * 5.0);
    }
    final a = sp > 0.3 ? math.sin(_phase) * 0.7 : 0.0;
    for (var i = 0; i < 8; i++) {
      final p = _parts['leg$i'];
      if (p == null) continue;
      if (species.body == 'spider') {
        p.rz = math.sin(_phase + i * 1.3) * 0.25;
      } else {
        p.rx = ((i % 2 == 0) == (i < 2)) ? a : -a;
      }
    }
    final arm0 = _parts['arm0'];
    if (arm0 != null && species.body == 'humanoid') {
      arm0.rx = lerpd(arm0.rx, -1.4 + a * 0.3, dt * 6.0);
      _parts['arm1']!.rx = -1.4 - a * 0.3;
    }
    if (species.body == 'blob') {
      _squash = 1.0 + math.sin(_age * 6.0) * 0.06 + (!onFloor ? 0.15 : 0.0);
    }
    _shakeX = hurt > 0.0 ? math.sin(_age * 80.0) * 0.05 : 0.0;
    _applyModel();
  }

  void _applyModel() {
    for (final p in _parts.values) {
      p.apply();
    }
    final sq = species.body == 'blob' ? _squash : 1.0;
    node.rotation = _toppleX == 0.0 ? Quaternion.axisAngle(Vector3(0, 1, 0), _modelYaw) : eulerYXZ(_toppleX, _modelYaw, 0);
    final ms = _modelScale * affixScale;
    node.scale = Vector3(ms / math.sqrt(sq), ms * sq * _breath, ms / math.sqrt(sq));
    node.position = position + Vector3(_shakeX, _toppleY, 0);
  }

  double modelYaw() => _modelYaw;

  // --- stage 24: a tamed mob rides the save ------------------------------------------

  Map<String, Object> toJson() => {
        'species': species.id,
        'pos': [position.x, position.y, position.z],
        'hp': hp,
        'max_hp': maxHp,
        'level': mobLevel,
        'affix': affix,
        'tamed': tamed,
        'name': displayName(),
        'yaw': modelYaw(),
        // Stage 26: a villager keeps its offers and its village across the save.
        'trades': [for (final t in trades) t.toJson()],
        'home': home == null ? <double>[] : [home!.x, home!.y, home!.z],
      };

  /// Rebuilds a saved mob: `setupMob` was already called by the loader, then
  /// level, affix, health and the tame state without the taming notice.
  void fromJson(Map<String, dynamic> d) {
    final p = (d['pos'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    position = Vector3(p[0], p[1], p[2]);
    mobLevel = (d['level'] as num?)?.toInt() ?? 1;
    final a = d['affix']?.toString() ?? '';
    if (a != '') setAffix(a);
    maxHp = (d['max_hp'] as num?)?.toDouble() ?? maxHp;
    hp = (d['hp'] as num?)?.toDouble() ?? maxHp;
    if (d['tamed'] == true) restoreTamed();
    final hm = (d['home'] as List<dynamic>? ?? const []).map((e) => (e as num).toDouble()).toList();
    if (hm.length == 3) home = Vector3(hm[0], hm[1], hm[2]);
    final tr = d['trades'] as List<dynamic>? ?? const [];
    if (tr.isNotEmpty) trades = [for (final t in tr) TradeOffer.fromJson(t as List<dynamic>)];
    final yaw = (d['yaw'] as num?)?.toDouble() ?? 0.0;
    _face(Vector3(-math.sin(yaw), 0, -math.cos(yaw)));
    syncNode();
  }

  /// `tame` minus the reward: the bonus HP is already in the saved `max_hp`.
  /// The loader puts the mob in `Game.pets` (Godot's "pets" group).
  void restoreTamed() {
    tamed = true;
    _angry = false;
    state = MobState.idle;
    barVisible = true;
  }

  void setPuppetState(Vector3 pos, double yaw, double newHp, double newMax) {
    position = (position - pos).length < 4.0 ? position + (pos - position) * 0.5 : pos;
    _puppetYaw = yaw;
    if (newHp < hp) {
      hurt = 0.25;
      barVisible = true;
      // Stage 32: a puppet feels the hit too; the knockback rides the host's pose.
      _freeze = hitStop;
      _flash = hitFlash;
      _applyOverride(PlayerModel.flashMaterial());
      Sfx.play('hurt_${hurtGroup()}', -8.0);
    }
    hp = newHp;
    maxHp = newMax;
  }
}

/// Stage 26: one villager offer, `take x takeCount -> give x giveCount`; saved
/// as Godot's four-element array.
class TradeOffer {
  const TradeOffer(this.take, this.takeCount, this.give, this.giveCount);
  final String take;
  final int takeCount;
  final String give;
  final int giveCount;

  List<Object> toJson() => [take, takeCount, give, giveCount];

  static TradeOffer fromJson(List<dynamic> a) =>
      TradeOffer(a[0].toString(), (a[1] as num).toInt(), a[2].toString(), (a[3] as num).toInt());

  @override
  String toString() => '$take x$takeCount -> $give x$giveCount';
}

/// One elite affix: what it multiplies, the effect it inflicts and its colour.
class AffixDef {
  const AffixDef({
    this.speed = 1.0,
    this.hp = 1.0,
    this.damage = 1.0,
    this.scale = 1.0,
    this.effect = '',
    required this.r,
    required this.g,
    required this.b,
  });

  final double speed;
  final double hp;
  final double damage;
  final double scale;
  final String effect;
  final double r, g, b;

  Vector3 get color => Vector3(r, g, b);
}
