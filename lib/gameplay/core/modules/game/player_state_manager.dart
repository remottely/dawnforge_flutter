import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class PlayerStateManager {
  PlayerStateManager._();

  static final instance = PlayerStateManager._();

  Future<SpriteAnimation>? currentPlayerAnimation;
  DDBasePlayerView? lastPlayerView;
  DDBasePlayerModel? lastPlayerModel;
  bool _respawnWithFullLife = false;

  Map<String, dynamic> toJson() {
    return {'playerModel': lastPlayerModel?.toJson()};
  }

  void fromJson(Map<String, dynamic> json) {
    final data = json['playerModel'] as Map<String, dynamic>?;

    if (data == null) {
      lastPlayerModel = null;
      return;
    }

    final playerType = data['playerType'] as String?;

    switch (playerType) {
      case 'farmer':
        lastPlayerModel = FarmerPlayerModel.fromJson(data);
        break;
      case 'cute':
        lastPlayerModel = CutePlayerModel.fromJson(data);
        break;
      case 'sunny':
      default:
        lastPlayerModel = SunnyPlayerModel.fromJson(data);
        break;
    }
  }

  void reset() {
    lastPlayerModel = null;
    _respawnWithFullLife = false;
  }
}
