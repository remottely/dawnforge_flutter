enum EquippedHandType {
  ironSword,
  shovel,
  wateringCan,
  strawberry,
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

  static EquippedHandType fromJson(String json) {
    return EquippedHandType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => EquippedHandType.ironSword,
    );
  }

  // String get displayName {
  //   switch (this) {
  //     case EquippedHandType.ironSword:
  //       return 'Sword';
  //     case EquippedHandType.staff:
  //       return 'Staff';
  //     case EquippedHandType.shovel:
  //       return 'Shovel';
  //     case EquippedHandType.wateringCan:
  //       return 'Watering Can';
  //     case EquippedHandType.strawberry:
  //       return 'Strawberry';
  //     case EquippedHandType.harvestBasket:
  //       return 'Harvest Basket';
  //     case EquippedHandType.axe:
  //       return 'Axe';
  //     case EquippedHandType.spear:
  //       return 'Spear';
  //     case EquippedHandType.dagger:
  //       return 'Dagger';
  //     case EquippedHandType.mace:
  //       return 'Mace';
  //     case EquippedHandType.bow:
  //       return 'Bow';
  //     case EquippedHandType.crossbow:
  //       return 'Crossbow';

  //     case EquippedHandType.wand:
  //       return 'Wand';
  //   }
  // }
}
