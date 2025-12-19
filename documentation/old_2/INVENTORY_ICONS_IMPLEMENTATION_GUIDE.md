# Guia de Implementação: Sistema de Sprites para Ícones do Inventário

## Visão Geral

Este guia detalha a implementação do sistema de ícones baseados em sprites para o inventário, substituindo as abreviações de texto atuais por sprites visuais carregados de um texture atlas.

**Texture Atlas**: `assets/tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png`
- Grid de sprites 16x16
- Contém todos os ícones de itens do jogo

## Arquitetura

O sistema segue o mesmo padrão usado pelo sistema de crops:
1. **Database JSON** - Define coordenadas dos sprites no atlas
2. **Model Class** - Representa os dados do ícone
3. **Database Loader** - Carrega e gerencia os dados do JSON
4. **Factory Integration** - Popula os modelos com dados de ícones
5. **Widget Component** - Renderiza os sprites na UI
6. **UI Integration** - Integra o widget no inventário existente

---

## PASSO 1: Criar Database JSON

### Arquivo: `assets/items/items_icons_database.json`

```json
{
  "spritesheetPath": "tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png",
  "spriteWidth": 16,
  "spriteHeight": 16,
  "items": {
    "ironSword": {
      "rowIndex": 0,
      "columnIndex": 0
    },
    "shovel": {
      "rowIndex": 0,
      "columnIndex": 1
    },
    "wateringCan": {
      "rowIndex": 0,
      "columnIndex": 2
    },
    "harvestBasket": {
      "rowIndex": 0,
      "columnIndex": 3
    },
    "staff": {
      "rowIndex": 0,
      "columnIndex": 4
    },
    "stone": {
      "rowIndex": 0,
      "columnIndex": 5
    },
    "iron_ore": {
      "rowIndex": 0,
      "columnIndex": 6
    },
    "cabbage": {
      "rowIndex": 1,
      "columnIndex": 0
    },
    "radish": {
      "rowIndex": 1,
      "columnIndex": 1
    },
    "carrot": {
      "rowIndex": 1,
      "columnIndex": 2
    },
    "strawberry": {
      "rowIndex": 1,
      "columnIndex": 3
    },
    "wheat": {
      "rowIndex": 1,
      "columnIndex": 4
    },
    "pepper": {
      "rowIndex": 1,
      "columnIndex": 5
    },
    "turnip": {
      "rowIndex": 1,
      "columnIndex": 6
    },
    "cotton": {
      "rowIndex": 2,
      "columnIndex": 0
    },
    "onion": {
      "rowIndex": 2,
      "columnIndex": 1
    },
    "cauliflower": {
      "rowIndex": 2,
      "columnIndex": 2
    },
    "corn": {
      "rowIndex": 2,
      "columnIndex": 3
    },
    "tomato": {
      "rowIndex": 2,
      "columnIndex": 4
    },
    "grape": {
      "rowIndex": 2,
      "columnIndex": 5
    },
    "prickly_pear": {
      "rowIndex": 2,
      "columnIndex": 6
    },
    "coffee": {
      "rowIndex": 3,
      "columnIndex": 0
    },
    "zuchini": {
      "rowIndex": 3,
      "columnIndex": 1
    },
    "pumpkin": {
      "rowIndex": 3,
      "columnIndex": 2
    },
    "pineapple": {
      "rowIndex": 3,
      "columnIndex": 3
    },
    "watermelon": {
      "rowIndex": 3,
      "columnIndex": 4
    }
  }
}
```

**Nota**: Ajuste os índices de row/column conforme a posição real dos sprites no atlas.

---

## PASSO 2: Criar Model Class ItemIconData

### Arquivo: `lib/gameplay/inventory/models/item_icon_data.dart`

```dart
class ItemIconData {
  final String spritesheetPath;
  final int spriteWidth;
  final int spriteHeight;
  final int spriteRowIndex;
  final int spriteColumnIndex;

  ItemIconData({
    required this.spritesheetPath,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.spriteRowIndex,
    required this.spriteColumnIndex,
  });

  factory ItemIconData.fromJson(
    Map<String, dynamic> json,
    String globalSpritesheetPath,
    int globalSpriteWidth,
    int globalSpriteHeight,
  ) {
    return ItemIconData(
      spritesheetPath: globalSpritesheetPath,
      spriteWidth: globalSpriteWidth,
      spriteHeight: globalSpriteHeight,
      spriteRowIndex: json['rowIndex'] as int,
      spriteColumnIndex: json['columnIndex'] as int,
    );
  }
}
```

