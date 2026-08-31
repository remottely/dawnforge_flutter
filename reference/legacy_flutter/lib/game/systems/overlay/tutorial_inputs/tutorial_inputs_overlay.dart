import 'package:dawnforge/pre_game/screens/menu_screen.dart';
import 'package:dawnforge/game/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/systems/overlay/tutorial_inputs/tutorial_inputs_hud_def.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system_extension.dart';
import 'package:dawnforge/shared/overlay_design_system/responsive_overlay_base.dart';
import 'package:dawnforge/shared/design_system/theme/screen_size_info.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';
import 'package:flutter/material.dart';

final class TutorialInputsOverlay extends ResponsiveOverlayBase {
  const TutorialInputsOverlay({super.key});

  @override
  String get overlayId => 'tutorial_inputs';

  @override
  Widget buildOverlayContent(BuildContext context) {
    final spacing = AppDesignSystem.of(context).spacing;
    final screenSize = AppDesignSystem.of(context).screenSize;

    final keyBoxWidth = context.overlayValueByScreenSize(
      mobile: 80.0,
      tablet: 96.0,
      desktop: 120.0,
    );

    final isKeyboardMode =
        SettingsManager.instance.inputSelected == InputActionsType.keyboard;

    return Material(
      color: Colors.transparent,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.all(spacing.padding),
          decoration: BoxDecoration(
            color: const Color(0xAA222222),
            borderRadius: BorderRadius.circular(screenSize.isMobile ? 6 : 8),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToMainMenu(context),
                  child: const Text('Sair para Menu Principal'),
                ),
                if (isKeyboardMode)
                  ...List.generate(
                    TutorialInputsHUDDef.inputGuide.length,
                    (index) => _buildInputRow(
                      context,
                      TutorialInputsHUDDef.inputGuide[index]['key']!,
                      TutorialInputsHUDDef.inputGuide[index]['desc']!,
                      keyBoxWidth,
                      screenSize,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context,
    String key,
    String description,
    double keyBoxWidth,
    ScreenSizeInfo screenSize,
  ) {
    final ds = AppDesignSystem.of(context);
    final spacing = ds.spacing;
    final typography = ds.typography;

    final rowHeight = context.overlayValueByScreenSize(
      mobile: 20.0,
      tablet: 22.0,
      desktop: 26.0,
    );

    final keyBoxHeight = context.overlayValueByScreenSize(
      mobile: 18.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    return Container(
      height: rowHeight,
      margin: EdgeInsets.only(bottom: spacing.spacing / 2),
      child: Row(
        children: [
          Container(
            width: keyBoxWidth,
            height: keyBoxHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(screenSize.isMobile ? 3 : 4),
            ),
            padding: EdgeInsets.symmetric(horizontal: spacing.spacing),
            alignment: Alignment.centerLeft,
            child: Text(
              key,
              style: TextStyle(
                color: const Color(0xFF00FFAA),
                fontWeight: FontWeight.bold,
                fontSize: typography.baseFontSize - 1,
                fontFamily: 'Normal',
              ),
            ),
          ),
          SizedBox(width: spacing.spacing * 1.5),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: typography.baseFontSize,
                fontFamily: 'Normal',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMainMenu(BuildContext context) {
    AudioManager.instance.stopBackgroundMusic();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
