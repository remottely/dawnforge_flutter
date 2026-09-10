import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/painting.dart' show Offset;
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/items.dart';
import '../core/ivec3.dart';
import '../entities/boat.dart';
import '../entities/mob.dart';
import '../entities/player_model.dart';
import '../entities/target.dart';
import '../entities/voxel_body.dart';
import '../entities/voxel_mesh_builder.dart';
import '../game/game.dart';
import '../game/input.dart';
import '../game/inventory.dart';
import '../game/sfx.dart';
import '../world/voxel_world.dart';

class PlayerClass {
  const PlayerClass(this.name, this.hp, this.stamina, this.mana, this.shirtR, this.shirtG, this.shirtB, this.weapon,
      this.damageMult, this.ability);
  final String name;
  final double hp, stamina, mana;
  final double shirtR, shirtG, shirtB;
  final String weapon;
  final double damageMult;
  final String ability;
  Vector3 get shirt => Vector3(shirtR, shirtG, shirtB);
}

/// A voxel raycast hit.
class RayHit {
  RayHit(this.block, this.normal, this.distance);
  final IVec3 block;
  final IVec3 normal;
  final double distance;
}

/// The hero: third person orbit camera (V toggles first person), sweep body,
/// mine / place / attack, climb, swim, glide, sprint, stats and levelling.
class Player extends VoxelBody implements Target {
  static const double walkSpeed = 4.6;
  static const double sprintSpeed = 7.6;
  static const double sneakSpeed = 2.0;
  static const double swimSpeed = 3.0;
  static const double jumpVelocity = 8.6;
  static const double climbSpeed = 3.2;
  static const double reach = 5.0;
  static const double meleeReach = 3.6;
  static const double eyeHeight = 1.62;
  static const double mouseSensitivity = 0.0022;
  static double sensitivityScale = 1.0;
  static double baseFov = 72.0;

  static const Map<String, PlayerClass> classes = {
    'warrior': PlayerClass('Warrior', 30, 100, 20, 0.72, 0.22, 0.20, 'stone_sword', 1.25, 'Whirlwind'),
    'ranger': PlayerClass('Ranger', 22, 120, 30, 0.20, 0.55, 0.28, 'bow', 1.0, 'Arrow Volley'),
    'mage': PlayerClass('Mage', 18, 80, 100, 0.35, 0.28, 0.75, 'staff', 1.0, 'Fire Nova'),
    'rogue': PlayerClass('Rogue', 24, 140, 30, 0.25, 0.25, 0.30, 'dagger', 1.1, 'Shadow Dash'),
  };

  final Inventory inventory = Inventory();
  int selectedSlot = 0;
  String playerClass = 'warrior';
  double hp = 30.0;
  double maxHp = 30.0;
  double stamina = 100.0;
  double maxStamina = 100.0;
  double mana = 50.0;
  double maxMana = 50.0;
  double hunger = 20.0;
  int xp = 0;
  int level = 1;
  int armor = 0;
  double abilityCooldown = 0.0;
  bool firstPerson = false;
  @override
  bool isDead = false;
  bool gliding = false;
  bool climbing = false;
  Vector3 spawnPoint = Vector3.zero();
  Boat? riding;
  double sleeping = 0.0;

  final PlayerModel model = PlayerModel();
  late Game main;

  IVec3 aimedBlock = IVec3.zero;
  IVec3 aimedNormal = IVec3.zero;
  bool isAiming = false;
  Mob? aimedMob;
  double mineProgress = 0.0;
  IVec3 _mineTarget = const IVec3(999999, 0, 0);

  double yaw = 0.0;
  double pitch = -0.35;
  double _camDistance = 4.8;
  double get camDistance => _camDistance;
  double fov = 72.0;
  late final Node highlight;
  late final Node crack;
  late final UnlitMaterial _crackMat;
  late final PointLight torchLight;
  final Node _torchNode = Node();
  double _attackCooldown = 0.0;
  double _fallStartY = 0.0;
  double _hungerTimer = 0.0;
  double _regenTimer = 0.0;
  double damageFlash = 0.0;
  double _useCooldown = 0.0;
  double _lavaTimer = 0.0;
  double _drownTimer = 0.0;
  Vector3 _lastMoveDir = Vector3(0, 0, -1);
  double _stepTimer = 0.0;
  bool _wasInWater = false;
  bool _sprintHeld = false;

  PlayerClass get classDef => classes[playerClass]!;

  void setupPlayer(VoxelWorld w, Game mainGame, String cls) {
    setup(w, 0.3, 1.75);
    main = mainGame;
    playerClass = cls;
    final c = classDef;
    maxHp = c.hp;
    hp = maxHp;
    maxStamina = c.stamina;
    stamina = maxStamina;
    maxMana = c.mana;
    mana = maxMana;
    fov = baseFov;

    model.build(Vector3(0.92, 0.75, 0.62), c.shirt, Vector3(0.25, 0.30, 0.45), Vector3(0.30, 0.20, 0.12));
    node.add(model.root);

    // Block highlight: the 12 edges of a slightly inflated unit cube.
    const e = 0.003;
    final corners = <Vector3>[
      for (var i = 0; i < 8; i++)
        Vector3(-e + (1 + 2 * e) * (i & 1), -e + (1 + 2 * e) * ((i >> 1) & 1), -e + (1 + 2 * e) * ((i >> 2) & 1)),
    ];
    final segs = <double>[];
    for (var a = 0; a < 8; a++) {
      for (var bit = 0; bit < 3; bit++) {
        final b = a | (1 << bit);
        if (b != a && (a & (1 << bit)) == 0) {
          segs.addAll([corners[a].x, corners[a].y, corners[a].z, corners[b].x, corners[b].y, corners[b].z]);
        }
      }
    }
    highlight = Node(
      mesh: Mesh(
        LineSegmentsGeometry(LineSegmentData(positions: Float32List.fromList(segs)), width: 0.02),
        UnlitMaterial()..baseColorFactor = Vector4(0.05, 0.05, 0.05, 1),
      ),
    )
      ..visible = false
      ..castsShadows = false;

    _crackMat = UnlitMaterial()
      ..baseColorFactor = Vector4(0, 0, 0, 0)
      ..alphaMode = AlphaMode.blend;
    crack = Node(mesh: Mesh(CuboidGeometry(Vector3(1.01, 1.01, 1.01)), _crackMat))
      ..visible = false
      ..castsShadows = false;

    torchLight = PointLight(color: Vector3(1.0, 0.8, 0.5), intensity: 0.0, range: 9.0);
    _torchNode.position = Vector3(0, 1.4, 0);
    _torchNode.addComponent(PointLightComponent(torchLight));
    node.add(_torchNode);
    inventory.listeners.add(_refreshArmor);
    _giveStartingKit();
  }

