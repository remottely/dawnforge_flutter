import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';

class KnightHandSlotConfig {
  const KnightHandSlotConfig({
    required this.attachmentOffset,
    required this.facingRightOffset,
    required this.facingLeftOffset,
    this.facingRightScaleX = 1.0,
    this.facingLeftScaleX = -1.0,
  });

  final Vector2 attachmentOffset;
  final Vector2 facingRightOffset;
  final Vector2 facingLeftOffset;
  final double facingRightScaleX;
  final double facingLeftScaleX;

  KnightHandSlotConfig copyWith({
    Vector2? attachmentOffset,
    Vector2? facingRightOffset,
    Vector2? facingLeftOffset,
    double? facingRightScaleX,
    double? facingLeftScaleX,
  }) {
    return KnightHandSlotConfig(
      attachmentOffset: attachmentOffset ?? this.attachmentOffset,
      facingRightOffset: facingRightOffset ?? this.facingRightOffset,
      facingLeftOffset: facingLeftOffset ?? this.facingLeftOffset,
      facingRightScaleX: facingRightScaleX ?? this.facingRightScaleX,
      facingLeftScaleX: facingLeftScaleX ?? this.facingLeftScaleX,
    );
  }

  Vector2 resolvePosition(Vector2 ownerPosition, {required bool facingRight}) {
    final directionalOffset = facingRight
        ? facingRightOffset
        : facingLeftOffset;
    return ownerPosition + attachmentOffset + directionalOffset;
  }

  double resolveScaleX({required bool facingRight}) {
    return facingRight ? facingRightScaleX : facingLeftScaleX;
  }
}

class KnightHandItemConfig {
  KnightHandItemConfig({
    required this.id,
    required this.spritePath,
    required this.size,
    required this.slotConfigurations,
    this.defaultAttackDuration = const Duration(milliseconds: 500),
    this.baseAngle = 0.0,
    this.maxRotationAngle = math.pi / 3,
    this.windUpFraction = 0.1,
    this.strikeFraction = 0.2,
    this.recoveryFraction = 0.7,
    this.priorityOffset = 1,
  }) : assert(
         slotConfigurations.isNotEmpty,
         'Provide at least one slot configuration.',
       ),
       assert(
         (() {
           final total = windUpFraction + strikeFraction + recoveryFraction;
           return (total - 1.0).abs() < 0.0001;
         })(),
         'Animation fractions must sum to 1.0',
       );

  final String id;
  final String spritePath;
  final Vector2 size;
  final Map<KnightHandSlot, KnightHandSlotConfig> slotConfigurations;
  final Duration defaultAttackDuration;
  final double baseAngle;
  final double maxRotationAngle;
  final double windUpFraction;
  final double strikeFraction;
  final double recoveryFraction;
  final int priorityOffset;

  KnightHandSlotConfig configurationFor(KnightHandSlot slot) {
    if (slotConfigurations.containsKey(slot)) {
      return slotConfigurations[slot]!;
    }

    if (slotConfigurations.containsKey(KnightHandSlot.right)) {
      return slotConfigurations[KnightHandSlot.right]!;
    }

    return slotConfigurations.values.first;
  }
}