---

## PASSO 3: Criar Database Loader

### Arquivo: `lib/gameplay/inventory/database/item_icon_database.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/item_icon_data.dart';

class ItemIconDatabase {
  static final ItemIconDatabase _instance = ItemIconDatabase._internal();
  factory ItemIconDatabase() => _instance;
  ItemIconDatabase._internal();

  final Map<String, ItemIconData> _icons = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final String jsonString = await rootBundle.loadString('assets/items/items_icons_database.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final String globalSpritesheetPath = jsonData['spritesheetPath'];
    final int globalSpriteWidth = jsonData['spriteWidth'];
    final int globalSpriteHeight = jsonData['spriteHeight'];
    final Map<String, dynamic> items = jsonData['items'];

    items.forEach((key, value) {
      _icons[key] = ItemIconData.fromJson(
        value,
        globalSpritesheetPath,
        globalSpriteWidth,
        globalSpriteHeight,
      );
    });

    _initialized = true;
  }

  ItemIconData? getIconData(String itemKey) {
    return _icons[itemKey];
  }

  bool get isInitialized => _initialized;
}
```

---

## PASSO 4: Atualizar Item Model

### Arquivo: `lib/gameplay/inventory/models/item.dart`

**Adicionar campo:**

```dart
import 'item_icon_data.dart';

abstract class Item {
  final String key;
  final String name;
  final ItemType type;
  final int maxStack;
  final ItemIconData? iconData; // NOVO CAMPO

  Item({
    required this.key,
    required this.name,
    required this.type,
    this.maxStack = 99,
    this.iconData, // NOVO PARÂMETRO
  });
}
```

**Atualizar todas as subclasses** (WeaponItem, FarmToolItem, SeedItem, ResourceItem, etc.) para aceitar e passar `iconData`:

```dart
class WeaponItem extends Item {
  final EquippedHandType equippedHandType;
  final int attackPower;

  WeaponItem({
    required super.key,
    required super.name,
    required this.equippedHandType,
    required this.attackPower,
    super.maxStack,
    super.iconData, // ADICIONAR
  }) : super(type: ItemType.weapon);
}
```

---

## PASSO 5: Atualizar ItemFactory

### Arquivo: `lib/gameplay/inventory/item_factory.dart`

**1. Adicionar inicialização do ItemIconDatabase:**

```dart
import 'database/item_icon_database.dart';

class ItemFactory {
  static Future<void> initialize() async {
    await ItemIconDatabase().initialize(); // ADICIONAR ANTES DO CropDatabase
    await CropDatabase().initialize();
  }
}
```

**2. Atualizar método de criação:**

```dart
static Item? createItem(String itemKey, {int quantity = 1}) {
  final itemData = _itemsDatabase[itemKey];
  if (itemData == null) return null;

  final ItemIconData? iconData = ItemIconDatabase().getIconData(itemKey); // CARREGAR ICON DATA

  switch (itemData['type'] as String) {
    case 'weapon':
      return WeaponItem(
        key: itemKey,
        name: itemData['name'],
        equippedHandType: _parseEquippedHandType(itemData['equippedHandType']),
        attackPower: itemData['attackPower'] ?? 0,
        maxStack: itemData['maxStack'] ?? 99,
        iconData: iconData, // PASSAR ICON DATA
      );
    
    case 'farmTool':
      return FarmToolItem(
        key: itemKey,
        name: itemData['name'],
        equippedHandType: _parseEquippedHandType(itemData['equippedHandType']),
        maxStack: itemData['maxStack'] ?? 1,
        iconData: iconData, // PASSAR ICON DATA
      );
    
    case 'seed':
      final cropData = CropDatabase().getCrop(itemData['cropKey']);
      if (cropData == null) return null;
      return SeedItem(
        key: itemKey,
        name: itemData['name'],
        cropData: cropData,
        maxStack: itemData['maxStack'] ?? 99,
        iconData: iconData, // PASSAR ICON DATA
      );
    
    case 'resource':
      return ResourceItem(
        key: itemKey,
        name: itemData['name'],
        maxStack: itemData['maxStack'] ?? 99,
        iconData: iconData, // PASSAR ICON DATA
      );
    
    default:
      return null;
  }
}
```

---

## PASSO 6: Criar ItemIconWidget

### Arquivo: `lib/gameplay/inventory/widgets/item_icon_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import '../models/item.dart';
import '../../../shared/utils/sprite_animation_config_helper.dart';

