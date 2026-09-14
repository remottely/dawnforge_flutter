import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/painting.dart' show Offset;
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/items.dart';
import '../core/ivec3.dart';
import '../entities/boat.dart';
import '../entities/bobber.dart';
import '../entities/mob.dart';
import '../entities/player_model.dart';
import '../entities/target.dart';
import '../entities/voxel_body.dart';
import '../entities/voxel_mesh_builder.dart';
import '../game/achievements.dart';
import '../game/effects.dart';
import '../game/game.dart';

import '../game/input.dart';
import '../game/inventory.dart';
import '../game/net.dart';
import '../game/sfx.dart';
import '../game/talents.dart';
import '../world/voxel_world.dart';

class PlayerClass {
  const PlayerClass(this.name, this.hp, this.stamina, this.mana, this.shirtR, this.shirtG, this.shirtB, this.weapon,
      this.damageMult, this.ability, this.ability2, this.mana2);
  final String name;
  final double hp, stamina, mana;
  final double shirtR, shirtG, shirtB;
  final String weapon;
  final double damageMult;
  final String ability;

  /// Stage 23: the Q ability and its mana price (through `manaCost`).
  final String ability2;
  final double mana2;
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
    'warrior': PlayerClass('Warrior', 30, 100, 20, 0.72, 0.22, 0.20, 'stone_sword', 1.25, 'Whirlwind', 'Shield Bash', 10.0),
    'ranger': PlayerClass('Ranger', 22, 120, 30, 0.20, 0.55, 0.28, 'bow', 1.0, 'Arrow Volley', 'Volley', 10.0),
    'mage': PlayerClass('Mage', 18, 80, 100, 0.35, 0.28, 0.75, 'staff', 1.0, 'Fire Nova', 'Frost Nova', 25.0),
    'rogue': PlayerClass('Rogue', 24, 140, 30, 0.25, 0.25, 0.30, 'dagger', 1.1, 'Shadow Dash', 'Smoke Bomb', 15.0),
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

