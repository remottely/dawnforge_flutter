import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_animation_data.dart';

class CustomPlayerHandSlotSpec {
  final Vector2 attachmentOffset;
  final Vector2 facingRightOffset;
  final Vector2 facingLeftOffset;
  final double facingRightScaleX;
  final double facingLeftScaleX;

  const CustomPlayerHandSlotSpec({
    required this.attachmentOffset,
    required this.facingRightOffset,
    required this.facingLeftOffset,
    this.facingRightScaleX = 1.0,
    this.facingLeftScaleX = -1.0,
  });

  CustomPlayerHandSlotSpec copyWith({
    Vector2? attachmentOffset,
    Vector2? facingRightOffset,
    Vector2? facingLeftOffset,
    double? facingRightScaleX,
    double? facingLeftScaleX,
  }) {
    return CustomPlayerHandSlotSpec(
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

class CustomPlayerItemData {
  CustomPlayerItemData({
    required this.id,
    this.spritePath,
    this.animationData,
    required this.size,
    required this.slotSpecs,
    this.defaultAttackDuration = const Duration(milliseconds: 500),
    this.baseAngle = 0.0,
    this.maxRotationAngle = math.pi / 3,
    this.windUpFraction = 0.1,
    this.strikeFraction = 0.2,
    this.recoveryFraction = 0.7,
    this.priorityOffset = 1,
  }) : assert(
         spritePath != null || animationData != null,
         'Must provide either spritePath or animationData',
       ),
       assert(
         spritePath == null || animationData == null,
         'Cannot provide both spritePath and animationData',
       ),
       assert(slotSpecs.isNotEmpty, 'Provide at least one slot specification.'),
       assert(
         (() {
           final total = windUpFraction + strikeFraction + recoveryFraction;
           return (total - 1.0).abs() < 0.0001;
         })(),
         'Animation fractions must sum to 1.0',
       );

  final String id;

  /// Caminho do sprite estático (sistema legado)
  /// Mutuamente exclusivo com [animationData]
  final String? spritePath;

  /// Dados da animação (novo sistema)
  /// Mutuamente exclusivo com [spritePath]
  final CustomPlayerHandAnimationData? animationData;

  final Vector2 size;
  final Map<CustomPlayerHandSlot, CustomPlayerHandSlotSpec> slotSpecs;
  final Duration defaultAttackDuration;
  final double baseAngle;
  final double maxRotationAngle;
  final double windUpFraction;
  final double strikeFraction;
  final double recoveryFraction;
  final int priorityOffset;

  /// Retorna true se este item usa animação ao invés de sprite estático
  bool get isAnimated => animationData != null;

  CustomPlayerHandSlotSpec getSpec(CustomPlayerHandSlot slot) {
    if (slotSpecs.containsKey(slot)) {
      return slotSpecs[slot]!;
    }

    if (slotSpecs.containsKey(CustomPlayerHandSlot.right)) {
      return slotSpecs[CustomPlayerHandSlot.right]!;
    }

    return slotSpecs.values.first;
  }
}
