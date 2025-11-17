import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';

class KnightHandItemController {
  final GameComponent _owner;
  final KnightHandSlot _slot;
  final KnightHandItemData _data;
  final KnightHandItemModel _model;

  KnightHandItemController({
    required GameComponent owner,
    required KnightHandSlot slot,
    required KnightHandItemData data,
  }) : _owner = owner,
       _data = data,
       _slot = slot,
       _model = _createModel(data, slot) {
    // Detectar direção inicial do player
    if (owner is SimplePlayer) {
      final direction = owner.lastDirection;
      // Se a última direção foi para a esquerda, configurar facingRight = false
      if (direction == Direction.left ||
          direction == Direction.upLeft ||
          direction == Direction.downLeft) {
        _model.facingRight = false;
      } else if (direction == Direction.right ||
          direction == Direction.upRight ||
          direction == Direction.downRight) {
        _model.facingRight = true;
      }
      // Mantém facingRight = true como padrão se a direção for up/down/idle
    }
  }

  KnightHandItemView? _view;

  void Function(Duration duration)? _onAnimationDurationChanged;

  /// Callback executado no frame de ataque (apenas para modo animação)
  void Function()? _onAttackFrameExecute;

  KnightHandSlot get slot => _slot;

  KnightHandItemData get data => _data;

  KnightHandItemView? get view => _view;

  bool get isReady => _view != null && !_view!.isRemoved;

  bool get isAttacking => _model.isAttacking;

  bool get isFacingRight => _model.facingRight;

  Duration get currentAttackDuration => _model.attackDuration;

  Future<KnightHandItemView> createView() async {
    if (_view != null) {
      return _view!;
    }

    // Modo de animação ou sprite
    Sprite? sprite;
    if (_data.spritePath != null) {
      sprite = await Sprite.load(_data.spritePath!);
    }

    final handView = KnightHandItemView(
      initialSprite: sprite,
      position: _initialPosition,
      size: _data.size,
      priorityResolver: _calculatePriority,
      isAnimated: _data.isAnimated,
    );

    // Se for modo animação, carregar AMBAS as animações (idle e attack)
    if (_data.isAnimated && _data.animationData != null) {
      final idleAnimation = await _data.animationData!.createIdleAnimation();
      final attackAnimation = await _data.animationData!
          .createAttackAnimation();
      await handView.loadHandAnimations(
        idleAnimation: idleAnimation,
        attackAnimation: attackAnimation,
        textureSize: _data.animationData!.textureSize,
      );
    }

    handView.scale.x = _model.facingRight
        ? _model.facingRightScaleX
        : _model.facingLeftScaleX;
    _view = handView;
    return handView;
  }

  void update(double dt) {
    final currentView = _view;
    if (currentView == null || currentView.isRemoved) return;

    _updatePosition(currentView);

    // Se for modo de animação, controlar animação e executar callback no frame correto
    if (_data.isAnimated) {
      if (_model.isAttacking) {
        // Iniciar animação apenas UMA VEZ quando o ataque começa
        if (!currentView.isAnimationPlaying && !_model.attackFrameExecuted) {
          currentView.playAnimation();
          developer.log(
            '[HandController] 🎬 Animação iniciada para ${_data.id}',
          );
        }

        // Verificar se atingiu o frame de ataque
        if (!_model.attackFrameExecuted && _data.animationData != null) {
          final progress = currentView.animationProgress;
          final attackFrameProgress =
              _data.animationData!.attackFrameIndex /
              _data.animationData!.attackFrameCount;

          // Executar callback quando atingir ou passar o frame de ataque
          if (progress >= attackFrameProgress) {
            _model.attackFrameExecuted = true;
            developer.log(
              '[HandController] 💥 Frame de ataque atingido! Progress: $progress',
            );
            _onAttackFrameExecute?.call();
          }
        }

        // Verificar se a animação terminou
        if (!currentView.isAnimationPlaying && _model.attackFrameExecuted) {
          developer.log(
            '[HandController] ✓ Animação finalizada, parando ataque',
          );
          stopAttack();
        }
      } else if (currentView.isAnimationPlaying) {
        currentView.stopAnimation();
      }
      return;
    }

    // Modo sprite legado: aplicar rotação manual
    if (!_model.isAttacking) {
      currentView.angle = _model.baseAngle;
      return;
    }

    _advanceAnimation(dt, currentView);
  }

