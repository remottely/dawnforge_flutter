import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_stage.dart';
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile.dart';
import 'package:darkness_dungeon/gameplay/farm/models/soil_state.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

/// Componente visual de um tile de fazenda
/// Renderiza sprites de solo e crop baseado no estado do FarmTile
class FarmTileComponent extends DDDecoration {
  FarmTile farmTile;

  SpriteComponent? _soilSprite;
  SpriteComponent? _cropSprite;
  bool _isHighlighted = false;

  // Cache para evitar recarregamento desnecessário
  SoilState? _lastRenderedSoilState;
  String? _lastRenderedCropKey;

  FarmTileComponent({required this.farmTile, required Vector2 position})
    : super(position: position, size: TileConstants.tileSizeStandard);

  @override
  Future<void> onLoad() async {
    // Carregar sprites iniciais
    final soilSprite = await Sprite.load(_getSoilSpritePath());

    // Criar componente de solo
    _soilSprite = SpriteComponent(
      sprite: soilSprite,
      size: size,
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: 0,
    );
    add(_soilSprite!);

    developer.log(
      '[FarmTileComponent] 🟤 Soil sprite loaded: ${_getSoilSpritePath()}',
    );

    // Criar componente de crop (pode ser null inicialmente)
    if (farmTile.crop != null) {
      final cropSprite = await Sprite.load(_getCropSpritePath());
      _cropSprite = SpriteComponent(
        sprite: cropSprite,
        size: size,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
        priority: 1,
      );

      // Aplicar opacidade se withered
      if (farmTile.crop!.stage == CropStage.withered) {
        _cropSprite!.opacity = 0.5;
      }

      add(_cropSprite!);
      developer.log(
        '[FarmTileComponent] 🌱 Crop sprite loaded: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name})',
      );
    }

    _lastRenderedSoilState = farmTile.soilState;
    _lastRenderedCropKey = _getCropKey();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateSpritesIfNeeded();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Renderizar highlight se hover
    if (_isHighlighted) {
      _renderHighlight(canvas);
    }
  }

  Future<void> _updateSoilSprite() async {
    final spritePath = _getSoilSpritePath();
    final sprite = await Sprite.load(spritePath);

    _soilSprite!.sprite = sprite;
    developer.log('[FarmTileComponent] 🟤 Soil sprite updated: $spritePath');
  }

  Future<void> _updateCropSprite() async {
    if (farmTile.crop == null) {
      // Remover componente de crop se não há mais crop
      if (_cropSprite != null) {
        remove(_cropSprite!);
        _cropSprite = null;
      }
      return;
    }

    final spritePath = _getCropSpritePath();
    final sprite = await Sprite.load(spritePath);

    if (_cropSprite == null) {
      // Criar novo componente se não existe
      _cropSprite = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
        priority: 1,
      );
      add(_cropSprite!);
    } else {
      // Apenas trocar o sprite
      _cropSprite!.sprite = sprite;
    }

    // Adicionar opacidade se withered
    if (farmTile.crop!.stage == CropStage.withered) {
      _cropSprite!.opacity = 0.5;
    } else {
      _cropSprite!.opacity = 1.0;
    }

    developer.log(
      '[FarmTileComponent] 🌱 Crop sprite updated: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name})',
    );
  }

  String _getSoilSpritePath() {
    switch (farmTile.soilState) {
      case SoilState.untilled:
        return 'gameplay/farm/soil/untilled.png';
      case SoilState.tilled:
        return 'gameplay/farm/soil/tilled.png';
      case SoilState.watered:
        return 'gameplay/farm/soil/watered.png';
      case SoilState.fertilized:
        return 'gameplay/farm/soil/fertilized.png';
    }
  }

  String _getCropSpritePath() {
    if (farmTile.crop == null) return '';

    final crop = farmTile.crop!;
    final stageName = _getStageFileName(crop.stage);

    return 'gameplay/farm/crops/${crop.cropId}/$stageName.png';
  }

  String _getStageFileName(CropStage stage) {
    switch (stage) {
      case CropStage.seed:
        return 'seed';
      case CropStage.sprout:
        return 'sprout';
      case CropStage.growing:
        return 'growing';
      case CropStage.mature:
      case CropStage.withered:
        return 'mature'; // Reusar sprite mature com opacity diferente
    }
  }

  Future<void> _updateSpritesIfNeeded() async {
    final currentSoilState = farmTile.soilState;
    final currentCropKey = _getCropKey();

    // Atualizar solo se mudou
    if (currentSoilState != _lastRenderedSoilState) {
      await _updateSoilSprite();
      _lastRenderedSoilState = currentSoilState;
    }

    // Atualizar crop se mudou
    if (currentCropKey != _lastRenderedCropKey) {
      await _updateCropSprite();
      _lastRenderedCropKey = currentCropKey;
    }
  }

  String? _getCropKey() {
    if (farmTile.crop == null) return null;
    return '${farmTile.crop!.cropId}_${farmTile.crop!.stage.name}';
  }

  void _renderHighlight(Canvas canvas) {
    final paint = Paint()
      ..color =
          const Color(0x4400FF00) // Verde transparente
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), paint);
  }

  /// Atualizar tile (chamado externamente quando FarmManager muda o tile)
  Future<void> updateTile(FarmTile newTile) async {
    // developer.log(
    //   '[FarmTileComponent] 🔄 Update tile (${newTile.x}, ${newTile.y}): soil=${newTile.soilState}, crop=${newTile.crop?.cropId ?? "none"}',
    // );
    farmTile = newTile;
    await _updateSpritesIfNeeded();
  }

  void setHighlighted(bool highlighted) {
    _isHighlighted = highlighted;
  }
}
