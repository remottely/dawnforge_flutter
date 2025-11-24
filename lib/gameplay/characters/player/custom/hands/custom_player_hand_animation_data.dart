import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';

/// Configuração de animação para knight hands
///
/// Suporta duas animações:
/// - **Idle Animation**: Animação de espera (equipamento na mão)
/// - **Attack Animation**: Animação de ataque com frame de execução
///
/// Exemplo de uso:
/// ```dart
/// final swordAnimations = CustomPlayerHandAnimationData(
///   idlePath: 'weapons/sword_idle_strip4.png',
///   idleFrameCount: 4,
///   attackPath: 'weapons/sword_slash_strip6.png',
///   attackFrameCount: 6,
///   attackFrameIndex: 3, // Frame onde o dano será aplicado
///   attackDuration: Duration(milliseconds: 400),
/// );
/// ```
class CustomPlayerHandAnimationData {
  /// Caminho do sprite sheet da animação IDLE
  final String idlePath;

  /// Número de frames na animação idle
  final int idleFrameCount;

  /// Duração de cada frame idle (para loop suave)
  final Duration idleFrameDuration;

  /// Caminho do sprite sheet da animação de ATAQUE
  final String attackPath;

  /// Número de frames na animação de ataque
  final int attackFrameCount;

  /// Índice do frame onde o ataque deve ser executado (0-based)
  final int attackFrameIndex;

  /// Duração total da animação de ataque
  final Duration attackDuration;

  /// Tamanho de cada frame no sprite sheet
  final Vector2 textureSize;

  const CustomPlayerHandAnimationData({
    required this.idlePath,
    required this.idleFrameCount,
    this.idleFrameDuration = const Duration(milliseconds: 150),
    required this.attackPath,
    required this.attackFrameCount,
    required this.attackFrameIndex,
    required this.attackDuration,
    required this.textureSize,
  }) : assert(
         attackFrameIndex >= 0 && attackFrameIndex < attackFrameCount,
         'attackFrameIndex must be within frame range',
       );

  /// Cria a animação de IDLE
  Future<SpriteAnimation> loadIdleAnimation() async {
    return SpriteAnimation.load(
      idlePath,
      SpriteAnimationConfig.createCustomData(
        amount: idleFrameCount,
        textureSize: textureSize,
        stepTime: idleFrameDuration.inMilliseconds / 1000,
      ),
    );
  }

  /// Cria a animação de ATAQUE
  Future<SpriteAnimation> loadAttackAnimation() async {
    return SpriteAnimation.load(
      attackPath,
      SpriteAnimationConfig.createCustomData(
        amount: attackFrameCount,
        textureSize: textureSize,
        // stepTime: attackDuration.inMilliseconds / attackFrameCount / 1000,
        stepTime: 0.1,
        loop: false, // Ataque executa apenas UMA VEZ
      ),
    );
  }

  /// Calcula o tempo (em segundos) quando o frame de ataque ocorre
  double get attackFrameTime {
    final timePerFrame =
        attackDuration.inMilliseconds / attackFrameCount / 1000;
    return attackFrameIndex * timePerFrame;
  }

  @override
  String toString() {
    return 'CustomPlayerHandAnimationData('
        'idle: $idlePath ($idleFrameCount frames), '
        'attack: $attackPath ($attackFrameCount frames), '
        'attackFrame: $attackFrameIndex, '
        'duration: ${attackDuration.inMilliseconds}ms'
        ')';
  }
}
