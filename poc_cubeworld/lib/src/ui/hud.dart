import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' show Camera;
import 'package:vector_math/vector_math.dart' as vm;

import '../core/blocks.dart';
import '../core/items.dart';
import '../core/ivec3.dart';
import '../game/effects.dart';
import '../game/game.dart';
import '../game/settings.dart';
import '../world/voxel_world.dart';

/// Bars, hotbar, crosshair, notifications, minimap, boss bar and everything
/// projected from the world (mob bars, damage numbers, puppet labels).
class Hud {
  Hud._();

  static Color rarityColor(int bonus) {
    if (bonus >= 5) return const Color.fromRGBO(204, 115, 255, 1);
    if (bonus >= 3) return const Color.fromRGBO(102, 166, 255, 1);
    if (bonus >= 1) return const Color.fromRGBO(115, 242, 115, 1);
    return Colors.white;
  }

  static String itemLabel(String id, int bonus) {
    if (bonus <= 0) return Items.displayName(id);
    final tier = bonus >= 5 ? 'Epic' : (bonus >= 3 ? 'Rare' : 'Fine');
    return '$tier ${Items.displayName(id)} +$bonus';
  }

  static Color _c(double r, double g, double b, [double a = 1.0]) =>
      Color.fromRGBO((r * 255).round().clamp(0, 255), (g * 255).round().clamp(0, 255), (b * 255).round().clamp(0, 255), a);

  static Color itemColor(String id) {
    final d = Items.def(id);
    return _c(d.r, d.g, d.b);
  }

  static Color blockColor(int b) {
    final d = Blocks.def(b);
    return _c(d.r, d.g, d.b);
  }

  /// Shared with the inventory screen: an isometric cube for blocks, a glyph for the rest.
  static void drawItemIcon(Canvas ci, Rect r, String id) {
    final cx = r.left + r.width * 0.5;
    final cy = r.top + r.height * 0.5;
    final s = r.width * 0.32;
    if (Items.isBlock(id)) {
      final b = Items.blockOf(id);
      final col = blockColor(b);
      final shape = Blocks.shapeOf(b);
      if (shape == BlockShape.cross || shape == BlockShape.torch) {
        ci.drawLine(Offset(cx - s, cy + s), Offset(cx + s, cy - s), Paint()..color = col..strokeWidth = 4);
        ci.drawLine(Offset(cx + s, cy + s), Offset(cx - s, cy - s), Paint()..color = _scale(col, 0.8)..strokeWidth = 4);
        return;
      }
      final top = Path()
        ..moveTo(cx, cy - s)
        ..lineTo(cx + s, cy - s * 0.5)
        ..lineTo(cx, cy)
        ..lineTo(cx - s, cy - s * 0.5)
        ..close();
      final left = Path()
        ..moveTo(cx - s, cy - s * 0.5)
        ..lineTo(cx, cy)
        ..lineTo(cx, cy + s)
        ..lineTo(cx - s, cy + s * 0.5)
        ..close();
      final right = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + s, cy - s * 0.5)
        ..lineTo(cx + s, cy + s * 0.5)
        ..lineTo(cx, cy + s)
        ..close();
      ci.drawPath(top, Paint()..color = col);
      ci.drawPath(left, Paint()..color = _scale(col, 0.7));
      ci.drawPath(right, Paint()..color = _scale(col, 0.85));
      return;
    }
    final col = itemColor(id);
    final kind = Items.kind(id);
    if (kind == ItemKind.tool || kind == ItemKind.weapon) {
      ci.drawLine(Offset(cx - s * 0.8, cy + s), Offset(cx + s * 0.2, cy - s * 0.2),
          Paint()..color = const Color.fromRGBO(115, 82, 46, 1)..strokeWidth = 4);
      final tool = Items.toolOf(id);
      final style = kind == ItemKind.weapon ? Items.styleOf(id) : '';
      if (tool == ToolType.pickaxe) {
        ci.drawLine(Offset(cx - s * 0.5, cy - s * 0.9), Offset(cx + s, cy + s * 0.2), Paint()..color = col..strokeWidth = 5);
      } else if (tool == ToolType.axe) {
        ci.drawRect(Rect.fromLTWH(cx, cy - s, s * 0.8, s * 0.8), Paint()..color = col);
      } else if (tool == ToolType.shovel || tool == ToolType.hoe) {
        ci.drawRect(Rect.fromLTWH(cx, cy - s, s * 0.6, s * 0.7), Paint()..color = col);
      } else if (style == 'bow') {
        ci.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: s), -math.pi * 0.75, math.pi, false,
            Paint()..color = col..strokeWidth = 4..style = PaintingStyle.stroke);
        ci.drawLine(Offset(cx - s * 0.7, cy - s * 0.7), Offset(cx + s * 0.7, cy + s * 0.7), Paint()..color = Colors.white..strokeWidth = 1.5);
      } else if (style == 'staff') {
        ci.drawCircle(Offset(cx + s * 0.3, cy - s * 0.5), s * 0.4, Paint()..color = col);
      } else {
        ci.drawLine(Offset(cx + s * 0.2, cy - s * 0.2), Offset(cx + s, cy - s), Paint()..color = col..strokeWidth = 6);
      }
    } else if (kind == ItemKind.food) {
      ci.drawCircle(Offset(cx, cy), s * 0.8, Paint()..color = col);
    } else if (kind == ItemKind.equipment) {
      final rr = Rect.fromLTWH(cx - s * 0.8, cy - s * 0.8, s * 1.6, s * 1.6);
      ci.drawRect(rr, Paint()..color = col);
      ci.drawRect(rr, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    } else {
      final diamond = Path()
        ..moveTo(cx, cy - s)
        ..lineTo(cx + s * 0.8, cy)
        ..lineTo(cx, cy + s)
        ..lineTo(cx - s * 0.8, cy)
        ..close();
      ci.drawPath(diamond, Paint()..color = col);
    }
  }

  static Color _scale(Color c, double f) => Color.fromRGBO((c.r * 255 * f).round(), (c.g * 255 * f).round(), (c.b * 255 * f).round(), c.a);

  static void text(Canvas canvas, String s, Offset at, {double size = 14, Color color = Colors.white, TextAlign align = TextAlign.left, double? width, FontWeight weight = FontWeight.normal, bool shadow = true}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: size, color: color, fontWeight: weight, shadows: shadow ? const [Shadow(color: Colors.black87, blurRadius: 2, offset: Offset(1, 1))] : null)),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 4,
    )..layout(maxWidth: width ?? 1000);
    var x = at.dx;
    if (width != null && align == TextAlign.center) x = at.dx;
    if (width != null && align == TextAlign.right) x = at.dx;
    tp.paint(canvas, Offset(x, at.dy - tp.height + size * 0.2));
  }
}

