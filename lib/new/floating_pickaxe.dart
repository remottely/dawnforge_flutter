import 'dart:async' as async;
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/new/game_config.dart';

/// Fases da animação de ataque da picareta
enum AttackPhase {
  windUp, // Movimento negativo (preparação)
  strike, // Movimento positivo (golpe)
  recover, // Retorno ao ângulo 0
}

/// Componente de picareta estática na mão direita do knight
/// Inspirado no estilo visual do jogo Forager - rotaciona apenas durante ataques
class FloatingPickaxe extends GameDecoration {
  final GameComponent knight;

  // Configurações de posição estática
  Vector2 staticOffset = Vector2(10, 14); // Posição centralizada
  Vector2 rightOffset = Vector2(-1, 0); // Posição fixa na mão direita
  Vector2 leftOffset = Vector2(1, 0); // Posição fixa na mão esquerda

  // Estado de animação de ataque
  bool isAttacking = false;
  double attackTime = 0.0;
  double attackDuration =
      0.5; // Duração padrão - será sobrescrita pelo AttackSpeedController

  // Configurações de rotação durante ataque
  double baseAngle = 0.0; // Ângulo inicial (posição de repouso)
  double currentRotationAngle = 0.0;
  double maxRotationAngle = math.pi / 3; // 60 graus para cada lado
  AttackPhase currentPhase = AttackPhase.windUp;

  // Callback para notificar sobre mudanças de duração
  void Function(double newDuration)? onAnimationDurationChanged;

  /// Método estático para criar uma instância com sprite assíncrono
  static Future<FloatingPickaxe> create({
    required GameComponent knight,
    String spritePath = 'gameplay/characters/weapons/SolarPoweredHammer.png',
  }) async {
    return FloatingPickaxe._(
      knight: knight,
      sprite: await Sprite.load(spritePath),
    );
  }

  FloatingPickaxe._({required this.knight, required Sprite sprite})
    : super.withSprite(
        sprite: sprite,
        position: knight.position,
        size: GameConfig.pickaxeSize,
      ) {
    // Configura anchor para centralizar
    anchor = Anchor.bottomCenter;

    // Espelha a sprite horizontalmente (flip) para ficar virada para a direita
    scale.x = -1.0; // Inverte horizontalmente
  }

  // Override do priority para garantir que sempre fique acima do knight
  @override
  int get priority => LayerPriority.getComponentPriority(1000); // Prioridade extremamente alta

  @override
  void update(double dt) {
    super.update(dt);

    if (knight.isRemoved) {
      removeFromParent();
      return;
    }

    // Atualiza posição baseada na direção
    _updatePosition();

    // Atualiza animação de ataque se estiver ativa
    if (isAttacking) {
      updateAttackAnimation(dt);
    } else {
      // Quando não está atacando, mantém ângulo base (0)
      angle = baseAngle;
    }

    // Debug: Log status da animação para monitoramento
    if (isAttacking && attackTime > attackDuration + 0.1) {
      stopAttackAnimation();
    }
  }

  /// Atualiza a posição da picareta baseada na direção atual
  void _updatePosition() {
    Vector2 currentOffset = isFacingRight ? rightOffset : leftOffset;
    position = knight.position + staticOffset + currentOffset;
  }

  /// Retorna o offset correto baseado na direção
  Vector2 get _currentDirectionOffset =>
      isFacingRight ? rightOffset : leftOffset;

  /// Retorna a posição ideal da picareta
  Vector2 get idealPosition =>
      knight.position + staticOffset + _currentDirectionOffset;

  /// Inicia animação de ataque da picareta estilo Forager
  /// [customDuration] - Duração customizada da animação (opcional)
  void startAttackAnimation({Duration? customDuration}) {
    if (isAttacking) {
      return;
    }

    // Atualiza duração se fornecida
    if (customDuration != null) {
      updateAnimationDuration(customDuration);
    }

    isAttacking = true;
    attackTime = 0.0;
    currentPhase = AttackPhase.windUp;

    // Agenda o fim da animação
    async.Timer(Duration(milliseconds: (attackDuration * 1000).round()), () {
      stopAttackAnimation();
    });
  }

