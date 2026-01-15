import 'package:dawnforge/game/core/modules/save/player_progress_manager.dart';
import 'dart:convert';

void main() {
  final PlayerProgressManager manager = PlayerProgressManager.instance;
  manager.reset();

  // Setup
  manager.incrementAchievement('enemies_defeated', 50);
  manager.enemiesDefeated = 50;

  print(
    'Before JSON: enemies_defeated achievement = ${manager.getAchievementProgress("enemies_defeated")}',
  );
  print('Before JSON: enemiesDefeated stat = ${manager.enemiesDefeated}');

  // Serialize
  final Map<String, dynamic> json = manager.toJson();
  print('JSON: $json');
  print('JSON achievements type: ${json['achievements'].runtimeType}');
  print('JSON achievements content: ${json['achievements']}');

  // Simulate real JSON encoding/decoding
  final String jsonString = jsonEncode(json);
  print('JSON string: $jsonString');
  final Map<String, dynamic> decodedJson =
      jsonDecode(jsonString) as Map<String, dynamic>;
  print('Decoded JSON: $decodedJson');
  print(
    'Decoded achievements type: ${decodedJson['achievements'].runtimeType}',
  );

  // Reset and restore
  manager.reset();
  print(
    '\nAfter reset: enemies_defeated achievement = ${manager.getAchievementProgress("enemies_defeated")}',
  );

  manager.fromJson(decodedJson);
  print(
    'After fromJson: enemies_defeated achievement = ${manager.getAchievementProgress("enemies_defeated")}',
  );
  print('After fromJson: enemiesDefeated stat = ${manager.enemiesDefeated}');
  print('After fromJson: all achievements = ${manager.getAllAchievements()}');
}
