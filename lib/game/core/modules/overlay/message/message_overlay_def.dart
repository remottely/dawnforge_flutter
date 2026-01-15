import 'package:dawnforge/game/core/modules/overlay/message/message_overlay_service.dart';
import 'package:flutter/material.dart';

final class MessageOverlayDef {
  MessageOverlayDef._();

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
  static const String kNoStaminaMessage =
      'Sem Stamina! Recarregue ficando perto de uma tocha!';
  static const String kNoKeysMessage = 'Você não tem chaves!';
  static const String kCannotDigMessage = 'Não é possível cavar aqui!';
  static const String kCannotWaterMessage = 'Não é possível regar aqui!';
  static const String kCannotPlantMessage = 'Não é possível plantar aqui!';
  static const String kCannotHarvestMessage = 'Não há nada para colher!';

  /// Message display methods
  static void showNoStamina() {
    MessageOverlayService.instance.showWarning(
      kNoStaminaMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showNoKeys() {
    MessageOverlayService.instance.showWarning(
      kNoKeysMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotDig() {
    MessageOverlayService.instance.showWarning(
      kCannotDigMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotWater() {
    MessageOverlayService.instance.showWarning(
      kCannotWaterMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotPlant() {
    MessageOverlayService.instance.showWarning(
      kCannotPlantMessage,
      duration: kDefaultWarningDuration,
    );
  }

  static void showCannotHarvest() {
    MessageOverlayService.instance.showWarning(
      kCannotHarvestMessage,
      duration: kDefaultWarningDuration,
    );
  }
}
