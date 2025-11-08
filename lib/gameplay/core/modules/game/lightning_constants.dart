import 'package:flutter/material.dart';

final class LightingConstants {
  LightingConstants._();

  static final Color _orangeLighting = Colors.deepOrangeAccent.withValues(
    alpha: 0.2,
  );

  static final Color playerLighting = _orangeLighting;

  static final Color fireballAttackLighting = _orangeLighting;

  static final Color torchLighting = _orangeLighting;
}
