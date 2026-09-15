import 'dart:async' show unawaited;
import 'dart:ui' as ui;

import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/render/animation_creator.dart';
import 'package:dawnforge/src/core/render/sprite_loader.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter/widgets.dart';

/// The item's own sprite, cut from the sheet the pack authored for it.
///
/// The sheet comes from Flame's image cache, which the world renderers have
/// usually filled already; the first slot to show an item the player has never
/// seen on screen loads it once and everything after that is a cache read.
///
/// It was private to `item_slot_view.dart` until 0.75.0, on the rule that one
/// user is not a shared widget. The recipe grid is the second, and it asks for
/// the same picture of the same thing — an icon that disagrees with the item
/// lying on the grass is a bug the player sees before anyone else does.
final class ItemIconView extends StatefulWidget {
  const ItemIconView({required this.itemId, super.key});

  final String itemId;

  @override
  State<ItemIconView> createState() => _ItemIconViewState();
}

final class _ItemIconViewState extends State<ItemIconView> {
  ui.Image? _sheet;
  late Rect _source;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(ItemIconView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId) {
      _sheet = null;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final data = locator<ItemRegistry>().getItem(widget.itemId);
    final sheet = await SpriteLoader.loadSheet(data.spritesheetPath);
    // The still is the same one the world pickup draws, taken from the same
    // helper — an icon that disagrees with the thing lying on the grass is a
    // bug the player sees before anyone else does.
    final sprite = AnimationCreator.createStill(data, sheet);
    if (!mounted) return;
    setState(() {
      _sheet = sheet;
      _source = Rect.fromLTWH(
        sprite.srcPosition.x,
        sprite.srcPosition.y,
        sprite.srcSize.x,
        sprite.srcSize.y,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheet = _sheet;
    // Nothing drawn for the frame or two before the sheet decodes. An empty
    // box, never a spinner: a slot that flickers a loading state on every
    // pickup is worse than one that fills a frame late.
    if (sheet == null) return const SizedBox.shrink();
    return CustomPaint(painter: _SpritePainter(sheet, _source));
  }
}

final class _SpritePainter extends CustomPainter {
  const _SpritePainter(this.sheet, this.source);

  final ui.Image sheet;
  final Rect source;

  @override
  void paint(Canvas canvas, Size size) {
    // Pixel art: nearest-neighbour, or a 16px icon blurs into mush the moment
    // it is scaled up to a readable size.
    canvas.drawImageRect(
      sheet,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.sheet != sheet || oldDelegate.source != source;
}