  void _giveStartingKit() {
    final c = classDef;
    inventory.add(c.weapon, 1);
    inventory.add('wooden_pickaxe', 1);
    inventory.add('wooden_axe', 1);
    inventory.add('apple', 5);
    inventory.add('torch', 8);
    if (playerClass == 'ranger') inventory.add('arrow', 48);
    if (playerClass == 'mage') inventory.add('health_potion', 2);
  }

  void notify(String text) => main.notify(text);

  void setLook(double y, double p) {
    yaw = y;
    pitch = p;
  }

  void setFirstPerson(bool fp) {
    firstPerson = fp;
    model.visible = !fp;
    if (!fp) _camDistance = 4.8;
  }

  String heldItem() => inventory.idAt(selectedSlot);

  int pickUp(String id, int n) {
    final left = inventory.add(id, n);
    if (left < n) {
      notify('+${n - left} ${Items.displayName(id)}');
      Sfx.play('pickup', -8.0);
      main.quests.onPickup(id, n - left);
    }
    return left;
  }

  // --- camera -----------------------------------------------------------------

  Vector3 get forward => Vector3(-math.sin(yaw) * math.cos(pitch), math.sin(pitch), -math.cos(yaw) * math.cos(pitch));
  Vector3 get flatForward => Vector3(-math.sin(yaw), 0, -math.cos(yaw));
  Vector3 get rightVec => Vector3(math.cos(yaw), 0, -math.sin(yaw));
  Vector3 get upVec => Vector3(math.sin(pitch) * math.sin(yaw), math.cos(pitch), math.sin(pitch) * math.cos(yaw));
  Vector3 get backVec => -forward;

  Vector3 get pivotPosition => position + Vector3(0, firstPerson ? eyeHeight : 1.5, 0);

  Vector3 get cameraPosition {
    if (firstPerson) return pivotPosition;
    return pivotPosition + rightVec * 0.55 + upVec * 0.15 + backVec * _camDistance;
  }

  PerspectiveCamera camera() => PerspectiveCamera(
        position: cameraPosition,
        target: cameraPosition + forward,
        up: upVec,
        fovRadiansY: fov * math.pi / 180.0,
        fovNear: 0.05,
        fovFar: 700.0,
      );

  Vector3 aimOrigin() => firstPerson ? cameraPosition : pivotPosition + rightVec * 0.55;
  Vector3 aimDirection() => forward;

  void _updateCamera(double dt) {
    if (firstPerson) return;
    // Pull the camera in when a block sits between it and the head.
    final origin = pivotPosition;
    final shoulder = rightVec * 0.55;
    var wanted = 4.8;
    final free = _rayToSolid(origin + shoulder, backVec, wanted + 0.3);
    if (free >= 0.0) wanted = math.max(free - 0.35, 0.6);
    _camDistance = lerpd(_camDistance, wanted, dt * (wanted < _camDistance ? 18.0 : 6.0));
    model.visible = _camDistance > 1.1;
  }

  double _rayToSolid(Vector3 origin, Vector3 direction, double maxDist) {
    final hit = voxelRaycast(origin, direction, maxDist);
    return hit?.distance ?? -1.0;
  }

  RayHit? voxelRaycast(Vector3 origin, Vector3 direction, double reachDist) {
    var bx = origin.x.floor(), by = origin.y.floor(), bz = origin.z.floor();
    final sx = direction.x > 0.0 ? 1 : -1, sy = direction.y > 0.0 ? 1 : -1, sz = direction.z > 0.0 ? 1 : -1;
    final tdx = direction.x.abs() < 1e-9 ? double.infinity : (1.0 / direction.x).abs();
    final tdy = direction.y.abs() < 1e-9 ? double.infinity : (1.0 / direction.y).abs();
    final tdz = direction.z.abs() < 1e-9 ? double.infinity : (1.0 / direction.z).abs();
    var tmx = _distToBoundary(origin.x, direction.x, bx);
    var tmy = _distToBoundary(origin.y, direction.y, by);
    var tmz = _distToBoundary(origin.z, direction.z, bz);
    var normal = IVec3.zero;
    var travelled = 0.0;
    while (travelled <= reachDist) {
      final id = world.getBlockXYZ(bx, by, bz);
      if (id != Blocks.air && !Blocks.isLiquid(id)) return RayHit(IVec3(bx, by, bz), normal, travelled);
      if (tmx < tmy && tmx < tmz) {
        bx += sx;
        travelled = tmx;
        tmx += tdx;
        normal = IVec3(-sx, 0, 0);
      } else if (tmy < tmz) {
        by += sy;
        travelled = tmy;
        tmy += tdy;
        normal = IVec3(0, -sy, 0);
      } else {
        bz += sz;
        travelled = tmz;
        tmz += tdz;
        normal = IVec3(0, 0, -sz);
      }
    }
    return null;
  }

  double _distToBoundary(double o, double d, int cell) {
    if (d.abs() < 1e-9) return double.infinity;
    return d > 0.0 ? ((cell + 1.0 - o) / d) : ((cell - o) / d);
  }

