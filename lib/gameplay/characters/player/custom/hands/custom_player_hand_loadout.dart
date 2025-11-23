import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_item_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec.dart';

enum CustomPlayerAttackTrigger { primary, fireball, shieldDefense }

class CustomPlayerAttackExecutionContext {
  final SimplePlayer player;
  final CustomPlayerHandSlot slot;
  final CustomPlayerItemController handController;

  const CustomPlayerAttackExecutionContext({
    required this.player,
    required this.slot,
    required this.handController,
  });
}

typedef CustomPlayerAttackExecutor =
    FutureOr<void> Function(
      CustomPlayerAttackExecutionContext context,
      double damage,
    );

class CustomPlayerHandAttackSpec {
  final CustomPlayerAttackTrigger trigger;
  final AttackType attackType;
  final SynchronizedAttackSpec syncSpec;
  final CustomPlayerAttackExecutor execute;

  const CustomPlayerHandAttackSpec({
    required this.trigger,
    required this.attackType,
    required this.syncSpec,
    required this.execute,
  });
}

class CustomPlayerHandLoadoutEntry {
  final CustomPlayerHandSlot slot;
  final CustomPlayerItemData itemData;
  final CustomPlayerHandAttackSpec? attack;

  const CustomPlayerHandLoadoutEntry({
    required this.slot,
    required this.itemData,
    this.attack,
  });
}

class CustomPlayerHandLoadoutSetup {
  final List<CustomPlayerHandLoadoutEntry> entries;

  const CustomPlayerHandLoadoutSetup({required this.entries});

  CustomPlayerHandLoadoutEntry? entryFor(CustomPlayerHandSlot slot) {
    for (final entry in entries) {
      if (entry.slot == slot) return entry;
    }
    return null;
  }
}
