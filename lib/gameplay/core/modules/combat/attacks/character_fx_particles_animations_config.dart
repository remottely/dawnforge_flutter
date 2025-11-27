import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class CharacterFxParticlesAnimationsConfig {
  static const double kShowDamageGravity = 0.1;
  static const double kShowDamageInitVelocityVertical = -4.0;

  static const double _kShowDamageFontSize = 5.0;
  static const String _kShowDamageFontFamily = 'Normal';

  static const TextStyle kPlayerShowDamageTextStyle = TextStyle(
    fontSize: _kShowDamageFontSize,
    color: Colors.orange,
    fontFamily: _kShowDamageFontFamily,
  );

  static const TextStyle kEnemyShowDamageTextStyle = TextStyle(
    fontSize: _kShowDamageFontSize,
    color: Colors.white,
    fontFamily: _kShowDamageFontFamily,
  );

  static const double _kAttackParticlesRadius = 0.3;

  static Particle createPrimaryAttackParticles() => Particle.generate(
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

  static Particle createFireballAttackParticles() => Particle.generate(
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
