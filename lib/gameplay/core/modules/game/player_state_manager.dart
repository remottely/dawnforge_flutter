import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class PlayerStateManager {
  PlayerStateManager._();

  static final instance = PlayerStateManager._();

  Future<SpriteAnimation>? currentPlayerAnimation;
  DDBasePlayerView? lastPlayerView;
  DDBasePlayerModel? lastPlayerModel;

  Map<String, dynamic> toJson() {
    return {'playerModel': lastPlayerModel?.toJson()};
  }

  void fromJson(Map<String, dynamic> json) {
    if (json['playerModel'] != null) {
      lastPlayerModel = SunnyPlayerModel.fromJson(
        json['playerModel'] as Map<String, dynamic>,
      );
    }
  }

  void reset() {
    lastPlayerModel = null;
  }
}
