import 'package:flutter/widgets.dart';

/// The button every surface in this game presses — extracted from
/// `inventory_panel_view.dart` at 0.75.0, which is the moment its own comment
/// named: *"it moves to `ui/widgets/` when a second surface needs the same
/// thing, which is the point at which what they share is known rather than
/// guessed."* The bench's Make it, Stop, All and the two steppers are that
/// second surface, five times over.
///
/// A click and a tap are one press here (rule 12) — `onTap` answers both. The
/// GAMEPAD is still the gap FP4.3a opened in writing: there is no focus ring
/// to move onto this, and there will not be one until the virtual cursor is
/// ported.
///
/// It is stateful for one reason: it holds whether it is being pressed. A
/// button that gives nothing back under a finger reads as broken on a phone
/// long before it reads as plain.
///
/// [isEnabled] is the honest half of a refusal. A disabled button is DRAWN and
/// dimmed rather than hidden, and it swallows the press instead of passing it
/// on: a control that vanishes when you cannot use it teaches nothing, and one
/// that lets the press through would spend a batch the player cannot pay for.
final class PanelButton extends StatefulWidget {
  const PanelButton({
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.tint,
    this.minWidth,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;

  /// What the button is FOR, when that is worth saying in colour — the accent
  /// of a Make it, the danger of a Stop. Null wears the panel's own quiet fill.
  final Color? tint;

  final double? minWidth;

  @override
  State<PanelButton> createState() => _PanelButtonState();
}

const _border = Color(0xFF4A3B2A);
const _fill = Color(0xFF2C2318);
const _pressedFill = Color(0xFF4A3B2A);
const _label = Color(0xFFF6EDE0);
const _labelDisabled = Color(0x66F6EDE0);

final class _PanelButtonState extends State<PanelButton> {
  bool _isPressed = false;

  void _setPressed({required bool value}) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;
    final base = widget.tint ?? _fill;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(value: true) : null,
      onTapUp: enabled ? (_) => _setPressed(value: false) : null,
      onTapCancel: enabled ? () => _setPressed(value: false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled
              ? (_isPressed ? _pressedFill : base)
              : _fill.withValues(alpha: 0.4),
          border: Border.all(color: _border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.minWidth ?? 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: enabled ? _label : _labelDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Whether a finger is on it — read by the tests, and by nothing else.
  bool get isPressed => _isPressed;
}
