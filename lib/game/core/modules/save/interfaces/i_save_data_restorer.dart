import 'package:dawnforge/game/core/modules/save/save_data_model.dart';

abstract interface class ISaveDataRestorer {
  bool restoreGameState(SaveData saveData);

  void resetAllManagers();

  bool validateSaveData(SaveData saveData);
}