  void _updateAim() {
    final origin = aimOrigin();
    final dir = aimDirection();
    final hit = voxelRaycast(origin, dir, reach);
    isAiming = hit != null;
    aimedMob = null;
    var mobDist = double.infinity;
    for (final mob in main.mobs) {
      final d = mob.rayDistance(origin, dir);
      if (d >= 0.0 && d < meleeReach && d < mobDist) {
        mobDist = d;
        aimedMob = mob;
      }
    }
    if (hit != null && (aimedMob == null || hit.distance < mobDist)) {
      aimedBlock = hit.block;
      aimedNormal = hit.normal;
      highlight.visible = true;
      highlight.position = aimedBlock.toVector3();
    } else {
      isAiming = false;
      highlight.visible = false;
    }
  }

  // --- the tick --------------------------------------------------------------------

  void _handleOneShots(GameInput input, bool gameplay) {
    if (!gameplay) return;
    final look = input.takeLookDelta();
    if (look != Offset.zero) {
      yaw -= look.dx * mouseSensitivity * sensitivityScale;
      pitch = (pitch - look.dy * mouseSensitivity * sensitivityScale).clamp(-1.45, 1.45);
    }
    final wheel = input.takeWheel();
    if (wheel != 0) selectedSlot = (selectedSlot + wheel + 9) % 9;
    final digit = input.hotbarPressed();
    if (digit >= 0) selectedSlot = digit;
    if (input.justPressed(GameAction.toggleView)) setFirstPerson(!firstPerson);
    if (input.justPressed(GameAction.dropItem)) _dropHeld();
    if (input.justPressed(GameAction.eat)) _eatHeld();
    if (input.justPressed(GameAction.attack)) _attackPressed();
    if (input.justPressed(GameAction.use)) _usePressed();
    if (input.justPressed(GameAction.ability)) _useAbility();
    if (input.justPressed(GameAction.interact)) {
      final m = aimedMob;
      if (m != null && m.species.trader) {
        main.trade(m);
      } else {
        _toggleBoat();
      }
    }
  }

