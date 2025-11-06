import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/pickaxe/knight_pickaxe_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/pickaxe/knight_pickaxe_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/pickaxe/knight_pickaxe_view.dart';

class KnightPickaxeController {
  KnightPickaxeController({required GameComponent knight}) : _knight = knight;

  final GameComponent _knight;
  final KnightPickaxeModel _model = KnightPickaxeModel();

  KnightPickaxeView? _view;

  void Function(Duration duration)? _onAnimationDurationChanged;

  KnightPickaxeModel get model => _model;

  KnightPickaxeView? get view => _view;

  bool get isReady => _view != null && !(_view!.isRemoved);

  bool get isFacingRight => _model.facingRight;

  Duration get currentAttackDuration => _model.attackDuration;

  Future<KnightPickaxeView> createView({required String spritePath}) async {
    if (_view != null) {
      return _view!;
    }

    final sprite = await Sprite.load(spritePath);
    final pickaxeView = KnightPickaxeView(
      sprite: sprite,
      position: _initialPosition,
    );
    pickaxeView.scale.x = -1.0; // Facing right by default
    _view = pickaxeView;
    return pickaxeView;
  }

  void update(double dt) {
    final currentView = _view;
    if (currentView == null || currentView.isRemoved) return;

    _updatePosition(currentView);

    if (!_model.isAttacking) {
      currentView.angle = 0;
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
    _model.currentPhase = KnightPickaxeAttackPhase.windUp;
  }

  void stopAttack() {
    if (!_model.isAttacking) return;

    _model.resetAnimationState();
    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      currentView.angle = 0;
    }
  }

  void updateAnimationDuration(Duration newDuration) {
    if (_model.attackDuration == newDuration) return;

    _model.updateAttackDuration(newDuration);
    _onAnimationDurationChanged?.call(newDuration);
  }

  void setDirection({required bool facingRight}) {
    if (_model.facingRight == facingRight) {
      return;
    }

    _model.facingRight = facingRight;
    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      currentView.scale.x = facingRight ? -1.0 : 1.0;
      _updatePosition(currentView);
    }
  }

  void updateDirectionFromVelocity(Vector2 velocity) {
    if (velocity.x.abs() <= 1.0) return;
    setDirection(facingRight: velocity.x > 0);
  }

  void updateOffsets({
    Vector2? staticOffset,
    Vector2? rightOffset,
    Vector2? leftOffset,
  }) {
    if (staticOffset != null) _model.staticOffset = staticOffset;
    if (rightOffset != null) _model.rightOffset = rightOffset;
    if (leftOffset != null) _model.leftOffset = leftOffset;

    final currentView = _view;
    if (currentView != null && !currentView.isRemoved) {
      _updatePosition(currentView);
    }
  }

  Future<void> updateSprite(String spritePath) async {
    await _view?.updateSprite(spritePath);
  }

  void setAnimationDurationChangedCallback(
    void Function(Duration duration)? callback,
  ) {
    _onAnimationDurationChanged = callback;
  }

  // void flashColor(
  //   Color color, {
  //   Duration duration = const Duration(milliseconds: 200),
  // }) {
  //   final currentView = _view;
  //   if (currentView == null || currentView.isRemoved) return;

  //   // currentView.add(
  //   //   ColorEffect(
  //   //     color.withValues(alpha: 0.7),
  //   //     EffectController(duration: duration.inMilliseconds / 1000.0),
  //   //   ),
  //   // );
  //   // currentView.add(
  //   //   ColorEffect(
  //   //     Colors.transparent.withValues(alpha: 0.7),
  //   //     EffectController(duration: duration.inMilliseconds / 1000.0),
  //   //   ),
  //   // );
  // }

  Map<String, dynamic> get debugInfo => {
    'isReady': isReady,
    'isAttacking': _model.isAttacking,
    'facingRight': _model.facingRight,
    'position': (_view == null
        ? 'uninitialized'
        : '${_view!.position.x.toStringAsFixed(1)}, ${_view!.position.y.toStringAsFixed(1)}'),
    'angleDegrees': _view == null
        ? 'N/A'
        : (_view!.angle * 180 / math.pi).toStringAsFixed(1),
    'attackDurationMs': _model.attackDuration.inMilliseconds,
  };

  void dispose() {
    _view?.removeFromParent();
    _view = null;
    _model.resetAnimationState();
  }

  void _updatePosition(KnightPickaxeView currentView) {
    currentView.position =
        _knight.position + _model.staticOffset + _model.directionOffset;
  }

  void _advanceAnimation(double dt, KnightPickaxeView currentView) {
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

    final windUpEnd = KnightPickaxeConfig.windUpFraction;
    final strikeEnd = windUpEnd + KnightPickaxeConfig.strikeFraction;

    if (progress < windUpEnd) {
      _model.currentPhase = KnightPickaxeAttackPhase.windUp;
      final phaseProgress = progress / windUpEnd;
      double delayedProgress = 0.0;
      if (phaseProgress > 0.8) {
        delayedProgress = (phaseProgress - 0.8) / 0.2;
      }
      final easedProgress = _easeInQuad(delayedProgress);
      _model.currentRotationAngle =
          -KnightPickaxeConfig.maxRotationAngle *
          0.3 *
          easedProgress *
          directionMultiplier;
    } else if (progress < strikeEnd) {
      _model.currentPhase = KnightPickaxeAttackPhase.strike;
      final phaseProgress =
          (progress - windUpEnd) / KnightPickaxeConfig.strikeFraction;
      final easedProgress = _easeOutQuart(phaseProgress);
      final startAngle =
          -KnightPickaxeConfig.maxRotationAngle * 0.3 * directionMultiplier;
      _model.currentRotationAngle =
          startAngle +
          (KnightPickaxeConfig.maxRotationAngle *
              1.3 *
              easedProgress *
              directionMultiplier);
    } else {
      _model.currentPhase = KnightPickaxeAttackPhase.recover;
      final phaseProgress =
          (progress - strikeEnd) / KnightPickaxeConfig.recoveryFraction;
      final easedProgress = _easeOutBounce(phaseProgress);
      final startAngle =
          KnightPickaxeConfig.maxRotationAngle * directionMultiplier;
      _model.currentRotationAngle = startAngle * (1.0 - easedProgress);
    }

    currentView.angle = _model.currentRotationAngle;

    if (progress >= 1.0) {
      stopAttack();
    }
  }

  Vector2 get _initialPosition =>
      _knight.position + _model.staticOffset + _model.directionOffset;

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
