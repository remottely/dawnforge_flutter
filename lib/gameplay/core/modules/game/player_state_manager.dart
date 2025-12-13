import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

/// Singleton que centraliza o estado persistente do player
///
/// Mantém informações que devem ser preservadas entre:
/// - Transições de mapa
/// - Sessões de jogo (save/load)
///
/// Responsabilidades:
/// - Armazenar modelos dos players (Knight, Sunny)
/// - Prover interface para serialização (save/load)
class PlayerStateManager {
  PlayerStateManager._();

  static final instance = PlayerStateManager._();

  // ============================================================================
  // Player Models (persistentes entre mapas)
  // ============================================================================
  DDFarmPlayerModel? currentPlayerModel; // TODO(Kevin): remove this nullable

  /// Obter ou criar modelo do Sunny
  DDFarmPlayerModel? getFarmModel() {
    // // TODO(Kevin): change it to accept dynamic player configs
    // currentPlayerModel ??=
    //     initialPlayerModel; // TODO(Kevin): remove this nullable
    return currentPlayerModel;
  }

  // ============================================================================
  // Serialization (para save/load futuro)
  // ============================================================================

  /// Serializar estado completo para JSON
  Map<String, dynamic> toJson() {
    return {'sunnyModel': currentPlayerModel?.toJson()};
  }

  /// Restaurar estado completo de JSON
  void fromJson(Map<String, dynamic> json) {
    if (json['sunnyModel'] != null) {
      currentPlayerModel = SunnyPlayerModel.fromJson(
        json['sunnyModel'] as Map<String, dynamic>,
      );
    }

    developer.log('[PlayerStateManager] State restored from JSON');
  }

  /// Resetar todo o estado (novo jogo)
  void reset() {
    currentPlayerModel = null;
    developer.log('[PlayerStateManager] State reset');
  }

  // /// Debug: Log estado atual
  // void debugPrintState() {
  //   developer.log('[PlayerStateManager] Current State:');
  //   developer.log('  Sunny Life: ${_sunnyPlayerModel?.life}');
  //   developer.log(
  //     '  Sunny Model: ${_sunnyPlayerModel != null ? 'initialized' : 'null'}',
  //   );
  // }
}
