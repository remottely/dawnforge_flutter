// lib/shared/framework/character/behavior/movement_behavior.dart (SIMPLIFICADO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/character/character.dart';
import 'package:flutter/foundation.dart';

class MovementConfig {
  final double runSpeedMultiplier;
  final double walkSpeed;
  final SimpleDirectionAnimation walkAnimation;
  final SimpleDirectionAnimation runAnimation;

  const MovementConfig({
    required this.runSpeedMultiplier,
    required this.walkSpeed,
    required this.walkAnimation,
    required this.runAnimation,
  });
}

class MovementBehavior extends CharacterBehavior {
  final MovementConfig config;
  bool _isRunning = false;

  MovementBehavior(this.config);

  @override
  void onAttach() {
    super.onAttach();
    debugPrint('[MovementBehavior] 🎨 onAttach chamado');
    // ✅ NÃO seta animação aqui! O DemoPlayer faz isso no onMount
  }

  @override
  void update(double dt) {
    // Lógica de corrida etc
  }

  @override
  bool onInput(JoystickActionEvent event) {
    // Handle run input
    return false;
  }
}
