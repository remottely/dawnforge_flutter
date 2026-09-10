import 'achievements.dart';

/// Session-wide settings and statistics (persisted with the save).
class GameState {
  GameState._();
  static final GameState instance = GameState._();

  int seedValue = 1337;
  String playerClass = 'warrior';
  String worldName = 'default';
  bool freshWorld = false;
  int blocksMined = 0;
  int blocksPlaced = 0;
  int mobsKilled = 0;
  int deaths = 0;
  double playTime = 0.0;
  final Set<String> placedChests = {};

  /// Bestiary: kills per species, and every species ever met.
  final Map<String, int> kills = {};
  final Set<String> seen = {};

  Map<String, Object> toJson() => {
        'blocks_mined': blocksMined,
        'blocks_placed': blocksPlaced,
        'mobs_killed': mobsKilled,
        'deaths': deaths,
        'play_time': playTime,
        'class': playerClass,
        'placed_chests': placedChests.toList(),
        'kills': kills,
        'seen': seen.toList(),
        'achievements': Achievements.instance.toJson(),
      };

  void fromJson(Map<String, dynamic> d) {
    blocksMined = (d['blocks_mined'] as num?)?.toInt() ?? 0;
    blocksPlaced = (d['blocks_placed'] as num?)?.toInt() ?? 0;
    mobsKilled = (d['mobs_killed'] as num?)?.toInt() ?? 0;
    deaths = (d['deaths'] as num?)?.toInt() ?? 0;
    playTime = (d['play_time'] as num?)?.toDouble() ?? 0.0;
    playerClass = d['class']?.toString() ?? playerClass;
    placedChests.clear();
    for (final k in (d['placed_chests'] as List<dynamic>? ?? const [])) {
      placedChests.add(k.toString());
    }
    kills.clear();
    for (final e in (d['kills'] as Map<String, dynamic>? ?? const {}).entries) {
      kills[e.key] = (e.value as num).toInt();
    }
    seen.clear();
    for (final k in (d['seen'] as List<dynamic>? ?? const [])) {
      seen.add(k.toString());
    }
    Achievements.instance.fromJson(d['achievements'] as Map<String, dynamic>? ?? const {});
  }
}
