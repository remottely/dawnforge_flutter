import 'dart:async' show unawaited;
import 'dart:ui' as ui;

import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/render/animation_creator.dart';
import 'package:dawnforge/src/core/render/sprite_loader.dart';
import 'package:dawnforge/src/core/resources/inventory/item_stack.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter/widgets.dart';

/// One inventory slot as it is DRAWN — the Dart port of the spec's
/// `ItemSlotVisual`: a frame, the item's icon, its count, and whether it is the
/// selected one.
///
/// It is told what to show and shows it. Deciding which stack belongs here, and
/// what a tap on it means, belong to whoever composes the slots — this widget
/// owns no inventory reference and mutates nothing.
final class ItemSlotView extends StatelessWidget {
  const ItemSlotView({
    required this.stack,
    required this.isSelected,
    this.isGhost = false,
    super.key,
  });

  /// Side of a drawn slot, in logical pixels. Four times the tile so a 16px
  /// icon reads at arm's length on a phone; the interface zoom setting takes
  /// this over when settings land (FP5.2).
  static const double size = GameConstants.tileDimension * 4;

  static const _frame = Color(0xCC1B1712);
  static const _border = Color(0xFF4A3B2A);
  static const _borderSelected = Color(0xFFFFD95A);
  static const _countColor = Color(0xFFF6EDE0);

  final ItemStack stack;
  final bool isSelected;

  /// Draw the frame but not what is in it — the hole a stack leaves in the
  /// grid while it is under the player's finger. The slot keeps its place, so
  /// nothing reflows mid-drag.
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _frame,
          border: Border.all(
            color: isSelected ? _borderSelected : _border,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: stack.isEmpty || isGhost
            ? null
            : Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: _ItemIcon(itemId: stack.itemId),
                    ),
                  ),
                  // A count of one is the absence of a number, not the number
                  // one: a single apple reads as an apple.
                  if (stack.amount > 1)
                    Positioned(
                      right: 3,
                      bottom: 1,
                      child: Text(
                        '${stack.amount}',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          color: _countColor,
                          // Black is Shadow's own default; the count has to
                          // stay legible over a bright icon as well as a dark
                          // one, so it carries both a halo and an offset.
                          shadows: <Shadow>[
                            Shadow(blurRadius: 2),
                            Shadow(offset: Offset(1, 1)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// The item's own sprite, cut from the sheet the pack authored for it.
///
/// The sheet comes from Flame's image cache, which the world renderers have
/// usually filled already; the first slot to show an item the player has never
/// seen on screen loads it once and everything after that is a cache read.
final class _ItemIcon extends StatefulWidget {
  const _ItemIcon({required this.itemId});

  final String itemId;

  @override
  State<_ItemIcon> createState() => _ItemIconState();
}

final class _ItemIconState extends State<_ItemIcon> {
  ui.Image? _sheet;
  late Rect _source;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(_ItemIcon oldWidget) {
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
