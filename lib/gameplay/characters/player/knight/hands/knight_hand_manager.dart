import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';

class KnightHandManager {
  KnightHandManager({required SimplePlayer owner}) : _owner = owner;

  final SimplePlayer _owner;
  final Map<KnightHandSlot, _KnightHandRuntime> _hands = {};
  final Map<KnightAttackTrigger, KnightHandSlot> _triggerToSlot = {};

  Future<void> applyLoadout(KnightHandLoadoutConfig loadout) async {
    for (final entry in loadout.entries) {
      await applyEntry(entry);
    }
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
      config: entry.itemConfig,
    );

    final view = await itemController.createView();
    _owner.gameRef.add(view);
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
    for (final runtime in _hands.values) {
      runtime.dispose();
    }
    _hands.clear();
    _triggerToSlot.clear();
  }

  void _clearTriggerForSlot(KnightHandSlot slot) {
    _triggerToSlot.removeWhere((_, mappedSlot) => mappedSlot == slot);
  }

  SynchronizedAttackController _createAttackController(
    KnightHandItemController itemController,
    KnightHandAttackConfig attackBinding,
  ) {
    return SynchronizedAttackController(config: attackBinding.syncConfig)
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
  const _KnightHandRuntime({
    required this.itemController,
    this.attackBinding,
    this.attackController,
  });

  final KnightHandItemController itemController;
  final KnightHandAttackConfig? attackBinding;
  final SynchronizedAttackController? attackController;

  void dispose() {
    attackController?.dispose();
    itemController.dispose();
  }
}