  /// Atualiza a duração da animação dinamicamente
  void updateAnimationDuration(Duration newDuration) {
    double newDurationSeconds = newDuration.inMilliseconds / 1000.0;

    if ((newDurationSeconds - attackDuration).abs() > 0.01) {
      // Só atualiza se há diferença significativa
      attackDuration = newDurationSeconds;
      onAnimationDurationChanged?.call(attackDuration);
    }
  }

  /// Obtém a duração atual da animação
  Duration get currentAnimationDuration =>
      Duration(milliseconds: (attackDuration * 1000).round());

  /// Para a animação de ataque e restaura valores normais
  void stopAttackAnimation() {
    isAttacking = false;
    attackTime = 0.0;
    currentRotationAngle = 0.0;
    angle = baseAngle;
  }

  /// Atualiza a animação durante o ataque - 3 fases com delays e debounce
  /// Considera a direção da picareta para inverter a animação
  void updateAttackAnimation(double dt) {
    attackTime += dt;

    double progress = (attackTime / attackDuration).clamp(0.0, 1.0);

    // Fases com tempos diferentes para criar o efeito desejado:
    // 20% - Delay inicial (carregamento/preparação)
    // 30% - Golpe rápido para frente
    // 50% - Retorno com debounce suave

    double windUpPhase = 0.1; // 10% do tempo para carregamento
    double strikePhase = 0.2; // 20% do tempo para golpe
    double recoveryPhase = 0.7; // 70% do tempo para retorno suave

    // Fator de direção: 1 para direita, -1 para esquerda
    double directionMultiplier = isFacingRight ? 1.0 : -1.0;

    if (progress < windUpPhase) {
      // Fase 1: Wind-up com delay - movimento muito sutil para trás
      currentPhase = AttackPhase.windUp;
      double phaseProgress = (progress / windUpPhase);

      // Delay inicial (80% do tempo sem movimento, 20% movimento leve)
      double delayedProgress = 0.0;
      if (phaseProgress > 0.8) {
        delayedProgress =
            (phaseProgress - 0.8) / 0.2; // Normaliza os últimos 20%
      }

      double easedProgress = _easeInQuad(delayedProgress);
      // Inverte a preparação baseado na direção
      currentRotationAngle =
          -maxRotationAngle *
          0.3 *
          easedProgress *
          directionMultiplier; // Preparação invertida para esquerda
    } else if (progress < windUpPhase + strikePhase) {
      // Fase 2: Strike - golpe rápido e direto para frente
      currentPhase = AttackPhase.strike;
      double phaseProgress = ((progress - windUpPhase) / strikePhase);
      double easedProgress = _easeOutQuart(
        phaseProgress,
      ); // Movimento rápido e direto

      double startAngle =
          -maxRotationAngle *
          0.3 *
          directionMultiplier; // Começa do final da fase anterior
      currentRotationAngle =
          startAngle +
          (maxRotationAngle *
              1.3 *
              easedProgress *
              directionMultiplier); // Golpe invertido para esquerda
    } else {
      // Fase 3: Recovery - retorno com debounce suave
      currentPhase = AttackPhase.recover;
      double phaseProgress =
          ((progress - windUpPhase - strikePhase) / recoveryPhase);
      double easedProgress = _easeOutBounce(phaseProgress); // Debounce suave

      double startAngle =
          maxRotationAngle * directionMultiplier; // Começa do ângulo máximo
      currentRotationAngle =
          startAngle * (1.0 - easedProgress); // Volta suavemente ao 0
    }

    // Aplica a rotação
    angle = baseAngle + currentRotationAngle;
  }

  /// Função de easing quadrática para entrada (delay suave)
  double _easeInQuad(double t) {
    return t * t;
  }

  /// Função de easing quarta potência para saída rápida (golpe direto)
  double _easeOutQuart(double t) {
    return 1.0 - math.pow(1.0 - t, 4.0);
  }

