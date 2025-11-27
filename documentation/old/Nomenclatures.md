# Nomenclatures Guide

Este documento define padrões de nomenclatura para métodos, propriedades e variáveis no projeto, visando clareza, consistência e fácil manutenção.

## Prefixos

- **build**: Utilizado para métodos que constroem ou configuram objetos, geralmente a partir de parâmetros ou lógica interna.
  - Exemplo: `buildDirectionalAnimation`, `buildLightingConfig`
- **create**: Indica criação de uma nova instância de objeto, especialmente quando cada chamada retorna um novo objeto.
  - Exemplo: `createHitbox`, `createProjectile`
- **load**: Usado para métodos que carregam recursos externos (assets, arquivos, dados assíncronos). Normalmente retorna um `Future`.
  - Exemplo: `loadSpriteSheet`, `loadAnimation`, `loadAudio`

## Sufixos

- **Sprite**: Refere-se a imagens ou objetos gráficos estáticos individuais usados em renderização.
  - Exemplo: `barrelSprite`, `lifePotionSprite`
- **Animation**: Refere-se a uma sequência de sprites (sprite sheet) ou frames que compõem uma animação.
  - Exemplo: `runAnimation`, `idleAnimation`, `attackAnimation`

## Recomendações Gerais

- Use prefixos para indicar claramente a ação do método (criar, construir, carregar).
- Use sufixos para indicar o tipo de recurso ou objeto retornado.
- Evite redundância de contexto: dentro de classes específicas, não repita o nome do contexto no nome da propriedade.
- Prefira nomes descritivos e objetivos, facilitando a leitura e manutenção do código.

---

Here are naming improvement suggestions for your lib codebase, tailored for a 2D top-down game (Stardew Valley style) and inspired by best practices from system design, design systems, Flutter/Flame, and game engines like Unity/Unreal:

1. Consistency & Clarity
   Use consistent suffixes:
   View → Component (Flame/Unity/Unreal use “Component” for game objects)
   Config → Config or Definition (for static data)
   Controller → Controller or Behavior (Unity: “Behaviour”, Unreal: “Controller”)
   Model → State or Data (if used for runtime state)
   Prefer full, descriptive names:
   KnightPlayerView → KnightComponent or KnightPlayerComponent
   DungeonBossEnemyConfig → DungeonBossConfig or DungeonBossDefinition
   DFGameDecoration → DecorationComponent
   DFPushableDecoration → PushableDecorationComponent
   DFSensorPlayerDecoration → PlayerSensorComponent
   BarrelDecorationView → BarrelComponent
   DoorDecorationView → DoorComponent
   MapSensorView → MapTransitionSensorComponent
2. Folder & File Structure
   Use plural for folders:
   characters/players/knight/knight_component.dart
   enemies/goblin/goblin_component.dart
   environment/decorations/door_component.dart
   Group related files:
   knight_component.dart, knight_controller.dart, knight_config.dart in the same folder.
3. Naming for Systems & Managers
   Use Manager for global systems:
   AudioManager, UIManager, DialogueManager
   Use Service for external or cross-cutting concerns:
   SaveService, LocalizationService
4. Animation & Asset Naming
   Use Animation for animation classes:
   KnightIdleAnimation, GoblinAttackAnimation
   Use Asset for asset paths/constants:
   AssetPaths.knightIdle, AssetPaths.doorOpen
5. Gameplay & Mechanics
   Use Tile, Cell, or Slot for grid-based elements:
   FarmTileComponent, InventorySlotComponent
   Use Decoration for objects the player can interact with:
   ChestDecorationComponent, DoorDecorationComponent
6. Events & Actions
   Use Event for event classes:
   PlayerDiedEvent, ItemCollectedEvent
   Use Action for player or AI actions:
   AttackAction, MoveAction, HarvestAction
7. General Recommendations
   Avoid abbreviations unless they are standard (e.g., UI, NPC).
   Use PascalCase for class names, snake_case for file names.
   Avoid “View” unless it’s a UI widget (in Flutter, “Widget” is preferred for UI).
   For Flame/Unity/Unreal, “Component” is the standard for game objects.
   Example Refactor Table
   Old Name Suggested Name
   KnightPlayerView KnightPlayerComponent
   DungeonBossEnemyConfig DungeonBossConfig
   BarrelDecorationView BarrelComponent
   DoorKeyDecorationView DoorKeyComponent
   LifePotionDecorationView LifePotionComponent
   MapSensorView MapTransitionSensorComponent
   DFPushableDecoration PushableDecorationComponent
   DFSensorPlayerDecoration PlayerSensorComponent
   CharacterParticlesAnimations CharacterParticleAnimations
   GameplayAudioManager AudioManager
   Summary:

Use Component for all in-game objects.
Use Config or Definition for static data.
Use Controller or Behavior for logic.
Use Manager for global systems.
Use clear, descriptive, and consistent names throughout.
If you want a concrete refactor plan for a specific folder or class, let me know!

---
