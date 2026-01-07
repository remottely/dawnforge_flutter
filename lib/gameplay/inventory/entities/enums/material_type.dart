enum MaterialType {
  wood,
  stone,
  ore,
  fiber,
  key,
  harvestLoot,
  unknown;

  String toJson() => name;

  static MaterialType fromJson(String json) {
    return MaterialType.values.firstWhere(
      (value) => value.name == json,
      orElse: () => MaterialType.unknown,
    );
  }
}