/// Rebuilds the 96x96 top-down map once a second while visible.
class Minimap {
  static const int radius = 48;
  ui.Image? image;
  double _timer = 0.0;
  bool _busy = false;

  void update(double dt, Game game) {
    if (!game.mapVisible) return;
    _timer -= dt;
    if (_timer > 0.0 || _busy) return;
    _timer = 1.0;
    _rebuild(game);
  }

  void _rebuild(Game game) {
    const n = radius * 2;
    final pixels = Uint8List(n * n * 4);
    final px = game.player.position.x.toInt();
    final pz = game.player.position.z.toInt();
    final world = game.world;
    for (var iz = 0; iz < n; iz++) {
      for (var ix = 0; ix < n; ix++) {
        final wx = px - radius + ix;
        final wz = pz - radius + iz;
        var r = 0.05, g = 0.05, b = 0.08;
        if (world.chunks.containsKey(VoxelWorld.chunkOfXZ(wx, wz))) {
          final y = world.groundHeight(wx, wz) - 1;
          final id = world.getBlockXYZ(wx, y, wz);
          if (id != Blocks.air) {
            final d = Blocks.def(id);
            final shade = (0.55 + (y - 40) / 80.0).clamp(0.4, 1.2);
            r = d.r * shade;
            g = d.g * shade;
            b = d.b * shade;
          }
          final above = world.getBlockXYZ(wx, y + 1, wz);
          if (above != Blocks.air && Blocks.isLiquid(above)) {
            final d = Blocks.def(above);
            r = d.r;
            g = d.g;
            b = d.b;
          }
        }
        final o = (iz * n + ix) * 4;
        pixels[o] = (r * 255).round().clamp(0, 255);
        pixels[o + 1] = (g * 255).round().clamp(0, 255);
        pixels[o + 2] = (b * 255).round().clamp(0, 255);
        pixels[o + 3] = 255;
      }
    }
    _busy = true;
    ui.decodeImageFromPixels(pixels, n, n, ui.PixelFormat.rgba8888, (img) {
      image?.dispose();
      image = img;
      _busy = false;
    });
  }
}

