import 'package:equatable/equatable.dart';

/// Domain model for inventory and equipment save data.
///
/// Represents all items, equipment, and storage containers
/// in the player's possession.
final class InventorySaveData {
  /// Player's main inventory slots
  final List<InventorySlotData> inventorySlots;

  /// Equipped items (weapon, armor, accessories)
  final Map<String, EquippedItemData?> equipment;

  /// Storage containers (chests, fridges, etc.)
  final Map<String, List<InventorySlotData>> containers;

  /// Quick bar slots for fast item access
  final List<InventorySlotData> quickBarSlots;

  /// Maximum inventory capacity
  final int maxInventorySlots;

  const InventorySaveData({
    required this.inventorySlots,
    required this.equipment,
    required this.containers,
    required this.quickBarSlots,
    required this.maxInventorySlots,
  });

  /// Creates initial empty inventory.
  factory InventorySaveData.initial({int maxSlots = 36}) {
    return InventorySaveData(
      inventorySlots: List.generate(maxSlots, (_) => InventorySlotData.empty()),
      equipment: {
        'weapon': null,
        'offhand': null,
        'helmet': null,
        'chest': null,
        'legs': null,
        'boots': null,
        'ring1': null,
        'ring2': null,
      },
      containers: {},
      quickBarSlots: List.generate(10, (_) => InventorySlotData.empty()),
      maxInventorySlots: maxSlots,
    );
  }

  factory InventorySaveData.fromJson(Map<String, dynamic> json) {
    return InventorySaveData(
      inventorySlots:
          (json['inventorySlots'] as List<dynamic>?)
              ?.map(
                (e) => InventorySlotData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      equipment:
          (json['equipment'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              value == null
                  ? null
                  : EquippedItemData.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      containers:
          (json['containers'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>)
                  .map(
                    (e) =>
                        InventorySlotData.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            ),
          ) ??
          {},
      quickBarSlots:
          (json['quickBarSlots'] as List<dynamic>?)
              ?.map(
                (e) => InventorySlotData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      maxInventorySlots: json['maxInventorySlots'] as int? ?? 36,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventorySlots': inventorySlots.map((slot) => slot.toJson()).toList(),
      'equipment': equipment.map(
        (key, value) => MapEntry(key, value?.toJson()),
      ),
      'containers': containers.map(
        (key, value) =>
            MapEntry(key, value.map((slot) => slot.toJson()).toList()),
      ),
      'quickBarSlots': quickBarSlots.map((slot) => slot.toJson()).toList(),
      'maxInventorySlots': maxInventorySlots,
    };
  }

  bool isValid() {
    return inventorySlots.length <= maxInventorySlots &&
        quickBarSlots.length <= 10 &&
        maxInventorySlots > 0;
  }

  /// Gets total number of used inventory slots.
  int get usedSlots {
    return inventorySlots.where((slot) => !slot.isEmpty).length;
  }

  /// Gets list of all equipped items.
  List<EquippedItemData> get equippedItems {
    return equipment.values.whereType<EquippedItemData>().toList();
  }

  InventorySaveData copyWith({
    List<InventorySlotData>? inventorySlots,
    Map<String, EquippedItemData?>? equipment,
    Map<String, List<InventorySlotData>>? containers,
    List<InventorySlotData>? quickBarSlots,
    int? maxInventorySlots,
  }) {
    return InventorySaveData(
      inventorySlots: inventorySlots ?? this.inventorySlots,
      equipment: equipment ?? this.equipment,
      containers: containers ?? this.containers,
      quickBarSlots: quickBarSlots ?? this.quickBarSlots,
      maxInventorySlots: maxInventorySlots ?? this.maxInventorySlots,
    );
  }

  @override
  String toString() {
    return 'InventorySaveData('
        'slots: $usedSlots/$maxInventorySlots, '
        'equipped: ${equippedItems.length}, '
        'containers: ${containers.length}'
        ')';
  }
}

/// Represents a single inventory slot.
final class InventorySlotData extends Equatable {
  final String? itemId;
  final int quantity;
  final Map<String, dynamic>? metadata;

  const InventorySlotData({this.itemId, required this.quantity, this.metadata});

  factory InventorySlotData.empty() {
    return const InventorySlotData(quantity: 0);
  }

  bool get isEmpty => itemId == null || quantity <= 0;

  factory InventorySlotData.fromJson(Map<String, dynamic> json) {
    return InventorySlotData(
      itemId: json['itemId'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (itemId != null) 'itemId': itemId,
      'quantity': quantity,
      if (metadata != null) 'metadata': metadata,
    };
  }

  InventorySlotData copyWith({
    String? itemId,
    int? quantity,
    Map<String, dynamic>? metadata,
  }) {
    return InventorySlotData(
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'Slot(item: $itemId, qty: $quantity)';

  @override
  List<Object?> get props => [itemId, quantity];
}

/// Represents an equipped item with stats.
final class EquippedItemData extends Equatable {
  final String itemId;
  final String slot;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? metadata;

  const EquippedItemData({
    required this.itemId,
    required this.slot,
    this.stats,
    this.metadata,
  });

  factory EquippedItemData.fromJson(Map<String, dynamic> json) {
    return EquippedItemData(
      itemId: json['itemId'] as String,
      slot: json['slot'] as String,
      stats: json['stats'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'slot': slot,
      if (stats != null) 'stats': stats,
      if (metadata != null) 'metadata': metadata,
    };
  }

  EquippedItemData copyWith({
    String? itemId,
    String? slot,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? metadata,
  }) {
    return EquippedItemData(
      itemId: itemId ?? this.itemId,
      slot: slot ?? this.slot,
      stats: stats ?? this.stats,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'Equipped($itemId in $slot)';

  @override
  // TODO: implement props
  List<Object?> get props => [itemId, slot];
}
