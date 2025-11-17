import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_animation_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';

/// Preset para equipamentos com animação
///
/// Este preset demonstra como criar um equipamento que usa DUAS animações:
/// - **Idle Animation**: Animação de espera (equipamento parado na mão)
/// - **Attack Animation**: Animação de ataque com frame de execução
///
/// Exemplo de uso:
/// ```dart
/// final swordData = KnightAnimatedWeaponPreset.create(
///   id: 'iron_sword',
///   idlePath: 'weapons/sword_idle_strip4.png',
///   idleFrameCount: 4,
///   attackPath: 'weapons/sword_slash_strip6.png',
///   attackFrameCount: 6,
///   attackFrameIndex: 3,
///   attackDuration: Duration(milliseconds: 400),
///   textureSize: Vector2(64, 64),
///   size: Vector2(64, 64),
///   attachmentOffset: Vector2(0, -16),
///   directionalOffset: Vector2(8, 0),
///   mirroredDirectionalOffset: Vector2(-8, 0),
/// );
/// ```
class KnightAnimatedWeaponPreset {
  KnightAnimatedWeaponPreset._();

  static KnightHandItemData create({
    required String id,
    required String idlePath,
    required int idleFrameCount,
    Duration idleFrameDuration = const Duration(milliseconds: 150),
    required String attackPath,
    required int attackFrameCount,
    required int attackFrameIndex,
    required Duration attackDuration,
    required Vector2 textureSize,
    required Vector2 size,
    required Vector2 attachmentOffset,
    required Vector2 directionalOffset,
    required Vector2 mirroredDirectionalOffset,
  }) {
    // Criar dados das animações (idle + attack)
    final animationData = KnightHandAnimationData(
      idlePath: idlePath,
      idleFrameCount: idleFrameCount,
      idleFrameDuration: idleFrameDuration,
      attackPath: attackPath,
      attackFrameCount: attackFrameCount,
      attackFrameIndex: attackFrameIndex,
      attackDuration: attackDuration,
      textureSize: textureSize,
    );

    // Criar specs para cada slot
    KnightHandSlotSpec buildSlotSpec(KnightHandSlot slot) {
      final isRightHand = slot == KnightHandSlot.right;
      return KnightHandSlotSpec(
        attachmentOffset: attachmentOffset,
        facingRightOffset: isRightHand
            ? mirroredDirectionalOffset
            : directionalOffset,
        facingLeftOffset: isRightHand
            ? directionalOffset
            : mirroredDirectionalOffset,
      );
    }

    return KnightHandItemData(
      id: id,
      animationData: animationData,
      size: size,
      slotSpecs: {
        for (final slot in KnightHandSlot.values) slot: buildSlotSpec(slot),
      },
      // Usar a duração da animação de ataque
      defaultAttackDuration: attackDuration,
    );
  }
}
