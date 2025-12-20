final class FarmFeedbackDef {
  FarmFeedbackDef._();

  static const String kSoilTilled = 'Soil tilled!';
  static const String kCropWatered = 'Watered!';
  static const String kSeedPlanted = 'Planted!';
  static const String kCannotPlant = 'You can\'t plant here!';
  static const String kGameSaved = 'Game saved!';
  static const String kSaveCleared = 'Save cleared! Restart the game.';

  static const String kInventoryFull = 'Inventory full!';
  static const String kSaveError = 'Error while saving!';
  static const String kClearSaveError = 'Error while clearing save!';

  static String dayAdvanced(int dayNumber) => 'Day $dayNumber!';

  static String cropHarvested(int amount, String itemName) =>
      'Harvested ${amount}x $itemName!';
}