  /// Stage 23: the Q ability.
  double ability2Cooldown = 0.0;
  bool firstPerson = false;
  @override
  bool isDead = false;
  bool gliding = false;
  bool climbing = false;
  Vector3 spawnPoint = Vector3.zero();
  Boat? riding;
  Mob? mount;
  Bobber? bobber;
  double sleeping = 0.0;
  final StatusEffects effects = StatusEffects();
  int talentPoints = 0;
  final Map<String, int> talents = {};
  double _invulnerable = 0.0;
  double _dodge = 0.0;
  Vector3 _dodgeDir = Vector3(0, 0, -1);
  double _dodgeCd = 0.0;

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
    inventory.listeners.add(() => bagDirty = true);
    _giveStartingKit();
  }

  /// Stage 25: a client re-declares its bag to the host when set.
  bool bagDirty = false;

  /// Probe (stage 25): every slot full, except one that leaves room for exactly
  /// one more [id].
  void probeFillBag(String id) {
    for (var i = 0; i < Inventory.size; i++) {
      inventory.setSlot(i, ItemStack('stone', Items.stackSize('stone')));
    }
    inventory.setSlot(Inventory.size - 1, ItemStack(id, Items.stackSize(id) - 1));
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
      if (id == 'diamond') Achievements.instance.unlock('diamonds');
    }
    return left;
  }

  // --- camera -----------------------------------------------------------------

  Vector3 get forward => Vector3(-math.sin(yaw) * math.cos(pitch), math.sin(pitch), -math.cos(yaw) * math.cos(pitch));
  Vector3 get flatForward => Vector3(-math.sin(yaw), 0, -math.cos(yaw));
  // flutter_scene builds its view basis as `up x forward`, so its screen-right
  // is the mirror of the right-handed right vector the Godot POC uses: at yaw 0
  // world +X projects to the left half of the view. Every lateral quantity here
  // is that mirrored basis, or strafing and the shoulder offset come out flipped.
  Vector3 get rightVec => Vector3(-math.cos(yaw), 0, math.sin(yaw));
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
      yaw += look.dx * mouseSensitivity * sensitivityScale;
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
    if (input.justPressed(GameAction.ability2)) _useAbility2();
    if (input.justPressed(GameAction.dodge)) _dodgePressed();
    if (input.justPressed(GameAction.interact)) {
      final m = aimedMob;
      if (m != null && m.species.trader) {
        main.trade(m);
      } else {
        _interactPressed();
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
    ability2Cooldown = math.max(ability2Cooldown - dt, 0.0);
    if (sleeping > 0.0) {
      _sleepTick(dt);
      return;
    }
    model.tiltX = lerpd(model.tiltX, 0.0, dt * 8.0);
    model.posY = lerpd(model.posY, 0.0, dt * 8.0);
    _tendBobber();
    bobber?.update(dt);
    if (riding != null) {
      _rideTick(dt, input, gameplay);
      return;
    }
    if (mount != null) {
      _mountTick(dt, input, gameplay);
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
    if (_probeWalk.length2 > 0.0) wish = _probeWalk.clone();
    if (wish.length > 1.0) wish = wish.normalized();
    final sprinting = gameplay && input.down(GameAction.sprint) && stamina > 1.0 && inputY < 0.0 && !inWater;
    final sneaking = gameplay && input.down(GameAction.sneak);
    var speed = sprinting ? sprintSpeed : (sneaking ? sneakSpeed : walkSpeed);
    if (inWater) speed = swimSpeed;
    speed *= effects.speedMultiplier() * (1.0 + 0.05 * talentRank('swiftness'));
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
      Achievements.instance.unlock('glider');
      velocity.y = math.max(velocity.y, -1.6);
      wish = wish.length < 0.1 ? fwd : wish;
      speed = 11.0;
    }

    // Dodge roll: a short burst with invulnerability, the model tumbles forward.
    if (_dodge > 0.0) {
      _dodge -= dt;
      wish = _dodgeDir;
      speed = 13.0;
      model.tiltX = -math.pi * 2.0 * (1.0 - _dodge / dodgeTime).clamp(0.0, 1.0);
    }
    final accel = _dodge > 0.0 ? 40.0 : (onFloor ? 14.0 : (gliding ? 3.0 : 6.0));
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
      effects.apply('burning', 3.0);
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
    if (gameplay && input.down(GameAction.use) && _useCooldown <= 0.0 && _useRepeats()) _usePressed();
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
    if (!_sprintHeld && !climbing) {
      stamina = math.min(stamina + 14.0 * (1.0 + 0.25 * talentRank('endurance')) * dt, maxStamina);
    }
    mana = math.min(mana + 2.5 * (1.0 + 0.25 * talentRank('arcana')) * dt, maxMana);
    _invulnerable = math.max(_invulnerable - dt, 0.0);
    _dodgeCd = math.max(_dodgeCd - dt, 0.0);
    if (inWater && effects.has('burning')) effects.clear('burning');
    for (final ev in effects.tick(dt)) {
      if (ev.damage > 0.0) {
        takeDamage(ev.damage, ev.id);
      } else if (hp < maxHp) {
        hp = math.min(hp + ev.heal, maxHp);
        main.spawnDamageNumber(centre() + Vector3(0, 0.6, 0), ev.heal, StatusEffects.def(ev.id).color);
      }
    }
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
    _wearHeld();
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
    return (base * classDef.damageMult * (1.0 + (level - 1) * 0.08) * damageMultiplier()).roundToDouble();
  }

  static const double staffBoltMana = 4.0;
  static const double staffArcMana = 18.0;
  static const double bowShotStamina = 3.0;
  static const double bowFanStamina = 14.0;

  double _rangedDamage(String item, double mult) =>
      ((Items.damageOf(item) + inventory.bonusAt(selectedSlot)) * mult * classDef.damageMult * (1.0 + (level - 1) * 0.08) * damageMultiplier() * (1.0 + 0.12 * talentRank('eagle_eye')))
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
    _wearHeld();
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
    _wearHeld();
  }

  /// Staff spray (hold the attack button): a fast stream of thick bolts, cheap on mana.
  void _castBolt(String staff) {
    if (mana < manaCost(staffBoltMana)) {
      notify('Not enough mana');
      _attackCooldown = 0.3;
      return;
    }
    mana -= manaCost(staffBoltMana);
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
    if (mana < manaCost(staffArcMana)) {
      notify('Not enough mana');
      _useCooldown = 0.3;
      return;
    }
    mana -= manaCost(staffArcMana);
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
    if (riding != null) {
      leaveBoat();
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
    if (best != null) boardBoat(best);
  }

  /// Sit in [b]. A replica (stage 25) is the host's boat: the host is asked to
  /// seat this peer's puppet and the steer input rides in the pose; the seat
  /// follows the streamed pose.
  void boardBoat(Boat b) {
    riding = b;
    Achievements.instance.unlock('sailor');
    if (b.replica) {
      Net.instance.requestBoard(b.netId);
    } else {
      b.driver = this;
    }
    notify('Rowing. [F] to get off');
  }

  void leaveBoat() {
    final b = riding;
    if (b == null) return;
    riding = null;
    if (b.replica) {
      Net.instance.requestUnboard();
    } else {
      b.driver = null;
    }
    b.throttle = 0.0;
    b.steer = 0.0;
    position = b.position - rightVec * 1.2 + Vector3(0, 0.6, 0);
    velocity = Vector3.zero();
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
    // A probe rows forward through probeWalk, as Godot's headless probe does.
    if (_probeWalk.length2 > 0.0) {
      inputX = 0.0;
      inputY = -1.0;
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
        if (b.replica) {
          // The host drops the item and frees it (stage 25).
          Net.instance.requestBreakBoat(b.netId);
        } else {
          main.spawnDrop(b.position + Vector3(0, 0.5, 0), 'boat', 1);
          b.removed = true;
        }
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
        abilityCooldown = 8.0 * (1.0 - 0.2 * talentRank('rage'));
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

  /// Stage 23: one use off the held tool or weapon; at zero it breaks and the
  /// slot empties.
  void _wearHeld() {
    final item = heldItem();
    if (item == '' || Items.durabilityOf(item) <= 0) return;
    if (inventory.wear(selectedSlot)) {
      Sfx.play('break', -2.0, 0.6);
      notify('Your ${Items.displayName(item)} broke!');
    }
  }

  /// Stage 23: the Q ability, one per class, paid in mana (`mana2`, through
  /// `manaCost`).
  void _useAbility2() {
    final c = classDef;
    if (ability2Cooldown > 0.0) {
      notify('${c.ability2} ready in ${ability2Cooldown.round()}s');
      return;
    }
    final cost = manaCost(c.mana2);
    if (mana < cost) {
      notify('Not enough mana');
      return;
    }
    var fwd = aimDirection().clone()..y = 0.0;
    if (fwd.length < 0.1) {
      fwd = Vector3(-math.sin(yaw), 0, -math.cos(yaw));
    }
    fwd.normalize();
    switch (playerClass) {
      case 'warrior':
        // Shield Bash: a 3 m lunge; every mob in the 3.5 m half-space ahead is
        // struck and stunned.
        velocity += fwd * 12.0;
        velocity.y = math.max(velocity.y, 2.0);
        _lastMoveDir = fwd.clone();
        model.swing();
        final dmg = _meleeDamage(heldItem()) * 0.8;
        for (final b in List.of(main.mobs)) {
          final to = b.position - position;
          if (to.length < 3.5 && to.normalized().dot(fwd) > 0.3) {
            b.takeDamage(dmg, position, 6.0, this);
            b.stun(2.0);
            main.spawnDamageNumber(b.centre(), dmg, Vector3(1, 0.9, 0.4));
          }
        }
        main.spawnEffect(centre() + fwd * 1.5, Vector3(1, 0.9, 0.4), 2.0);
        Sfx.play('hit', -2.0, 0.8);
        ability2Cooldown = 6.0;
      case 'ranger':
        // Volley: five arrows across a 40 degree fan.
        if (inventory.countOf('arrow') < 5) {
          notify('Need 5 arrows');
          return;
        }
        inventory.remove('arrow', 5);
        model.swing();
        Sfx.play('shoot', -2.0);
        final bow = weaponStyle() == 'bow' ? heldItem() : 'bow';
        for (var i = 0; i < 5; i++) {
          main.spawnProjectile(_muzzle(), _fanDirection(i, 5, 40.0 * math.pi / 180.0) * 34.0, _rangedDamage(bow, 0.9), this, 'arrow', 0.05, 5.0);
        }
        ability2Cooldown = 5.0;
      case 'mage':
        // Frost Nova: every mob within 5 m is slowed for 4 s and takes 4.
        for (final b in List.of(main.mobs)) {
          if ((b.position - position).length < 5.0) {
            b.takeDamage(4.0, position, 3.0, this);
            b.slow(4.0);
            main.spawnDamageNumber(b.centre(), 4.0, Vector3(0.5, 0.7, 1.0));
          }
        }
        main.spawnEffect(centre(), Vector3(0.5, 0.75, 1.0), 5.0);
        Sfx.play('bolt', -4.0, 1.4);
        ability2Cooldown = 9.0;
      case 'rogue':
        // Smoke Bomb: 3 s untouchable and swift; every mob within 12 m forgets
        // the player.
        _invulnerable = 3.0;
        effects.apply('speed', 3.0);
        for (final b in main.mobs) {
          if ((b.position - position).length < 12.0) b.loseTarget(3.0);
        }
        main.spawnEffect(centre(), Vector3(0.3, 0.3, 0.35), 4.0);
        Sfx.play('splash', -6.0, 0.6);
        ability2Cooldown = 12.0;
    }
    mana -= cost;
  }

  /// Probes: fire the Q ability with its cooldown cleared.
  void probeAbility2() {
    ability2Cooldown = 0.0;
    _useAbility2();
  }

  /// Probes: switch class in place (stats to the class maximums, its weapon in
  /// hand).
  void probeSetClass(String cls) {
    final c = classes[cls];
    if (c == null) throw ArgumentError('unknown class $cls');
    playerClass = cls;
    maxHp = c.hp;
    hp = maxHp;
    maxStamina = c.stamina;
    stamina = maxStamina;
    maxMana = c.mana;
    mana = maxMana;
    if (inventory.find(c.weapon) < 0) inventory.add(c.weapon, 1);
    selectedSlot = inventory.find(c.weapon);
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
    var t = Items.mineTime(heldItem(), id);
    if (t > 0.0) t /= effects.mineMultiplier();
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
    if (Items.isLeaves(id) && held != '' && Items.toolOf(held) == ToolType.shears) drop = Blocks.idOf(id);
    if (drop != '') main.spawnDrop(b.toVector3() + Vector3(0.5, 0.3, 0.5), drop, 1);
    main.onBlockBroken(b, id);
    if (held != '' && Items.kind(held) == ItemKind.tool && Blocks.hardness(id) > 0.0) _wearHeld();
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
    if (item == 'fishing_rod') {
      _useCooldown = 0.4;
      final b = bobber;
      if (b != null) {
        if (b.isBiting) {
          catchFish();
        } else {
          reelIn(true);
        }
        return;
      }
      final water = liquidRaycast(aimOrigin(), aimDirection(), fishingReach);
      if (water == null) {
        notify('Cast at water');
      } else {
        castFishing(water);
      }
      return;
    }
    final mob = aimedMob;
    if (mob != null && item != '') {
      if (!mob.tamed && mob.species.tameWith.contains(item)) {
        inventory.takeFromSlot(selectedSlot, 1);
        if (main.random.nextDouble() < mob.species.tameChance) {
          mob.tame(this);
          main.spawnEffect(mob.centre(), Vector3(1, 0.7, 0.9), 1.5);
        } else {
          notify('The ${mob.species.name.toLowerCase()} sniffs the ${Items.displayName(item).toLowerCase()}...');
        }
        _useCooldown = 0.5;
        return;
      }
      if (item == 'shears' && mob.species.id == 'sheep' && !mob.sheared) {
        shearMob(mob);
        _useCooldown = 0.4;
        return;
      }
      if (item == 'bucket' && mob.species.id == 'cow') {
        inventory.setSlot(selectedSlot, ItemStack('milk_bucket', 1));
        notify('Milked the cow');
        Sfx.play('splash', -12.0, 1.3);
        _useCooldown = 0.5;
        return;
      }
    }
    if (item == 'bucket') {
      final cell = liquidRaycast(aimOrigin(), aimDirection(), reach);
      if (cell != null && scoopLiquid(cell)) {
        _useCooldown = 0.4;
        return;
      }
    }
    if (item != '' && Items.liquidOf(item) != '' && isAiming) {
      if (pourLiquid(aimedBlock + aimedNormal)) _useCooldown = 0.4;
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
      if (tid == 'waypoint') {
        main.openJournal(3);
        _useCooldown = 0.5;
        return;
      }
      if (tid == 'crafting_table' || tid == 'furnace' || tid == 'chest' || tid == 'brewing_stand') {
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
      if (Blocks.isStairs(bid)) {
        final f = flatForward;
        bid = Blocks.stairsFacing(bid, f.x, f.z);
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
    if (d.effect != '') {
      inventory.takeFromSlot(selectedSlot, 1);
      drink(d.effect, d.seconds);
      if (d.heal > 0.0) hp = (hp + d.heal).clamp(1.0, maxHp);
      if (d.container != '' && inventory.add(d.container, 1) > 0) {
        main.spawnDrop(centre(), d.container, 1);
      }
      notify('Drank ${d.name}');
      Sfx.play('eat', -6.0);
      Achievements.instance.unlock('brewer');
      return;
    }
    if (hunger >= 20.0 && d.heal <= 0.0) {
      notify('Not hungry');
      return;
    }
    inventory.takeFromSlot(selectedSlot, 1);
    hunger = math.min(hunger + d.hunger, 20.0);
    hp = (hp + d.heal).clamp(1.0, maxHp);
    if (d.hunger >= 5) effects.apply('well_fed', 20.0);
    Sfx.play('eat', -6.0);
    notify('Ate ${d.name}');
  }

  void _dropHeld() {
    final stack = inventory.takeFromSlot(selectedSlot, 1);
    if (stack == null) return;
    final dir = forward;
    main.spawnDrop(position + Vector3(0, 1.4, 0) + dir * 0.6, stack.id, stack.count, dir * 6.0 + Vector3(0, 2, 0), 1.5);
  }

  /// The local player is never a peer's puppet.
  @override
  int get peerId => 0;

  @override
  void takeDamage(double amount, String source, [Vector3? from]) {
    if (isDead || amount <= 0.0) return;
    // An effect's own tick always lands: dodging out of poison would be free.
    final isTick = StatusEffects.defs.containsKey(source);
    if (_invulnerable > 0.0 && !isTick && source != 'starving') return;
    final totalArmor = armor + effects.armorBonus() + talentRank('toughness');
    final reduced = isTick ? amount : math.max(amount - totalArmor * 0.4, amount * 0.35);
    hp -= reduced;
    damageFlash = 1.0;
    Sfx.play('hurt', -3.0);
    main.spawnDamageNumber(centre() + Vector3(0, 0.6, 0), reduced,
        isTick ? StatusEffects.def(source).color : Vector3(1, 0.3, 0.3));
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
      talentPoints += 1;
      notify('Level $level! Talent point earned (J)');
      final ach = Achievements.instance;
      if (level >= 5) ach.unlock('level_5');
      if (level >= 10) ach.unlock('level_10');
      Sfx.play('levelup');
      main.quests.onLevel(level);
      main.spawnEffect(centre(), Vector3(1, 0.9, 0.3), 3.0);
      need = xpToNext();
    }
  }

  int xpToNext() => (40.0 * math.pow(level.toDouble(), 1.45)).toInt();

  void respawn() {
    isDead = false;
    if (mount != null) dismount();
    hp = maxHp;
    hunger = 20.0;
    stamina = maxStamina;
    mana = maxMana;
    effects.rows.clear();
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
        'effects': effects.toJson(),
        'talent_points': talentPoints,
        'talents': talents,
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
    effects.fromJson(d['effects'] as Map<String, dynamic>? ?? const {});
    talentPoints = (d['talent_points'] as num?)?.toInt() ?? 0;
    talents.clear();
    for (final e in (d['talents'] as Map<String, dynamic>? ?? const {}).entries) {
      talents[e.key] = (e.value as num).toInt();
    }
    syncNode();
  }

  // --- stage 20: mounts, fishing, shears, buckets -----------------------------------

  static const double fishingReach = 8.0;
  static const double mountReach = 3.5;
  static final Vector3 saddleOffset = Vector3(0, 0.6, 0);

  /// F: leave what is ridden, else mount the tamed horse in front, else board
  /// or leave a boat.
  void _interactPressed() {
    if (mount != null) {
      dismount();
      return;
    }
    if (riding != null) {
      _toggleBoat();
      return;
    }
    final horse = _findMount();
    if (horse != null) {
      mountHorse(horse);
      return;
    }
    final m = aimedMob;
    if (m != null && m.isMount && !m.tamed) {
      notify('This ${m.species.name.toLowerCase()} is wild. Tame it with wheat or an apple');
      return;
    }
    _toggleBoat();
  }

  /// The nearest tamed, unridden mount the camera ray touches within
  /// [mountReach].
  Mob? _findMount() {
    Mob? best;
    var bestD = mountReach;
    for (final m in main.pets) {
      if (!m.isMount || !m.tamed || m.ridden || m.isDead) continue;
      final d = (m.position - position).length;
      if (d < bestD && m.rayDistance(aimOrigin(), aimDirection(), 0.4) >= 0.0) {
        best = m;
        bestD = d;
      }
    }
    return best;
  }

  void mountHorse(Mob h) {
    if (!h.tamed || !h.isMount) throw StateError('only a tamed mount can be ridden');
    if (mount != null || riding != null) return;
    mount = h;
    h.ridden = true;
    h.riddenBy = 1;
    h.rideInput = Vector3.zero();
    velocity = Vector3.zero();
    // The host's horse carries the rider (stage 21b).
    if (Net.instance.isClient) Net.instance.requestMount(h.netId);
    _resetMining();
    notify('Riding. [F] to get off');
    Achievements.instance.unlock('rider');
  }

  void dismount() {
    final h = mount;
    if (h == null) return;
    mount = null;
    h.ridden = false;
    h.riddenBy = 0;
    h.rideInput = Vector3.zero();
    h.rideSprint = false;
    if (Net.instance.isClient) Net.instance.requestDismount();
    if (!h.removed) {
      position = h.position + Vector3(-math.sin(yaw + math.pi * 0.5), 0.3, -math.cos(yaw + math.pi * 0.5)) * 1.2;
    }
    velocity = Vector3.zero();
    _fallStartY = position.y;
  }

  bool isMounted() => mount != null;

  /// Mounted: the rider's wish goes to the horse, the rider sits on its back
  /// and the camera follows.
  void _mountTick(double dt, GameInput input, bool gameplay) {
    final h = mount!;
    if (h.removed || h.isDead) {
      dismount();
      return;
    }
    var inputX = 0.0, inputY = 0.0;
    if (gameplay) {
      if (input.down(GameAction.moveLeft)) inputX -= 1;
      if (input.down(GameAction.moveRight)) inputX += 1;
      if (input.down(GameAction.moveForward)) inputY -= 1;
      if (input.down(GameAction.moveBack)) inputY += 1;
    }
    var wish = flatForward * -inputY + rightVec * inputX;
    if (wish.length > 1.0) wish = wish.normalized();
    h.rideInput = wish;
    h.rideSprint = gameplay && input.down(GameAction.sprint) && inputY < 0.0;
    if (gameplay && input.down(GameAction.jump)) h.rideJump = true;
    position = h.centre() + saddleOffset;
    velocity = h.velocity.clone();
    _fallStartY = position.y;
    model.animate(dt, 0.0, true, false, false);
    model.yaw = lerpAngle(model.yaw, h.modelYaw(), dt * 8.0);
    model.setHeld(heldItem());
    fov = lerpd(fov, baseFov + (h.rideSprint ? 8.0 : 0.0), dt * 6.0);
    syncNode();
    _updateCamera(dt);
    _updateAim();
    if (gameplay && input.down(GameAction.attack) && _attackCooldown <= 0.0) _attackPressed();
    if (gameplay && input.down(GameAction.use) && _useCooldown <= 0.0 && _useRepeats()) _usePressed();
    damageFlash = math.max(damageFlash - dt * 3.0, 0.0);
    world.updateAround(position);
  }

  /// Holding the use button repeats a placement; the rod and the buckets act
  /// once per press.
  bool _useRepeats() {
    final item = heldItem();
    return item != 'fishing_rod' && item != 'bucket' && (item == '' || Items.liquidOf(item) == '');
  }

  /// The first liquid cell along a ray, stopping at the first solid; null when
  /// there is none.
  IVec3? liquidRaycast(Vector3 origin, Vector3 direction, double reachDist) {
    var block = IVec3.floor(origin);
    final stepX = direction.x > 0 ? 1 : -1, stepY = direction.y > 0 ? 1 : -1, stepZ = direction.z > 0 ? 1 : -1;
    final tdx = direction.x == 0 ? double.infinity : (1.0 / direction.x).abs();
    final tdy = direction.y == 0 ? double.infinity : (1.0 / direction.y).abs();
    final tdz = direction.z == 0 ? double.infinity : (1.0 / direction.z).abs();
    var tmx = _distToBoundary(origin.x, direction.x, block.x);
    var tmy = _distToBoundary(origin.y, direction.y, block.y);
    var tmz = _distToBoundary(origin.z, direction.z, block.z);
    var travelled = 0.0;
    while (travelled <= reachDist) {
      final id = world.getBlock(block);
      if (Blocks.isLiquid(id)) return block;
      if (id != Blocks.air && Blocks.isSolid(id)) return null;
      if (tmx < tmy && tmx < tmz) {
        block = block + IVec3(stepX, 0, 0);
        travelled = tmx;
        tmx += tdx;
      } else if (tmy < tmz) {
        block = block + IVec3(0, stepY, 0);
        travelled = tmy;
        tmy += tdy;
      } else {
        block = block + IVec3(0, 0, stepZ);
        travelled = tmz;
        tmz += tdz;
      }
    }
    return null;
  }

  /// Cast the line at a water cell: the bobber flies there and waits for a bite.
  void castFishing(IVec3 cell) {
    if (!world.isLiquid(cell)) throw ArgumentError('a line is cast at water');
    if (bobber != null) reelIn(false);
    final b = Bobber(world, this, model.handWorldPosition(), cell);
    bobber = b;
    main.entities.add(b.node);
    main.entities.add(b.lineNode);
    model.swing();
    Sfx.play('swing', -12.0, 1.3);
  }

  void reelIn(bool say) {
    final b = bobber;
    if (b == null) return;
    main.entities.remove(b.node);
    main.entities.remove(b.lineNode);
    bobber = null;
    if (say) notify('Reeled in');
  }

  /// The line is dropped when the rod leaves the hand or the bobber is left
  /// too far behind.
  void _tendBobber() {
    final b = bobber;
    if (b == null) return;
    if (heldItem() != 'fishing_rod' || (b.position - position).length > fishingReach * 2.0) {
      reelIn(false);
    }
  }

  /// A bite answered in time: 70% fish, 10% salmon, 15% junk, 5% treasure.
  /// Returns the item id.
  String catchFish() {
    final b = bobber;
    if (b == null || !b.isBiting) throw StateError('catchFish needs a biting bobber');
    final rng = main.random;
    final roll = rng.nextDouble();
    String got;
    Loot? loot;
    if (roll < 0.70) {
      got = 'raw_fish';
    } else if (roll < 0.80) {
      got = 'raw_salmon';
    } else if (roll < 0.95) {
      got = const ['stick', 'bone', 'leather'][rng.nextInt(3)];
    } else {
      final treasure = rng.nextDouble();
      if (treasure < 0.4) {
        got = 'magic_dust';
      } else if (treasure < 0.8) {
        got = 'gem_shard';
      } else {
        loot = main.randomLootWeapon(rng, 2);
        got = loot.id;
      }
      notify('Treasure!');
    }
    if (loot == null) {
      if (pickUp(got, 1) > 0) main.spawnDrop(centre(), got, 1);
    } else if (!inventory.addStack(ItemStack(loot.id, 1, bonus: loot.bonus))) {
      main.spawnDrop(centre(), got, 1);
    }
    main.spawnEffect(b.position, Vector3(0.5, 0.75, 1.0), 1.0);
    Sfx.play('splash', -6.0, 1.2);
    model.swing();
    gainXp(2);
    Achievements.instance.unlock('fisher');
    reelIn(false);
    return got;
  }

  /// Shears on a sheep: 1..3 wool drops beside it. Returns the number dropped.
  int shearMob(Mob m) {
    final n = m.shear();
    main.spawnDrop(m.centre(), 'wool', n, Vector3.zero(), 0.0);
    Sfx.play('dig', -6.0);
    model.swing();
    return n;
  }

  /// An empty bucket over a liquid SOURCE: the cell empties and the bucket
  /// fills with it. A flowing cell gives nothing; the puddle it belonged to
  /// drains once its source is gone.
  bool scoopLiquid(IVec3 cell) {
    final id = world.getBlock(cell);
    if (!Blocks.isLiquidSource(id) || heldItem() != 'bucket') return false;
    if (!world.setBlock(cell, Blocks.air)) return false;
    inventory.setSlot(selectedSlot, ItemStack('${Blocks.liquidKind(id)}_bucket', 1));
    Sfx.play('splash', -10.0);
    model.swing();
    return true;
  }

  /// A filled bucket at a replaceable cell: a source goes there (the world's
  /// flow spreads it) and the empty bucket comes back.
  bool pourLiquid(IVec3 target) {
    final liquid = Items.liquidOf(heldItem());
    if (liquid == '' || !Blocks.isReplaceable(world.getBlock(target))) return false;
    if (!world.setBlock(target, Blocks.indexOf(liquid))) return false;
    inventory.setSlot(selectedSlot, ItemStack('bucket', 1));
    Sfx.play('splash', -10.0, 0.8);
    model.swing();
    return true;
  }

  // --- stage 18: effects, talents, dodge -------------------------------------------

  static const double dodgeTime = 0.4;

  int talentRank(String id) => talents[id] ?? 0;

  bool learnTalent(String id) {
    if (talentPoints <= 0 || talentRank(id) >= Talents.maxRank) return false;
    talentPoints -= 1;
    talents[id] = talentRank(id) + 1;
    if (id == 'vitality') {
      maxHp += 4.0;
      hp += 4.0;
    }
    notify('Learned ${id[0].toUpperCase()}${id.substring(1)} ${talents[id]}');
    Achievements.instance.unlock('talent');
    return true;
  }

  double damageMultiplier() => effects.damageMultiplier() * (1.0 + 0.08 * talentRank('might'));

  double manaCost(double base) => base * (1.0 - 0.15 * talentRank('focus'));

  /// Drink a potion effect: "cure" clears every bad effect, anything else
  /// applies for [seconds].
  void drink(String effect, double seconds) {
    if (effect == 'cure') {
      final n = effects.clearBad();
      notify('Cured $n ailment${n == 1 ? '' : 's'}');
      return;
    }
    effects.apply(effect, seconds);
    main.spawnEffect(centre(), StatusEffects.def(effect).color, 1.2);
  }

  void applyEffect(String id, double seconds, [double power = 1.0]) {
    if (isDead) return;
    final fresh = !effects.has(id);
    effects.apply(id, seconds, power);
    if (fresh) notify('${StatusEffects.def(id).name}!');
  }

  void _dodgePressed() {
    final cost = math.max(15.0 - 5.0 * talentRank('shadowstep'), 0.0);
    if (_dodge > 0.0 || _dodgeCd > 0.0 || stamina < cost || riding != null || mount != null || sleeping > 0.0 || inWater) {
      return;
    }
    stamina -= cost;
    _dodge = dodgeTime;
    _dodgeCd = 0.9;
    _invulnerable = dodgeTime;
    _dodgeDir = _lastMoveDir.length > 0.1 ? _lastMoveDir.normalized() : flatForward;
    Sfx.play('swing', -8.0, 0.7);
  }

  void probeDodge() => _dodgePressed();

  Vector3 _probeWalk = Vector3.zero();

  /// A probe's walk input: a world-space direction held until zero is handed back.
  void probeWalk(Vector3 dir) => _probeWalk = dir.clone();

  bool isDodging() => _dodge > 0.0;

  bool get invulnerable => _invulnerable > 0.0;
}
