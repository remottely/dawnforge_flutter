import 'package:bonfire/bonfire.dart';

class AnimationHelper {
  static const String playerActionsSprite = 'new/Player/Player_Actions.png';

  // Cada quadro tem 48x48
  static final Vector2 spriteSize = Vector2(48, 48);

  // Duas colunas por linha (2 frames)
  static const int columns = 2;

  // Ajuste o stepTime conforme desejar
  static const double defaultStepTime = 0.12;

  // Cache do SpriteSheet
  static Future<SpriteSheet>? _sheetFuture;

  static Future<SpriteSheet> _getSheet() {
    _sheetFuture ??= Flame.images
        .load(playerActionsSprite)
        .then((image) => SpriteSheet(image: image, srcSize: spriteSize));
    return _sheetFuture!;
  }

  // Anima uma linha do spritesheet (row)
  static Future<SpriteAnimation> _rowAnimation(
    int row, {
    double stepTime = defaultStepTime,
    bool loop = true,
  }) async {
    final sheet = await _getSheet();
    return sheet.createAnimation(
      row: row,
      from: 0,
      to: columns, // 0..1
      stepTime: stepTime,
      loop: loop,
    );
  }

  // Monta o SimpleDirectionAnimation para 3 linhas consecutivas
  // baseRow     -> direita
  // baseRow + 1 -> baixo
  // baseRow + 2 -> cima
  static Future<SimpleDirectionAnimation> _toolDirectionAnimation({
    required int baseRow,
    double idleStepTime = defaultStepTime,
    double runStepTime = defaultStepTime,
  }) async {
    return SimpleDirectionAnimation(
      idleRight: await _rowAnimation(baseRow, stepTime: idleStepTime),
      idleDown: await _rowAnimation(baseRow + 1, stepTime: idleStepTime),
      idleUp: await _rowAnimation(baseRow + 2, stepTime: idleStepTime),
      runRight: await _rowAnimation(baseRow, stepTime: runStepTime),
      runDown: await _rowAnimation(baseRow + 1, stepTime: runStepTime),
      runUp: await _rowAnimation(baseRow + 2, stepTime: runStepTime),
      enabledFlipX: true, // esquerda via flip
      enabledFlipY: false,
    );
  }

  // Picareta (rows 0, 1, 2)
  static Future<SimpleDirectionAnimation> getPickaxeAnimation({
    double idleStepTime = defaultStepTime,
    double runStepTime = defaultStepTime,
  }) => _toolDirectionAnimation(
    baseRow: 0,
    idleStepTime: idleStepTime,
    runStepTime: runStepTime,
  );

  // Machado (rows 3, 4, 5)
  static Future<SimpleDirectionAnimation> getAxeAnimation({
    double idleStepTime = defaultStepTime,
    double runStepTime = defaultStepTime,
  }) => _toolDirectionAnimation(
    baseRow: 3,
    idleStepTime: idleStepTime,
    runStepTime: runStepTime,
  );

  // Pá (rows 6, 7, 8)
  static Future<SimpleDirectionAnimation> getShovelAnimation({
    double idleStepTime = defaultStepTime,
    double runStepTime = defaultStepTime,
  }) => _toolDirectionAnimation(
    baseRow: 6,
    idleStepTime: idleStepTime,
    runStepTime: runStepTime,
  );

  // Regador (rows 9, 10, 11)
  static Future<SimpleDirectionAnimation> getWateringCanAnimation({
    double idleStepTime = defaultStepTime,
    double runStepTime = defaultStepTime,
  }) => _toolDirectionAnimation(
    baseRow: 9,
    idleStepTime: idleStepTime,
    runStepTime: runStepTime,
  );
}
