import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_widget.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/widgets/tutorial_inputs_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/equipment_overlay.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/inventory_overlay.dart';
import 'package:flutter/material.dart';

/// Overlay unificado que organiza todos os componentes da HUD em um grid 3x3
/// Grid com proporções: coluna 1 (flex 1), coluna 2 (flex 2), coluna 3 (flex 1)
/// Linha 1 (flex 1), Linha 2 (flex 2), Linha 3 (flex 1)
class UnifiedGameOverlay extends StatelessWidget with ResponsiveOverlayMixin {
  const UnifiedGameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final flexA = 1;
    final flexB = 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = isDesktopScreen(context);

        return IgnorePointer(
          ignoring: false,
          child: Column(
            children: [
              // Linha 1 (Top) - flex 1
              Expanded(
                flex: flexA,
                child: Row(
                  children: [
                    // Quadrante 1 (Top Left) - flex 1
                    Expanded(
                      flex: flexA,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.red.withOpacity(0.3)
                            : Colors.transparent,
                        child: const SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // Quadrante 2 (Top Center) - flex 2
                    Expanded(
                      flex: flexB,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.transparent,
                        alignment: Alignment.center,
                        child: const OverlayMessageWidget(),
                      ),
                    ),
                    // Quadrante 3 (Top Right) - flex 1
                    Expanded(
                      flex: flexA,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.green.withOpacity(0.3)
                            : Colors.transparent,
                        alignment: Alignment.topRight,
                        child: const EquipmentOverlay(),
                      ),
                    ),
                  ],
                ),
              ),
              // Linha 2 (Middle) - flex 2
              Expanded(
                flex: flexB,
                child: Row(
                  children: [
                    // Quadrante 4 (Middle Left) - flex 1
                    // Mobile/Tablet: InventoryOverlay aqui
                    Expanded(
                      flex: flexA,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.pink.withOpacity(0.3)
                            : Colors.transparent,
                        alignment: Alignment.centerLeft,
                        child: !isDesktop
                            ? const InventoryOverlay()
                            : const SizedBox.shrink(),
                      ),
                    ),
                    // Quadrante 5 (Center) - flex 2
                    Expanded(
                      flex: flexB,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.yellow.withOpacity(0.3)
                            : Colors.transparent,
                        alignment: Alignment.center,
                        child: const TutorialInputsOverlay(),
                      ),
                    ),
                    // Quadrante 6 (Middle Right) - flex 1
                    Expanded(
                      flex: flexA,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.brown.withOpacity(0.3)
                            : Colors.transparent,
                        child: const SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Linha 3 (Bottom) - flex 1
              Expanded(
                flex: flexA,
                child: Row(
                  children: [
                    // Quadrante 7 (Bottom Left) - flex 1
                    Expanded(
                      flex: flexA,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.purple.withOpacity(0.3)
                            : Colors.transparent,
                        child: const SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // Quadrante 8 (Bottom Center) - flex 2
                    // Desktop: InventoryOverlay aqui
                    Expanded(
                      flex: flexB,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.transparent,
                        alignment: Alignment.bottomCenter,
                        child: isDesktop
                            ? const InventoryOverlay()
                            : const SizedBox.shrink(),
                      ),
                    ),
                    // Quadrante 9 (Bottom Right) - flex 1
                    Expanded(
                      flex: flexA,
                      child: Container(
                        color: AppEnvironment.kIsDebugMode
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.transparent,
                        child: const SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
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
  }
}
