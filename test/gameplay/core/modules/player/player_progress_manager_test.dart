import 'dart:convert';

import 'package:darkness_dungeon/gameplay/core/modules/save/player_progress_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PlayerProgressManager manager;

  setUp(() {
    // Get singleton instance and reset before each test
    manager = PlayerProgressManager.instance;
    manager.reset();
  });

  group('PlayerProgressManager Tests', () {
    test('test_singleton_returns_same_instance', () {
      // Arrange & Act
      final instance1 = PlayerProgressManager.instance;
      final instance2 = PlayerProgressManager.instance;

      // Assert
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('test_flags_set_and_check', () {
      // Arrange
      const testFlag = 'quest_1_completed';

      // Act
      manager.setFlag(testFlag);

      // Assert
      expect(manager.hasFlag(testFlag), isTrue);
      expect(manager.hasFlag('non_existent_flag'), isFalse);

      // Verify in getAllFlags
      final allFlags = manager.getAllFlags();
      expect(allFlags.contains(testFlag), isTrue);
    });

    test('test_flags_remove', () {
      // Arrange
      const testFlag = 'test_flag';
      manager.setFlag(testFlag);
      expect(manager.hasFlag(testFlag), isTrue);

      // Act
      manager.removeFlag(testFlag);

      // Assert
      expect(manager.hasFlag(testFlag), isFalse);

      // Remove non-existent flag should not cause error
      manager.removeFlag('non_existent');
    });

    test('test_achievements_increment', () {
      // Arrange
      const achievementId = 'enemies_defeated';

      // Act - Increment by default (1)
      manager.incrementAchievement(achievementId);
      expect(manager.getAchievementProgress(achievementId), equals(1));

      // Act - Increment by custom amount
      manager.incrementAchievement(achievementId, 5);
      expect(manager.getAchievementProgress(achievementId), equals(6));

      // Act - Increment again
      manager.incrementAchievement(achievementId, 10);
      expect(manager.getAchievementProgress(achievementId), equals(16));
    });

    test('test_achievement_completion_check', () {
      // Arrange
      const achievementId = 'items_collected';
      const requiredAmount = 10;

      // Act - Increment to exact required amount
      manager.incrementAchievement(achievementId, 10);

      // Assert - Should be completed
      expect(
        manager.isAchievementCompleted(achievementId, requiredAmount),
        isTrue,
      );

      // Assert - Should not be completed for higher requirement
      expect(manager.isAchievementCompleted(achievementId, 11), isFalse);

      // Act - Increment above required amount
      manager.incrementAchievement(achievementId, 5);

      // Assert - Should still be completed
      expect(
        manager.isAchievementCompleted(achievementId, requiredAmount),
        isTrue,
      );

      // Test non-existent achievement
      expect(manager.isAchievementCompleted('non_existent', 1), isFalse);
    });

    test('test_serialization_roundtrip', () {
      // Arrange - Setup state
      manager.setFlag('quest_1_completed');
      manager.setFlag('npc_met_blacksmith');
      manager.setFlag('area_forest_unlocked');

      manager.incrementAchievement('enemies_defeated', 50);
      manager.incrementAchievement('items_crafted', 10);

      // Note: updateStats increments, it doesn't set absolute values
      // So we need to use the achievement system for tracking or set directly
      manager.totalPlayTimeSeconds = 3600;
      manager.enemiesDefeated = 50;
      manager.itemsCrafted = 10;
      manager.distanceTraveled = 5000;

      // Act - Serialize (with proper JSON encoding/decoding)
      final json = manager.toJson();
      final jsonString = jsonEncode(json);
      final decodedJson = jsonDecode(jsonString) as Map<String, dynamic>;

      // Reset and deserialize
      manager.reset();
      expect(manager.getAllFlags().isEmpty, isTrue); // Verify reset worked
      expect(manager.totalPlayTimeSeconds, equals(0));

      manager.fromJson(decodedJson);

      // Assert - Verify flags restored
      expect(manager.hasFlag('quest_1_completed'), isTrue);
      expect(manager.hasFlag('npc_met_blacksmith'), isTrue);
      expect(manager.hasFlag('area_forest_unlocked'), isTrue);
      expect(manager.getAllFlags().length, equals(3));

      // Assert - Verify achievements restored
      expect(manager.getAchievementProgress('enemies_defeated'), equals(50));
      expect(manager.getAchievementProgress('items_crafted'), equals(10));
      expect(manager.getAllAchievements().length, equals(2));

      // Assert - Verify stats restored
      expect(manager.totalPlayTimeSeconds, equals(3600));
      expect(manager.enemiesDefeated, equals(50));
      expect(manager.itemsCrafted, equals(10));
      expect(manager.distanceTraveled, equals(5000));
    });
    test('test_reset_clears_all_data', () {
      // Arrange - Add various data
      manager.setFlag('test_flag_1');
      manager.setFlag('test_flag_2');
      manager.incrementAchievement('test_achievement', 100);
      manager.updateStats({
        'totalPlayTimeSeconds': 1000,
        'enemiesDefeated': 20,
      });

      expect(manager.getAllFlags().isNotEmpty, isTrue);
      expect(manager.getAllAchievements().isNotEmpty, isTrue);
      expect(manager.totalPlayTimeSeconds, greaterThan(0));

      // Act
      manager.reset();

      // Assert - Everything should be cleared
      expect(manager.getAllFlags().isEmpty, isTrue);
      expect(manager.getAllAchievements().isEmpty, isTrue);
      expect(manager.totalPlayTimeSeconds, equals(0));
      expect(manager.enemiesDefeated, equals(0));
      expect(manager.itemsCrafted, equals(0));
      expect(manager.distanceTraveled, equals(0));
    });

    test('test_get_completed_quests', () {
      // Arrange
      manager.setFlag('quest_1_completed');
      manager.setFlag('quest_2_in_progress');
      manager.setFlag('quest_3_completed');
      manager.setFlag('npc_met_blacksmith');

      // Act
      final completedQuests = manager.getCompletedQuests();

      // Assert
      expect(completedQuests.length, equals(2));
      expect(completedQuests.contains('quest_1_completed'), isTrue);
      expect(completedQuests.contains('quest_3_completed'), isTrue);
      expect(completedQuests.contains('quest_2_in_progress'), isFalse);
    });

    test('test_get_met_npcs', () {
      // Arrange
      manager.setFlag('npc_met_blacksmith');
      manager.setFlag('npc_met_merchant');
      manager.setFlag('quest_1_completed');
      manager.setFlag('npc_met_wizard');

      // Act
      final metNPCs = manager.getMetNPCs();

      // Assert
      expect(metNPCs.length, equals(3));
      expect(metNPCs.contains('npc_met_blacksmith'), isTrue);
      expect(metNPCs.contains('npc_met_merchant'), isTrue);
      expect(metNPCs.contains('npc_met_wizard'), isTrue);
      expect(metNPCs.contains('quest_1_completed'), isFalse);
    });

    test('test_get_unlocked_areas', () {
      // Arrange
      manager.setFlag('area_forest_unlocked');
      manager.setFlag('area_cave_unlocked');
      manager.setFlag('quest_1_completed');
      manager.setFlag('area_mountain_unlocked');

      // Act
      final unlockedAreas = manager.getUnlockedAreas();

      // Assert
      expect(unlockedAreas.length, equals(3));
      expect(unlockedAreas.contains('area_forest_unlocked'), isTrue);
      expect(unlockedAreas.contains('area_cave_unlocked'), isTrue);
      expect(unlockedAreas.contains('area_mountain_unlocked'), isTrue);
    });

    test('test_update_stats', () {
      // Arrange
      expect(manager.totalPlayTimeSeconds, equals(0));
      expect(manager.enemiesDefeated, equals(0));
      expect(manager.itemsCrafted, equals(0));
      expect(manager.distanceTraveled, equals(0));

      // Act
      manager.updateStats({
        'totalPlayTimeSeconds': 100,
        'enemiesDefeated': 5,
        'itemsCrafted': 2,
        'distanceTraveled': 1000,
      });

      // Assert
      expect(manager.totalPlayTimeSeconds, equals(100));
      expect(manager.enemiesDefeated, equals(5));
      expect(manager.itemsCrafted, equals(2));
      expect(manager.distanceTraveled, equals(1000));

      // Act - Update again (should accumulate)
      manager.updateStats({'totalPlayTimeSeconds': 50, 'enemiesDefeated': 3});

      // Assert - Values should be accumulated
      expect(manager.totalPlayTimeSeconds, equals(150));
      expect(manager.enemiesDefeated, equals(8));
      expect(manager.itemsCrafted, equals(2)); // Not updated, stays same

      // Test unknown stat (should log warning but not crash)
      manager.updateStats({'unknownStat': 100});
    });
  });
}
