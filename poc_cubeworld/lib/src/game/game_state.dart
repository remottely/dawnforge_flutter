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

  Map<String, Object> toJson() => {
        'blocks_mined': blocksMined,
        'blocks_placed': blocksPlaced,
        'mobs_killed': mobsKilled,
        'deaths': deaths,
        'play_time': playTime,
        'class': playerClass,
        'placed_chests': placedChests.toList(),
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
  }
}
