import 'package:dawnforge/game/core/systems/input_actions/keyboard_setup.dart';
import 'package:dawnforge/shared/design_system_old/widgets/atoms/dd_dialog_widget.dart';
import 'package:dawnforge/shared/design_system_old/widgets/atoms/dd_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable yes/no dialog navigated with keyboard.
class BinaryChoiceDialog {
  const BinaryChoiceDialog._();

  /// Shows a binary choice dialog.
  /// Returns true for "yes", false for "no", null if dismissed.
  static Future<bool?> show({
    required BuildContext context,
    required String question,
    String yesLabel = 'Yes',
    String noLabel = 'No',
    LogicalKeyboardKey upKey = LogicalKeyboardKey.keyW,
    LogicalKeyboardKey downKey = LogicalKeyboardKey.keyS,
    LogicalKeyboardKey cancelKey = KeyboardSetup.kInteractionKey,
    LogicalKeyboardKey confirmKey = KeyboardSetup.kPrimaryActionKey,
    String? hint,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        int selectedIndex = 0; // 0 = yes, 1 = no
        final focusNode = FocusNode();
        // Ensure this listener gets focus so it can receive W/S/arrow key events
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return Focus(
              focusNode: focusNode,
              autofocus: true,
              onKey: (node, event) {
                if (event is! RawKeyDownEvent) {
                  return KeyEventResult.ignored;
                }

                if (event.logicalKey == upKey ||
                    event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  setState(() => selectedIndex = 0);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == downKey ||
                    event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  setState(() => selectedIndex = 1);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == confirmKey) {
                  Navigator.of(dialogContext).pop(selectedIndex == 0);
                  return KeyEventResult.handled;
                }

                if (event.logicalKey == cancelKey) {
                  Navigator.of(dialogContext).pop(false);
                  return KeyEventResult.handled;
                }

                return KeyEventResult.ignored;
              },
              child: DDDialogWidget(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E2A3A), Color(0xFF0F1924)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF8BA6C1),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DDText.large(
                          text: question,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        _DialogOption(
                          label: yesLabel,
                          isSelected: selectedIndex == 0,
                        ),
                        const SizedBox(height: 10),
                        _DialogOption(
                          label: noLabel,
                          isSelected: selectedIndex == 1,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: DDText.small(
                            text:
                                hint ??
                                'Use ${upKey.keyLabel ?? upKey.debugName ?? 'W'} / ${downKey.keyLabel ?? downKey.debugName ?? 'S'} and ${confirmKey.keyLabel ?? confirmKey.debugName ?? 'confirm'} to choose.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DialogOption extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _DialogOption({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFE28A) : const Color(0xFF3B4A5C),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? const Color(0xFFFFE28A).withOpacity(0.18)
            : const Color(0xFF13202E),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x80FFE28A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: DDText.small(text: label, textAlign: TextAlign.center),
    );
  }
}
