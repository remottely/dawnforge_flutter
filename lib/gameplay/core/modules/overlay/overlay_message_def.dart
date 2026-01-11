import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_service.dart';
import 'package:flutter/material.dart';

final class OverlayMessageDef {
  OverlayMessageDef._();

  /// Message durations
  static const Duration kDefaultWarningDuration = Duration(milliseconds: 1500);
  static const Duration kDefaultErrorDuration = Duration(milliseconds: 2000);
  static const Duration kDefaultInfoDuration = Duration(milliseconds: 1500);
  static const Duration kDefaultSuccessDuration = Duration(milliseconds: 1500);

  /// Message colors
  static const Color kWarningColor = Colors.orange;
  static const Color kErrorColor = Colors.red;
  static const Color kInfoColor = Colors.blue;
  static const Color kSuccessColor = Colors.green;

  /// Common messages
  static const String kNoStaminaMessage = 'Sem Stamina! Recarregue ficando perto de uma tocha!';
  static const String kNoKeysMessage = 'Você não tem chaves!';
  static const String kCannotDigMessage = 'Não é possível cavar aqui!';
  static const String kCannotWaterMessage = 'Não é possível regar aqui!';
  static const String kCannotPlantMessage = 'Não é possível plantar aqui!';
  static const String kCannotHarvestMessage = 'Não há nada para colher!';

  /// Message display methods
  static void showNoStamina() {
    OverlayMessageService.instance.showWarning(
      kNoStaminaMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showNoKeys() {
    OverlayMessageService.instance.showWarning(
      kNoKeysMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotDig() {
    OverlayMessageService.instance.showWarning(
      kCannotDigMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotWater() {
    OverlayMessageService.instance.showWarning(
      kCannotWaterMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotPlant() {
    OverlayMessageService.instance.showWarning(
      kCannotPlantMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotHarvest() {
    OverlayMessageService.instance.showWarning(
      kCannotHarvestMessage,
      duration: kDefaultWarningDuration,
    );
  }
}
