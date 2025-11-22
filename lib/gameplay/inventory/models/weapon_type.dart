enum WeaponType {
  ironSword,

  digger,

  wateringCan,

  seeds,

  axe,

  spear,

  dagger,

  mace,

  bow,

  crossbow,

  staff,

  wand,

  shield;

  String toJson() => name;

  static WeaponType fromJson(String json) {
    return WeaponType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => WeaponType.ironSword,
    );
  }

  String get displayName {
    switch (this) {
      case WeaponType.ironSword:
        return 'Sword';
      case WeaponType.digger:
        return 'Digger';
      case WeaponType.wateringCan:
        return 'Watering Can';
      case WeaponType.seeds:
        return 'Seed';
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