  /// Função de easing com bounce para saída suave (debounce)
  double _easeOutBounce(double t) {
    const double n1 = 7.5625;
    const double d1 = 2.75;

    if (t < 1 / d1) {
      return n1 * t * t;
    } else if (t < 2 / d1) {
      return n1 * (t -= 1.5 / d1) * t + 0.75;
    } else if (t < 2.5 / d1) {
      return n1 * (t -= 2.25 / d1) * t + 0.9375;
    } else {
      return n1 * (t -= 2.625 / d1) * t + 0.984375;
    }
  }

  /// Altera temporariamente a cor da picareta (para feedback visual)
  void flashColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 200),
  }) {
    add(
      ColorEffect(
        color.withValues(alpha: 0.7),
        EffectController(duration: duration.inMilliseconds / 1000.0),
      ),
    );
  }

  /// Customiza a aparência da picareta
  void customizeAppearance({
    Vector2? newSize,
    Vector2? newStaticOffset,
    Vector2? newRightOffset,
    Vector2? newLeftOffset,
    double? newMaxRotationAngle,
    Duration? newAttackDuration, // Agora recebe Duration ao invés de double
  }) {
    if (newSize != null) {
      GameConfig.pickaxeSize = newSize;
      size = newSize;
    }
    if (newStaticOffset != null) staticOffset = newStaticOffset;
    if (newRightOffset != null) rightOffset = newRightOffset;
    if (newLeftOffset != null) leftOffset = newLeftOffset;
    if (newMaxRotationAngle != null) maxRotationAngle = newMaxRotationAngle;
    if (newAttackDuration != null) updateAnimationDuration(newAttackDuration);

    // Atualiza posição após mudanças
    _updatePosition();
  }

  /// Registra callback para mudanças de duração
  void setOnAnimationDurationChangedCallback(
    void Function(double newDuration)? callback,
  ) {
    onAnimationDurationChanged = callback;
  }

  /// Ajusta apenas os offsets de direção (método conveniente)
  void adjustDirectionOffsets({Vector2? rightOffset, Vector2? leftOffset}) {
    if (rightOffset != null) this.rightOffset = rightOffset;
    if (leftOffset != null) this.leftOffset = leftOffset;
    _updatePosition();
  }

  /// Atualiza o sprite da picareta (para quando fornecer o sprite real)
  Future<void> updateSprite(String spritePath) async {
    sprite = await Sprite.load(spritePath);
  }

  /// Controla a direção da picareta (espelhamento)
  void setDirection({required bool facingRight}) {
    // Só atualiza se a direção realmente mudou
    if (isFacingRight != facingRight) {
      scale.x = facingRight
          ? -1.0
          : 1.0; // -1.0 = direita (flip), 1.0 = esquerda (normal)

      // Atualiza a posição imediatamente após mudar direção
      _updatePosition();
    }
  }

  /// Verifica se a picareta está virada para a direita
  bool get isFacingRight => scale.x < 0;

  /// Converte para direita (método utilitário)
  void faceRight() => setDirection(facingRight: true);

  /// Converte para esquerda (método utilitário)
  void faceLeft() => setDirection(facingRight: false);

  /// Alterna a direção atual
  void toggleDirection() => setDirection(facingRight: !isFacingRight);

  /// Retorna uma string representando a direção atual
  String get directionString => isFacingRight ? "right" : "left";

  /// Debug: Informações sobre a picareta
  Map<String, dynamic> get debugInfo => {
    'priority': priority,
    'direction': directionString,
    'isAttacking': isAttacking,
    'position':
        '${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)}',
    'angle': '${(angle * 180 / math.pi).toStringAsFixed(1)}°',
  };

  /// Força um priority ainda mais alto se necessário - reinicia o componente
  void forceHighPriority() {
    removeFromParent();
    if (parent != null) {
      parent!.add(this);
    }
  }

  /// Redefine o priority para o valor padrão alto - reinicia o componente
  void resetPriority() {
    removeFromParent();
    if (parent != null) {
      parent!.add(this);
    }
  }
}
