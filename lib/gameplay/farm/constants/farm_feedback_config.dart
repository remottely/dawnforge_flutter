final class FarmFeedbackDef {
  FarmFeedbackDef._();

  static const String kSoilTilled = 'Terra Arada!';
  static const String kCropWatered = 'Regado!';
  static const String kSeedPlanted = 'Plantado!';
  static const String kGameSaved = 'Jogo salvo!';
  static const String kSaveCleared = 'Save limpo! Reinicie o jogo.';

  static const String kInventoryFull = 'Inventário cheio!';
  static const String kSaveError = 'Erro ao salvar!';
  static const String kClearSaveError = 'Erro ao limpar save!';

  static String dayAdvanced(int dayNumber) => 'Dia $dayNumber!';

  static String cropHarvested(int amount, String itemName) =>
      'Colhido ${amount}x $itemName!';
}
