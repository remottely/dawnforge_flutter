import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/inputs_hud_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/inputs_state.dart';
import 'package:flutter/material.dart';

class InputsOverlay extends StatelessWidget {
  const InputsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InputsState.instance.isVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return child!;
      },
      child: _buildOverlay(),
    );
  }

  Widget _buildOverlay() {
    const double padding = 6;
    const double lineHeight = 22;
    const double keyBoxWidth = 96;
    const double keyBoxHeight = 20;

    final double panelHeight =
        InputsHUDDef.inputGuide.length * lineHeight + padding * 2;

    return Positioned(
      left: 16,
      bottom: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          height: panelHeight,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: const Color(0xAA222222),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              InputsHUDDef.inputGuide.length,
              (index) => _buildInputRow(
                InputsHUDDef.inputGuide[index]['key']!,
                InputsHUDDef.inputGuide[index]['desc']!,
                keyBoxWidth,
                keyBoxHeight,
                padding,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(
    String key,
    String description,
    double keyBoxWidth,
    double keyBoxHeight,
    double padding,
  ) {
    return Container(
      height: 22,
      margin: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Container(
            width: keyBoxWidth,
            height: keyBoxHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              key,
              style: const TextStyle(
                color: Color(0xFF00FFAA),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                fontFamily: 'Normal',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 13,
                fontFamily: 'Normal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
