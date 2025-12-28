import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/tutorial_inputs_hud_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/tutorial_inputs_state.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_base.dart';
import 'package:flutter/material.dart';

class TutorialInputsOverlay extends ResponsiveOverlayBase {
  const TutorialInputsOverlay({super.key});

  @override
  String get overlayId => 'tutorial_inputs';

  @override
  ValueNotifier<bool> get visibilityNotifier => TutorialInputsState.instance.isVisible;

  @override
  OverlayPosition getOverlayPosition(BuildContext context) {
    final margin = getResponsiveMargin(context);
    return OverlayPosition.bottomLeft(
      margin: margin,
      safeAreaPadding: EdgeInsets.all(margin / 2),
    );
  }

  @override
  Widget buildOverlayContent(
    BuildContext context,
    ResponsiveOverlayData data,
  ) {
    final keyBoxWidth = valueByScreenSize(
      context,
      small: 80.0,
      medium: 96.0,
      large: 110.0,
      extraLarge: 120.0,
    );

    return Material(
      color: Colors.transparent,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.all(data.padding),
          decoration: BoxDecoration(
            color: const Color(0xAA222222),
            borderRadius: BorderRadius.circular(data.isSmallScreen ? 6 : 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              TutorialInputsHUDDef.inputGuide.length,
              (index) => _buildInputRow(
                context,
                data,
                TutorialInputsHUDDef.inputGuide[index]['key']!,
                TutorialInputsHUDDef.inputGuide[index]['desc']!,
                keyBoxWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context,
    ResponsiveOverlayData data,
    String key,
    String description,
    double keyBoxWidth,
  ) {
    final rowHeight = valueByScreenSize(
      context,
      small: 20.0,
      medium: 22.0,
      large: 24.0,
      extraLarge: 26.0,
    );

    final keyBoxHeight = valueByScreenSize(
      context,
      small: 18.0,
      medium: 20.0,
      large: 22.0,
      extraLarge: 24.0,
    );

    return Container(
      height: rowHeight,
      margin: EdgeInsets.only(bottom: data.spacing / 2),
      child: Row(
        children: [
          Container(
            width: keyBoxWidth,
            height: keyBoxHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(data.isSmallScreen ? 3 : 4),
            ),
            padding: EdgeInsets.symmetric(horizontal: data.spacing),
            alignment: Alignment.centerLeft,
            child: Text(
              key,
              style: TextStyle(
                color: const Color(0xFF00FFAA),
                fontWeight: FontWeight.bold,
                fontSize: data.baseFontSize - 1,
                fontFamily: 'Normal',
              ),
            ),
          ),
          SizedBox(width: data.spacing * 1.5),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: data.baseFontSize,
                fontFamily: 'Normal',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
