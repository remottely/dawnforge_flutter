/// Tipos de itens disponíveis no jogo
enum ItemType {
  /// Armas de combate (espadas, machados de guerra)
  weapon,

  /// Ferramentas (picareta, machado, enxada)
  tool,

  /// Consumíveis (poções, comida)
  consumable,

  /// Materiais de crafting (madeira, minério, pedra)
  material,

  /// Sementes para agricultura
  seed,

  /// Equipamentos (armaduras, acessórios)
  equipment,

  /// Itens de quest
  quest,

  /// Tesouros (baús, relíquias)
  treasure;

  /// Serializa para JSON
  String toJson() => name;

  /// Deserializa de JSON
  static ItemType fromJson(String json) => values.byName(json);
}
