class ItemIconData {
  final String spritesheetPath;
  final int spriteWidth;
  final int spriteHeight;
  final int spriteRowIndex;
  final int spriteColumnIndex;

  const ItemIconData({
    required this.spritesheetPath,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.spriteRowIndex,
    required this.spriteColumnIndex,
  });

  factory ItemIconData.fromJson(
    Map<String, dynamic> json,
    String globalSpritesheetPath,
    int globalSpriteWidth,
    int globalSpriteHeight,
  ) {
    return ItemIconData(
      spritesheetPath: globalSpritesheetPath,
      spriteWidth: globalSpriteWidth,
      spriteHeight: globalSpriteHeight,
      spriteRowIndex: json['rowIndex'] as int,
      spriteColumnIndex: json['columnIndex'] as int,
    );
  }
}