/// Stage 24: the full-screen world map (M cycles minimap -> world map -> off).
/// One pixel per block over every loaded chunk plus every visited one (flat
/// grey when out of the window), rebuilt every 2 s while visible.
class WorldMap {
  static const int maxChunks = 64; // the image never grows past 64x64 chunks (1024 px)
  static const Map<int, String> structureNames = {
    1: 'Dungeon', 2: 'Tower', 3: 'Camp', 4: 'Village', 5: 'Ruin', 6: 'Well', 7: 'Mine', 8: 'Temple',
  };
  static final Map<int, Color> structureColors = {
    1: Hud._c(0.85, 0.25, 0.25), 2: Hud._c(0.75, 0.75, 0.85), 3: Hud._c(0.95, 0.6, 0.2), 4: Hud._c(0.95, 0.9, 0.4),
    5: Hud._c(0.6, 0.55, 0.45), 6: Hud._c(0.35, 0.65, 0.95), 7: Hud._c(0.55, 0.4, 0.25), 8: Hud._c(0.95, 0.8, 0.5),
  };
  static final Color waypointColor = Hud._c(0.3, 0.95, 1.0);
  static final Color mountColor = Hud._c(0.6, 0.38, 0.18);
  static const Color spawnColor = Colors.white;

  ui.Image? image;

  /// The world block at the image's top-left.
  int originX = 0, originZ = 0;
  double _timer = 0.0;
  bool _busy = false;
  bool _shown = false;

  void update(double dt, Game game) {
    if (!game.worldMapVisible) {
      _shown = false;
      return;
    }
    if (!_shown) {
      _shown = true;
      _timer = 0.0;
    }
    _timer -= dt;
    if (_timer > 0.0 || _busy) return;
    _timer = 2.0;
    _rebuild(game);
  }

  void _rebuild(Game game) {
    final world = game.world;
    final here = VoxelWorld.chunkOf(IVec3.floor(game.player.position));
    final all = <ChunkPos>{...game.visitedChunks, ...world.chunks.keys};
    var loX = 1 << 30, loZ = 1 << 30, hiX = -(1 << 30), hiZ = -(1 << 30);
    for (final c in all) {
      if ((c.x - here.x).abs() > maxChunks ~/ 2 || (c.z - here.z).abs() > maxChunks ~/ 2) continue;
      loX = math.min(loX, c.x);
      loZ = math.min(loZ, c.z);
      hiX = math.max(hiX, c.x);
      hiZ = math.max(hiZ, c.z);
    }
    if (loX > hiX) {
      loX = hiX = here.x;
      loZ = hiZ = here.z;
    }
    final w = (hiX - loX + 1) * VoxelWorld.sizeX;
    final h = (hiZ - loZ + 1) * VoxelWorld.sizeZ;
    final ox = loX * VoxelWorld.sizeX;
    final oz = loZ * VoxelWorld.sizeZ;
    final pixels = Uint8List(w * h * 4); // transparent where nothing was seen
    for (final c in all) {
      if (c.x < loX || c.x > hiX || c.z < loZ || c.z > hiZ) continue;
      final loaded = world.chunks.containsKey(c);
      for (var iz = 0; iz < VoxelWorld.sizeZ; iz++) {
        for (var ix = 0; ix < VoxelWorld.sizeX; ix++) {
          final wx = c.x * VoxelWorld.sizeX + ix;
          final wz = c.z * VoxelWorld.sizeZ + iz;
          var r = 0.22, g = 0.22, b = 0.26; // visited, out of the window
          if (loaded) {
            final y = world.groundHeight(wx, wz) - 1;
            final id = world.getBlockXYZ(wx, y, wz);
            r = 0.05;
            g = 0.05;
            b = 0.08;
            if (id != Blocks.air) {
              final d = Blocks.def(id);
              final shade = (0.55 + (y - 40) / 80.0).clamp(0.4, 1.2);
              r = d.r * shade;
              g = d.g * shade;
              b = d.b * shade;
            }
            final above = world.getBlockXYZ(wx, y + 1, wz);
            if (above != Blocks.air && Blocks.isLiquid(above)) {
              final d = Blocks.def(above);
              r = d.r;
              g = d.g;
              b = d.b;
            }
          }
          final o = ((wz - oz) * w + (wx - ox)) * 4;
          pixels[o] = (r * 255).round().clamp(0, 255);
          pixels[o + 1] = (g * 255).round().clamp(0, 255);
          pixels[o + 2] = (b * 255).round().clamp(0, 255);
          pixels[o + 3] = 255;
        }
      }
    }
    _busy = true;
    ui.decodeImageFromPixels(pixels, w, h, ui.PixelFormat.rgba8888, (img) {
      image?.dispose();
      image = img;
      originX = ox;
      originZ = oz;
      _busy = false;
    });
  }
}

