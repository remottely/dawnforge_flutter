import 'dart:math' as math;

import 'package:flutter_scene/scene.dart' hide Spawner;
import 'package:vector_math/vector_math.dart';

import '../core/ivec3.dart';
import '../core/species.dart';
import '../game/achievements.dart';
import '../game/game.dart';
import '../game/game_state.dart';
import '../game/inventory.dart';
import '../game/sfx.dart';
import '../player/player.dart';
import '../world/voxel_world.dart';
import 'player_model.dart';
import 'remote_player.dart';
import 'target.dart';
import 'voxel_body.dart';
import 'voxel_mesh_builder.dart';

enum MobState { idle, wander, chase, attack, flee, dead }

/// A creature: voxel model by body type, a small state machine, health bar,
/// drops and XP.
class Mob extends VoxelBody {
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
  final int instanceId = _nextId++;
  static int _nextId = 1;

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
    velocity += push * knockback + Vector3(0, 4.0, 0);
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
    if (affix != '') {
      ach.unlock('elite');
      main.spawnDrop(centre(), 'gem_shard', 1 + main.random.nextInt(2));
      main.spawnDrop(centre(), 'magic_dust', 1);
    }
    player.gainXp((species.xp * (1.0 + (mobLevel - 1) * 0.15) * (affix != '' ? 2.5 : 1.0)).toInt());
    main.quests.onKill(species.id);
    for (final e in species.drops.entries) {
      final n = e.value[0] + main.random.nextInt(e.value[1] - e.value[0] + 1);
      if (n > 0) main.spawnDrop(centre(), e.key, n);
    }
    if (isBoss) {
      main.spawnDrop(centre(), 'diamond', 1);
      final loot = main.randomLootWeapon(main.random, 4);
      main.spawnLootDrop(centre(), ItemStack(loot.id, 1, bonus: loot.bonus));
    }
    main.spawnEffect(centre(), Vector3(0.9, 0.3, 0.3), 1.0);
    _deathTimer = 0.0;
  }

  void update(double dt) {
    if (state == MobState.dead) {
      _deathTimer += dt;
      final t = (_deathTimer / 0.3).clamp(0.0, 1.0);
      node.scale = Vector3(lerpd(1.0, 1.2, t), lerpd(1.0, 0.05, t), lerpd(1.0, 1.2, t));
      if (_deathTimer >= 0.3) removed = true;
      return;
    }
    if (puppet) {
      _modelYaw = lerpAngle(_modelYaw, _puppetYaw, dt * 10.0);
      hurt = math.max(hurt - dt, 0.0);
      _applyModel();
      return;
    }
    _age += dt;
    _attackCd = math.max(_attackCd - dt, 0.0);
    _hopCd = math.max(_hopCd - dt, 0.0);
    hurt = math.max(hurt - dt, 0.0);
    _timer -= dt;
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
    _target = _nearestTarget();
    final target = _target!;
    final dist = (position - target.position).length;
    final toPlayer = target.position - position;
    toPlayer.y = 0.0;
    final aggro = species.hostile ? 18.0 : 0.0;
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
    if (inWater && rideInput.length > 0.1) velocity.y = 3.0;
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
        if ((species.hostile || _angry) && dist < aggro && !targetDead) state = MobState.chase;
      case MobState.chase:
        if (targetDead || dist > aggro * 2.2) {
          state = MobState.idle;
          _angry = false;
        }
        _dir = toPlayer.length2 > 0 ? toPlayer.normalized() : Vector3.zero();
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

  void _moveAndAnimate(double dt) {
    var speed = species.speed * speedMult;
    if (state == MobState.wander) speed *= 0.5;
    final hops = species.hops;
    if (inWater) {
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
    } else {
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

  void _face(Vector3 dir) {
    if (dir.length < 0.01) return;
    _modelYaw = lerpAngle(_modelYaw, math.atan2(-dir.x, -dir.z), 0.2);
  }

  void _animate(double dt) {
    final sp = math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z);
    _phase += dt * sp * 2.2;
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
    node.rotation = Quaternion.axisAngle(Vector3(0, 1, 0), _modelYaw);
    final ms = _modelScale * affixScale;
    node.scale = Vector3(ms / math.sqrt(sq), ms * sq, ms / math.sqrt(sq));
    node.position = position + Vector3(_shakeX, 0, 0);
  }

  double modelYaw() => _modelYaw;

  void setPuppetState(Vector3 pos, double yaw, double newHp, double newMax) {
    position = (position - pos).length < 4.0 ? position + (pos - position) * 0.5 : pos;
    _puppetYaw = yaw;
    if (newHp < hp) {
      hurt = 0.25;
      barVisible = true;
    }
    hp = newHp;
    maxHp = newMax;
  }
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
