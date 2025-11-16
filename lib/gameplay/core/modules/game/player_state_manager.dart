import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';

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

  KnightPlayerModel? _knightPlayerModel;
  SunnyPlayerModel? _sunnyPlayerModel;

  /// Obter ou criar modelo do Knight
  KnightPlayerModel getKnightModel() {
    _knightPlayerModel ??= KnightPlayerModel();
    return _knightPlayerModel!;
  }

  /// Obter ou criar modelo do Sunny
  SunnyPlayerModel getSunnyModel() {
    _sunnyPlayerModel ??= SunnyPlayerModel();
    return _sunnyPlayerModel!;
  }

  // ============================================================================
  // Serialization (para save/load futuro)
  // ============================================================================

  /// Serializar estado completo para JSON
  Map<String, dynamic> toJson() {
    return {
      'knightModel': _knightPlayerModel?.toJson(),
      'sunnyModel': _sunnyPlayerModel?.toJson(),
    };
  }

  /// Restaurar estado completo de JSON
  void fromJson(Map<String, dynamic> json) {
    if (json['knightModel'] != null) {
      _knightPlayerModel = KnightPlayerModel.fromJson(
        json['knightModel'] as Map<String, dynamic>,
      );
    }

    if (json['sunnyModel'] != null) {
      _sunnyPlayerModel = SunnyPlayerModel.fromJson(
        json['sunnyModel'] as Map<String, dynamic>,
      );
    }

    developer.log('[PlayerStateManager] State restored from JSON');
  }

  /// Resetar todo o estado (novo jogo)
  void reset() {
    _knightPlayerModel = null;
    _sunnyPlayerModel = null;
    developer.log('[PlayerStateManager] State reset');
  }

  /// Debug: Log estado atual
  void debugPrintState() {
    developer.log('[PlayerStateManager] Current State:');
    developer.log('  Knight Life: ${_knightPlayerModel?.life}');
    developer.log('  Sunny Life: ${_sunnyPlayerModel?.life}');
    developer.log(
      '  Knight Model: ${_knightPlayerModel != null ? 'initialized' : 'null'}',
    );
    developer.log(
      '  Sunny Model: ${_sunnyPlayerModel != null ? 'initialized' : 'null'}',
    );
  }
}