class HudPainter extends CustomPainter {
  HudPainter(this.game, this.camera, this.minimap, this.worldMap, {required Listenable repaint}) : super(repaint: repaint);

  final Game game;
  final Camera? camera;
  final Minimap minimap;
  final WorldMap worldMap;

  static Paint _p(Color c) => Paint()..color = c;

  /// Stage 24: every marker, through [toScreen] (world x, z -> canvas) and
  /// [inside]; [scale] sizes the icons and [labels] names them (the world map
  /// only).
  void _drawMarkers(Canvas canvas, Offset Function(double x, double z) toScreen, bool Function(double x, double z) inside,
      double scale, bool labels) {
    final ring = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final sp = game.player.spawnPoint;
    if (inside(sp.x, sp.z)) {
      final at = toScreen(sp.x, sp.z);
      canvas.drawCircle(at, 3.0 * scale, _p(WorldMap.spawnColor));
      canvas.drawCircle(at, 3.0 * scale, ring);
      if (labels) Hud.text(canvas, 'Spawn', at + const Offset(-46, 4), size: 12, color: WorldMap.spawnColor);
    }
    for (final e in game.discoveredStructures.entries) {
      final x = e.key.x.toDouble(), z = e.key.z.toDouble();
      if (!inside(x, z)) continue;
      final at = toScreen(x, z);
      final r = 3.5 * scale;
      final col = WorldMap.structureColors[e.value] ?? const Color.fromRGBO(255, 0, 255, 1);
      final rect = Rect.fromCenter(center: at, width: r * 2, height: r * 2);
      canvas.drawRect(rect, _p(col));
      canvas.drawRect(rect, ring);
      if (labels) Hud.text(canvas, WorldMap.structureNames[e.value] ?? '?', at + Offset(r + 3, 4), size: 12, color: col);
    }
    for (final e in game.waypoints.entries) {
      final x = e.key.x.toDouble(), z = e.key.z.toDouble();
      if (!inside(x, z)) continue;
      final at = toScreen(x, z);
      final r = 4.5 * scale;
      canvas.drawPath(
          Path()
            ..moveTo(at.dx, at.dy - r)
            ..lineTo(at.dx + r, at.dy)
            ..lineTo(at.dx, at.dy + r)
            ..lineTo(at.dx - r, at.dy)
            ..close(),
          _p(WorldMap.waypointColor));
      if (labels) Hud.text(canvas, e.value, at + Offset(6 * scale, 4), size: 12, color: WorldMap.waypointColor);
    }
    for (final m in game.tamedMounts()) {
      if (!inside(m.position.x, m.position.z)) continue;
      final at = toScreen(m.position.x, m.position.z);
      canvas.drawCircle(at, 3.0 * scale, _p(WorldMap.mountColor));
      canvas.drawCircle(
          at,
          3.0 * scale,
          Paint()
            ..color = const Color.fromRGBO(255, 230, 179, 1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
      if (labels) Hud.text(canvas, m.displayName(), at + Offset(6 * scale, 16), size: 12, color: const Color.fromRGBO(230, 191, 128, 1));
    }
  }

  void _drawWorldMap(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _p(const Color.fromRGBO(0, 0, 0, 0.7)));
    // The Godot panel is 1040x760; a smaller window scales it down.
    final k = math.min(1.0, math.min((size.width - 20) / 1040, (size.height - 20) / 760));
    canvas.save();
    canvas.translate(size.width * 0.5 - 520 * k, size.height * 0.5 - 380 * k);
    canvas.scale(k);
    const panel = Rect.fromLTWH(0, 0, 1040, 760);
    canvas.drawRect(panel, _p(Hud._c(0.08, 0.08, 0.1, 0.96)));
    canvas.drawRect(panel, Paint()
      ..color = Hud._c(0.6, 0.6, 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0);
    Hud.text(canvas, 'World map', const Offset(20, 32), size: 22);
    Hud.text(canvas, 'M: close · explored ${game.visitedChunks.length} chunks · grey = visited, out of view', const Offset(20, 52),
        size: 13, color: Hud._c(0.7, 0.7, 0.7));
    final img = worldMap.image;
    if (img != null) {
      final area = Rect.fromLTWH(20, 64, panel.width - 40, panel.height - 110);
      final iw = img.width.toDouble(), ih = img.height.toDouble();
      final s = math.min(area.width / iw, area.height / ih);
      final shown = Rect.fromLTWH(area.left + (area.width - iw * s) * 0.5, area.top + (area.height - ih * s) * 0.5, iw * s, ih * s);
      canvas.drawRect(shown.inflate(2), _p(const Color.fromRGBO(0, 0, 0, 0.8)));
      canvas.drawImageRect(img, Rect.fromLTWH(0, 0, iw, ih), shown, Paint()..filterQuality = FilterQuality.none);
      Offset toScreen(double x, double z) => Offset(shown.left + (x - worldMap.originX) * s, shown.top + (z - worldMap.originZ) * s);
      bool inside(double x, double z) {
        final px = x - worldMap.originX, pz = z - worldMap.originZ;
        return px >= 0.0 && pz >= 0.0 && px < iw && pz < ih;
      }

      _drawMarkers(canvas, toScreen, inside, 1.6, true);
      final player = game.player;
      final pc = toScreen(player.position.x, player.position.z);
      final fwd = player.forward;
      canvas.drawPath(
          Path()
            ..moveTo(pc.dx + fwd.x * 12.0, pc.dy + fwd.z * 12.0)
            ..lineTo(pc.dx - fwd.z * 6.0, pc.dy + fwd.x * 6.0)
            ..lineTo(pc.dx + fwd.z * 6.0, pc.dy - fwd.x * 6.0)
            ..close(),
          _p(Colors.white));
      Hud.text(canvas, 'You', pc + const Offset(-10, -12), size: 12);
    }
    // Legend
    final ly = panel.bottom - 30;
    const lx = 20.0;
    final grey = Hud._c(0.85, 0.85, 0.85);
    canvas.drawCircle(Offset(lx + 5, ly), 4.0, _p(WorldMap.spawnColor));
    Hud.text(canvas, 'spawn', Offset(lx + 14, ly + 4), size: 12, color: grey);
    final d = Offset(lx + 75, ly);
    canvas.drawPath(
        Path()
          ..moveTo(d.dx, d.dy - 5)
          ..lineTo(d.dx + 5, d.dy)
          ..lineTo(d.dx, d.dy + 5)
          ..lineTo(d.dx - 5, d.dy)
          ..close(),
        _p(WorldMap.waypointColor));
    Hud.text(canvas, 'waypoint', Offset(lx + 84, ly + 4), size: 12, color: grey);
    canvas.drawCircle(Offset(lx + 165, ly), 4.0, _p(WorldMap.mountColor));
    Hud.text(canvas, 'mount', Offset(lx + 174, ly + 4), size: 12, color: grey);
    var sx = lx + 240;
    for (var kind = 1; kind <= 8; kind++) {
      canvas.drawRect(Rect.fromLTWH(sx - 4, ly - 4, 8, 8), _p(WorldMap.structureColors[kind]!));
      Hud.text(canvas, WorldMap.structureNames[kind]!, Offset(sx + 7, ly + 4), size: 12, color: grey);
      sx += 22 + WorldMap.structureNames[kind]!.length * 7;
    }
    canvas.restore();
  }

  Offset? _project(vm.Vector3 world, Size size) => camera?.worldToScreen(world, size);

  void _bar(Canvas c, double x, double y, double w, double h, double ratio, Color color, String label) {
    c.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.55));
    c.drawRect(Rect.fromLTWH(x + 2, y + 2, (w - 4) * ratio.clamp(0.0, 1.0), h - 4), Paint()..color = color);
    Hud.text(c, label, Offset(x + 8, y + h - 6), size: 15);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!game.ready) return;
    final player = game.player;
    final c = Offset(size.width * 0.5, size.height * 0.5);
    // Damage flash
    if (player.hp < player.maxHp * 0.25) {
      final t = DateTime.now().millisecondsSinceEpoch / 200.0;
      canvas.drawRect(Offset.zero & size, Paint()..color = Color.fromRGBO(153, 0, 0, 0.12 + 0.08 * math.sin(t)));
    }
    if (player.damageFlash > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Color.fromRGBO(200, 0, 0, 0.25 * player.damageFlash));
    }
    // Projected world labels: mob bars, damage numbers, puppets.
    for (final mob in [...game.mobs, ...game.pets]) {
      if (!mob.barVisible || mob.isDead) continue;
      final p = _project(mob.position + vm.Vector3(0, mob.height + 0.35, 0), size);
      if (p == null) continue;
      final dist = (mob.position - player.position).length;
      if (dist > 40) continue;
      final w = (60.0 * (8.0 / math.max(dist, 4.0))).clamp(28.0, 90.0);
      final h = w * 0.12;
      canvas.drawRect(Rect.fromCenter(center: p, width: w, height: h), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.7));
      final ratio = (mob.hp / mob.maxHp).clamp(0.0, 1.0);
      final bc = mob.barColor();
      final fill = mob.species.hostile || mob.tamed || mob.affix != ''
          ? Color.fromRGBO((bc.x * 255).round(), (bc.y * 255).round(), (bc.z * 255).round(), 1)
          : const Color.fromRGBO(77, 217, 77, 1);
      canvas.drawRect(Rect.fromLTWH(p.dx - w * 0.48, p.dy - h * 0.33, w * 0.96 * ratio, h * 0.66), Paint()..color = fill);
    }
    for (final n in game.damageNumbers) {
      final t = (n.age / 0.9).clamp(0.0, 1.0);
      final rise = 1.4 * (1 - math.pow(1 - t, 2));
      final p = _project(n.pos + vm.Vector3(0, rise, 0), size);
      if (p == null) continue;
      final alpha = n.age < 0.3 ? 1.0 : (1.0 - (n.age - 0.3) / 0.6).clamp(0.0, 1.0);
      final dist = (n.pos - player.position).length;
      final fs = (26.0 * (6.0 / math.max(dist, 3.0))).clamp(12.0, 34.0);
      Hud.text(canvas, n.text, Offset(p.dx - fs * 0.3 * n.text.length, p.dy), size: fs, color: Hud._c(n.color.x, n.color.y, n.color.z, alpha), weight: FontWeight.bold);
    }
    for (final pup in game.puppets) {
      final p = _project(pup.position + vm.Vector3(0, 2.1, 0), size);
      if (p == null) continue;
      Hud.text(canvas, pup.title, Offset(p.dx - 30, p.dy), size: 14, align: TextAlign.center, width: 60);
    }
    // Crosshair
    final col = player.aimedMob != null ? const Color.fromRGBO(255, 77, 77, 1) : Colors.white;
    final cp = Paint()..color = col..strokeWidth = 2;
    canvas.drawLine(c + const Offset(-9, 0), c + const Offset(-3, 0), cp);
    canvas.drawLine(c + const Offset(3, 0), c + const Offset(9, 0), cp);
    canvas.drawLine(c + const Offset(0, -9), c + const Offset(0, -3), cp);
    canvas.drawLine(c + const Offset(0, 3), c + const Offset(0, 9), cp);
    if (player.mineProgress > 0.0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: 16), -math.pi / 2, math.pi * 2 * player.mineProgress, false,
          Paint()..color = const Color.fromRGBO(255, 255, 255, 0.9)..strokeWidth = 3..style = PaintingStyle.stroke);
    }

    // Stats (bottom left)
    const x = 20.0;
    final y = size.height - 150.0;
    _bar(canvas, x, y, 260, 24, player.hp / player.maxHp, const Color.fromRGBO(217, 38, 51, 1), 'HP ${player.hp.ceil()} / ${player.maxHp.toInt()}');
    _bar(canvas, x, y + 28, 260, 20, player.stamina / player.maxStamina, const Color.fromRGBO(64, 191, 64, 1), 'Stamina');
    _bar(canvas, x, y + 52, 260, 20, player.mana / player.maxMana, const Color.fromRGBO(77, 115, 242, 1), 'Mana ${player.mana.toInt()}');
    _bar(canvas, x, y + 76, 260, 20, player.hunger / 20.0, const Color.fromRGBO(217, 140, 51, 1), 'Food');
    final xpRatio = player.xp / player.xpToNext();
    _bar(canvas, x, y + 100, 260, 18, xpRatio, const Color.fromRGBO(191, 153, 242, 1),
        'Lv ${player.level}  ${player.classDef.name}   XP ${player.xp}/${player.xpToNext()}');
    // Ability
    final ab = player.classDef.ability;
    final ready = player.abilityCooldown <= 0.0;
    canvas.drawRect(Rect.fromLTWH(x + 270, y + 100, 150, 18), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.55));
    Hud.text(canvas, '[R] $ab${ready ? '' : ' (${player.abilityCooldown.round()}s)'}', Offset(x + 276, y + 114),
        size: 14, color: ready ? const Color.fromRGBO(255, 255, 153, 1) : const Color.fromRGBO(179, 179, 179, 1));
    // Stage 23: the second ability under the first.
    final ab2 = player.classDef.ability2;
    final ready2 = player.ability2Cooldown <= 0.0;
    canvas.drawRect(Rect.fromLTWH(x + 270, y + 122, 150, 18), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.55));
    Hud.text(canvas, '[Q] $ab2${ready2 ? '' : ' (${player.ability2Cooldown.round()}s)'}', Offset(x + 276, y + 136),
        size: 14, color: ready2 ? const Color.fromRGBO(179, 230, 255, 1) : const Color.fromRGBO(179, 179, 179, 1));

    if (player.talentPoints > 0) {
      Hud.text(canvas, '[J] ${player.talentPoints} talent point${player.talentPoints == 1 ? '' : 's'}',
          Offset(x + 270, y + 94), size: 14, color: const Color.fromRGBO(255, 230, 128, 1));
    }
    // Status effects, stacked above the bars.
    var ey = y - 30.0;
    for (final id in player.effects.rows.keys) {
      final d = StatusEffects.def(id);
      final left = player.effects.timeLeft(id);
      final col = Color.fromRGBO((d.r * 255).round(), (d.g * 255).round(), (d.b * 255).round(), 1);
      canvas.drawRect(Rect.fromLTWH(x, ey, 200, 22), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.55));
      canvas.drawRect(Rect.fromLTWH(x, ey, 6, 22), Paint()..color = col);
      Hud.text(canvas, '${d.name}  ${left.ceil()}s', Offset(x + 12, ey + 16),
          size: 13, color: d.bad ? col : Colors.white);
      ey -= 26.0;
    }

    // Hotbar (bottom centre)
    const slot = 54.0;
    final hx = c.dx - slot * 4.5;
    final hy = size.height - 70.0;
    for (var i = 0; i < 9; i++) {
      final r = Rect.fromLTWH(hx + i * slot, hy, slot - 4, slot - 4);
      canvas.drawRect(r, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.55));
      if (i == player.selectedSlot) {
        canvas.drawRect(r, Paint()..color = const Color.fromRGBO(255, 255, 255, 0.9)..style = PaintingStyle.stroke..strokeWidth = 3);
      }
      final id = player.inventory.idAt(i);
      if (id != '') {
        Hud.drawItemIcon(canvas, r, id);
        final n = player.inventory.countAt(i);
        if (n > 1) Hud.text(canvas, '$n', Offset(r.left + 4, r.bottom - 6), size: 14);
        if (player.inventory.bonusAt(i) > 0) {
          canvas.drawRect(r, Paint()..color = Hud.rarityColor(player.inventory.bonusAt(i))..style = PaintingStyle.stroke..strokeWidth = 2);
        }
        // Stage 23: a worn tool shows what is left of it under the icon.
        final maxDur = Items.durabilityOf(id);
        final dur = player.inventory.durAt(i);
        if (maxDur > 0 && dur < maxDur) {
          final ratio = dur / maxDur;
          canvas.drawRect(Rect.fromLTWH(r.left + 5, r.bottom - 7, r.width - 10, 4), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.8));
          canvas.drawRect(Rect.fromLTWH(r.left + 5, r.bottom - 7, (r.width - 10) * ratio, 4),
              Paint()..color = Color.fromRGBO(((1.0 - ratio) * 255).round(), (ratio * 255).round(), 38, 1));
        }
      }
    }
    final held = player.heldItem();
    if (held != '') {
      final bonus = player.inventory.bonusAt(player.selectedSlot);
      Hud.text(canvas, Hud.itemLabel(held, bonus), Offset(c.dx - 200, hy - 8), size: 16, align: TextAlign.center, width: 400, color: Hud.rarityColor(bonus));
    }

    // Time (top centre)
    Hud.text(canvas, game.timeLabel(), Offset(c.dx - 100, 26), size: 16, align: TextAlign.center, width: 200);

    // Notifications (right)
    var ny = size.height * 0.35;
    for (final n in game.notes) {
      final a = n.t.clamp(0.0, 1.0);
      Hud.text(canvas, n.text, Offset(size.width - 330, ny), size: 17, align: TextAlign.right, width: 310, color: Color.fromRGBO(255, 255, 255, a));
      ny += 22;
    }

    // Aimed mob name
    final am = player.aimedMob;
    if (am != null) {
      Hud.text(canvas, '${am.displayName()}  ${am.hp.ceil()}/${am.maxHp.toInt()}', Offset(c.dx - 150, c.dy - 40),
          size: 16, align: TextAlign.center, width: 300, color: const Color.fromRGBO(255, 204, 204, 1));
    }

    // Boss bar
    final boss = game.boss;
    if (boss != null && !boss.removed) {
      const bw = 500.0;
      _bar(canvas, c.dx - bw * 0.5, 44, bw, 22, boss.hp / boss.maxHp, const Color.fromRGBO(179, 26, 128, 1),
          '${boss.displayName()}   ${boss.hp.ceil()} / ${boss.maxHp.toInt()}');
    }
    // Quest (top right)
    final q = game.quests.current;
    if (q != null) {
      final qx = size.width - 330;
      canvas.drawRect(Rect.fromLTWH(qx, 14, 316, 54), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.5));
      Hud.text(canvas, 'Quest: ${q.title}', Offset(qx + 10, 34), size: 15, color: const Color.fromRGBO(255, 230, 153, 1));
      Hud.text(canvas, '${q.text}  (${game.quests.progress}/${q.n})', Offset(qx + 10, 56), size: 13);
    }
    // Minimap (M)
    final map = minimap.image;
    if (game.mapVisible && map != null) {
      const ms = 240.0;
      final mr = Rect.fromLTWH(size.width - ms - 20, 80, ms, ms);
      canvas.drawRect(mr.inflate(3), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.7));
      canvas.drawImageRect(map, Rect.fromLTWH(0, 0, map.width.toDouble(), map.height.toDouble()), mr, Paint()..filterQuality = FilterQuality.none);
      final pc = mr.center;
      final fwd = player.forward;
      final tri = Path()
        ..moveTo(pc.dx + fwd.x * 9.0, pc.dy + fwd.z * 9.0)
        ..lineTo(pc.dx - fwd.z * 4.0, pc.dy + fwd.x * 4.0)
        ..lineTo(pc.dx + fwd.z * 4.0, pc.dy - fwd.x * 4.0)
        ..close();
      canvas.drawPath(tri, Paint()..color = Colors.white);
      const k = ms / (Minimap.radius * 2);
      for (final m in game.mobs) {
        final d = m.position - player.position;
        if (d.x.abs() < Minimap.radius && d.z.abs() < Minimap.radius) {
          canvas.drawCircle(Offset(pc.dx + d.x * k, pc.dy + d.z * k), 2.5,
              Paint()..color = m.species.hostile ? const Color.fromRGBO(255, 77, 77, 1) : const Color.fromRGBO(102, 255, 102, 1));
        }
      }
      for (final m in game.pets) {
        final d = m.position - player.position;
        canvas.drawCircle(Offset(pc.dx + d.x * k, pc.dy + d.z * k), 2.5, Paint()..color = const Color.fromRGBO(102, 153, 255, 1));
      }
      // Stage 24: markers on the minimap.
      final px = player.position.x, pz = player.position.z;
      _drawMarkers(canvas, (x, z) => Offset(pc.dx + (x - px) * k, pc.dy + (z - pz) * k),
          (x, z) => (x - px).abs() < Minimap.radius && (z - pz).abs() < Minimap.radius, 1.0, false);
      Hud.text(canvas, 'N up · red hostile · green passive · blue pet', Offset(mr.left, mr.bottom + 16), size: 11, color: const Color.fromRGBO(204, 204, 204, 1));
      Hud.text(canvas, 'cyan waypoint · brown mount · white spawn · squares structures · M again: world map',
          Offset(mr.left, mr.bottom + 30), size: 11, color: const Color.fromRGBO(204, 204, 204, 1), width: ms + 20);
    }
    if (game.worldMapVisible) _drawWorldMap(canvas, size);
    if (game.debugVisible) {
      Hud.text(canvas, game.debugText(), const Offset(12, 22), size: 13, color: const Color.fromRGBO(255, 255, 255, 0.85));
    } else if (Settings.instance.showFps) {
      Hud.text(canvas, 'FPS ${game.fps.round()}', const Offset(12, 22), size: 13, color: const Color.fromRGBO(255, 255, 153, 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant HudPainter old) => true;
}
