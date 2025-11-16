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
  KnightPlayerView? _cachedPlayer;

  bool get isDefending => _isDefending;

  @override
  void update(double dt) {
    super.update(dt);

    // Cache do player
    if (_cachedPlayer == null) {
      final players = gameRef.query<KnightPlayerView>();
      if (players.isNotEmpty) {
        _cachedPlayer = players.first;
        developer.log('[ShieldDefenseInput] Player encontrado e cacheado');
      }
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_cachedPlayer == null) return false;

    // Detectar Z pressionado (KeyDown)
    if (event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kFireballAttackKey) {
      if (!_isDefending) {
        final success = _cachedPlayer!.startShieldDefense();
        if (success) {
          _isDefending = true;
          developer.log(
            '[ShieldDefenseInput] ✓ Defesa iniciada - inputs bloqueados',
          );
          _blockPlayerMovement();
          return true; // Consumir o evento
        }
      }
      return false;
    }

    // Detectar Z solto (KeyUp)
    if (event is KeyUpEvent &&
        event.logicalKey == KeyboardSetup.kFireballAttackKey) {
      if (_isDefending) {
        _cachedPlayer!.stopShieldDefense();
        _isDefending = false;
        developer.log(
          '[ShieldDefenseInput] ✓ Defesa finalizada - inputs liberados',
        );
        _unblockPlayerMovement();
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
  void _blockPlayerMovement() {
    if (_cachedPlayer == null) return;

    // Zerar velocidade do player
    _cachedPlayer!.idle();

    // Desabilitar controles (se possível via Bonfire)
    // O bloqueio principal é via interceptação de inputs acima
  }

  /// Reabilita movimento do player após defesa
  void _unblockPlayerMovement() {
    // O movimento é reabilitado automaticamente quando
    // os inputs voltam a ser processados normalmente
  }

  @override
  void onRemove() {
    // Garantir que defesa seja desativada ao remover componente
    if (_isDefending && _cachedPlayer != null) {
      _cachedPlayer!.stopShieldDefense();
      _isDefending = false;
    }
    super.onRemove();
  }
}
