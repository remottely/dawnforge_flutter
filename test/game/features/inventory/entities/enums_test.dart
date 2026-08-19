import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_type.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/loot_category.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/material_type.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/tool_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HandItemId', () {
    group('serialization', () {
      test('every value round-trips', () {
        for (final id in HandItemId.values) {
          expect(HandItemId.fromJson(id.toJson()), id, reason: '$id');
        }
      });

      test('unknown name → unknown instead of throwing', () {
        expect(HandItemId.fromString('nonexistent_item'), HandItemId.unknown);
      });
    });

    group('isSeed', () {
      test('every real *_seed_bag value is a seed', () {
        final seedBags = HandItemId.values.where(
          (id) =>
              id.name.endsWith('_seed_bag') && id != HandItemId.empty_seed_bag,
        );

        expect(seedBags, isNotEmpty);
        for (final id in seedBags) {
          expect(id.isSeed, isTrue, reason: '$id');
        }
      });

      test('empty_seed_bag is a placeholder, not a plantable seed', () {
        expect(HandItemId.empty_seed_bag.isSeed, isFalse);
        expect(HandItemId.empty_seed_bag.isEquippable, isFalse);
      });

      test('a harvest loot item is not a seed', () {
        expect(HandItemId.carrot_loot_item.isSeed, isFalse);
      });

      test('a tool is not a seed', () {
        expect(HandItemId.shovel.isSeed, isFalse);
      });
    });

    group('capability predicates', () {
      test('farm tools are recognised', () {
        expect(HandItemId.shovel.isFarmTool, isTrue);
        expect(HandItemId.wateringCan.isFarmTool, isTrue);
        expect(HandItemId.harvestBasket.isFarmTool, isTrue);
      });

      test('combat weapons are recognised', () {
        expect(HandItemId.ironSword.isCombatWeapon, isTrue);
        expect(HandItemId.sword.isCombatWeapon, isTrue);
        expect(HandItemId.staff.isCombatWeapon, isTrue);
      });

      test('pickaxes are recognised', () {
        expect(HandItemId.iron_pickaxe.isPickaxe, isTrue);
        expect(HandItemId.steel_pickaxe.isPickaxe, isTrue);
        expect(HandItemId.shovel.isPickaxe, isFalse);
      });

      test('only the iron sword can defend', () {
        expect(HandItemId.ironSword.canDefense, isTrue);
        expect(HandItemId.sword.canDefense, isFalse);
      });

      test('isEquippable is the union of seed, farm tool and weapon', () {
        for (final id in HandItemId.values) {
          expect(
            id.isEquippable,
            id.isSeed || id.isFarmTool || id.isCombatWeapon,
            reason: '$id',
          );
        }
      });

      test('canBeEquippedInMainHandSlot matches isEquippable', () {
        for (final id in HandItemId.values) {
          expect(
            id.canBeEquippedInMainHandSlot,
            id.isEquippable,
            reason: '$id',
          );
        }
      });

      test('a raw material is not equippable', () {
        expect(HandItemId.wood.isEquippable, isFalse);
        expect(HandItemId.stone.isEquippable, isFalse);
      });
    });
  });

  group('HandItemQuality', () {
    test('price multipliers follow the quality ladder', () {
      expect(HandItemQuality.normal.priceMultiplier, 1.0);
      expect(HandItemQuality.silver.priceMultiplier, 1.25);
      expect(HandItemQuality.gold.priceMultiplier, 1.5);
      expect(HandItemQuality.iridium.priceMultiplier, 2.0);
    });

    test('unknown quality is priced as normal', () {
      expect(HandItemQuality.unknown.priceMultiplier, 1.0);
    });

    test('star count follows the quality ladder', () {
      expect(HandItemQuality.normal.starCount, 0);
      expect(HandItemQuality.silver.starCount, 1);
      expect(HandItemQuality.gold.starCount, 2);
      expect(HandItemQuality.iridium.starCount, 3);
      expect(HandItemQuality.unknown.starCount, 0);
    });

    test('every value round-trips', () {
      for (final quality in HandItemQuality.values) {
        expect(HandItemQuality.fromJson(quality.toJson()), quality);
      }
    });

    test('unknown name → unknown', () {
      expect(HandItemQuality.fromJson('mythic'), HandItemQuality.unknown);
    });

    test('toString is the display name', () {
      expect(HandItemQuality.gold.toString(), 'Gold');
    });
  });

  group('HandItemType', () {
    test('every value round-trips', () {
      for (final type in HandItemType.values) {
        expect(HandItemType.fromJson(type.toJson()), type);
      }
    });

    test('unknown name → throws (there is no unknown member)', () {
      expect(() => HandItemType.fromJson('gadget'), throwsArgumentError);
    });
  });

  group('SeasonType', () {
    group('matches', () {
      test('same season → true', () {
        expect(SeasonType.spring.matches(SeasonType.spring), isTrue);
      });

      test('different seasons → false', () {
        expect(SeasonType.spring.matches(SeasonType.winter), isFalse);
      });

      test('any matches everything, in both directions', () {
        for (final season in SeasonType.values) {
          expect(SeasonType.any.matches(season), isTrue, reason: '$season');
          expect(season.matches(SeasonType.any), isTrue, reason: '$season');
        }
      });
    });

    // COMPORTAMENTO ATUAL, INCORRETO — ver refactoring/03-fase-3 §3.4.
    // `next()` percorre `values`, que inclui `any` e `unknown`, então o ciclo
    // do calendário passa por valores que não são estações. Ao corrigir,
    // `winter.next()` deve devolver `spring`.
    group('next (broken — walks non-calendar values)', () {
      test('spring → summer → fall → winter as expected', () {
        expect(SeasonType.spring.next(), SeasonType.summer);
        expect(SeasonType.summer.next(), SeasonType.fall);
        expect(SeasonType.fall.next(), SeasonType.winter);
      });

      test('winter → any instead of wrapping back to spring', () {
        expect(SeasonType.winter.next(), SeasonType.any);
      });

      test('the cycle takes 6 steps instead of 4', () {
        var season = SeasonType.spring;
        var steps = 0;

        do {
          season = season.next();
          steps++;
        } while (season != SeasonType.spring && steps < 20);

        expect(steps, 6);
      });
    });

    test('every value round-trips', () {
      for (final season in SeasonType.values) {
        expect(SeasonType.fromJson(season.toJson()), season);
      }
    });

    test('unknown name → unknown', () {
      expect(SeasonType.fromJson('monsoon'), SeasonType.unknown);
    });
  });

  group('ToolType', () {
    test('every value round-trips', () {
      for (final type in ToolType.values) {
        expect(ToolType.fromJson(type.toJson()), type);
      }
    });

    test('unknown name → unknown', () {
      expect(ToolType.fromJson('chainsaw'), ToolType.unknown);
    });
  });

  group('MaterialType', () {
    test('every value round-trips', () {
      for (final type in MaterialType.values) {
        expect(MaterialType.fromJson(type.toJson()), type);
      }
    });

    test('unknown name → unknown', () {
      expect(MaterialType.fromJson('plutonium'), MaterialType.unknown);
    });
  });

  group('LootCategory', () {
    test('every value round-trips', () {
      for (final category in LootCategory.values) {
        expect(LootCategory.fromJson(category.toJson()), category);
      }
    });

    test('unknown name → unknown', () {
      expect(LootCategory.fromJson('mineral'), LootCategory.unknown);
    });

    test('produce and animal products can have quality', () {
      expect(LootCategory.vegetable.canHaveQuality, isTrue);
      expect(LootCategory.fruit.canHaveQuality, isTrue);
      expect(LootCategory.animalProduct.canHaveQuality, isTrue);
      expect(LootCategory.misc.canHaveQuality, isFalse);
    });

    test('flowers can have quality but are not edible', () {
      expect(LootCategory.flower.canHaveQuality, isTrue);
      expect(LootCategory.flower.isEdible, isFalse);
    });

    test('every value exposes a display name', () {
      for (final category in LootCategory.values) {
        expect(category.displayName, isNotEmpty, reason: '$category');
      }
    });
  });

  group('ItemIconData', () {
    test('round-trips through JSON', () {
      const icon = ItemIconData(
        spritesheetPath: 'atlas.png',
        spriteWidth: 16,
        spriteHeight: 32,
        spriteRowIndex: 4,
        spriteColumnIndex: 7,
      );

      final restored = ItemIconData.fromJson(icon.toJson());

      expect(restored.spritesheetPath, icon.spritesheetPath);
      expect(restored.spriteWidth, icon.spriteWidth);
      expect(restored.spriteHeight, icon.spriteHeight);
      expect(restored.spriteRowIndex, icon.spriteRowIndex);
      expect(restored.spriteColumnIndex, icon.spriteColumnIndex);
    });

    // O `toJson` grava a chave como `columnIndex` mas o campo se chama
    // `spriteColumnIndex` — assimetria proposital de documentar, porque
    // qualquer renomeação precisa mexer nos dois lados.
    test('column index is serialized under the key "columnIndex"', () {
      const icon = ItemIconData(
        spritesheetPath: 'atlas.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 0,
        spriteColumnIndex: 3,
      );

      expect(icon.toJson()['columnIndex'], 3);
      expect(icon.toJson().containsKey('spriteColumnIndex'), isFalse);
    });
  });
}
