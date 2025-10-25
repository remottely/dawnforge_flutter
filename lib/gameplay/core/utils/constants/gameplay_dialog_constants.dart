import 'package:darkness_dungeon/darkness_dungeon.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';

class GameplayDialogConstants {
  static Say playerLeftDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: PlayerSpriteAnimations.knightPlayerIdleRight6(),
      ),
      personSayDirection: PersonSayDirection.LEFT,
    );
  }

  static Say wizardRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: NpcSpriteAnimations.wizardIdleLeft(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }

  static Say kidRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: NpcSpriteAnimations.kidIdleLeft(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }

  static Say bossLeftDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: EnemySpriteAnimations.dungeonBossEnemyIdleRight4(),
      ),
      personSayDirection: PersonSayDirection.LEFT,
    );
  }

  static Say bossRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(
          text: GameplayStringsLocation.instance.getString('talk_boss_2'),
        ),
      ],
      person: DFAnimatedSpriteWidget(
        animation: EnemySpriteAnimations.dungeonBossEnemyIdleLeft4(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }
}
