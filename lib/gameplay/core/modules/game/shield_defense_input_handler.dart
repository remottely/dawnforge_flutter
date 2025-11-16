import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:flutter/services.dart';

/// Componente que gerencia a defesa com escudo via input de teclado
///
/// Detecta quando Z está pressionado e bloqueia todos os outros inputs
/// enquanto o player está defendendo.
class ShieldDefenseInputHandler extends GameComponent
    with KeyboardEventListener {
  bool _isDefending = false;

  bool get isDefending => _isDefending;

  /// Busca o player atual a cada chamada para garantir compatibilidade com troca de mapas
  KnightPlayerView? _getCurrentPlayer() {
    final players = gameRef.query<KnightPlayerView>();
    return players.isNotEmpty ? players.first : null;
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final player = _getCurrentPlayer();
    if (player == null) return false;

    // Detectar Z pressionado (KeyDown)
    if (event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kFireballAttackKey) {
      if (!_isDefending) {
        final success = player.startShieldDefense();
        if (success) {
          _isDefending = true;
          developer.log(
            '[ShieldDefenseInput] ✓ Defesa iniciada - inputs bloqueados',
          );
          _blockPlayerMovement(player);
          return true; // Consumir o evento
        }
      }
      return false;
    }

    // Detectar Z solto (KeyUp)
    if (event is KeyUpEvent &&
        event.logicalKey == KeyboardSetup.kFireballAttackKey) {
      if (_isDefending) {
        player.stopShieldDefense();
        _isDefending = false;
        developer.log(
          '[ShieldDefenseInput] ✓ Defesa finalizada - inputs liberados',
        );
        return true; // Consumir o evento
      }
      return false;
    }

    // Bloquear TODOS os outros inputs enquanto está defendendo
    if (_isDefending) {
      developer.log(
        '[ShieldDefenseInput] ✗ Input bloqueado durante defesa: ${event.logicalKey}',
      );
      return true; // Consumir e bloquear o evento
    }

    return false; // Permitir processamento normal
  }

  /// Bloqueia movimento do player durante defesa
  void _blockPlayerMovement(KnightPlayerView player) {
    // Zerar velocidade do player
    player.idle();

    // Desabilitar controles (se possível via Bonfire)
    // O bloqueio principal é via interceptação de inputs acima
  }

  @override
  void onRemove() {
    // Garantir que defesa seja desativada ao remover componente
    if (_isDefending) {
      final player = _getCurrentPlayer();
      if (player != null) {
        player.stopShieldDefense();
      }
      _isDefending = false;
    }
    super.onRemove();
  }
}
