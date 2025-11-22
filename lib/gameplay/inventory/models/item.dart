import 'item_rarity.dart';
import 'item_type.dart';

/// Modelo base abstrato para todos os itens do jogo
///
/// Todos os itens devem estender esta classe e implementar
/// os métodos [toJson] e [copyWith].
abstract class Item {
  /// ID único do item (ex: 'ironSword', 'healthPotion')
  final String id;

  /// Nome exibido ao jogador
  final String name;

  /// Descrição do item
  final String description;

  /// Tipo do item
  final ItemType type;

  /// Raridade do item
  final ItemRarity rarity;

  /// Tamanho máximo da pilha (stack)
  final int maxStackSize;

  /// Valor base em moedas
  final int baseValue;

  /// Caminho do ícone do item
  final String iconPath;

  /// Pode empilhar múltiplos itens?
  final bool isStackable;

  /// Pode dropar no chão?
  final bool isDroppable;

  /// Pode negociar/vender?
  final bool isTradeable;

  /// Construtor base do item
  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = ItemRarity.common,
    this.maxStackSize = 1,
    required this.baseValue,
    required this.iconPath,
    this.isStackable = false,
    this.isDroppable = true,
    this.isTradeable = true,
  });

  /// Valor de venda (baseValue * multiplicador da raridade)
  int get sellValue => (baseValue * rarity.sellValueMultiplier).round();

  /// Serialização para JSON
  Map<String, dynamic> toJson();

  /// Cria cópia do item com modificações
  Item copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Item(id: $id, name: $name, type: $type)';
}
