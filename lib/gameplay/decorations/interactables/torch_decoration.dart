// import 'package:bonfire/bonfire.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
// import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

// // --- Configurações movidas para o topo para organização ---
// final class _TorchDecorationConfig {
//   _TorchDecorationConfig._();

//   static final Vector2 _textureSize = TileConstants.tileSizeStandard;
//   static final Vector2 _componentSize = _textureSize;

//   static Future<SpriteAnimation> _loadSpriteAnimation() => SpriteAnimation.load(
//     'gameplay/decorations/torch_decoration_6.png',
//     SpriteAnimationConfig.createStandardData(
//       amount: 6,
//       textureSize: _textureSize,
//     ),
//   );

//   static final LightingConfig _lightingConfig = LightingConfig(
//     radius: TileConstants.kTileDimensionExtraLarge,
//     blurBorder: TileConstants.kTileDimensionStandard,
//     color: LightingConstants.torchLighting,
//   );
// }

// class TorchDecorationView extends DDDecoration {
//   /// Rastreia o estado atual da tocha.
//   bool isLit;

//   TorchDecorationView({required super.position})
//     : isLit = false,
//       super.withAnimation(
//         animation: _TorchDecorationConfig._loadSpriteAnimation(),
//         size: _TorchDecorationConfig._componentSize,
//       ) {
//     // setupLighting(_TorchDecorationConfig._lightingConfig);
//   }

//   TorchDecorationView.empty({required super.position})
//     : isLit = true,
//       super.withAnimation(
//         animation: _TorchDecorationConfig._loadSpriteAnimation(),
//         size: _TorchDecorationConfig._componentSize,
//       );

//   // TorchDecorationView({
//   //   required super.position,
//   //   this.isLit = true, // Define se a tocha começa acesa ou apagada
//   // }) : super.withAnimation(
//   //        animation: _TorchDecorationConfig._loadSpriteAnimation(),
//   //        size: _TorchDecorationConfig._componentSize,
//   //      );

//   @override
//   Future<void> onLoad() {
//     // Define o estado inicial da luz e da animação
//     _updateTorchState();
//     return super.onLoad();
//   }

//   /// Método público para alternar o estado da tocha
//   void toggleLitState() {
//     isLit = !isLit;
//     _updateTorchState();
//   }

//   /// Lógica interna para atualizar a luz e a animação
//   void _updateTorchState() {
//     if (isLit) {
//       // Se estiver acesa, adiciona luz e toca a animação
//       setupLighting(_TorchDecorationConfig._lightingConfig);
//       // animation?.play();
//     } else {
//       // Se estiver apagada, remove a luz e pausa a animação (no primeiro frame)
//       // gameRef.lighting?.remove(this);
//       // animation?.setFrame(0);
//       // animation?.pause();
//     }
//   }

//   @override
//   void render(Canvas canvas) {
//     // A tocha agora é renderizada em ambos os estados (acesa ou apagada),
//     // pois a animação pausada no frame 0 servirá como a "tocha apagada".
//     super.render(canvas);
//   }
// }
