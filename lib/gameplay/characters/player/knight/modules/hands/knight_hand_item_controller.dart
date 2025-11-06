import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_slot.dart';

class KnightHandItemController {
  KnightHandItemController({
    required GameComponent owner,
    required KnightHandSlot slot,
    required KnightHandItemConfig config,
  }) : _owner = owner,
       _config = config,
       _slot = slot,
       _model = _createModel(config, slot);
  final GameComponent _owner;
  final KnightHandSlot _slot;
  final KnightHandItemConfig _config;
  final KnightHandItemModel _model;

  KnightHandItemView? _view;

  void Function(Duration duration)? _onAnimationDurationChanged;

  KnightHandSlot get slot => _slot;

  KnightHandItemConfig get config => _config;

  KnightHandItemView? get view => _view;

  bool get isReady => _view != null && !_view!.isRemoved;

  bool get isAttacking => _model.isAttacking;

  bool get isFacingRight => _model.facingRight;

  Duration get currentAttackDuration => _model.attackDuration;

  Future<KnightHandItemView> createView() async {
    if (_view != null) {
      return _view!;
    }

    final sprite = await Sprite.load(_config.spritePath);
    final handView = KnightHandItemView(
      sprite: sprite,
      position: _initialPosition,
      size: _config.size,
      priorityResolver: () => _owner.priority + _config.priorityOffset,
    );
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

  void flashColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 200),
  }) {
    final currentView = _view;
    if (currentView == null || currentView.isRemoved) return;

    currentView.add(
      ColorEffect(
        color.withOpacity(0.7),
        EffectController(duration: duration.inMilliseconds / 1000.0),
      ),
    );
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
    _view?.removeFromParent();
    _view = null;
    _model.resetAnimationState();
  }

  static KnightHandItemModel _createModel(
    KnightHandItemConfig config,
    KnightHandSlot slot,
  ) {
    final slotConfig = config.configurationFor(slot);
    return KnightHandItemModel(
      attackDuration: config.defaultAttackDuration,
      attachmentOffset: slotConfig.attachmentOffset,
      facingRightOffset: slotConfig.facingRightOffset,
      facingLeftOffset: slotConfig.facingLeftOffset,
      baseAngle: config.baseAngle,
      maxRotationAngle: config.maxRotationAngle,
      windUpFraction: config.windUpFraction,
      strikeFraction: config.strikeFraction,
      recoveryFraction: config.recoveryFraction,
      facingRightScaleX: slotConfig.facingRightScaleX,
      facingLeftScaleX: slotConfig.facingLeftScaleX,
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
