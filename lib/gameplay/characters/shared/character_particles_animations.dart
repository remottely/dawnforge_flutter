import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class CharacterParticlesAnimations {
  static const kShowDamageGravity = 0.1;
  static const kShowDamageInitVelocityVertical = -4.0;

  static const _kShowDamageFontSize = 5.0;
  static const _kShowDamageFontFamily = 'Normal';

  static const kPlayerShowDamageTextStyle = TextStyle(
    fontSize: _kShowDamageFontSize,
    color: Colors.orange,
    fontFamily: _kShowDamageFontFamily,
  );

  static const kEnemyShowDamageTextStyle = TextStyle(
    fontSize: _kShowDamageFontSize,
    color: Colors.white,
    fontFamily: _kShowDamageFontFamily,
  );

  static final fLightingConfigColor = Colors.deepOrangeAccent.withValues(
    alpha: 0.2,
  );

  static const _kAttackParticlesRadius = 0.3;

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
