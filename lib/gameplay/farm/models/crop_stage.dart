/// Estágio de crescimento de uma crop
enum CropStage {
  /// Semente plantada
  seed,

  /// Broto inicial
  sprout,

  /// Crescendo
  growing,

  /// Maduro (pode colher)
  mature,

  /// Morto (passou da época)
  withered;

  /// Serialização para JSON
  String toJson() => name;

  /// Deserialização de JSON
  static CropStage fromJson(String json) => values.byName(json);

  /// Pode colher neste estágio?
  bool get canHarvest => this == CropStage.mature;

  /// Está morto?
  bool get isDead => this == CropStage.withered;
}
