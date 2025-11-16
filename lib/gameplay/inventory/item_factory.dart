import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart' show rootBundle;

import 'items/consumable_item.dart';
import 'items/material_item.dart';
import 'items/seed_item.dart';
import 'items/tool_item.dart';
import 'items/weapon_item.dart';
import 'models/item.dart';
import 'models/item_type.dart';

/// Factory para criação de itens a partir de um database JSON
///
/// O ItemFactory carrega um arquivo JSON com definições de todos os itens
/// do jogo e permite criar instâncias de itens pelo seu ID.
final class ItemFactory {
  ItemFactory._();

  static final Map<String, Map<String, dynamic>> _itemDatabase = {};
  static bool _isInitialized = false;

  /// Caminho do arquivo de database de itens
  static const String _kDatabasePath = 'assets/items/items_database.json';

  /// Inicializar factory carregando database de itens
  ///
  /// Deve ser chamado antes de usar [createItem] ou outros métodos.
  /// É seguro chamar múltiplas vezes, só carrega uma vez.
  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[ItemFactory] Already initialized');
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(_kDatabasePath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      for (final entry in jsonData.entries) {
        _itemDatabase[entry.key] = entry.value as Map<String, dynamic>;
      }

      _isInitialized = true;
      developer.log('[ItemFactory] Loaded ${_itemDatabase.length} items');
    } catch (e, stackTrace) {
      developer.log(
        '[ItemFactory] ERROR loading database',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Criar item por ID
  ///
  /// Retorna null se:
  /// - Factory não foi inicializado
  /// - ID não existe no database
  /// - Tipo de item não é suportado
  static Item? createItem(String itemId) {
    if (!_isInitialized) {
      developer.log(
        '[ItemFactory] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    final itemData = _itemDatabase[itemId];
    if (itemData == null) {
      developer.log('[ItemFactory] Item not found: $itemId');
      return null;
    }

    try {
      final type = ItemType.fromJson(itemData['type'] as String);

      switch (type) {
        case ItemType.weapon:
          return WeaponItem.fromJson(itemData);
        case ItemType.tool:
          return ToolItem.fromJson(itemData);
        case ItemType.consumable:
          return ConsumableItem.fromJson(itemData);
        case ItemType.material:
          return MaterialItem.fromJson(itemData);
        case ItemType.seed:
          return SeedItem.fromJson(itemData);
        default:
          developer.log(
            '[ItemFactory] Unsupported type: $type for item $itemId',
          );
          return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        '[ItemFactory] ERROR creating item $itemId',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Criar múltiplos itens de uma vez
  ///
  /// Ignora IDs inválidos e retorna apenas itens válidos.
  static List<Item> createItems(List<String> itemIds) {
    return itemIds.map(createItem).whereType<Item>().toList();
  }

  /// Listar todos os IDs de itens disponíveis
  static List<String> getAllItemIds() {
    return _itemDatabase.keys.toList();
  }

  /// Listar IDs de itens por tipo
  static List<String> getItemIdsByType(ItemType type) {
    return _itemDatabase.entries
        .where((e) => e.value['type'] == type.toJson())
        .map((e) => e.key)
        .toList();
  }

  /// Verificar se item existe no database
  static bool itemExists(String itemId) {
    return _itemDatabase.containsKey(itemId);
  }

  /// Limpar database (útil para testes)
  static void reset() {
    _itemDatabase.clear();
    _isInitialized = false;
    developer.log('[ItemFactory] Reset');
  }

  /// Factory foi inicializado?
  static bool get isInitialized => _isInitialized;

  /// Quantidade de itens no database
  static int get itemCount => _itemDatabase.length;
}
