enum ToolType {
  harvest,
  shovel,
  watering_can,
  pickaxe,
  axe,
  hoe,
  unknown;

  String toJson() => name;

  static ToolType fromJson(String json) {
    return ToolType.values.firstWhere(
      (value) => value.name == json,
      orElse: () => ToolType.unknown,
    );
  }
}
