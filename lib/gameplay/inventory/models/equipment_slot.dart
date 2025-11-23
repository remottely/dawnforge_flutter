import 'item.dart';

/// Tipos de slot de equipamento disponíveis
enum EquipmentSlotType {
  /// Arma principal
  weapon,

  /// Escudo ou arma secundária
  offhand,

  /// Capacete
  helmet,

  /// Peitoral/armadura de torso
  chest,

  /// Calças/armadura de pernas
  legs,

  /// Botas
  boots,

  /// Acessório 1 (anel, colar, etc)
  accessory1,

  /// Acessório 2 (anel, colar, etc)
  accessory2;

  /// Serializa para JSON
  String toJson() => name;

  /// Deserializa de JSON
  static EquipmentSlotType fromJson(String json) => values.byName(json);
}

/// Representa um slot de equipamento do personagem
///
/// Cada slot pode conter um item equipado ou estar vazio.
final class EquipmentSlot {
  /// Tipo do slot de equipamento
  final EquipmentSlotType slotType;

  /// Item atualmente equipado (null = vazio)
  final Item? equippedItem;

  /// Cria um slot de equipamento
  const EquipmentSlot({required this.slotType, this.equippedItem});

  /// Slot está vazio?
  bool get isEmpty => equippedItem == null;

  /// Slot está ocupado?
  bool get isOccupied => equippedItem != null;

  /// Cria novo slot com item equipado
  EquipmentSlot equip(Item item) {
    return EquipmentSlot(slotType: slotType, equippedItem: item);
  }

  /// Cria novo slot sem item (desequipa)
  EquipmentSlot unequip() {
    return EquipmentSlot(slotType: slotType);
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    return {'slotType': slotType.toJson(), 'equippedItemId': equippedItem?.id};
  }

  /// Deserialização de JSON
  ///
  /// Requer um [itemResolver] para obter a instância do Item pelo ID.
  static EquipmentSlot fromJson(
    Map<String, dynamic> json,
    Item? Function(String) itemResolver,
  ) {
    final itemId = json['equippedItemId'] as String?;
    return EquipmentSlot(
      slotType: EquipmentSlotType.fromJson(json['slotType'] as String),
      equippedItem: itemId != null ? itemResolver(itemId) : null,
    );
  }

  @override
  String toString() =>
      'EquipmentSlot(slotType: $slotType, equippedItem: ${equippedItem?.id})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentSlot &&
          runtimeType == other.runtimeType &&
          slotType == other.slotType &&
          equippedItem == other.equippedItem;

  @override
  int get hashCode => Object.hash(slotType, equippedItem);
}
