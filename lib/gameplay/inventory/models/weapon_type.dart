enum WeaponType {
  ironSword,

  shovel,

  wateringCan,

  seeds,

  harvestBasket,

  axe,

  spear,

  dagger,

  mace,

  bow,

  crossbow,

  staff,

  wand;

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
      case WeaponType.shovel:
        return 'Shovel';
      case WeaponType.wateringCan:
        return 'Watering Can';
      case WeaponType.seeds:
        return 'Seed';
      case WeaponType.harvestBasket:
        return 'Harvest Basket';
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
    }
  }
}
