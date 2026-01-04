class SoilStateSprite {
  final int rowIndex;
  final int columnIndex;

  const SoilStateSprite({required this.rowIndex, required this.columnIndex});
}

final class SoilStateSpriteDatabaseDef {
  SoilStateSpriteDatabaseDef._();

  static const String spritesheetPath =
      'tiled/Modern_Farm_v1.2/tilesets/1_Terrains_16x16.png';
  static const int spriteWidth = 16;
  static const int spriteHeight = 16;

  static const Map<String, SoilStateSprite> soilStateSpriteList = {
    'untilled': SoilStateSprite(rowIndex: 3, columnIndex: 0),
    'tilled': SoilStateSprite(rowIndex: 17, columnIndex: 9),
    'watered': SoilStateSprite(rowIndex: 1, columnIndex: 17),
    'fertilized': SoilStateSprite(rowIndex: 2, columnIndex: 3),
  };
}