  void startAttack({Duration? customDuration}) {
    if (!isReady || _model.isAttacking) return;

    if (customDuration != null) {
      updateAnimationDuration(customDuration);
    }

    _model.isAttacking = true;
    _model.elapsedSeconds = 0;
  }

  void stopAttack() {
    if (!_model.isAttacking) return;

    _model.resetAnimationState();
    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      currentView.angle = _model.baseAngle;
    }
  }

  void updateAnimationDuration(Duration newDuration) {
    if (_model.attackDuration == newDuration) return;
    _model.updateAttackDuration(newDuration);
    _onAnimationDurationChanged?.call(newDuration);
  }

  void setAnimationDurationChangedCallback(
    void Function(Duration duration)? callback,
  ) {
    _onAnimationDurationChanged = callback;
  }

  /// Define o callback executado no frame de ataque
  /// Este callback é chamado quando a animação atinge o attackFrameIndex
  void setAttackFrameCallback(void Function()? callback) {
    _onAttackFrameExecute = callback;
  }

  void setDirection({required bool facingRight}) {
    if (_model.facingRight == facingRight) {
      return;
    }

    _model.facingRight = facingRight;
    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      currentView.scale.x = facingRight
          ? _model.facingRightScaleX
          : _model.facingLeftScaleX;
      _updatePosition(currentView);

      // Força recálculo da ordem de renderização removendo e readicionando
      // Usamos microtask para evitar condições de corrida durante o frame atual
      final parent = currentView.parent;
      if (parent != null && parent.isMounted) {
        Future.microtask(() {
          if (!currentView.isRemoved && parent.isMounted) {
            currentView.removeFromParent();
            parent.add(currentView);
          }
        });
      }
    }
  }

  void updateDirectionFromVelocity(Vector2 velocity) {
    if (velocity.x.abs() <= 1.0) return;
    setDirection(facingRight: velocity.x > 0);
  }

  void updateOffsets({
    Vector2? attachmentOffset,
    Vector2? facingRightOffset,
    Vector2? facingLeftOffset,
  }) {
    _model.updateOffsets(
      attachmentOffset: attachmentOffset,
      facingRightOffset: facingRightOffset,
      facingLeftOffset: facingLeftOffset,
    );

    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      _updatePosition(currentView);
    }
  }

  Future<void> updateSprite(String spritePath) async {
    await _view?.updateSprite(spritePath);
  }

  void updateScales({double? facingRightScaleX, double? facingLeftScaleX}) {
    _model.updateScales(
      facingRightScaleX: facingRightScaleX,
      facingLeftScaleX: facingLeftScaleX,
    );

    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      currentView.scale.x = _model.facingRight
          ? _model.facingRightScaleX
          : _model.facingLeftScaleX;
    }
  }

  Map<String, dynamic> get debugInfo => {
    'slot': _slot.debugLabel,
    'isReady': isReady,
    'isAttacking': _model.isAttacking,
    'facingRight': _model.facingRight,
    'position': (_view == null
        ? 'uninitialized'
        : '${_view!.position.x.toStringAsFixed(1)}, ${_view!.position.y.toStringAsFixed(1)}'),
    'angleDegrees': _view == null
        ? 'N/A'
        : ((_view!.angle) * 180 / math.pi).toStringAsFixed(1),
    'attackDurationMs': _model.attackDuration.inMilliseconds,
  };

  void dispose() {
    developer.log('[HandController] Disposing hand: $_slot (${_data.id})');
    _view?.removeFromParent();
    _view = null;
    _model.resetAnimationState();
    developer.log('[HandController] ✓ Hand disposed: $_slot');
  }

  int _calculatePriority() {
    final isRightHand = _slot == KnightHandSlot.right;
    final shouldRenderInFront = isRightHand
        ? _model.facingRight
        : !_model.facingRight;

    if (shouldRenderInFront) {
      return _owner.priority + _data.priorityOffset;
    } else {
      return _owner.priority - _data.priorityOffset;
    }
  }

  static KnightHandItemModel _createModel(
    KnightHandItemData data,
    KnightHandSlot slot,
  ) {
    final slotSpec = data.getSpec(slot);
    return KnightHandItemModel(
      attackDuration: data.defaultAttackDuration,
      attachmentOffset: slotSpec.attachmentOffset,
      facingRightOffset: slotSpec.facingRightOffset,
      facingLeftOffset: slotSpec.facingLeftOffset,
      baseAngle: data.baseAngle,
      maxRotationAngle: data.maxRotationAngle,
      windUpFraction: data.windUpFraction,
      strikeFraction: data.strikeFraction,
      recoveryFraction: data.recoveryFraction,
      facingRightScaleX: slotSpec.facingRightScaleX,
      facingLeftScaleX: slotSpec.facingLeftScaleX,
    );
  }

  Vector2 get _directionalOffset =>
      _model.facingRight ? _model.facingRightOffset : _model.facingLeftOffset;

  Vector2 get _initialPosition =>
      _owner.position + _model.attachmentOffset + _directionalOffset;

  void _updatePosition(KnightHandItemView currentView) {
    currentView.position =
        _owner.position + _model.attachmentOffset + _directionalOffset;
  }

  void _advanceAnimation(double dt, KnightHandItemView currentView) {
    _model.elapsedSeconds += dt;
    final totalDurationSeconds = _model.attackDurationSeconds;
    if (totalDurationSeconds <= 0) {
      stopAttack();
      return;
    }

    final progress = (_model.elapsedSeconds / totalDurationSeconds).clamp(
      0.0,
      1.0,
    );
    final directionMultiplier = _model.facingRight ? 1.0 : -1.0;

    final windUpEnd = _model.windUpFraction;
    final strikeEnd = windUpEnd + _model.strikeFraction;

    if (progress < windUpEnd) {
      final phaseProgress = progress / windUpEnd;
      double delayedProgress = 0.0;
      if (phaseProgress > 0.8) {
        delayedProgress = (phaseProgress - 0.8) / 0.2;
      }
      final easedProgress = _easeInQuad(delayedProgress);
      _model.currentRotationAngle =
          -_model.maxRotationAngle * 0.3 * easedProgress * directionMultiplier;
    } else if (progress < strikeEnd) {
      final phaseProgress = (progress - windUpEnd) / _model.strikeFraction;
      final easedProgress = _easeOutQuart(phaseProgress);
      final startAngle = -_model.maxRotationAngle * 0.3 * directionMultiplier;
      _model.currentRotationAngle =
          startAngle +
          (_model.maxRotationAngle * 1.3 * easedProgress * directionMultiplier);
    } else {
      final phaseProgress = (progress - strikeEnd) / _model.recoveryFraction;
      final easedProgress = _easeOutBounce(phaseProgress);
      final startAngle = _model.maxRotationAngle * directionMultiplier;
      _model.currentRotationAngle = startAngle * (1.0 - easedProgress);
    }

    currentView.angle = _model.baseAngle + _model.currentRotationAngle;

    if (progress >= 1.0) {
      stopAttack();
    }
  }

  double _easeInQuad(double t) => t * t;

  double _easeOutQuart(double t) => 1.0 - math.pow(1.0 - t, 4.0).toDouble();

  double _easeOutBounce(double t) {
    const double n1 = 7.5625;
    const double d1 = 2.75;

    if (t < 1 / d1) {
      return n1 * t * t;
    } else if (t < 2 / d1) {
      t -= 1.5 / d1;
      return n1 * t * t + 0.75;
    } else if (t < 2.5 / d1) {
      t -= 2.25 / d1;
      return n1 * t * t + 0.9375;
    } else {
      t -= 2.625 / d1;
      return n1 * t * t + 0.984375;
    }
  }
}
