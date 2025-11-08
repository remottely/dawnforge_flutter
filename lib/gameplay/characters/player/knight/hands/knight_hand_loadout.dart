import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

enum KnightAttackTrigger { primary, fireball }

class KnightAttackExecutionContext {
  const KnightAttackExecutionContext({
    required this.player,
    required this.slot,
    required this.handController,
  });

  final SimplePlayer player;
  final KnightHandSlot slot;
  final KnightHandItemController handController;
}

typedef KnightAttackExecutor =
    FutureOr<void> Function(
      KnightAttackExecutionContext context,
      double damage,
    );

class KnightHandAttackConfig {
  const KnightHandAttackConfig({
    required this.trigger,
    required this.attackType,
    required this.syncConfig,
    required this.execute,
  });

  final KnightAttackTrigger trigger;
  final AttackType attackType;
  final SynchronizedAttackData syncConfig;
  final KnightAttackExecutor execute;
}

class KnightHandLoadoutEntry {
  const KnightHandLoadoutEntry({
    required this.slot,
    required this.itemConfig,
    this.attack,
  });

  final KnightHandSlot slot;
  final KnightHandItemConfig itemConfig;
  final KnightHandAttackConfig? attack;
}

class KnightHandLoadoutConfig {
  const KnightHandLoadoutConfig({required this.entries});

  final List<KnightHandLoadoutEntry> entries;

  KnightHandLoadoutEntry? entryFor(KnightHandSlot slot) {
    for (final entry in entries) {
      if (entry.slot == slot) return entry;
    }
    return null;
  }
}
