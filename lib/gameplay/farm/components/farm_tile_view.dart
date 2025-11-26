import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_stage_model.dart';
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart'
    as model;
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart';
import 'package:darkness_dungeon/gameplay/farm/models/soil_state_model.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
// import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/interaction/tool_interactable_mixin.dart';

/// View de um tile de fazenda que integra com o FarmManager
/// Este componente é criado pelo Tiled map e gerencia a visualização
class FarmTileView extends DDDecoration with ToolInteractableMixin {
  // TODO(Kevin): put DD back
  final int tileX;
  final int tileY;

  // State backing this view
  late FarmTileModel farmTile;

  SpriteComponent? _soilSprite;
  DDDecoration? _cropDecoration;
  bool _isHighlighted = false;

  // Cache para evitar recarregamento desnecessário
  SoilStateModel? _lastRenderedSoilState;
  String? _lastRenderedCropKey;

  FarmTileView({required Vector2 position})
    : tileX = (position.x / 16).floor(),
      tileY = (position.y / 16).floor(),
      super(position: position, size: TileConstants.tileSizeStandard) {
    // Inicializar tile no FarmManager se não existir
    final existingTile = FarmManager.instance.getTile(tileX, tileY);
    if (existingTile == null) {
      final newTile = model.FarmTileModel(x: tileX, y: tileY);
      FarmManager.instance.setTile(newTile);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    developer.log('[FarmTileView] Loading tile at ($tileX, $tileY)');

    // Obter o tile do FarmManager
    farmTile = FarmManager.instance.getTile(tileX, tileY)!;

    // Criar componente de solo (sempre renderiza como chão - sem Y-sorting)
    final soilSprite = await Sprite.load(_getSoilSpritePath());
    _soilSprite = SpriteComponent(
      sprite: soilSprite,
      size: size,
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: 0,
    );
    add(_soilSprite!);

    developer.log(
      '[FarmTileView] 🟤 Soil sprite loaded: ${_getSoilSpritePath()}',
    );

    // Se houver crop, criar como DDDecoration com Y-sorting
    if (farmTile.crop != null) {
      await _createCropDecoration();
      developer.log(
        '[FarmTileView] 🌱 Crop decoration loaded: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name}) with Y-sorting',
      );
    }

    _lastRenderedSoilState = farmTile.soilState;
    _lastRenderedCropKey = _getCropKey();
  }

  /// Cria uma decoração 3D para a crop (com Y-sorting)
  /// A crop será renderizada na frente ou atrás do player baseado na posição Y
  Future<void> _createCropDecoration() async {
    if (farmTile.crop == null) return;

    final cropSprite = await Sprite.load(_getCropSpritePath());

    _cropDecoration = DDDecoration.withSprite(
      sprite: cropSprite,
      position: position, // Posição global no mundo
      size: size,
    );

    if (farmTile.crop!.stage == CropStageModel.withered) {
      _cropDecoration!.opacity = 0.5;
    }

    // Adicionar ao gameRef (mundo do jogo) em vez de como child
    gameRef.add(_cropDecoration!);
  }

  /// Verifica se o player está sobrepondo este tile
  bool isPlayerOnTile(Player player) {
    final bottomCenter = Offset(
      player.rectCollision.center.dx,
      player.rectCollision.bottom,
    );
    return rectCollision.contains(bottomCenter);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final currentTile = FarmManager.instance.getTile(tileX, tileY);
    if (currentTile != null) {
      if (currentTile.soilState != _lastRenderedSoilState ||
          currentTile.crop?.cropId != _lastRenderedCropKey) {
        // Estado mudou — atualizar sprites conforme necessário
      }
      updateTile(currentTile);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_isHighlighted) {
      _renderHighlight(canvas);
    }
  }

  Future<void> _updateSoilSprite() async {
    final spritePath = _getSoilSpritePath();
    final sprite = await Sprite.load(spritePath);
    _soilSprite!.sprite = sprite;

    developer.log('[FarmTileView] 🟤 Soil sprite updated: $spritePath');
  }

  Future<void> _updateCropDecoration() async {
    // Remover decoração antiga se existir
    if (_cropDecoration != null) {
      _cropDecoration!.removeFromParent();
      _cropDecoration = null;
    }

    // Se não tem crop, apenas retorna
    if (farmTile.crop == null) {
      developer.log('[FarmTileView] 🌱 Crop removed (no Y-sorting)');
      return;
    }

    // Criar nova decoração com Y-sorting
    await _createCropDecoration();

    developer.log(
      '[FarmTileView] 🌱 Crop decoration updated: ${farmTile.crop!.cropId} (${farmTile.crop!.stage.name}) with Y-sorting',
    );
  }

  String _getSoilSpritePath() {
    switch (farmTile.soilState) {
      case SoilStateModel.untilled:
        return 'gameplay/farm/soil/untilled.png';
      case SoilStateModel.tilled:
        return 'gameplay/farm/soil/tilled.png';
      case SoilStateModel.watered:
        return 'gameplay/farm/soil/watered.png';
      case SoilStateModel.fertilized:
        return 'gameplay/farm/soil/fertilized.png';
    }
  }

  String _getCropSpritePath() {
    if (farmTile.crop == null) return '';
    final crop = farmTile.crop!;
    final stageName = _getStageFileName(crop.stage);
    return 'gameplay/farm/crops/${crop.cropId}/$stageName.png';
  }

  String _getStageFileName(CropStageModel stage) {
    switch (stage) {
      case CropStageModel.seed:
        return 'seed';
      case CropStageModel.sprout:
        return 'sprout';
      case CropStageModel.growing:
        return 'growing';
      case CropStageModel.mature:
      case CropStageModel.withered:
        // TODO(Kevin): create withered sprite
        return 'mature';
    }
  }

  Future<void> _updateSpritesIfNeeded() async {
    final currentSoilState = farmTile.soilState;
    final currentCropKey = _getCropKey();

    if (currentSoilState != _lastRenderedSoilState) {
      await _updateSoilSprite();
      _lastRenderedSoilState = currentSoilState;
    }

    if (currentCropKey != _lastRenderedCropKey) {
      await _updateCropDecoration();
      _lastRenderedCropKey = currentCropKey;
    }
  }

  String? _getCropKey() {
    if (farmTile.crop == null) return null;
    return '${farmTile.crop!.cropId}_${farmTile.crop!.stage.name}';
  }

  void _renderHighlight(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x4400FF00)
      ..style = PaintingStyle.fill;
    canvas.drawRect(size.toRect(), paint);
  }

  /// Atualizar tile (chamado externamente quando FarmManager muda o tile)
  Future<void> updateTile(FarmTileModel newTile) async {
    farmTile = newTile;
    await _updateSpritesIfNeeded();
  }

  void setHighlighted(bool highlighted) {
    _isHighlighted = highlighted;
  }

  @override
  void onToolUsed(
    ToolType tool,
    GameComponent user, {
    required Vector2 position,
  }) {
    if (tool != ToolType.shovel) return;

    final success = FarmManager.instance.tillSoil(farmTile.x, farmTile.y);
    if (success) {
      final updated = FarmManager.instance.getTile(farmTile.x, farmTile.y);
      if (updated != null) {
        updateTile(updated);
      }
    }
  }

  @override
  void onRemove() {
    // Limpar a crop decoration quando o tile for removido
    if (_cropDecoration != null) {
      _cropDecoration!.removeFromParent();
      _cropDecoration = null;
    }
    super.onRemove();
  }

  @override
  int get priority => 20;
}
