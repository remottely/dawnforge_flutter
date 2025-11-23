/// Estado do solo em um tile de fazenda
enum SoilState {
  /// Não preparado para plantio
  untilled,

  /// Arado (pronto para plantar)
  tilled,

  /// Regado (crescimento mais rápido)
  watered,

  /// Fertilizado (qualidade maior)
  fertilized;

  /// Serialização para JSON
  String toJson() => name;

  /// Deserialização de JSON
  static SoilState fromJson(String json) => values.byName(json);

  /// Modificador de velocidade de crescimento
  double get growthSpeedMultiplier {
    switch (this) {
      case SoilState.untilled:
        return 0.0; // Não cresce
      case SoilState.tilled:
        return 1.0;
      case SoilState.watered:
        return 1.5;
      case SoilState.fertilized:
        return 2.0;
    }
  }
}
