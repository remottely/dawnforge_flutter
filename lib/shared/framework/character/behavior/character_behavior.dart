// lib/shared/framework/character/behavior/character_behavior.dart (CORRIGIDO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/character/character.dart'; // ✅ Import explícito

/// Comportamento modular anexável a qualquer Character
abstract class CharacterBehavior {
  // ✅ TIPO EXPLÍCITO: Character (não dynamic ou late)
  late Character character;
  
  bool needsUpdate = true;
  
  /// Anexa o behavior ao character (chamado automaticamente)
  void attach(Character char) {
    character = char;
    onAttach();
  }
  
  /// Callback quando o behavior é anexado
  void onAttach() {}
  
  /// Atualização por frame
  void update(double dt) {}
  
  /// Processa input do jogador
  bool onInput(JoystickActionEvent event) => false;
  
  /// Callback quando o character toma dano
  void onReceiveDamage(double damage) {}
  
  /// Callback quando o character morre
  void onDie() {}
  
  /// Desabilita temporariamente o update deste behavior
  void pauseUpdate() {
    needsUpdate = false;
  }
  
  /// Reabilita o update deste behavior
  void resumeUpdate() {
    needsUpdate = true;
  }
  
  /// Cleanup
  void dispose() {}
}