// lib/shared/framework/character/behavior/character_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/character/character.dart';
import 'package:dawnforge/shared/framework/character/character.dart';

/// Comportamento modular anexável a qualquer Character
abstract class CharacterBehavior {
  late Character character;
  
  /// Anexa o behavior ao character (chamado automaticamente)
  void attach(Character char) {
    character = char;
    onAttach();
  }
  
  /// Callback quando o behavior é anexado
  void onAttach() {}
  
  /// Atualização por frame
  void update(double dt) {}
  
  /// Processa input do jogador (retorna true se consumiu o input)
  bool onInput(JoystickActionEvent event) => false;
  
  /// Callback quando o character toma dano
  void onReceiveDamage(double damage) {}
  
  /// Callback quando o character morre
  void onDie() {}
  
  /// Cleanup
  void dispose() {}
}