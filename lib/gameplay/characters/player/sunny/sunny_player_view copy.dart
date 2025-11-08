// import 'package:bonfire/bonfire.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_manager.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_default_hand_loadout.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
// import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
// import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';

// class SunnyPlayerView extends SimplePlayer
//     with Lighting, BlockMovementCollision {
//   SunnyPlayerView(
//     Vector2 position, {
//     required SunnyPlayerModel model,
//     KnightHandLoadoutConfig? handLoadout,
//   }) : _model = model,
//        _handLoadout = handLoadout ?? createDefaultKnightHandLoadout(),
//        super(
//          animation: SunnyPlayerConfig.animation,
//          size: SunnyPlayerConfig.componentSize,
//          position: position,
//          life: SunnyPlayerConfig.kLife,
//          speed: SunnyPlayerConfig.kSpeed,
//        ) {
//     anchor = Anchor.center;
//   }

//   final SunnyPlayerModel _model;
//   final KnightHandLoadoutConfig _handLoadout;
//   late final SunnyPlayerController _controller;
//   late final KnightHandManager _handManager = KnightHandManager(owner: this);

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     _initializeVisualConfiguration();
//     _initializeController();
//     add(SunnyPlayerConfig.hitbox);
//     await _handManager.applyLoadout(_handLoadout);
//   }

//   @override
//   void update(double dt) {
//     if (isDead) return;
//     _controller.update(dt);
//     _handManager.update(dt, velocity);
//     _updateSpriteDirection();
//     super.update(dt);
//   }

//   void _updateSpriteDirection() {
//     if (velocity.x < 0 && !isFlippedHorizontally) {
//       flipHorizontallyAroundCenter();
//     } else if (velocity.x > 0 && isFlippedHorizontally) {
//       flipHorizontallyAroundCenter();
//     }
//   }

//   @override
//   void onJoystickAction(JoystickActionEvent event) {
//     if (isDead) return;
//     _controller.handleInputAction(event);
//     super.onJoystickAction(event);
//   }

//   @override
//   void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
//     if (isDead) return;
//     _showDamageFx(damage);
//     super.onReceiveDamage(attacker, damage, id);
//   }

//   @override
//   void onDie() {
//     _showDeathFx();
//     removeFromParent();
//     super.onDie();
//   }

//   @override
//   void onRemove() {
//     _handManager.dispose();
//     _controller.dispose();
//     super.onRemove();
//   }

//   // Public API for external interaction
//   // void useTool() => _controller.useTool();
//   // void switchTool(FarmTool newTool) => _controller.switchTool(newTool);
//   // void restoreEnergy() => _controller.restoreEnergy();
//   SunnyPlayerModel get model => _controller.model;

//   void _initializeVisualConfiguration() {
//     setupLighting(SunnyPlayerConfig.lightingConfig);
//     setupMovementByJoystick(intensityEnabled: true);
//   }

//   void _initializeController() {
//     _controller = SunnyPlayerController(
//       model: _model,
//       onPrimaryAttack: _onPlayPrimaryAttack,
//       onFireballAttack: _onPlayFireballAttack,
//       onToolUse: _onPlayToolAnimation,
//       onShowExclamation: _onShowExclamationEmote,
//       onCheckEnemyVision: _onCheckEnemyVision,
//     );
//   }

//   KnightHandItemController? handControllerFor(KnightHandSlot slot) =>
//       _handManager.handControllerFor(slot);

//   bool _executeAttackForTrigger(KnightAttackTrigger trigger, double damage) {
//     return _handManager.executeAttack(trigger, damage);
//   }

//   /// Private helper methods
//   void _showDamageFx(double damage) => showDamage(
//     damage,
//     config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
//     gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
//     initVelocityVertical:
//         CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
//   );

//   void _showDeathFx() =>
//       gameRef.add(SunnyPlayerConfig.createCryptComponent(position));

//   /// Controller callback implementations
//   bool _onPlayPrimaryAttack(double damage) =>
//       _executeAttackForTrigger(KnightAttackTrigger.primary, damage);

//   bool _onPlayFireballAttack(double damage) =>
//       _executeAttackForTrigger(KnightAttackTrigger.fireball, damage);

//   void _onPlayToolAnimation() {
//     // TODO: Implementar animação de ferramenta
//   }

//   void _onShowExclamationEmote() {
//     add(
//       CharacterEmoteManager.displayEmoteAboveCharacter(
//         asset: CharacterEmoteManager.kExclamationEmoteAsset,
//         amount: 8,
//         target: this,
//       ),
//     );
//   }

//   void _onCheckEnemyVision({
//     required double visionRadius,
//     required void Function() notObserved,
//     required void Function(List<Enemy> enemies) observed,
//   }) {
//     seeEnemy(
//       radiusVision: visionRadius,
//       notObserved: notObserved,
//       observed: observed,
//     );
//   }
// }
