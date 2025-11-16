import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec.dart';

enum KnightAttackTrigger { primary, fireball, shieldDefense }

class KnightAttackExecutionContext {
  final SimplePlayer player;
  final KnightHandSlot slot;
  final KnightHandItemController handController;

  const KnightAttackExecutionContext({
    required this.player,
    required this.slot,
    required this.handController,
  });
}

typedef KnightAttackExecutor =
    FutureOr<void> Function(
      KnightAttackExecutionContext context,
      double damage,
    );

class KnightHandAttackSpec {
  final KnightAttackTrigger trigger;
  final AttackType attackType;
  final SynchronizedAttackSpec syncSpec;
  final KnightAttackExecutor execute;

  const KnightHandAttackSpec({
    required this.trigger,
    required this.attackType,
    required this.syncSpec,
    required this.execute,
  });
}

class KnightHandLoadoutEntry {
  final KnightHandSlot slot;
  final KnightHandItemData itemData;
  final KnightHandAttackSpec? attack;

  const KnightHandLoadoutEntry({
    required this.slot,
    required this.itemData,
    this.attack,
  });
}

class KnightHandLoadoutSetup {
  final List<KnightHandLoadoutEntry> entries;

  const KnightHandLoadoutSetup({required this.entries});

  KnightHandLoadoutEntry? entryFor(KnightHandSlot slot) {
    for (final entry in entries) {
      if (entry.slot == slot) return entry;
    }
    return null;
  }
}
