import 'package:bonfire/bonfire.dart';

class CustomPlayerItemModel {
  bool isAttacking = false;
  bool facingRight = true;
  double elapsedSeconds = 0;
  double currentRotationAngle = 0;

  /// Flag que indica se o frame de ataque já foi executado
  bool attackFrameExecuted = false;

  Duration attackDuration;

  Vector2 attachmentOffset;
  Vector2 facingRightOffset;
  Vector2 facingLeftOffset;

  double baseAngle;
  double maxRotationAngle;
  double windUpFraction;
  double strikeFraction;
  double recoveryFraction;

  double facingRightScaleX;
  double facingLeftScaleX;

  CustomPlayerItemModel({
    required Duration attackDuration,
    required Vector2 attachmentOffset,
    required Vector2 facingRightOffset,
    required Vector2 facingLeftOffset,
    required double baseAngle,
    required double maxRotationAngle,
    required double windUpFraction,
    required double strikeFraction,
    required double recoveryFraction,
    required double facingRightScaleX,
    required double facingLeftScaleX,
  }) : attackDuration = attackDuration,
       attachmentOffset = attachmentOffset.clone(),
       facingRightOffset = facingRightOffset.clone(),
       facingLeftOffset = facingLeftOffset.clone(),
       baseAngle = baseAngle,
       maxRotationAngle = maxRotationAngle,
       windUpFraction = windUpFraction,
       strikeFraction = strikeFraction,
       recoveryFraction = recoveryFraction,
       facingRightScaleX = facingRightScaleX,
       facingLeftScaleX = facingLeftScaleX;

  double get attackDurationSeconds => attackDuration.inMilliseconds / 1000.0;

  void resetAnimationState() {
    isAttacking = false;
    elapsedSeconds = 0;
    currentRotationAngle = 0;
    attackFrameExecuted = false;
  }

  void updateAttackDuration(Duration newDuration) {
    attackDuration = newDuration;
  }

  void updateOffsets({
    Vector2? attachmentOffset,
    Vector2? facingRightOffset,
    Vector2? facingLeftOffset,
  }) {
    if (attachmentOffset != null) {
      this.attachmentOffset = attachmentOffset.clone();
    }
    if (facingRightOffset != null) {
      this.facingRightOffset = facingRightOffset.clone();
    }
    if (facingLeftOffset != null) {
      this.facingLeftOffset = facingLeftOffset.clone();
    }
  }

  void updateScales({double? facingRightScaleX, double? facingLeftScaleX}) {
    if (facingRightScaleX != null) {
      this.facingRightScaleX = facingRightScaleX;
    }
    if (facingLeftScaleX != null) {
      this.facingLeftScaleX = facingLeftScaleX;
    }
  }
}
