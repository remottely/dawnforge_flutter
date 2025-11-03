import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

/// Config: Constantes, animações e configurações do Chest
/// Não contém lógica de negócio
final class ChestInteractableConfig {
  ChestInteractableConfig._();

  // Constants
  static const double kVisionRadius =
      16.0; // GameplayTileConstants.kTileDimensionStandard
  static const int kVisionCheckInterval = 500;
  static const String kVisionCheckIntervalId = 'SeePlayer';
  static const String kInteractionPromptText = 'Touch me!!';
  static const double kHealAmountPerPotion = 30.0;

  // Component size
  static final Vector2 componentSize = Vector2.all(
    GameplayTileConstants.kTileDimensionStandard * 0.6,
  );

  // Potion spawn positions (relative to chest position)
  static final Vector2 kPotion1Offset = Vector2(
    componentSize.x * 2,
    componentSize.y * -1.5,
  );

  static final Vector2 kPotion2Offset = Vector2(
    componentSize.x * 2,
    componentSize.y * 2,
  );

  // Smoke explosion size
  static final Vector2 smokeExplosionSize = Vector2.all(
    GameplayTileConstants.kTileDimensionStandard * 0.5,
  );

  // Text configuration
  static TextPaint createTextConfig(double componentWidth) => TextPaint(
    style: TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: componentWidth / 2,
    ),
  );

  static Vector2 getTextPosition(
    double componentWidth,
    double componentHeight,
  ) => Vector2(componentWidth / -1.5, -componentHeight);

  // Animations
  static Future<SpriteAnimation> get chestAnimation => SpriteAnimation.load(
    'gameplay/environment/interactables/chest_spritesheet.png',
    SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: 0.1,
      textureSize: Vector2(16, 16),
    ),
  );

  static Future<SpriteAnimation> get emoteAnimation => SpriteAnimation.load(
    CharacterEmoteManager.kExclamationEmoteAsset,
    SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: 0.1,
      textureSize: Vector2(32, 32),
    ),
  );
}
