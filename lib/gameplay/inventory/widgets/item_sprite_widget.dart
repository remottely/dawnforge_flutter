import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/inventory/entities/data/item_icon_data.dart';
import 'package:flutter/material.dart';

class ItemSpriteWidget extends StatefulWidget {
  final ItemIconData? iconData;
  final double size;

  const ItemSpriteWidget({super.key, required this.iconData, this.size = 32});

  @override
  State<ItemSpriteWidget> createState() => _ItemSpriteWidgetState();
}

class _ItemSpriteWidgetState extends State<ItemSpriteWidget> {
  Sprite? _sprite;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSprite();
  }

  @override
  void didUpdateWidget(ItemSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData) {
      _loadSprite();
    }
  }

  Future<void> _loadSprite() async {
    if (widget.iconData == null) {
      if (mounted) {
        setState(() {
          _sprite = null;
          _isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Load sprite directly using Flame without depending on game context
      final image = await Flame.images.load(
        widget.iconData?.spritesheetPath ?? '',
      );

      final spriteWidth = widget.iconData?.spriteWidth.toDouble();
      final spriteHeight = widget.iconData?.spriteHeight.toDouble();
      final col = widget.iconData?.spriteColumnIndex ?? 0;
      final row = widget.iconData?.spriteRowIndex ?? 0;

      final sprite = Sprite(
        image,
        srcPosition: Vector2(
          col * (spriteWidth ?? 0),
          row * (spriteHeight ?? 0),
        ),
        srcSize: Vector2(spriteWidth ?? 0, spriteHeight ?? 0),
      );

      if (mounted) {
        setState(() {
          _sprite = sprite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sprite = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (_sprite == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(painter: _SpritePainter(_sprite!)),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final Sprite sprite;

  _SpritePainter(this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    sprite.render(
      canvas,
      position: Vector2.zero(),
      size: Vector2(size.width, size.height),
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return oldDelegate.sprite != sprite;
  }
}
