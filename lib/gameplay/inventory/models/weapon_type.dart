/// Tipos de armas disponíveis no jogo
enum WeaponType {
  /// Espadas - armas corpo a corpo balanceadas
  sword,

  /// Machados - alto dano, ataque lento
  axe,

  /// Lanças - alcance médio
  spear,

  /// Adagas - rápidas, baixo dano
  dagger,

  /// Martelos/Maças - alto dano, quebradores de armadura
  mace,

  /// Arcos - ataque à distância
  bow,

  /// Bestas - ataque à distância, mais lento que arco
  crossbow,

  /// Cajados mágicos
  staff,

  /// Varinhas mágicas
  wand,

  /// Escudos - usados para defesa
  shield;

  /// Converte enum para JSON string
  String toJson() => name;

  /// Cria enum a partir de JSON string
  static WeaponType fromJson(String json) {
    return WeaponType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => WeaponType.sword,
    );
  }

  /// Nome formatado para exibição
  String get displayName {
    switch (this) {
      case WeaponType.sword:
        return 'Sword';
      case WeaponType.axe:
        return 'Axe';
      case WeaponType.spear:
        return 'Spear';
      case WeaponType.dagger:
        return 'Dagger';
      case WeaponType.mace:
        return 'Mace';
      case WeaponType.bow:
        return 'Bow';
      case WeaponType.crossbow:
        return 'Crossbow';
      case WeaponType.staff:
        return 'Staff';
      case WeaponType.wand:
        return 'Wand';
      case WeaponType.shield:
        return 'Shield';
    }
  }
}
