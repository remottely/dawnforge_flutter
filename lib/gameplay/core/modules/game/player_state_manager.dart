import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';

class PlayerStateManager {
  PlayerStateManager._();

  static final instance = PlayerStateManager._();

  DDFarmPlayerView? lastFarmPlayerView;
  DDFarmPlayerModel? lastFarmPlayerModel;

  Map<String, dynamic> toJson() {
    return {'sunnyModel': lastFarmPlayerModel?.toJson()};
  }

  void fromJson(Map<String, dynamic> json) {
    if (json['sunnyModel'] != null) {
      lastFarmPlayerModel = SunnyPlayerModel.fromJson(
        json['sunnyModel'] as Map<String, dynamic>,
      );
    }

    developer.log('[PlayerStateManager] State restored from JSON');
  }

  void reset() {
    lastFarmPlayerModel = null;
    developer.log('[PlayerStateManager] State reset');
  }
}