  void physicsProcess(double dt, GameInput input, bool gameplay) {
    if (isDead) return;
    _handleOneShots(input, gameplay);
    _sprintHeld = gameplay && input.down(GameAction.sprint);
    _tickStats(dt);
    _attackCooldown = math.max(_attackCooldown - dt, 0.0);
    _useCooldown = math.max(_useCooldown - dt, 0.0);
    abilityCooldown = math.max(abilityCooldown - dt, 0.0);
    if (sleeping > 0.0) {
      _sleepTick(dt);
      return;
    }
    model.tiltX = lerpd(model.tiltX, 0.0, dt * 8.0);
    model.posY = lerpd(model.posY, 0.0, dt * 8.0);
    if (riding != null) {
      _rideTick(dt, input, gameplay);
      return;
    }

    var inputX = 0.0, inputY = 0.0;
    if (gameplay) {
      if (input.down(GameAction.moveLeft)) inputX -= 1;
      if (input.down(GameAction.moveRight)) inputX += 1;
      if (input.down(GameAction.moveForward)) inputY -= 1;
      if (input.down(GameAction.moveBack)) inputY += 1;
    }
    final fwd = flatForward;
    final right = rightVec;
    var wish = fwd * -inputY + right * inputX;
    if (wish.length > 1.0) wish = wish.normalized();
    final sprinting = gameplay && input.down(GameAction.sprint) && stamina > 1.0 && inputY < 0.0 && !inWater;
    final sneaking = gameplay && input.down(GameAction.sneak);
    var speed = sprinting ? sprintSpeed : (sneaking ? sneakSpeed : walkSpeed);
    if (inWater) speed = swimSpeed;
    if (sprinting) stamina = math.max(stamina - 6.0 * dt, 0.0);

    final jumpHeld = gameplay && input.down(GameAction.jump);
    // Fly mode (F5): no gravity, vertical on jump / sneak.
    if (main.flyMode) {
      velocity.y = (jumpHeld ? 12.0 : 0.0) - (sneaking ? 12.0 : 0.0);
      speed *= 2.5;
      final wishF = wish * speed;
      velocity.x = lerpd(velocity.x, wishF.x, dt * 10.0);
      velocity.z = lerpd(velocity.z, wishF.z, dt * 10.0);
      move(dt);
      _fallStartY = position.y;
      model.animate(dt, 0.0, false, true, false);
      model.setHeld(heldItem());
      _finishTick(dt, input, gameplay, fwd, wish, sprinting);
      return;
    }
    // Climbing (Cube World): push into a wall while holding jump.
    climbing = false;
    if (jumpHeld && wish.length > 0.1 && wallAhead(wish) && !inWater && stamina > 0.5) {
      climbing = true;
      velocity.y = climbSpeed;
      stamina = math.max(stamina - 10.0 * dt, 0.0);
    } else if (_onLadder()) {
      velocity.y = jumpHeld ? climbSpeed : (sneaking ? -climbSpeed : 0.0);
      climbing = jumpHeld;
    } else if (inWater) {
      if (jumpHeld) {
        velocity.y = math.min(velocity.y + 20.0 * dt, 4.0);
      } else {
        applyGravity(dt);
      }
    } else {
      applyGravity(dt);
      if (jumpHeld && onFloor) {
        velocity.y = jumpVelocity;
        _fallStartY = position.y;
      }
    }

    // Gliding: hold G in the air with a glider in the inventory.
    gliding = false;
    if (gameplay && input.down(GameAction.glide) && !onFloor && !inWater && velocity.y < 0.0 && inventory.countOf('glider') > 0) {
      gliding = true;
      velocity.y = math.max(velocity.y, -1.6);
      wish = wish.length < 0.1 ? fwd : wish;
      speed = 11.0;
    }

    final accel = onFloor ? 14.0 : (gliding ? 3.0 : 6.0);
    velocity.x = lerpd(velocity.x, wish.x * speed, dt * accel);
    velocity.z = lerpd(velocity.z, wish.z * speed, dt * accel);

    final wasFloor = onFloor;
    move(dt);
    if (hitWall && wish.length > 0.1 && !climbing && !inWater) tryStepUp();
    // Fall damage.
    if (!wasFloor && onFloor) {
      final fall = _fallStartY - position.y;
      if (fall > 4.0 && !inWater) takeDamage(((fall - 4.0) * 1.2).floorToDouble(), 'fall');
    }
    if (onFloor || gliding || climbing || inWater) {
      _fallStartY = position.y;
    } else if (velocity.y > 0.0) {
      _fallStartY = math.max(_fallStartY, position.y);
    }
    if (inLava) {
      _lavaTimer += dt;
      if (_lavaTimer > 0.4) {
        _lavaTimer = 0.0;
        takeDamage(4.0, 'lava');
      }
    }
    if (headInWater) {
      _drownTimer += dt;
      if (_drownTimer > 8.0) {
        takeDamage(2.0, 'drowning');
        _drownTimer = 6.5;
      }
    } else {
      _drownTimer = 0.0;
    }

    // Face the movement direction (or the camera when aiming/attacking).
    if (wish.length > 0.1) _lastMoveDir = wish.clone();
    var face = _lastMoveDir;
    if (firstPerson || (gameplay && (input.down(GameAction.attack) || input.down(GameAction.use))) || gliding) face = fwd;
    final targetYaw = math.atan2(-face.x, -face.z);
    model.yaw = lerpAngle(model.yaw, targetYaw, dt * 12.0);
    final horizontalSpeed = math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z);
    model.animate(dt, horizontalSpeed, onFloor, gliding, climbing);
    if (onFloor && horizontalSpeed > 1.0) {
      _stepTimer -= dt * horizontalSpeed;
      if (_stepTimer <= 0.0) {
        _stepTimer = 2.4;
        Sfx.play('dig', -18.0, 0.7);
      }
    }
    if (inWater && !_wasInWater) Sfx.play('splash', -8.0);
    _wasInWater = inWater;
    model.setHeld(heldItem());
    _finishTick(dt, input, gameplay, fwd, wish, sprinting);
  }

  void _finishTick(double dt, GameInput input, bool gameplay, Vector3 fwd, Vector3 wish, bool sprinting) {
    final held = heldItem();
    torchLight.intensity = (held == 'torch' || held == 'lamp') ? 10.0 : 0.0;
    fov = lerpd(fov, baseFov + (sprinting ? 8.0 : 0.0), dt * 6.0);
    syncNode();
    _updateCamera(dt);
    _updateAim();
    if (gameplay && input.down(GameAction.attack)) {
      _attackTick(dt);
    } else {
      _resetMining();
    }
    if (gameplay && input.down(GameAction.use) && _useCooldown <= 0.0) _usePressed();
    damageFlash = math.max(damageFlash - dt * 3.0, 0.0);
    world.updateAround(position);
  }

  bool _onLadder() {
    final feet = world.getBlockXYZ(position.x.floor(), (position.y + 0.2).floor(), position.z.floor());
    final mid = world.getBlockXYZ(position.x.floor(), (position.y + 1.0).floor(), position.z.floor());
    return (feet != Blocks.air && Blocks.idOf(feet) == 'ladder') || (mid != Blocks.air && Blocks.idOf(mid) == 'ladder');
  }

  void _refreshArmor() {
    armor = 0;
    for (final s in inventory.slots) {
      if (s == null) continue;
      final d = Items.def(s.id);
      if (d.armor > 0) armor = math.max(armor, d.armor);
    }
  }

  void _tickStats(double dt) {
    _hungerTimer += dt;
    if (_hungerTimer > 1.0) {
      _hungerTimer = 0.0;
      hunger = math.max(hunger - 1.0 / 45.0, 0.0);
    }
    if (hunger <= 0.0) {
      _regenTimer += dt;
      if (_regenTimer > 4.0) {
        _regenTimer = 0.0;
        takeDamage(1.0, 'starving');
      }
    } else if (hp < maxHp && hunger >= 6.0) {
      _regenTimer += dt;
      if (_regenTimer > 3.0) {
        _regenTimer = 0.0;
        hp = math.min(hp + 1.0, maxHp);
      }
    }
    if (!_sprintHeld && !climbing) stamina = math.min(stamina + 14.0 * dt, maxStamina);
    mana = math.min(mana + 2.5 * dt, maxMana);
  }

  // --- actions ----------------------------------------------------------------------

  void _attackPressed() {
    if (_attackCooldown > 0.0) return;
    final item = heldItem();
    final style = weaponStyle();
    if (style == 'bow' || style == 'staff') {
      _rangedFire(item, style, false);
      return;
    }
    if (aimedMob == null && _tryBreakBoat()) return;
    model.swing();
    Sfx.play('swing', -10.0);
    _attackCooldown = style == 'melee_fast' ? 0.28 : 0.5;
    // The camera's aimedMob only decides whether to swing at a boat; the hit
    // itself is a reach check the simulation runs: the host resolves it, a
    // client asks for it.
    final dmg = _meleeDamage(item);
    final followUp = style == 'melee_fast' && main.random.nextDouble() < 0.3 ? dmg * 0.5 : 0.0;
    main.meleeStrike(aimDirection(), dmg, followUp, this);
  }

  void probeStrike() {
    _attackCooldown = 0.0;
    _attackPressed();
  }

  void probeFire(bool secondary) {
    final style = weaponStyle();
    if (style == 'bow' || style == 'staff') _rangedFire(heldItem(), style, secondary);
  }

  String weaponStyle() {
    final item = heldItem();
    return item != '' && Items.kind(item) == ItemKind.weapon ? Items.styleOf(item) : 'melee';
  }

  /// Holding the attack button: ranged weapons keep firing at their own rate
  /// (Cube World's staff spray); everything else mines the aimed block.
  void _attackTick(double dt) {
    final style = weaponStyle();
    if (style == 'bow' || style == 'staff') {
      _resetMining();
      if (_attackCooldown <= 0.0) _rangedFire(heldItem(), style, false);
      return;
    }
    _mineTick(dt);
  }

  double _meleeDamage(String item) {
    var base = 1.0;
    if (item != '') {
      final k = Items.kind(item);
      if (k == ItemKind.weapon || k == ItemKind.tool) base = Items.damageOf(item).toDouble();
    }
    base += inventory.bonusAt(selectedSlot);
    return (base * classDef.damageMult * (1.0 + (level - 1) * 0.08)).roundToDouble();
  }

  static const double staffBoltMana = 4.0;
  static const double staffArcMana = 18.0;
  static const double bowShotStamina = 3.0;
  static const double bowFanStamina = 14.0;

  double _rangedDamage(String item, double mult) =>
      ((Items.damageOf(item) + inventory.bonusAt(selectedSlot)) * mult * classDef.damageMult * (1.0 + (level - 1) * 0.08))
          .roundToDouble();

  Vector3 _rotated(Vector3 v, Vector3 axis, double angle) => Quaternion.axisAngle(axis, angle).rotated(v);

  Vector3 _fanDirection(int index, int count, double totalAngle) {
    final dir = aimDirection();
    if (count <= 1) return dir;
    final t = index / (count - 1) - 0.5;
    final axis = dir.y.abs() < 0.9 ? Vector3(0, 1, 0) : Vector3(1, 0, 0);
    return _rotated(dir, axis, t * totalAngle).normalized();
  }

  Vector3 _muzzle() => aimOrigin() + aimDirection() * 0.8 + Vector3(0, -0.15, 0);

  void _rangedFire(String item, String style, bool secondary) {
    if (style == 'staff') {
      if (secondary) {
        _castArc(item);
      } else {
        _castBolt(item);
      }
    } else {
      if (secondary) {
        _shootFan(item);
      } else {
        _shootArrow(item);
      }
    }
  }

  void _shootArrow(String bow) {
    if (inventory.countOf('arrow') <= 0) {
      notify('No arrows!');
      _attackCooldown = 0.3;
      return;
    }
    if (stamina < bowShotStamina) {
      notify('Too tired to draw');
      _attackCooldown = 0.3;
      return;
    }
    inventory.remove('arrow', 1);
    stamina -= bowShotStamina;
    Sfx.play('shoot', -6.0);
    model.swing();
    _attackCooldown = Items.tierOf(bow) < 3 ? 0.5 : 0.4;
    final dir = _rotated(aimDirection(), Vector3(0, 1, 0), (main.random.nextDouble() - 0.5) * 0.02);
    main.spawnProjectile(_muzzle(), dir * 36.0, _rangedDamage(bow, 1.0), this, 'arrow', 0.05, 5.0);
  }

  /// Fan shot (right button with a bow): three arrows across a 24° fan.
  void _shootFan(String bow) {
    if (inventory.countOf('arrow') < 3) {
      notify('Need 3 arrows');
      _useCooldown = 0.3;
      return;
    }
    if (stamina < bowFanStamina) {
      notify('Too tired to draw');
      _useCooldown = 0.3;
      return;
    }
    inventory.remove('arrow', 3);
    stamina -= bowFanStamina;
    Sfx.play('shoot', -4.0);
    model.swing();
    _attackCooldown = 0.7;
    _useCooldown = 1.4;
    for (var i = 0; i < 3; i++) {
      main.spawnProjectile(_muzzle(), _fanDirection(i, 3, 24.0 * math.pi / 180.0) * 34.0, _rangedDamage(bow, 0.85), this, 'arrow', 0.05, 5.0);
    }
  }

  /// Staff spray (hold the attack button): a fast stream of thick bolts, cheap on mana.
  void _castBolt(String staff) {
    if (mana < staffBoltMana) {
      notify('Not enough mana');
      _attackCooldown = 0.3;
      return;
    }
    mana -= staffBoltMana;
    Sfx.play('bolt', -9.0);
    model.swing();
    _attackCooldown = Items.tierOf(staff) < 3 ? 0.22 : 0.17;
    final rng = main.random;
    var dir = _rotated(aimDirection(), Vector3(0, 1, 0), (rng.nextDouble() - 0.5) * 0.08);
    dir = _rotated(dir, Vector3(1, 0, 0), (rng.nextDouble() - 0.5) * 0.04);
    main.spawnProjectile(_muzzle(), dir * 26.0, _rangedDamage(staff, 0.6), this, 'bolt', 0.35, 3.0);
  }

  /// Arc (right button with a staff): Cube World's cone, as five bolts across 50°.
  void _castArc(String staff) {
    if (mana < staffArcMana) {
      notify('Not enough mana');
      _useCooldown = 0.3;
      return;
    }
    mana -= staffArcMana;
    Sfx.play('bolt', -3.0);
    model.swing();
    _attackCooldown = 0.6;
    _useCooldown = 1.1;
    main.spawnEffect(_muzzle(), Vector3(1, 0.55, 0.2), 1.0);
    for (var i = 0; i < 5; i++) {
      main.spawnProjectile(_muzzle(), _fanDirection(i, 5, 50.0 * math.pi / 180.0) * 22.0, _rangedDamage(staff, 0.9), this, 'bolt', 0.4, 6.0);
    }
  }

  /// Sleeping: the model lies on the bed while the night is skipped.
  void startSleep() {
    sleeping = 2.4;
    velocity = Vector3.zero();
  }

  void _sleepTick(double dt) {
    sleeping -= dt;
    model.tiltX = lerpd(model.tiltX, -1.5, dt * 6.0);
    model.posY = lerpd(model.posY, 0.35, dt * 6.0);
    model.animate(dt, 0.0, true, false, false);
    syncNode();
    _updateCamera(dt);
    if (sleeping <= 0.0) notify('Good morning!');
  }

  void _toggleBoat() {
    final b = riding;
    if (b != null) {
      riding = null;
      b.driver = null;
      b.throttle = 0.0;
      position = b.position + Vector3(-math.sin(yaw + math.pi * 0.5), 0.6, -math.cos(yaw + math.pi * 0.5)) * 1.2;
      velocity = Vector3.zero();
      return;
    }
    Boat? best;
    var bestD = 3.0;
    for (final boat in main.boats) {
      final d = (boat.position - position).length;
      if (boat.driver == null && d < bestD) {
        best = boat;
        bestD = d;
      }
    }
    if (best != null) {
      riding = best;
      best.driver = this;
      notify('Rowing. [F] to get off');
    }
  }

  void _rideTick(double dt, GameInput input, bool gameplay) {
    final boat = riding!;
    var inputX = 0.0, inputY = 0.0;
    if (gameplay) {
      if (input.down(GameAction.moveLeft)) inputX -= 1;
      if (input.down(GameAction.moveRight)) inputX += 1;
      if (input.down(GameAction.moveForward)) inputY -= 1;
      if (input.down(GameAction.moveBack)) inputY += 1;
    }
    boat.throttle = -inputY;
    boat.steer = inputX;
    position = boat.seat();
    velocity = boat.velocity.clone();
    model.animate(dt, 0.0, true, false, false);
    model.yaw = lerpAngle(model.yaw, boat.yaw, dt * 8.0);
    model.setHeld(heldItem());
    syncNode();
    _updateCamera(dt);
    _updateAim();
    if (gameplay && input.down(GameAction.attack) && _attackCooldown <= 0.0) _attackPressed();
    world.updateAround(position);
  }

  bool _tryBreakBoat() {
    for (final b in main.boats) {
      if (b.driver == null && b.rayDistance(aimOrigin(), aimDirection(), 0.2) >= 0.0 && (b.position - position).length < 4.0) {
        main.spawnDrop(b.position + Vector3(0, 0.5, 0), 'boat', 1);
        b.removed = true;
        model.swing();
        Sfx.play('break', -6.0);
        _attackCooldown = 0.4;
        return true;
      }
    }
    return false;
  }

  void _toggleDoor(IVec3 at) {
    var lower = at;
    if (Blocks.idOf(world.getBlock(at + IVec3.down)).startsWith('door_')) lower = at + IVec3.down;
    final id = Blocks.idOf(world.getBlock(lower));
    final flipped = id.endsWith('_open') ? id.substring(0, id.length - 5) : '${id}_open';
    final bid = Blocks.indexOf(flipped);
    if (Blocks.isSolid(bid) && (overlapsBlock(lower) || overlapsBlock(lower + IVec3.up))) return;
    world.setBlock(lower, bid);
    world.setBlock(lower + IVec3.up, bid);
    Sfx.play('place', -8.0);
  }

  bool _placeDoor(IVec3 target) {
    if (!Blocks.isReplaceable(world.getBlock(target + IVec3.up)) || !Blocks.isSolid(world.getBlock(target + IVec3.down))) return false;
    final d = aimDirection();
    final bid = Blocks.indexOf(d.x.abs() > d.z.abs() ? 'door_x' : 'door_z');
    if (overlapsBlock(target) || overlapsBlock(target + IVec3.up)) return false;
    world.setBlock(target, bid);
    world.setBlock(target + IVec3.up, bid);
    return true;
  }

  void _useAbility() {
    if (abilityCooldown > 0.0) {
      notify('${classDef.ability} ready in ${abilityCooldown.round()}s');
      return;
    }
    switch (playerClass) {
      case 'warrior':
        if (stamina < 25.0) {
          notify('Too tired');
          return;
        }
        stamina -= 25.0;
        model.swing();
        final dmg = _meleeDamage(heldItem()) * 1.5;
        for (final b in List.of(main.mobs)) {
          if ((b.position - position).length < 4.0) {
            b.takeDamage(dmg, position, 9.0, this);
            main.spawnDamageNumber(b.centre(), dmg, Vector3(1, 0.5, 0.2));
          }
        }
        main.spawnEffect(centre(), Vector3(1, 0.6, 0.2), 4.0);
        abilityCooldown = 8.0;
      case 'ranger':
        if (inventory.countOf('arrow') < 8) {
          notify('Need 8 arrows');
          return;
        }
        if (stamina < 25.0) {
          notify('Too tired');
          return;
        }
        inventory.remove('arrow', 8);
        stamina -= 25.0;
        model.swing();
        Sfx.play('shoot', -2.0);
        final bow = weaponStyle() == 'bow' ? heldItem() : 'bow';
        for (var i = 0; i < 8; i++) {
          final dir = _rotated(Vector3(0, 0, -1), Vector3(0, 1, 0), i * math.pi * 2 / 8.0);
          main.spawnProjectile(centre() + dir * 0.6, dir * 30.0 + Vector3(0, 2.0, 0), _rangedDamage(bow, 1.2), this, 'arrow', 0.05, 6.0);
        }
        main.spawnEffect(centre(), Vector3(0.6, 0.9, 0.5), 2.0);
        abilityCooldown = 7.0;
      case 'mage':
        if (mana < 30.0) {
          notify('Not enough mana');
          return;
        }
        mana -= 30.0;
        for (final b in List.of(main.mobs)) {
          if ((b.position - position).length < 6.0) {
            final dmg = 8.0 + level * 2;
            b.takeDamage(dmg, position, 7.0, this);
            main.spawnDamageNumber(b.centre(), dmg, Vector3(1, 0.4, 0.1));
          }
        }
        main.spawnEffect(centre(), Vector3(1, 0.35, 0.1), 6.0);
        abilityCooldown = 10.0;
      case 'rogue':
        if (stamina < 20.0) {
          notify('Too tired');
          return;
        }
        stamina -= 20.0;
        final dir = _lastMoveDir.length > 0.1 ? _lastMoveDir.clone() : forward;
        dir.y = 0.0;
        velocity += dir.normalized() * 22.0;
        velocity.y = 3.0;
        main.spawnEffect(centre(), Vector3(0.4, 0.3, 0.7), 2.0);
        abilityCooldown = 3.0;
    }
  }

  void _mineTick(double dt) {
    if (!isAiming || aimedMob != null) {
      _resetMining();
      return;
    }
    if (aimedBlock != _mineTarget) {
      _mineTarget = aimedBlock;
      mineProgress = 0.0;
    }
    final id = world.getBlock(aimedBlock);
    final t = Items.mineTime(heldItem(), id);
    if (t < 0.0) {
      crack.visible = false;
      return;
    }
    mineProgress += dt / t;
    if ((mineProgress * 5.0) % 1.0 < dt / t * 5.0) Sfx.play('dig', -12.0);
    crack.visible = true;
    crack.position = aimedBlock.centre;
    _crackMat.baseColorFactor = Vector4(0, 0, 0, (mineProgress * 0.6).clamp(0.0, 0.6));
    if (mineProgress >= 1.0) {
      _breakBlock(aimedBlock, id);
      _resetMining();
      _attackCooldown = 0.15;
    }
  }

  void _resetMining() {
    mineProgress = 0.0;
    _mineTarget = const IVec3(999999, 0, 0);
    crack.visible = false;
  }

  void _breakBlock(IVec3 b, int id) {
    if (!world.setBlock(b, Blocks.air)) return;
    var drop = Blocks.dropOf(id);
    final held = heldItem();
    if (Blocks.toolOf(id) != ToolType.none && Blocks.minTier(id) > 0) {
      final ok = held != '' && Items.toolOf(held) == Blocks.toolOf(id) && Items.tierOf(held) >= Blocks.minTier(id);
      if (!ok) drop = '';
    }
    final rng = main.random;
    if (Blocks.idOf(id) == 'gravel' && rng.nextDouble() < 0.15) drop = 'flint';
    if (Blocks.idOf(id) == 'oak_leaves' && rng.nextDouble() < 0.06) drop = 'apple';
    if (Blocks.idOf(id) == 'tall_grass') {
      drop = rng.nextDouble() < 0.35 ? 'wheat_seeds' : (rng.nextDouble() < 0.15 ? 'string' : '');
    }
    if (drop != '') main.spawnDrop(b.toVector3() + Vector3(0.5, 0.3, 0.5), drop, 1);
    main.onBlockBroken(b, id);
    // Plants above a removed block fall off.
    final above = world.getBlock(b + IVec3.up);
    if (above != Blocks.air && Blocks.isPlant(above)) world.setBlock(b + IVec3.up, Blocks.air);
  }

  void _usePressed() {
    final item = heldItem();
    final style = weaponStyle();
    if (style == 'bow' || style == 'staff') {
      _rangedFire(item, style, true);
      return;
    }
    final mob = aimedMob;
    if (mob != null && item == 'bone' && mob.species.id == 'wolf' && !mob.tamed) {
      inventory.takeFromSlot(selectedSlot, 1);
      if (main.random.nextDouble() < 0.5) {
        mob.tame(this);
        main.spawnEffect(mob.centre(), Vector3(1, 0.7, 0.9), 1.5);
      } else {
        notify('The wolf sniffs the bone...');
      }
      _useCooldown = 0.5;
      return;
    }
    if (isAiming) {
      final targetId = world.getBlock(aimedBlock);
      final tid = Blocks.idOf(targetId);
      if (tid == 'tnt') {
        main.igniteTnt(aimedBlock);
        _useCooldown = 0.5;
        return;
      }
      if (tid == 'bed') {
        main.sleepInBed(aimedBlock);
        _useCooldown = 0.6;
        return;
      }
      if (tid.startsWith('door_')) {
        _toggleDoor(aimedBlock);
        _useCooldown = 0.35;
        return;
      }
      if (tid == 'enchanting_table') {
        main.enchantHeld();
        _useCooldown = 0.5;
        return;
      }
      if (tid == 'wheat_2') {
        world.setBlock(aimedBlock, Blocks.air);
        final rng = main.random;
        main.spawnDrop(aimedBlock.toVector3() + Vector3(0.5, 0.3, 0.5), 'wheat', 1 + rng.nextInt(3));
        main.spawnDrop(aimedBlock.toVector3() + Vector3(0.5, 0.3, 0.5), 'wheat_seeds', 1 + rng.nextInt(2));
        _useCooldown = 0.3;
        return;
      }
      if (item != '' && Items.toolOf(item) == ToolType.hoe && (tid == 'dirt' || tid == 'grass') && aimedNormal == IVec3.up) {
        world.setBlock(aimedBlock, Blocks.indexOf('farmland'));
        Sfx.play('dig', -8.0);
        _useCooldown = 0.3;
        return;
      }
      if (item == 'wheat_seeds' && tid == 'farmland' && aimedNormal == IVec3.up && world.getBlock(aimedBlock + IVec3.up) == Blocks.air) {
        world.setBlock(aimedBlock + IVec3.up, Blocks.indexOf('wheat_0'));
        main.plantCrop(aimedBlock + IVec3.up);
        inventory.takeFromSlot(selectedSlot, 1);
        Sfx.play('place', -10.0);
        _useCooldown = 0.3;
        return;
      }
      if (tid == 'crafting_table' || tid == 'furnace' || tid == 'chest') {
        main.openStation(tid, aimedBlock);
        _useCooldown = 0.4;
        return;
      }
    }
    if (item == '') return;
    if (Items.kind(item) == ItemKind.food) {
      _eatHeld();
      _useCooldown = 0.5;
      return;
    }
    if (item == 'boat') {
      _useCooldown = 0.5;
      final spot = aimOrigin() + aimDirection() * 3.0;
      final cell = IVec3.floor(spot);
      for (var dy = 0; dy < 3; dy++) {
        final c = cell + IVec3(0, -dy, 0);
        if (world.isLiquid(c)) {
          main.spawnBoat(c.toVector3() + Vector3(0.5, 0.9, 0.5), yaw);
          inventory.takeFromSlot(selectedSlot, 1);
          return;
        }
      }
      notify('Boats go on water');
      return;
    }
    if (Items.isBlock(item) && isAiming) {
      final target = aimedBlock + aimedNormal;
      final current = world.getBlock(target);
      if (!Blocks.isReplaceable(current)) return;
      var bid = Items.blockOf(item);
      if (item == 'torch' && aimedNormal.y == 0 && !Blocks.isSolid(world.getBlock(target + IVec3.down))) {
        bid = Blocks.indexOf('wall_torch');
      }
      if (item == 'door') {
        if (_placeDoor(target)) {
          inventory.takeFromSlot(selectedSlot, 1);
          model.swing();
          Sfx.play('place', -10.0);
          _useCooldown = 0.3;
        }
        return;
      }
      if (Blocks.isSolid(bid) && overlapsBlock(target)) return;
      for (final mob in main.mobs) {
        if (Blocks.isSolid(bid) && mob.overlapsBlock(target)) return;
      }
      if (Blocks.isPlant(bid) && !Blocks.isSolid(world.getBlock(target + IVec3.down))) return;
      if (world.setBlock(target, bid)) {
        inventory.takeFromSlot(selectedSlot, 1);
        model.swing();
        main.onBlockPlaced(target, bid);
        _useCooldown = 0.22;
      }
    }
  }

  void _eatHeld() {
    final item = heldItem();
    if (item == '' || Items.kind(item) != ItemKind.food) return;
    final d = Items.def(item);
    if (hunger >= 20.0 && d.heal <= 0.0) {
      notify('Not hungry');
      return;
    }
    inventory.takeFromSlot(selectedSlot, 1);
    hunger = math.min(hunger + d.hunger, 20.0);
    hp = (hp + d.heal).clamp(1.0, maxHp);
    Sfx.play('eat', -6.0);
    notify('Ate ${d.name}');
  }

  void _dropHeld() {
    final stack = inventory.takeFromSlot(selectedSlot, 1);
    if (stack == null) return;
    final dir = forward;
    main.spawnDrop(position + Vector3(0, 1.4, 0) + dir * 0.6, stack.id, stack.count, dir * 6.0 + Vector3(0, 2, 0), 1.5);
  }

  @override
  void takeDamage(double amount, String source, [Vector3? from]) {
    if (isDead || amount <= 0.0) return;
    final reduced = math.max(amount - armor * 0.4, amount * 0.35);
    hp -= reduced;
    damageFlash = 1.0;
    Sfx.play('hurt', -3.0);
    main.spawnDamageNumber(centre() + Vector3(0, 0.6, 0), reduced, Vector3(1, 0.3, 0.3));
    if (from != null) {
      final push = position - from;
      push.y = 0.0;
      if (push.length2 > 0) push.normalize();
      velocity += push * 5.0 + Vector3(0, 3.5, 0);
    }
    if (hp <= 0.0) {
      hp = 0.0;
      isDead = true;
      main.onPlayerDied();
    }
  }

  void gainXp(int amount) {
    xp += amount;
    var need = xpToNext();
    while (xp >= need) {
      xp -= need;
      level += 1;
      maxHp += 3.0;
      hp = maxHp;
      maxStamina += 5.0;
      maxMana += 5.0;
      notify('Level $level!');
      Sfx.play('levelup');
      main.quests.onLevel(level);
      main.spawnEffect(centre(), Vector3(1, 0.9, 0.3), 3.0);
      need = xpToNext();
    }
  }

  int xpToNext() => (40.0 * math.pow(level.toDouble(), 1.45)).toInt();

  void respawn() {
    isDead = false;
    hp = maxHp;
    hunger = 20.0;
    stamina = maxStamina;
    mana = maxMana;
    velocity = Vector3.zero();
    position = spawnPoint.clone();
    syncNode();
  }

  Map<String, Object> toJson() => {
        'pos': [position.x, position.y, position.z],
        'yaw': yaw,
        'pitch': pitch,
        'class': playerClass,
        'hp': hp,
        'max_hp': maxHp,
        'stamina': stamina,
        'max_stamina': maxStamina,
        'mana': mana,
        'max_mana': maxMana,
        'hunger': hunger,
        'xp': xp,
        'level': level,
        'inventory': inventory.toJson(),
        'slot': selectedSlot,
        'first_person': firstPerson,
        'spawn': [spawnPoint.x, spawnPoint.y, spawnPoint.z],
      };

  void fromJson(Map<String, dynamic> d) {
    final p = (d['pos'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    position = Vector3(p[0], p[1], p[2]);
    yaw = (d['yaw'] as num?)?.toDouble() ?? 0.0;
    pitch = (d['pitch'] as num?)?.toDouble() ?? -0.3;
    hp = (d['hp'] as num?)?.toDouble() ?? maxHp;
    maxHp = (d['max_hp'] as num?)?.toDouble() ?? maxHp;
    stamina = (d['stamina'] as num?)?.toDouble() ?? maxStamina;
    maxStamina = (d['max_stamina'] as num?)?.toDouble() ?? maxStamina;
    mana = (d['mana'] as num?)?.toDouble() ?? maxMana;
    maxMana = (d['max_mana'] as num?)?.toDouble() ?? maxMana;
    hunger = (d['hunger'] as num?)?.toDouble() ?? 20.0;
    xp = (d['xp'] as num?)?.toInt() ?? 0;
    level = (d['level'] as num?)?.toInt() ?? 1;
    inventory.fromJson(d['inventory'] as List<dynamic>? ?? const []);
    selectedSlot = (d['slot'] as num?)?.toInt() ?? 0;
    setFirstPerson(d['first_person'] == true);
    final s = (d['spawn'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? p;
    spawnPoint = Vector3(s[0], s[1], s[2]);
    syncNode();
  }
}
