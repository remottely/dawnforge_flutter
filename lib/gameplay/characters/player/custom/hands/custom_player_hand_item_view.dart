import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

/// View component para knight hand
///
/// Suporta dois modos de renderização:
/// 1. **Sprite Mode** (legado): Renderiza um sprite estático que pode ser rotacionado
/// 2. **Animation Mode** (novo): Renderiza uma animação completa sem rotação
///
/// No modo de animação, a rotação do equipamento é ignorada pois
/// a animação já contém todos os frames do movimento do ataque.
class CustomPlayerHandItemView extends DDDecoration {
  CustomPlayerHandItemView({
    Sprite? initialSprite,
    required super.position,
    required super.size,
    required int Function() priorityResolver,
    required bool isAnimated,
  }) : _priorityResolver = priorityResolver,
       _isAnimated = isAnimated {
    // Usar center para animações, bottomCenter para sprites
    anchor = isAnimated ? Anchor.center : Anchor.bottomCenter;
    if (initialSprite != null) {
      sprite = initialSprite;
    }
  }

  final int Function() _priorityResolver;
  final bool _isAnimated;

  /// Child component para renderizar animação IDLE
  SpriteAnimationComponent? _idleAnimationComponent;

  /// Child component para renderizar animação ATTACK
  SpriteAnimationComponent? _attackAnimationComponent;

  /// Controla se a animação de ataque está tocando
  bool _isAnimationPlaying = false;

  @override
  int get priority => _priorityResolver();

  /// Retorna true se este item usa animação
  bool get isAnimated => _isAnimated;

  /// Retorna true se a animação está tocando atualmente
  bool get isAnimationPlaying => _isAnimationPlaying;

  /// Atualiza o sprite estático (apenas para modo sprite)
  Future<void> updateSprite(String spritePath) async {
    if (_isAnimated) return; // Ignora se está no modo animação
    sprite = await Sprite.load(spritePath);
  }

  /// Define as animações para o componente (idle e attack)
  Future<void> loadHandAnimations({
    required SpriteAnimation idleAnimation,
    required SpriteAnimation attackAnimation,
    required Vector2 textureSize,
  }) async {
    if (!_isAnimated) return;

    // Atualizar o tamanho do view para o tamanho real do sprite
    size = textureSize;

    // Remove animações anteriores se existirem
    _idleAnimationComponent?.removeFromParent();
    _attackAnimationComponent?.removeFromParent();

    // Criar componente de animação IDLE com textureSize correto
    // Posição (0,0) relativa ao pai (que já tem anchor center)
    _idleAnimationComponent = SpriteAnimationComponent(
      animation: idleAnimation,
      size: textureSize,
      position: Vector2.zero(), // Posição relativa ao pai
    );
    add(_idleAnimationComponent!);

    // Criar componente de animação ATTACK com textureSize correto (inicialmente invisível)
    // Posição (0,0) relativa ao pai (que já tem anchor center)
    _attackAnimationComponent = SpriteAnimationComponent(
      animation: attackAnimation,
      size: textureSize,
      position: Vector2.zero(), // Posição relativa ao pai
      removeOnFinish: false,
    );
    _attackAnimationComponent!.animationTicker?.paused = true;
    _attackAnimationComponent!.animationTicker?.reset();
    _attackAnimationComponent!.opacity = 0; // Invisível inicialmente
    add(_attackAnimationComponent!);
  }

  /// Inicia a reprodução da animação de ataque
  void playAnimation() {
    if (!_isAnimated || _attackAnimationComponent == null) return;

    // Esconder idle, mostrar attack
    _idleAnimationComponent?.opacity = 0;
    _attackAnimationComponent!.opacity = 1;

    _attackAnimationComponent!.animationTicker?.reset();
    _attackAnimationComponent!.animationTicker?.paused = false;
    _attackAnimationComponent!.animationTicker?.onComplete = () {
      _isAnimationPlaying = false;
      // Voltar para idle
      _attackAnimationComponent?.opacity = 0;
      _idleAnimationComponent?.opacity = 1;
    };
    _isAnimationPlaying = true;
  }

  /// Para a reprodução da animação de ataque
  void stopAnimation() {
    if (!_isAnimated || _attackAnimationComponent == null) return;

    _attackAnimationComponent!.animationTicker?.paused = true;
    _attackAnimationComponent!.animationTicker?.reset();
    _attackAnimationComponent!.opacity = 0;
    _idleAnimationComponent?.opacity = 1;
    _isAnimationPlaying = false;
  }

  /// Retorna o progresso atual da animação de ataque (0.0 a 1.0)
  double get animationProgress {
    if (!_isAnimated || _attackAnimationComponent == null) return 0.0;

    final ticker = _attackAnimationComponent!.animationTicker;
    if (ticker == null) return 0.0;

    final totalTime = ticker.totalDuration();
    if (totalTime <= 0) return 0.0;

    return (ticker.currentIndex / ticker.spriteAnimation.frames.length).clamp(
      0.0,
      1.0,
    );
  }

  @override
  void onRemove() {
    _idleAnimationComponent?.removeFromParent();
    _attackAnimationComponent?.removeFromParent();
    super.onRemove();
  }
}
