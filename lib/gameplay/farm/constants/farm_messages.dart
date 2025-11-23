/// User-facing messages for farm actions.
///
/// Centralizes all feedback messages to maintain consistency and support
/// future internationalization.
final class FarmMessages {
  FarmMessages._();

  // ============================================================================
  // Success Messages
  // ============================================================================

  static const String kSoilTilled = 'Terra Arada!';
  static const String kCropWatered = 'Regado!';
  static const String kSeedPlanted = 'Plantado!';
  static const String kGameSaved = 'Jogo salvo!';
  static const String kSaveCleared = 'Save limpo! Reinicie o jogo.';

  // ============================================================================
  // Error Messages
  // ============================================================================

  static const String kInventoryFull = 'Inventário cheio!';
  static const String kSaveError = 'Erro ao salvar!';
  static const String kClearSaveError = 'Erro ao limpar save!';

  // ============================================================================
  // Dynamic Messages
  // ============================================================================

  /// Message shown when advancing to a new day.
  static String dayAdvanced(int dayNumber) => 'Dia $dayNumber!';

  /// Message shown when harvesting crops.
  static String cropHarvested(int amount, String itemName) =>
      'Colhido ${amount}x $itemName!';
}
