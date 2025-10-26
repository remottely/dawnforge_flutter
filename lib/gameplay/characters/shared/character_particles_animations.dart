import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class CharacterParticlesAnimations {
  static const double kShowDamageGravity = 0.1;
  static const double kShowDamageInitVelocityVertical = -4;

  static const double _kShowDamageFontSize = 5;
  static const String _kShowDamageFontFamily = 'Normal';

  static final TextStyle playerShowDamageTextStyle = TextStyle(
    fontSize: _kShowDamageFontSize,
    color: Colors.orange,
    fontFamily: _kShowDamageFontFamily,
  );

  static final TextStyle enemyShowDamageTextStyle = TextStyle(
    fontSize: _kShowDamageFontSize,
    color: Colors.white,
    fontFamily: _kShowDamageFontFamily,
  );

  static LightingConfig knightLightingConfig(double width) => LightingConfig(
    radius: width * 1.5,
    blurBorder: width,
    color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
  );

  static const double _kAttackParticlesRadius = 0.3;

  static Particle swordParticles() => Particle.generate(
    count: 10,
    lifespan: 1,
    generator: (i) => AcceleratedParticle(
      acceleration: Vector2(0, 100),
      speed: (Vector2.random() - Vector2.random()) * 50,
      child: CircleParticle(
        radius: _kAttackParticlesRadius,
        paint: Paint()..color = Colors.red,
      ),
    ),
  );

  static Particle fireballParticles() => Particle.generate(
    count: 30,
    lifespan: 1,
    generator: (i) => AcceleratedParticle(
      acceleration: Vector2(0, 200),
      speed: (Vector2.random() - Vector2.random()) * 100,
      child: CircleParticle(
        radius: _kAttackParticlesRadius,
        paint: Paint()..color = Colors.yellow,
      ),
    ),
  );
}