class ItemIconWidget extends StatelessWidget {
  final Item item;
  final double size;

  const ItemIconWidget({
    super.key,
    required this.item,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = item.iconData;

    if (iconData == null) {
      // Fallback: mostrar abreviação de texto
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Text(
          item.key.substring(0, 2).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return FutureBuilder<Sprite>(
      future: SpriteAnimationConfigHelper.loadSpriteFromSheet(
        'assets/${iconData.spritesheetPath}',
        Vector2(iconData.spriteWidth.toDouble(), iconData.spriteHeight.toDouble()),
        iconData.spriteColumnIndex,
        iconData.spriteRowIndex,
        skipFirstFrames: 0,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            size: Size(size, size),
            painter: _SpritePainter(sprite: snapshot.data!),
          );
        }

        // Loading ou erro: mostrar abreviação
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Text(
            item.key.substring(0, 2).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  final Sprite sprite;

  _SpritePainter({required this.sprite});

  @override
  void paint(Canvas canvas, Size size) {
    sprite.render(
      canvas,
      position: Vector2.zero(),
      size: Vector2(size.width, size.height),
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return sprite != oldDelegate.sprite;
  }
}
```

---

## PASSO 7: Integrar na UI do Inventário

### Exemplo de integração

Onde você atualmente renderiza o texto/abreviação do item, substitua por:

```dart
// ANTES:
Text(item.key.substring(0, 2).toUpperCase())

// DEPOIS:
ItemIconWidget(
  item: item,
  size: 32.0, // ajuste conforme necessário
)
```

### Localização típica

Procure por arquivos como:
- `lib/gameplay/hud/inventory_widget.dart`
- `lib/gameplay/hud/hotbar_widget.dart`
- Qualquer widget que renderize itens do inventário

---

## PASSO 8: Atualizar pubspec.yaml

Adicione o database JSON aos assets:

```yaml
flutter:
  assets:
    - assets/items/items_icons_database.json
    # ... outros assets existentes
```

---

## Fluxo de Dados

```
items_icons_database.json
        ↓
ItemIconDatabase.initialize()
        ↓
ItemFactory.createItem()
        ↓
    Item.iconData
        ↓
ItemIconWidget (renderiza sprite)
        ↓
    UI do Inventário
```

---

## Checklist de Implementação

- [ ] **Passo 1**: Criar `items_icons_database.json` com coordenadas corretas
- [ ] **Passo 2**: Criar `ItemIconData` model class
- [ ] **Passo 3**: Criar `ItemIconDatabase` loader
- [ ] **Passo 4**: Adicionar campo `iconData` em `Item` e subclasses
- [ ] **Passo 5**: Atualizar `ItemFactory` para carregar e passar `iconData`
- [ ] **Passo 6**: Criar `ItemIconWidget` component
- [ ] **Passo 7**: Integrar `ItemIconWidget` na UI do inventário
- [ ] **Passo 8**: Adicionar JSON ao `pubspec.yaml`
- [ ] **Teste**: Verificar que todos os itens mostram sprites corretos
- [ ] **Fallback**: Confirmar que itens sem iconData mostram abreviação

---

## Benefícios

✅ **Consistência Visual**: Todos os ícones de um único atlas  
✅ **Performance**: Carregamento eficiente de sprites  
✅ **Manutenibilidade**: Adicionar novos itens apenas requer atualizar JSON  
✅ **Escalabilidade**: Padrão replicável para outros sistemas  
✅ **Fallback Robusto**: Sistema funciona mesmo sem dados de ícone  

---

## Próximos Passos (Opcional)

- Adicionar animações de hover nos ícones
- Implementar tooltips com informações do item
- Adicionar badges visuais (quantidade, raridade, etc)
- Criar variantes de ícones para estados especiais (equipado, etc)
