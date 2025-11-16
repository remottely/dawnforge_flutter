import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/shield_defense_component.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';

class KnightHandManager {
  KnightHandManager({required SimplePlayer owner}) : _owner = owner;

  final SimplePlayer _owner;
  final Map<KnightHandSlot, _KnightHandRuntime> _hands = {};
  final Map<KnightAttackTrigger, KnightHandSlot> _triggerToSlot = {};

  // Sistema de defesa
  ShieldDefenseComponent? _defenseComponent;
  bool _isDefending = false;
  String? _currentShieldSpritePath;

  bool get isDefending => _isDefending;

  Future<void> applyLoadout(KnightHandLoadoutSetup loadout) async {
    developer.log(
      '[KnightHandManager] Applying loadout with ${loadout.entries.length} entries',
    );

    // 1. Identificar slots que devem ser removidos
    final slotsToRemove = <KnightHandSlot>[];
    for (final slot in _hands.keys) {
      final hasEntry = loadout.entries.any((entry) => entry.slot == slot);
      if (!hasEntry) {
        slotsToRemove.add(slot);
      }
    }

    // 2. Remover slots que não estão mais no loadout
    for (final slot in slotsToRemove) {
      developer.log('[KnightHandManager] Removing slot: $slot');
      final existing = _hands.remove(slot);
      if (existing != null) {
        _clearTriggerForSlot(slot);
        existing.dispose();
        developer.log('[KnightHandManager] ✓ Slot $slot removed and disposed');
      }
    }

    // 3. Adicionar/atualizar novos entries
    for (final entry in loadout.entries) {
      developer.log(
        '[KnightHandManager] Applying entry for slot: ${entry.slot}',
      );
      await applyEntry(entry);
    }

    developer.log(
      '[KnightHandManager] Loadout applied. Active slots: ${_hands.keys.toList()}',
    );
  }

  Future<KnightHandItemController> applyEntry(
    KnightHandLoadoutEntry entry,
  ) async {
    final existing = _hands.remove(entry.slot);
    if (existing != null) {
      _clearTriggerForSlot(entry.slot);
      existing.dispose();
    }

    final itemController = KnightHandItemController(
      owner: _owner,
      slot: entry.slot,
      data: entry.itemData,
    );

    final view = await itemController.createView();
    _owner.gameRef.add(view);

    // Garantir que a direção inicial está correta antes do primeiro update
    final direction = _owner.lastDirection;
    if (direction == Direction.left ||
        direction == Direction.upLeft ||
        direction == Direction.downLeft) {
      itemController.setDirection(facingRight: false);
    } else if (direction == Direction.right ||
        direction == Direction.upRight ||
        direction == Direction.downRight) {
      itemController.setDirection(facingRight: true);
    }

    itemController.update(0);

    final attackBinding = entry.attack;
    SynchronizedAttackController? attackController;
    if (attackBinding != null) {
      attackController = _createAttackController(itemController, attackBinding);
      _triggerToSlot[attackBinding.trigger] = entry.slot;
    } else {
      _clearTriggerForSlot(entry.slot);
    }

    _hands[entry.slot] = _KnightHandRuntime(
      itemController: itemController,
      attackBinding: attackBinding,
      attackController: attackController,
    );

    return itemController;
  }

  bool executeAttack(KnightAttackTrigger trigger, double damage) {
    final slot = _triggerToSlot[trigger];
    if (slot == null) return false;

    final runtime = _hands[slot];
    if (runtime == null ||
        runtime.attackBinding == null ||
        runtime.attackController == null) {
      return false;
    }

    final info = runtime.attackController!.execute(
      runtime.attackBinding!.attackType,
      () => runtime.attackBinding!.execute(
        KnightAttackExecutionContext(
          player: _owner,
          slot: slot,
          handController: runtime.itemController,
        ),
        damage,
      ),
    );

    return info != null;
  }

  KnightHandItemController? handControllerFor(KnightHandSlot slot) =>
      _hands[slot]?.itemController;

  void update(double dt, Vector2 velocity) {
    for (final runtime in _hands.values) {
      runtime.itemController.updateDirectionFromVelocity(velocity);
      runtime.itemController.update(dt);
    }
  }

  void dispose() {
    _stopDefenseInternal();
    for (final runtime in _hands.values) {
      runtime.dispose();
    }
    _hands.clear();
    _triggerToSlot.clear();
  }

  void _clearTriggerForSlot(KnightHandSlot slot) {
    _triggerToSlot.removeWhere((_, mappedSlot) => mappedSlot == slot);
  }

  // ==========================================================================
  // Sistema de Defesa com Escudo
  // ==========================================================================

  /// Inicia o modo de defesa com escudo
  /// Retorna true se conseguiu iniciar (tem escudo equipado)
  bool startDefense() {
    if (_isDefending) return true; // Já está defendendo

    // Verificar se tem escudo no slot de defesa
    final defenseSlot = _triggerToSlot[KnightAttackTrigger.shieldDefense];
    if (defenseSlot == null) {
      developer.log('[KnightHandManager] Sem escudo equipado para defender');
      return false;
    }

    final runtime = _hands[defenseSlot];
    if (runtime == null) {
      developer.log('[KnightHandManager] Runtime de defesa não encontrado');
      return false;
    }

    // Obter sprite path do shield
    // _currentShieldSpritePath = runtime.itemController.data.spritePath;
    _currentShieldSpritePath =
        'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/7_Shield/SteelShield1.png';

    developer.log('[KnightHandManager] Iniciando defesa com escudo');
    _isDefending = true;

    // Criar componente de defesa se não existir
    if (_defenseComponent == null) {
      _defenseComponent = ShieldDefenseComponent(
        player: _owner,
        shieldSpritePath: _currentShieldSpritePath!,
      );
      _owner.gameRef.add(_defenseComponent!);
    }

    _defenseComponent!.activate();

    developer.log('[KnightHandManager] ✓ Defesa ativada - player imune a dano');

    return true;
  }

  /// Para o modo de defesa
  void stopDefense() {
    if (!_isDefending) return;

    developer.log('[KnightHandManager] Parando defesa');
    _stopDefenseInternal();
  }

  void _stopDefenseInternal() {
    _isDefending = false;

    if (_defenseComponent != null) {
      _defenseComponent!.deactivate();
      _defenseComponent!.removeFromParent();
      _defenseComponent = null;
    }

    _currentShieldSpritePath = null;
  }

  // ==========================================================================

  SynchronizedAttackController _createAttackController(
    KnightHandItemController itemController,
    KnightHandAttackSpec attackBinding,
  ) {
    return SynchronizedAttackController(spec: attackBinding.syncSpec)
      ..setOnAnimationDurationChangedCallback(
        itemController.updateAnimationDuration,
      )
      ..setOnAnimationSyncCallback((info) {
        itemController.startAttack(customDuration: info.animationDuration);
      })
      ..setOnAttackDestroyedCallback((_) {
        itemController.stopAttack();
      });
  }
}

class _KnightHandRuntime {
  final KnightHandItemController itemController;
  final KnightHandAttackSpec? attackBinding;
  final SynchronizedAttackController? attackController;

  const _KnightHandRuntime({
    required this.itemController,
    this.attackBinding,
    this.attackController,
  });

  void dispose() {
    attackController?.dispose();
    itemController.dispose();
  }
}
