import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/combat/shield_defense_component.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_view.dart';

/// Abstract view for players with dual-hand equipment system.
///
/// Extends hybrid combat player to add equipment management through a
/// dual-hand system. This class coordinates combat actions with equipped
/// items, delegating attack execution to the appropriate hand/item based
/// on the attack trigger type.
///
/// Features:
/// - Dual-hand equipment management (left/right slots)
/// - Attack routing through equipment system
/// - Equipment-based combat execution
/// - Customizable equipment loadouts
///
/// Type Parameters:
/// - [C] The specific controller type extending DDCombatPlayerController
/// - [M] The specific model type extending DDCombatPlayerModel
abstract class DDDefensePlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDCombatPlayerView<C, M> {
  DDDefensePlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.speed,
  });

  // ============================================================================
  // Lifecycle Override - Equipment Initialization
  // ============================================================================

  @override
  void update(double dt) {
    if (isDead) return;

    // Update controller (handles stamina regen, enemy detection)
    controller.update(dt);

    // Call parent update (handles movement and other SimplePlayer logic)
    super.update(dt);
  }

  // ============================================================================
  // Combat & Damage Handling Override
  // ============================================================================

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    // Bloquear dano se está defendendo com escudo
    if (isDefending) {
      // Mostrar feedback visual de bloqueio (sem aplicar dano)
      showDamage(
        0,
        config: const TextStyle(
          color: Color(0xFF00FFFF), // Ciano para indicar bloqueio
          fontSize: 12,
        ),
      );
      return; // Não chama super, bloqueando o dano
    }

    // Processar dano normalmente se não está defendendo
    super.onReceiveDamage(attacker, damage, id);
  }

  // ============================================================================
  // Public Equipment API
  // ============================================================================

  // ============================================================================
  // Combat Execution - Equipment System Delegation
  // ============================================================================

  /// defense
  // Sistema de defesa
  ShieldDefenseComponent? _defenseComponent;

  bool _isDefending = false;

  bool get isDefending => _isDefending;

  /// Inicia modo de defesa com escudo
  bool startShieldDefense() {
    return startDefense();
  }

  /// Para modo de defesa com escudo
  void stopShieldDefense() {
    stopDefense();
  }

  /// Inicia o modo de defesa com escudo
  /// Retorna true se conseguiu iniciar (tem escudo equipado)

  /// Inicia o modo de defesa com escudo
  /// Retorna true se conseguiu iniciar (tem escudo equipado)
  bool startDefense() {
    if (_isDefending) return true; // Já está defendendo

    _isDefending = true;

    // Criar componente de defesa se não existir
    if (_defenseComponent == null) {
      _defenseComponent = ShieldDefenseComponent(player: this);
      this.gameRef.add(_defenseComponent!);
    }

    _defenseComponent!.activate();

    return true;
  }

  /// Para o modo de defesa
  void stopDefense() {
    if (!_isDefending) return;

    _stopDefenseInternal();
  }

  void _stopDefenseInternal() {
    _isDefending = false;

    if (_defenseComponent != null) {
      _defenseComponent!.deactivate();
      _defenseComponent!.removeFromParent();
      _defenseComponent = null;
    }
  }
}
