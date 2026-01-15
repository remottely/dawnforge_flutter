import 'package:dawnforge/game/core/modules/save/save_data_model.dart';

abstract interface class ISaveDataCollector {
  SaveData collectGameState();

  bool validateManagerStates();

  String getStateSummary();
}
