deixe o meu codigo mais limpo e profissional e escalavel, se baseie no codigo q enviarei juntamente. quero o codigo completo como resposta.
codigo a ser corrigido:
import 'package:dawnforge/gameplay/core/modules/hud/responsive/responsive_overlay_mixin.dart';
import 'package:dawnforge/gameplay/core/modules/hud/responsive/overlay_responsive_config.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/gameplay/inventory/state/equipment_state.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/state/inventory_state.dart';
import 'package:dawnforge/gameplay/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/gameplay/inventory/entities/hand_item.dart';
import 'package:dawnforge/gameplay/inventory/widgets/item_sprite_widget.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:flutter/material.dart';
import 'package:dawnforge/gameplay/market/market_state.dart';
import 'package:dawnforge/gameplay/market/market_manager.dart';
import 'package:dawnforge/gameplay/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_service.dart';

class InventoryOverlay extends StatelessWidget with ResponsiveOverlayMixin {
  const InventoryOverlay({super.key});

  String get overlayId => 'inventory';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InventoryState.instance.isVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();

        // LayoutBuilder para reagir a mudanças de tamanho em tempo real
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = getScreenSize(context);
            final padding = OverlayResponsiveConfig.getPadding(screenSize);
            final spacing = OverlayResponsiveConfig.getSpacing(screenSize);
            final slotSize = OverlayResponsiveConfig.getSlotSize(screenSize);
            final baseFontSize = OverlayResponsiveConfig.getBaseFontSize(
              screenSize,
            );

