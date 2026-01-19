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

  Map<String, dynamic> toJson() {
    return {
      'spritesheetPath': spritesheetPath,
      'spriteWidth': spriteWidth,
      'spriteHeight': spriteHeight,
      'spriteRowIndex': spriteRowIndex,
      'columnIndex': spriteColumnIndex,
    };
  }

  factory ItemIconData.fromJson(Map<String, dynamic> json) {
    return ItemIconData(
      spritesheetPath: json['spritesheetPath'] as String,
      spriteWidth: json['spriteWidth'] as int,
      spriteHeight: json['spriteHeight'] as int,
      spriteRowIndex: json['spriteRowIndex'] as int,
      spriteColumnIndex: json['columnIndex'] as int,
    );
  }
}
