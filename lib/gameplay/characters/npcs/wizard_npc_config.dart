import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// WizardNpcConfig
/// ---------------------------------------------------------------------------
/// Contém todos os dados estáticos, constantes e métodos utilitários para
/// configuração do WizardNpcView. Use este padrão para outros configs.
abstract class WizardNpcConfig {
  //////////////////////////////////////////////////////////////////////////////
  // GENERAL CONFIGURATION
  //////////////////////////////////////////////////////////////////////////////

  /// Tamanho padrão do sprite do NPC
  static final Vector2 spriteSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.8,
    GameplayConstants.kTileDimensionStandard * 1.0,
  );

  //////////////////////////////////////////////////////////////////////////////
  // VISION
  //////////////////////////////////////////////////////////////////////////////

  static const double kVisionRadius = GameplayConstants.kVisionRadiusSmall;

  //////////////////////////////////////////////////////////////////////////////
  // ANIMATION
  //////////////////////////////////////////////////////////////////////////////

  static final SimpleDirectionAnimation buildDirectionalAnimation =
      SimpleDirectionAnimation(
        idleRight: NpcSpriteAnimations.wizardIdleLeft(),
        runRight: NpcSpriteAnimations.wizardIdleLeft(),
      );
}
