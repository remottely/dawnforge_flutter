import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class PlayerStateManager {
  PlayerStateManager._();

  static final PlayerStateManager instance = PlayerStateManager._();

  Future<SpriteAnimation>? currentPlayerAnimation;
  DDBasePlayerView? _lastPlayerView;
  DDBasePlayerView? get lastPlayerView => _lastPlayerView;
  void setLastPlayerView(DDBasePlayerView view) => _lastPlayerView = view;

  DDBasePlayerModel? _lastPlayerModel;
  DDBasePlayerModel? get lastPlayerModel => _lastPlayerModel;
  void setLastPlayerModel(DDBasePlayerModel model) => _lastPlayerModel = model;

  bool _respawnWithFullLife = false;

  Map<String, dynamic> toJson() {
    final json = {'playerModel': _lastPlayerModel?.toJson()};
    final life = _lastPlayerModel?.life;
    final stamina = _lastPlayerModel?.stamina;
    final coins = _lastPlayerModel?.coins;
    final position = _lastPlayerModel?.position;

    GameLogger.info(
      '[PlayerStateManager] toJson life=$life, stamina=$stamina, coins=$coins, position=$position, json=$json',
    );
    return json;
  }

  void fromJson(Map<String, dynamic> json) {
    final data = json['playerModel'] as Map<String, dynamic>?;

    if (data == null) {
      _lastPlayerModel = null;
      return;
    }

    // final playerType = data['playerType'] as String?;

    // // switch (playerType) {
    // //   case 'farmer':
    // //     _lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    // //     break;
    // //   case 'cute':
    // //     _lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    // //     break;
    // //   case 'sunny':
    // //     _lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    // //     break;
    // //   case 'demo':
    // //     _lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    // //     break;
    // //   default:
    // //     _lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    // //     break;
    // // }

    // GameLogger.info(
    //   '[PlayerStateManager] fromJson restored type=$playerType, life=${_lastPlayerModel?.life}, stamina=${_lastPlayerModel?.stamina}, coins=${_lastPlayerModel?.coins}, raw=$data',
    // );
  }

  void reset() {
    _lastPlayerModel = null;
    _respawnWithFullLife = false;
  }
}
