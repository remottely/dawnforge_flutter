/// Raridade dos itens no jogo
enum ItemRarity {
  /// Comum - Branco
  common,

  /// Incomum - Verde
  uncommon,

  /// Raro - Azul
  rare,

  /// Épico - Roxo
  epic,

  /// Lendário - Dourado
  legendary;

  /// Serializa para JSON
  String toJson() => name;

  /// Deserializa de JSON
  static ItemRarity fromJson(String json) => values.byName(json);

  /// Multiplicador do valor de venda baseado na raridade
  double get sellValueMultiplier {
    switch (this) {
      case ItemRarity.common:
        return 1.0;
      case ItemRarity.uncommon:
        return 1.5;
      case ItemRarity.rare:
        return 2.5;
      case ItemRarity.epic:
        return 5.0;
      case ItemRarity.legendary:
        return 10.0;
    }
  }
}
