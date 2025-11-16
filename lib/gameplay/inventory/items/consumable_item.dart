import '../models/item.dart';
import '../models/item_rarity.dart';
import '../models/item_type.dart';

/// Item consumível (poção, comida, etc)
///
/// Consumíveis podem ser usados para restaurar HP/stamina ou aplicar buffs.
final class ConsumableItem extends Item {
  /// HP restaurado ao consumir
  final int healthRestore;

  /// Stamina restaurada ao consumir
  final int staminaRestore;

  /// Duração do efeito em segundos (0 = instantâneo)
  final int duration;

  /// IDs de buffs aplicados ao consumir
  final List<String> buffs;

  /// Cria um item consumível
  const ConsumableItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.consumable,
    super.isStackable = true,
    super.maxStackSize = 99,
    this.healthRestore = 0,
    this.staminaRestore = 0,
    this.duration = 0,
    this.buffs = const [],
  });

  /// Efeito é instantâneo?
  bool get isInstant => duration == 0;

  /// Possui buffs?
  bool get hasBuffs => buffs.isNotEmpty;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'rarity': rarity.toJson(),
      'baseValue': baseValue,
      'iconPath': iconPath,
      'maxStackSize': maxStackSize,
      'healthRestore': healthRestore,
      'staminaRestore': staminaRestore,
      'duration': duration,
      'buffs': buffs,
    };
  }

  /// Cria consumível a partir de JSON
  factory ConsumableItem.fromJson(Map<String, dynamic> json) {
    return ConsumableItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseValue: json['baseValue'] as int,
      iconPath: json['iconPath'] as String,
      rarity: ItemRarity.fromJson(json['rarity'] as String),
      maxStackSize: json['maxStackSize'] as int? ?? 99,
      healthRestore: json['healthRestore'] as int? ?? 0,
      staminaRestore: json['staminaRestore'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      buffs:
          (json['buffs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );
  }

  @override
  ConsumableItem copyWith({
    String? id,
    String? name,
    String? description,
    int? baseValue,
    String? iconPath,
    ItemRarity? rarity,
    int? maxStackSize,
    int? healthRestore,
    int? staminaRestore,
    int? duration,
    List<String>? buffs,
  }) {
    return ConsumableItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseValue: baseValue ?? this.baseValue,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
      maxStackSize: maxStackSize ?? this.maxStackSize,
      healthRestore: healthRestore ?? this.healthRestore,
      staminaRestore: staminaRestore ?? this.staminaRestore,
      duration: duration ?? this.duration,
      buffs: buffs ?? this.buffs,
    );
  }

  @override
  String toString() =>
      'ConsumableItem(id: $id, name: $name, hp: +$healthRestore, stamina: +$staminaRestore)';
}
