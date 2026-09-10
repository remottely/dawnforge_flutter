import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' show Camera;
import 'package:vector_math/vector_math.dart' as vm;

import '../core/blocks.dart';
import '../core/items.dart';
import '../game/game.dart';
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

class HudPainter extends CustomPainter {
  HudPainter(this.game, this.camera, this.minimap, {required Listenable repaint}) : super(repaint: repaint);

  final Game game;
  final Camera? camera;
  final Minimap minimap;

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
      final fill = mob.tamed ? const Color.fromRGBO(77, 153, 255, 1) : (mob.species.hostile ? const Color.fromRGBO(230, 51, 51, 1) : const Color.fromRGBO(77, 217, 77, 1));
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
      Hud.text(canvas, 'N up · red hostile · green passive · blue pet', Offset(mr.left, mr.bottom + 16), size: 11, color: const Color.fromRGBO(204, 204, 204, 1));
    }
    if (game.debugVisible) {
      Hud.text(canvas, game.debugText(), const Offset(12, 22), size: 13, color: const Color.fromRGBO(255, 255, 255, 0.85));
    }
  }

  @override
  bool shouldRepaint(covariant HudPainter old) => true;
}