            final borderColor = Color(0xff68280d);
            final borderWidth = screenSize == ScreenSize.mobile ? 3.0 : screenSize == ScreenSize.tablet ? 5.0 : 6.0;
            final border = isDesktopScreen(context)
                ? Border(
                    left: BorderSide(color: borderColor, width: borderWidth),
                    top: BorderSide(color: borderColor, width: borderWidth),
                    right: BorderSide(color: borderColor, width: borderWidth),
                  )
                : Border(
                    right: BorderSide(color: borderColor, width: borderWidth),
                  );
            return Material(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xfffebc6e),
                  border: border,
                ),
                child: _buildInventoryGrid(
                  context,
                  spacing,
                  slotSize,
                  baseFontSize,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryGrid(
    BuildContext context,
    double spacing,
    double slotSize,
    double baseFontSize,
  ) {
    // Listen to inventory changes with the actual slots list
    return ValueListenableBuilder<int>(
      valueListenable: getIt<EquipmentManager>().selectedSlotIndexNotifier,
      builder: (context, selectedIndex, _) {
        return ValueListenableBuilder<List<InventorySlot>>(
          valueListenable: getIt<InventoryManager>().slotsNotifier,
          builder: (context, slots, _) {
            return ValueListenableBuilder<HandItem?>(
              valueListenable: EquipmentState.instance.equippedItem,
              builder: (context, equippedItem, child) {
                // Desktop: 1 linha horizontal com rolagem horizontal
                if (isDesktopScreen(context)) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(slots.length, (index) {
                        final slot = slots[index];
                        // return Padding(
                        //   padding: EdgeInsets.only(
                        //     right: index < slots.length - 1 ? spacing : 0,
                        //   ),
                        //   child:
                        return _buildInventorySlot(
                          index,
                          spacing,
                          slotSize,
                          baseFontSize,
                          slot,
                          slot.item,
                          slot.quantity,
                          equippedItem,
                          selectedIndex,
                          // ),
                        );
                      }),
                    ),
                  );
                } else {
                  // Mobile e Tablet: 1 coluna vertical com rolagem vertical
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(slots.length, (index) {
                        final slot = slots[index];
                        // return Padding(
                        //   padding: EdgeInsets.only(
                        //     bottom: index < slots.length - 1 ? spacing : 0,
                        //   ),
                        //   child:
                        return _buildInventorySlot(
                          index,
                          spacing,
                          slotSize,
                          baseFontSize,
                          slot,
                          slot.item,
                          slot.quantity,
                          equippedItem,
                          selectedIndex,
                          // ),
                        );
                      }),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInventorySlot(
    int index,
    double spacing,
    double slotSize,
    double baseFontSize,
    InventorySlot slot,
    HandItem? item,
    int? quantity,
    HandItem? equippedItem,
    int selectedIndex,
  ) {
    // Color slotColor = item != null ? Color(0xfff2a65e) : Color(0xffba6156);
    // Color slotColor = item != null ? Color(0xfffebc6e) : Color(0xfff5aa66);
    // Cor para índices pares vs ímpares
    Color slotColor = index % 2 == 0
        ? Color(0xfffebc6e) // Cor para índices pares (0, 2, 4, 6...)
        : Color(0xfff5aa66); // Cor para índices ímpares (1, 3, 5, 7...)

    if (item != null && equippedItem != null && equippedItem.id == item.id) {
      slotColor = Colors.red.withOpacity(0.5);
    }

    final isSelected = selectedIndex == slot.index;

    // Get slot number label (1-9, 0 for slot 10, - for slot 11, + for slot 12)
    String? slotNumberLabel;
    if (slot.index < 9) {
      slotNumberLabel = '${slot.index + 1}';
    } else if (slot.index == 9) {
      slotNumberLabel = '0';
    } else if (slot.index == 10) {
      slotNumberLabel = '-';
    } else if (slot.index == 11) {
      slotNumberLabel = '+';
    }

    return GestureDetector(
      onTap: () => _handleTap(slot),
      child: Container(
        width: slotSize * 1.2,
        height: slotSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : slotColor,
          // border: Border.all(color: Colors.black, width: 1),
        ),
        child: Stack(
          children: [
            // Slot number (keyboard shortcut indicator)
            if (slotNumberLabel != null)
              Positioned(
                top: 1,
                left: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing / 2,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    slotNumberLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: baseFontSize - 4,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Normal',
                    ),
                  ),
                ),
              ),
            if (item != null) ...[
              // Item icon or abbreviation
              Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing),
                  child: ItemSpriteWidget(
                    iconData: item.iconData,
                    size: slotSize - (spacing * 2),
                  ),
                ),
              ),
              // Quantity indicator
              if (quantity != null && quantity > 1)
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing / 2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'x$quantity',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: baseFontSize - 4,
                        fontFamily: 'Normal',
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // static String _abbreviateItemName(String name) {
  //   if (name.length <= 4) return name;

  //   final words = name.split(' ');
  //   if (words.length > 1) {
  //     return words.map((w) => w.isNotEmpty ? w[0] : '').join('').toUpperCase();
  //   }

  //   return name.substring(0, 4).toUpperCase();
  // }

  void _handleTap(InventorySlot slot) {
    // Venda ao tocar quando o market estiver aberto e houver item vendável.
    if (MarketState.instance.isOpen.value) {
      if (slot.isEmpty || slot.item == null) {
        OverlayMessageService.instance.showError('Slot vazio.');
        return;
      }

      final item = slot.item!;
      final player =
          MarketState.instance.activePlayer.value ??
          PlayerStateManager.instance.lastPlayerModel;
      if (player == null) {
        OverlayMessageService.instance.showError('Player não disponível.');
        return;
      }

      if (!MarketManager.instance.canSellItem(
        item.id,
        getIt<InventoryManager>(),
      )) {
        OverlayMessageService.instance.showError(
          'Item não vendável no market.',
        );
        return;
      }

      final result = MarketManager.instance.sellItem(
        item.id,
        1,
        player,
        getIt<InventoryManager>(),
      );

      if (result.success) {
        OverlayMessageService.instance.showSuccess(result.message);
      } else {
        OverlayMessageService.instance.showError(result.message);
      }

      // Não deixa equipar/usar enquanto o market está aberto.
      return;
    }

    // Comportamento normal: selecionar slot / equipar.
    getIt<EquipmentManager>().selectSlotIndex(slot.index);
  }
}

codigo de referencia:
/// **AuthForm - Composite Pattern**
/// • extraFields dinâmicos por Page • MVVM + Loading
import 'package:flutter/material.dart';
import 'package:widget_composition_guide/auth/components/auth_form_viewmodel.dart';
import 'package:widget_composition_guide/design_system/components/app_elevated_button.dart';
import 'package:widget_composition_guide/design_system/components/app_text_field.dart';
import 'package:widget_composition_guide/design_system/theme/app_design_system.dart';

/// **COMPOSITION CORE:** Login = [], SignUp = [3 campos]
class AuthForm extends StatefulWidget {
  final String title;
  final String buttonLabel;
  final VoidCallback onButtonSubmit;

  /// **COMPOSITION CORE - extraFields**
  final List<Widget> extraFields;

  const AuthForm({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onButtonSubmit,
    this.extraFields = const [],
  });

  @override
  State<AuthForm> createState() => _AuthFormView();
}

/// **View:** ...extraFields (spread operator) + Loading binding
class _AuthFormView extends AuthFormViewModel {
  @override
  Widget build(BuildContext context) {
    final spacing = AppDesignSystem.of(context).spacing;

    return Column(
      spacing: spacing.authFormContent,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        _Fields(extraFields: widget.extraFields),

        _Button(
          labelText: widget.buttonLabel,
          onPressed: handleSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _Fields extends StatelessWidget {
  final List<Widget> extraFields;

  const _Fields({required this.extraFields});

  @override
  Widget build(BuildContext context) {
    final spacing = AppDesignSystem.of(context).spacing;

    return Column(
      spacing: spacing.authFormFields,
      children: [
        const AppTextField(labelText: 'Email'),
        const AppTextField(labelText: 'Senha', isPassword: true),

        // COMPOSITION: spread operator
        ...extraFields,
      ],
    );
  }
}

/// **Loading States:** CircularProgressIndicator ↔ AppElevatedButton
class _Button extends StatelessWidget {
  final String labelText;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _Button({
    required this.labelText,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = AppDesignSystem.of(context).sizes.buttonHeight;

    return isLoading
        ? Center(
            child: SizedBox(
              height: buttonHeight,
              width: buttonHeight,
              child: CircularProgressIndicator(),
            ),
          )
        : AppElevatedButton(
            onPressed: isLoading ? null : onPressed,
            labelText: labelText,
            fullWidth: true,
          );
  }
}
