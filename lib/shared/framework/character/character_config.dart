// lib/shared/framework/character/character_config.dart
import 'package:bonfire/bonfire.dart';

/// Configuração imutável do personagem (não muda durante o jogo)
class CharacterConfig {
  // Visual
  final Vector2 size;
  final RectangleHitbox hitbox;
  final LightingConfig lighting;
  
  // Stats base
  final double maxLife;
  final double baseSpeed;
  final double maxStamina;
  final int maxEnergy;
  
  // Regeneração
  final double staminaRegenRate; // stamina/segundo
  final Duration staminaRegenDebounce;
  
  // Detecção
  final double visionRadius;
  final double longVisionRadius;
  
  // Death
  final GameDecoration Function(Vector2 position)? getDeathMarker;
  
  const CharacterConfig({
    required this.size,
    required this.hitbox,
    required this.lighting,
    required this.maxLife,
    required this.baseSpeed,
    required this.maxStamina,
    required this.maxEnergy,
    this.staminaRegenRate = 1.0,
    this.staminaRegenDebounce = const Duration(milliseconds: 150),
    required this.visionRadius,
    required this.longVisionRadius,
    this.getDeathMarker,
  });
  
  // Factory para criar config padrão
  factory CharacterConfig.player({
    required Vector2 size,
    required RectangleHitbox hitbox,
    required LightingConfig lighting,
    required GameDecoration Function(Vector2 position) getDeathMarker,
    double maxLife = 100.0,
    double baseSpeed = 100.0,
    double maxStamina = 100.0,
    int maxEnergy = 100,
    double staminaRegenRate = 1.0,
    double visionRadius = 200.0,
    double longVisionRadius = 300.0,
  }) {
    return CharacterConfig(
      size: size,
      hitbox: hitbox,
      lighting: lighting,
      maxLife: maxLife,
      baseSpeed: baseSpeed,
      maxStamina: maxStamina,
      maxEnergy: maxEnergy,
      staminaRegenRate: staminaRegenRate,
      visionRadius: visionRadius,
      longVisionRadius: longVisionRadius,
      getDeathMarker: getDeathMarker,
    );
  }
}
